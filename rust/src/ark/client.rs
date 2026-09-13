use crate::ark::esplora::EsploraClient;
use anyhow::{anyhow, Result};
use bitcoin::bip32::Xpriv;
use bitcoin::Network;
use std::str::FromStr;
use std::sync::Arc;

// Re-export types that flutter_rust_bridge needs
pub use ark_bdk_wallet::Wallet;
pub use ark_client::{Client, OfflineClient, OfflineClientConfig, SqliteSwapStorage};

/// Seed length required by [`ArkWallet::init`].
const SEED_LEN: usize = 32;

#[derive(Clone)]
pub struct ArkWallet {
    pub inner: Arc<Client<EsploraClient, Wallet, SqliteSwapStorage>>,
}

impl ArkWallet {
    /// Initialise an Ark wallet.
    ///
    /// `secret_key` is a 32-byte BIP32 seed. The on-chain wallet and the Ark identity keys are both
    /// derived from it, so the same seed always yields the same addresses on a given network.
    ///
    /// `network` accepts the values understood by rust-bitcoin: `bitcoin` (mainnet), `signet`,
    /// `testnet` and `regtest`. Note that `mainnet` is *not* a valid value.
    ///
    /// `data_dir` is a writable directory used to persist swap state across restarts. It is
    /// created if it does not exist.
    pub async fn init(
        secret_key: Vec<u8>,
        network: String,
        esplora: String,
        server: String,
        boltz: String,
        data_dir: String,
    ) -> Result<ArkWallet> {
        if secret_key.len() != SEED_LEN {
            return Err(anyhow!(
                "Seed must be {} bytes, got {}",
                SEED_LEN,
                secret_key.len()
            ));
        }

        let network = Network::from_str(network.as_str()).map_err(|e| {
            anyhow!(
                "Invalid network '{}': {}. Expected one of: bitcoin, signet, testnet, regtest",
                network,
                e
            )
        })?;

        let xpriv = Xpriv::new_master(network, secret_key.as_slice())
            .map_err(|e| anyhow!("Failed to derive master key from seed: {e}"))?;

        let wallet = Wallet::new_from_xpriv(xpriv, network, esplora.as_str())
            .map_err(|e| anyhow!("Failed to create wallet: {e}"))?;
        let wallet = Arc::new(wallet);

        let esplora_client = EsploraClient::new(esplora.as_str())
            .map_err(|e| anyhow!("Failed to create Esplora client for '{}': {}", esplora, e))?;
        esplora_client
            .check_connection()
            .await
            .map_err(|e| anyhow!("Failed to connect to Esplora at '{}': {}", esplora, e))?;

        // Swap state must outlive the process: it tracks in-flight Boltz swaps, and losing it
        // mid-swap orphans the payment.
        let swap_storage_path = format!("{}/swap_storage.sql", data_dir.trim_end_matches('/'));
        let swap_storage = Arc::new(
            SqliteSwapStorage::new(swap_storage_path.clone())
                .await
                .map_err(|e| {
                    anyhow!(
                        "Failed to open swap storage at '{}': {}",
                        swap_storage_path,
                        e
                    )
                })?,
        );

        // `OfflineClientConfig::default()` targets mainnet; the caller's URLs override that.
        let config = OfflineClientConfig {
            ark_server_url: server.clone(),
            boltz_url: boltz,
            ..Default::default()
        };

        let client = OfflineClient::with_bip32(
            config,
            xpriv,
            None, // use ark-core's DEFAULT_DERIVATION_PATH
            Arc::new(esplora_client),
            wallet,
            swap_storage,
        )
        .connect()
        .await
        .map_err(|err| anyhow!("Failed to connect to Ark server at '{}': {}", server, err))?;

        Ok(ArkWallet {
            inner: Arc::new(client),
        })
    }
}

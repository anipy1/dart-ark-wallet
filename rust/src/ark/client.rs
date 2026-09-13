use crate::ark::esplora::EsploraClient;
use anyhow::{anyhow, Result};
use ark_client::vtxo_watcher::VtxoWatcherConfig;
use ark_delegator::DelegatorClient;
use bitcoin::bip32::Xpriv;
use bitcoin::Network;
use std::str::FromStr;
use std::sync::Arc;

// Re-export types that flutter_rust_bridge needs
pub use ark_bdk_wallet::Wallet;
pub use ark_client::vtxo_watcher::VtxoWatcherHandle;
pub use ark_client::{Client, OfflineClient, OfflineClientConfig, SqliteSwapStorage};

/// BIP32 master-key generation accepts a seed of 16..=64 bytes (BIP39 produces 64).
const SEED_LEN_MIN: usize = 16;
const SEED_LEN_MAX: usize = 64;

#[derive(Clone)]
pub struct ArkWallet {
    pub inner: Arc<Client<EsploraClient, Wallet, SqliteSwapStorage>>,
    /// Keeps the VTXO watcher alive. The watcher stops as soon as its handle is dropped, so this
    /// must be held for the lifetime of the wallet.
    pub watcher: Option<Arc<VtxoWatcherHandle>>,
}

impl ArkWallet {
    /// Initialise an Ark wallet.
    ///
    /// `secret_key` is a BIP32 seed of 16 to 64 bytes - pass the wallet's BIP39 seed directly so
    /// that Ark derives from the same master key as the rest of the wallet, and the mnemonic alone
    /// is enough to recover Ark funds. The on-chain wallet and the Ark identity keys are both
    /// derived from it, so the same seed always yields the same addresses on a given network.
    ///
    /// `network` accepts the values understood by rust-bitcoin: `bitcoin` (mainnet), `signet`,
    /// `testnet` and `regtest`. Note that `mainnet` is *not* a valid value.
    ///
    /// `data_dir` is a writable directory used to persist swap state across restarts. It is
    /// created if it does not exist.
    ///
    /// `delegator_url` opts into delegated renewal. A delegate can only renew VTXOs - it cannot
    /// move funds - but it changes the addresses this wallet produces, because a delegated VTXO
    /// carries a third Taproot leaf. Enabling or disabling it later therefore yields different
    /// addresses, so decide before funds arrive.
    pub async fn init(
        secret_key: Vec<u8>,
        network: String,
        esplora: String,
        server: String,
        boltz: String,
        data_dir: String,
        delegator_url: Option<String>,
    ) -> Result<ArkWallet> {
        if !(SEED_LEN_MIN..=SEED_LEN_MAX).contains(&secret_key.len()) {
            return Err(anyhow!(
                "Seed must be between {} and {} bytes, got {}",
                SEED_LEN_MIN,
                SEED_LEN_MAX,
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

        // Resolve the delegate first: its public key has to be known before the client is built,
        // because it becomes part of every VTXO this wallet creates.
        let delegator = match delegator_url {
            Some(url) => {
                let client = Arc::new(DelegatorClient::new(url.clone()));
                let info = client.info().await.map_err(|e| {
                    anyhow!("Failed to reach the delegate at '{}': {}", url, e)
                })?;
                let pk: bitcoin::PublicKey = info.pubkey.parse().map_err(|e| {
                    anyhow!("Delegate returned an unusable public key '{}': {}", info.pubkey, e)
                })?;
                let pk: bitcoin::XOnlyPublicKey = pk.into();

                Some((client, pk))
            }
            None => None,
        };

        // `OfflineClientConfig::default()` targets mainnet; the caller's URLs override that.
        let config = OfflineClientConfig {
            ark_server_url: server.clone(),
            boltz_url: boltz,
            delegator_pk: delegator.as_ref().map(|(_, pk)| *pk),
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

        let client = Arc::new(client);

        // The watcher performs the renewals the delegate is authorised for. Without a delegate
        // there is nothing to drive, so it is only started when one is configured.
        let watcher = delegator.map(|(delegator_client, _)| {
            Arc::new(client.start_vtxo_watcher(delegator_client, VtxoWatcherConfig::default()))
        });

        Ok(ArkWallet {
            inner: client,
            watcher,
        })
    }
}

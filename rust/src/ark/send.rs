use crate::ark::client::ArkWallet;
use anyhow::{anyhow, Result};
use ark_core::send::SendReceiver;
use rand::rngs::StdRng;
use rand::SeedableRng;
use std::str::FromStr;

pub use bitcoin::Address;
pub use bitcoin::Amount;

impl ArkWallet {
    pub async fn send_on_chain(&self, address: String, sats: i64) -> Result<String> {
        let address = Address::from_str(address.as_str())?;
        let txid = self
            .inner
            .send_on_chain(address.assume_checked(), Amount::from_sat(sats as u64))
            .await
            .map_err(|e| anyhow!("Failed sending onchain {e:#}"))?;
        Ok(txid.to_string())
    }

    pub async fn send_off_chain(&self, address: String, sats: i64) -> Result<String> {
        let address = ark_core::ArkAddress::decode(address.as_str())?;
        let receiver = SendReceiver::bitcoin(address, Amount::from_sat(sats as u64));
        let txid = self
            .inner
            .send(vec![receiver])
            .await
            .map_err(|e| anyhow!("Failed sending offchain {e:#}"))?;
        Ok(txid.to_string())
    }

    /// Offboard to an on-chain address with the operator's cooperation.
    ///
    /// Recoverable (expired) VTXOs are now selected by the SDK automatically, so the previous
    /// `select_recoverable_vtxos` flag no longer exists.
    pub async fn collaborative_redeem(&self, address: String, sats: i64) -> Result<String> {
        let rng = &mut StdRng::from_entropy();
        let address = Address::from_str(address.as_str())?;
        let txid = self
            .inner
            .collaborative_redeem(rng, address.assume_checked(), Amount::from_sat(sats as u64))
            .await
            .map_err(|e| anyhow!("Failed sending collaborative redeem {e:#}"))?;
        Ok(txid.to_string())
    }
}

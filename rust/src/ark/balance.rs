use crate::ark::client::ArkWallet;
use anyhow::{anyhow, Result};

pub use ark_client::OffChainBalance;

pub struct Balance {
    /// Received but not yet confirmed in a batch. Was called `pending` before.
    pub pre_confirmed: i64,
    pub confirmed: i64,
    /// VTXOs whose batch has expired. Still spendable, but only via a settle/renewal - they can no
    /// longer be exited unilaterally until renewed.
    pub recoverable: i64,
    /// Funds under a deprecated server signer past its cutoff. Not spendable offchain; becomes
    /// `recoverable` once the VTXO expires.
    pub pending_recovery: i64,
    pub total: i64,
}

impl ArkWallet {
    pub async fn balance(&self) -> Result<Balance> {
        let offchain_balance = self
            .inner
            .offchain_balance()
            .await
            .map_err(|error| anyhow!("Could not fetch balance {error}"))?;

        Ok(Balance {
            pre_confirmed: offchain_balance.pre_confirmed().to_sat() as i64,
            confirmed: offchain_balance.confirmed().to_sat() as i64,
            recoverable: offchain_balance.recoverable().to_sat() as i64,
            pending_recovery: offchain_balance.pending_recovery().to_sat() as i64,
            total: offchain_balance.total().to_sat() as i64,
        })
    }
}

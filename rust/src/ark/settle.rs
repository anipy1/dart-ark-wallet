use anyhow::{anyhow, Result};

use crate::ark::client::ArkWallet;

pub use rand::rngs::StdRng;
pub use rand::SeedableRng;

impl ArkWallet {
    /// Settle (renew) VTXOs into a fresh batch.
    ///
    /// Returns the commitment txid, or `None` when there was nothing to settle. The SDK now picks
    /// up recoverable VTXOs on its own, so the previous `select_recoverable_vtxos` flag is gone.
    pub async fn settle(&self) -> Result<Option<String>> {
        let mut rng = StdRng::from_entropy();
        let txid = self
            .inner
            .settle(&mut rng)
            .await
            .map_err(|e| anyhow!("Failed to settle: {e:#}"))?;
        Ok(txid.map(|t| t.to_string()))
    }
}

use anyhow::{anyhow, Result};

pub use ark_core::ArkAddress;
pub use bitcoin::Address;

use crate::ark::client::ArkWallet;

impl ArkWallet {
    /// Ark (off-chain) address. Now async: the SDK derives it through the key provider.
    pub async fn offchain_address(&self) -> Result<String> {
        let (offchain_address, _vtxo) = self
            .inner
            .get_offchain_address()
            .await
            .map_err(|error| anyhow!("Could not get offchain address {error:#}"))?;

        Ok(offchain_address.encode())
    }

    /// Bitcoin boarding address, for moving on-chain funds into Ark.
    pub async fn boarding_address(&self) -> Result<String> {
        let boarding_address = self
            .inner
            .get_boarding_address()
            .await
            .map_err(|error| anyhow!("Could not get boarding address {error:#}"))?;

        Ok(boarding_address.to_string())
    }
}

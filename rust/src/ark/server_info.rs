use anyhow::{anyhow, Result};

use crate::ark::client::ArkWallet;

pub struct ServerInfo {
    pub version: String,
    pub signer_pubkey: String,
    pub forfeit_pubkey: String,
    pub forfeit_address: String,
    pub checkpoint_tapscript: String,
    pub network: String,
    pub session_duration: i64,
    pub unilateral_exit_delay: u32,
    pub boarding_exit_delay: u32,
    pub utxo_min_amount: Option<i64>,
    pub utxo_max_amount: Option<i64>,
    pub vtxo_min_amount: Option<i64>,
    pub vtxo_max_amount: Option<i64>,
    pub dust: i64,
    pub digest: String,
}

impl ArkWallet {
    pub async fn server_info(&self) -> Result<ServerInfo> {
        let info = self
            .inner
            .server_info()
            .await
            .map_err(|e| anyhow!("Could not fetch server info {e:#}"))?;
        Ok(ServerInfo {
            version: info.version,
            signer_pubkey: info.signer_pk.to_string(),
            forfeit_pubkey: info.forfeit_pk.to_string(),
            forfeit_address: info.forfeit_address.to_string(),
            checkpoint_tapscript: info.checkpoint_tapscript.to_string(),
            network: info.network.to_string(),
            session_duration: info.session_duration as i64,
            unilateral_exit_delay: info.unilateral_exit_delay.0,
            boarding_exit_delay: info.boarding_exit_delay.0,
            utxo_min_amount: info.utxo_min_amount.map(|amount| amount.to_sat() as i64),
            utxo_max_amount: info.utxo_max_amount.map(|amount| amount.to_sat() as i64),
            vtxo_min_amount: info.vtxo_min_amount.map(|amount| amount.to_sat() as i64),
            vtxo_max_amount: info.vtxo_max_amount.map(|amount| amount.to_sat() as i64),
            dust: info.dust.to_sat() as i64,
            digest: info.digest.to_string(),
        })
    }
}

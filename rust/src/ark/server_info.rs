use anyhow::{anyhow, Result};

use crate::ark::client::ArkWallet;
use bitcoin::Sequence;

/// BIP68 encodes a relative timelock in the low 16 bits; bit 22 selects 512-second units
/// rather than blocks. The raw value is meaningless to a user, so decode it.
const BIP68_VALUE_MASK: u32 = 0x0000_FFFF;
const BIP68_SECONDS_PER_UNIT: i64 = 512;

fn decode_seconds(seq: Sequence) -> Option<i64> {
    if seq.is_relative_lock_time() && seq.is_time_locked() {
        Some((seq.0 & BIP68_VALUE_MASK) as i64 * BIP68_SECONDS_PER_UNIT)
    } else {
        None
    }
}

fn decode_blocks(seq: Sequence) -> Option<u32> {
    if seq.is_relative_lock_time() && seq.is_height_locked() {
        Some(seq.0 & BIP68_VALUE_MASK)
    } else {
        None
    }
}

pub struct ServerInfo {
    pub version: String,
    pub signer_pubkey: String,
    pub forfeit_pubkey: String,
    pub forfeit_address: String,
    pub checkpoint_tapscript: String,
    pub network: String,
    pub session_duration: i64,
    /// Raw BIP68 sequence value. Prefer the decoded `*_seconds` / `*_blocks` fields below:
    /// the raw number is an encoding, not a duration.
    pub unilateral_exit_delay: u32,
    /// Decoded delay in seconds, when the timelock is time-based.
    pub unilateral_exit_delay_seconds: Option<i64>,
    /// Decoded delay in blocks, when the timelock is height-based.
    pub unilateral_exit_delay_blocks: Option<u32>,
    pub boarding_exit_delay: u32,
    pub boarding_exit_delay_seconds: Option<i64>,
    pub boarding_exit_delay_blocks: Option<u32>,
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
            unilateral_exit_delay_seconds: decode_seconds(info.unilateral_exit_delay),
            unilateral_exit_delay_blocks: decode_blocks(info.unilateral_exit_delay),
            boarding_exit_delay: info.boarding_exit_delay.0,
            boarding_exit_delay_seconds: decode_seconds(info.boarding_exit_delay),
            boarding_exit_delay_blocks: decode_blocks(info.boarding_exit_delay),
            utxo_min_amount: info.utxo_min_amount.map(|amount| amount.to_sat() as i64),
            utxo_max_amount: info.utxo_max_amount.map(|amount| amount.to_sat() as i64),
            vtxo_min_amount: info.vtxo_min_amount.map(|amount| amount.to_sat() as i64),
            vtxo_max_amount: info.vtxo_max_amount.map(|amount| amount.to_sat() as i64),
            dust: info.dust.to_sat() as i64,
            digest: info.digest.to_string(),
        })
    }
}

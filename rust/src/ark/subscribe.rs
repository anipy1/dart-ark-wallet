use anyhow::{anyhow, Result};
use crate::frb_generated::StreamSink;
use futures::StreamExt;

use crate::ark::client::ArkWallet;

pub use ark_core::server::{SubscriptionEvent, SubscriptionResponse};

/// A VTXO that has just appeared on one of this wallet's addresses.
///
/// Ark payments settle off-chain, so nothing on the Bitcoin chain announces them. Without a
/// subscription the only way to notice one is to poll, which is both slow and wasteful.
pub struct ArkIncomingPayment {
    pub txid: String,
    pub vout: u32,
    pub amount: i64,
    /// A pre-confirmed VTXO spends from another VTXO rather than being a batch-tree leaf. It is
    /// immediately spendable off-chain, so for display purposes it counts as received.
    pub is_preconfirmed: bool,
}

impl ArkWallet {
    /// Stream VTXOs arriving on this wallet's off-chain address.
    ///
    /// The returned stream stays open until the server closes it or the Dart side stops
    /// listening. Errors end the stream rather than being retried here, so the caller decides
    /// whether to resubscribe.
    pub async fn watch_incoming_payments(&self, sink: StreamSink<ArkIncomingPayment>) -> Result<()> {
        let (address, _vtxo) = self
            .inner
            .get_offchain_address()
            .await
            .map_err(|e| anyhow!("Could not get offchain address {e:#}"))?;

        let subscription_id = self
            .inner
            .subscribe_to_scripts(vec![address], None)
            .await
            .map_err(|e| anyhow!("Could not subscribe to scripts {e:#}"))?;

        let mut stream = self
            .inner
            .get_subscription(subscription_id, None)
            .await
            .map_err(|e| anyhow!("Could not open subscription stream {e:#}"))?;

        let own_script = address.to_p2tr_script_pubkey();

        while let Some(item) = stream.next().await {
            let response = item.map_err(|e| anyhow!("Subscription stream failed {e:#}"))?;

            // Heartbeats keep the connection alive and carry nothing; the started message only
            // echoes the subscription id we already hold.
            let event = match response {
                SubscriptionResponse::Event(event) => event,
                SubscriptionResponse::Heartbeat
                | SubscriptionResponse::SubscriptionStarted { .. } => continue,
            };

            for vtxo in event.new_vtxos {
                // An event fires for every script in the subscription, and a transaction can pay
                // several parties at once, so only report the outputs that are actually ours.
                if vtxo.script != own_script {
                    continue;
                }

                let payment = ArkIncomingPayment {
                    txid: vtxo.outpoint.txid.to_string(),
                    vout: vtxo.outpoint.vout,
                    amount: vtxo.amount.to_sat() as i64,
                    is_preconfirmed: vtxo.is_preconfirmed,
                };

                // A closed sink means Dart stopped listening; there is nobody left to notify.
                if sink.add(payment).is_err() {
                    return Ok(());
                }
            }
        }

        Ok(())
    }
}

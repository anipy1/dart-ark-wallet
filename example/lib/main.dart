import 'dart:io';
import 'dart:math';

import 'package:ark_wallet_example/send_page.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ark_wallet/ark_wallet.dart' as ark;

/// Bitcoin mainnet configuration.
///
/// `network` uses rust-bitcoin's spelling: mainnet is `bitcoin`, not `mainnet`.
/// Operator URLs come from https://docs.arkadeos.com/wallets/getting-started/developer-resources
const kNetwork = 'bitcoin';
const kArkServer = 'https://arkade.computer';
const kBoltzUrl = 'https://api.boltz.exchange';

/// Arkade does not publish a mainnet Esplora endpoint, so we pick one. Note that whoever runs it
/// sees every address this wallet queries.
const kEsploraUrl = 'https://blockstream.info/api';

/// Delegated renewal. The delegate can only renew VTXOs, never move funds, and keeps them from
/// expiring while the wallet is closed. Note that enabling it changes the addresses this wallet
/// produces, because a delegated VTXO carries an extra Taproot leaf.
const kDelegatorUrl = 'https://delegate.arkade.money';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ark.LibArk.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ark.ArkWallet? _client;
  bool _isLoading = false;
  /// Guards against overlapping loads. `_load()` is reachable from initState, the refresh
  /// button and after a settle, and re-entering it would re-query the operator needlessly.
  bool _busy = false;
  int _loadCount = 0;
  String _exitDelay = '';
  String? _error;
  String _arkAddress = '';
  String _btcAddress = '';
  int _preConfirmed = 0;
  int _confirmed = 0;
  int _recoverable = 0;
  int _pendingRecovery = 0;
  int _total = 0;
  List<ark.Transaction> _txs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Load the wallet seed, generating one on first run.
  ///
  /// The upstream example hardcoded a seed. That is fine on a test network but on mainnet a seed
  /// committed to a public repository is a guaranteed loss, so we generate one per install.
  /// This file is NOT a secure store - it is adequate for a throwaway demo only.
  Future<List<int>> _loadOrCreateSeed(Directory dir) async {
    final file = File('${dir.path}/ark_seed.hex');
    if (await file.exists()) {
      return hex.decode((await file.readAsString()).trim());
    }
    final rng = Random.secure();
    final seed = List<int>.generate(32, (_) => rng.nextInt(256));
    await file.writeAsString(hex.encode(seed), flush: true);
    return seed;
  }

  /// Connect once, and reuse the client for every later refresh.
  ///
  /// `ArkWallet.init` opens the swap database and performs a gRPC handshake with the operator,
  /// so calling it per refresh means redundant work and network traffic.
  Future<ark.ArkWallet> _connect() async {
    final existing = _client;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${dir.path}/ark');
    await dataDir.create(recursive: true);

    return ark.ArkWallet.init(
      secretKey: await _loadOrCreateSeed(dir),
      network: kNetwork,
      esplora: kEsploraUrl,
      server: kArkServer,
      boltz: kBoltzUrl,
      dataDir: dataDir.path,
      delegatorUrl: kDelegatorUrl,
    );
  }

  Future<void> _load() async {
    if (_busy) {
      debugPrint('_load() skipped - already in flight');
      return;
    }
    _busy = true;
    _loadCount++;
    debugPrint('_load() #$_loadCount (client ${_client == null ? "absent" : "reused"})');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = await _connect();

      // Address getters are async now - they resolve through the key provider.
      final arkAddress = await client.offchainAddress();
      final btcAddress = await client.boardingAddress();
      final balance = await client.balance();
      final txs = await client.transactionHistory();

      final serverInfo = await client.serverInfo();
      debugPrint('connected to ${serverInfo.network} v${serverInfo.version}');
      debugPrint('signer ${serverInfo.signerPubkey}');
      debugPrint('dust ${serverInfo.dust}');
      final exitDelay = _formatDelay(
        serverInfo.unilateralExitDelaySeconds?.toInt(),
        serverInfo.unilateralExitDelayBlocks,
        serverInfo.unilateralExitDelay,
      );
      debugPrint('unilateral exit delay $exitDelay (raw ${serverInfo.unilateralExitDelay})');

      if (!mounted) return;
      setState(() {
        _client = client;
        _arkAddress = arkAddress;
        _btcAddress = btcAddress;
        _preConfirmed = balance.preConfirmed.toInt();
        _confirmed = balance.confirmed.toInt();
        _recoverable = balance.recoverable.toInt();
        _pendingRecovery = balance.pendingRecovery.toInt();
        _total = balance.total.toInt();
        _txs = txs;
        _exitDelay = exitDelay;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ark init failed: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } finally {
      _busy = false;
    }
  }

  /// Render a BIP68 relative timelock as something a person can act on.
  static String _formatDelay(int? seconds, int? blocks, int raw) {
    if (seconds != null) {
      final days = seconds / 86400;
      if (days >= 1) return '${days.toStringAsFixed(1)} days';
      return '${(seconds / 3600).toStringAsFixed(1)} hours';
    }
    if (blocks != null) return '$blocks blocks';
    return 'unknown (raw $raw)';
  }

  Future<void> _settle() async {
    final client = _client;
    if (client == null) return;
    try {
      // `settle()` no longer takes selectRecoverableVtxos - the SDK selects them itself.
      // Returns null when there was nothing to settle.
      final txid = await client.settle();
      _toast(txid == null ? 'Nothing to settle' : 'Settled: $txid');
      await _load();
    } catch (e) {
      _toast('Settle failed: $e');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The Transaction union gained an `offboard` variant, and it carries `commitmentTxid`
  /// rather than `txid`, so it has to be matched explicitly.
  (String, String) _describe(ark.Transaction tx) => switch (tx) {
    ark.Transaction_Boarding(:final txid, :final sats) => ('Boarding', '$sats sats · $txid'),
    ark.Transaction_Commitment(:final txid, :final sats) => ('Commitment', '$sats sats · $txid'),
    ark.Transaction_Redeem(:final txid, :final sats, :final isSettled) => (
      isSettled ? 'Redeem (settled)' : 'Redeem',
      '$sats sats · $txid',
    ),
    ark.Transaction_Offboard(:final commitmentTxid, :final sats) => (
      'Offboard',
      '$sats sats · $commitmentTxid',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ark wallet · mainnet'),
        actions: [
          IconButton(onPressed: _isLoading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                title: const Text('Ark Address'),
                subtitle: SelectableText(_arkAddress),
              ),
              ListTile(
                title: const Text('Boarding Address (on-chain)'),
                subtitle: SelectableText(_btcAddress),
              ),
              ListTile(title: const Text('Total'), subtitle: Text('$_total sats')),
              ListTile(title: const Text('Confirmed'), subtitle: Text('$_confirmed sats')),
              ListTile(
                title: const Text('Pre-confirmed'),
                subtitle: Text('$_preConfirmed sats'),
              ),
              ListTile(
                title: const Text('Recoverable'),
                subtitle: Text(
                  '$_recoverable sats'
                  '${_recoverable > 0 ? ' · expired, settle to restore unilateral exit' : ''}',
                ),
              ),
              ListTile(
                title: const Text('Pending recovery'),
                subtitle: Text('$_pendingRecovery sats'),
              ),
              ListTile(
                title: const Text('Unilateral exit delay'),
                subtitle: Text(
                  _exitDelay.isEmpty
                      ? '-'
                      : '$_exitDelay · funds are locked this long after starting an exit',
                ),
              ),
              const Divider(),
              const ListTile(title: Text('Transactions')),
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final (kind, detail) = _describe(_txs[index]);
              return ListTile(title: Text(kind), subtitle: Text(detail));
            }, childCount: _txs.length),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              TextButton.icon(
                onPressed: _client == null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendPage(client: _client!),
                        ),
                      ),
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              ),
              TextButton.icon(
                onPressed: _client == null ? null : _settle,
                icon: const Icon(Icons.clear_all),
                label: const Text('Settle / renew'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

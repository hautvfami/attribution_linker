import 'package:flutter/material.dart';
import 'package:attribution_linker/attribution_linker.dart';
import 'widgets/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attribution Linker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? _fingerprint;
  Map<String, dynamic>? _pendingData;
  bool _isLoading = false;
  bool _isFetchingPending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize with demo API endpoint
    AttributionLinker().init(
      entryPoint: 'https://httpbin.org/post', // Demo endpoint
      options: {
        'timeout': 15,
        'headers': {
          'X-Demo': 'attribution-linker-example',
          'X-App-Version': '1.0.0',
        },
        'demo_mode': true,
        'app_info': {
          'name': 'Attribution Linker Demo',
          'platform': 'Flutter',
        },
      },
    );
  }

  Future<void> _collectFingerprint() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fingerprint = await AttributionLinker().fingerprint;
      setState(() {
        _fingerprint = fingerprint;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPendingData() async {
    setState(() {
      _isFetchingPending = true;
      _error = null;
    });

    try {
      final pendingData = await AttributionLinker().fetchPendingData();
      setState(() {
        _pendingData = pendingData;
        _isFetchingPending = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isFetchingPending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with fingerprint collection button
              if (_fingerprint == null)
                FingerprintHeaderCard(
                  isLoading: _isLoading,
                  onCollectFingerprint: _collectFingerprint,
                ),
        
              const SizedBox(height: 16),

              // Pending data fetch button (only show if fingerprint collected)
              if (_fingerprint != null && _pendingData == null)
                PendingDataFetchCard(
                  isFetching: _isFetchingPending,
                  onFetchPendingData: _fetchPendingData,
                ),

              const SizedBox(height: 16),
        
              // Error display
              if (_error != null) ErrorCard(error: _error!),
        
              // Pending data display
              if (_pendingData != null)
                Expanded(
                  child: PendingDataDisplayCard(pendingData: _pendingData!),
                ),

              // Fingerprint data display (smaller if pending data exists)
              if (_fingerprint != null && _pendingData == null)
                Expanded(
                  child: FingerprintDataCard(fingerprint: _fingerprint!),
                ),
              
              if (_fingerprint != null && _pendingData != null)
                SizedBox(
                  height: 200,
                  child: FingerprintDataCard(fingerprint: _fingerprint!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

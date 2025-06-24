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
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AttributionLinker().init();
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
              FingerprintHeaderCard(
                isLoading: _isLoading,
                onCollectFingerprint: _collectFingerprint,
              ),
        
              const SizedBox(height: 16),
        
              // Error display
              if (_error != null) ErrorCard(error: _error!),
        
              // Fingerprint data display
              if (_fingerprint != null)
                Expanded(
                  child: FingerprintDataCard(fingerprint: _fingerprint!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

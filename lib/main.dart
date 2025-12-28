import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zssjaevaybmdeiidxsoe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpzc2phZXZheWJtZGVpaWR4c29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4NjM3OTIsImV4cCI6MjA4MjQzOTc5Mn0.os56bBBUn91TpeP5-UomwJ31-X9QN1wvf0_kQm7d-1M',
  );

  runApp(
    const ProviderScope(
      // ✅ REQUIRED
      child: MyApp(),
    ),
  );
}

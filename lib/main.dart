import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart'; // Or hive_ce_flutter if using CE
import 'package:island_cafe/feature/cart/data/model/cart_model.dart';
import 'package:island_cafe/main_widget.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Register Adapters (MUST be done before opening boxes that contain these types)
  Hive.registerAdapter(CartOptionAdapter());
  Hive.registerAdapter(CartModelAdapter());

  // 3. OPEN THE BOXES
  await Hive.openBox('voucher_box');   

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  
  runApp(const ProviderScope(child: MainWidget()));
}
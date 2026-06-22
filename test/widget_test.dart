import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:og_vibes_student/firebase_options.dart';
import 'package:og_vibes_student/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('OgVibesApp renders material root', (tester) async {
    await tester.pumpWidget(const OgVibesApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

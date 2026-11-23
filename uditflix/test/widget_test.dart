import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uditflix/main.dart';
import 'package:uditflix/screens/arcade_screen.dart';
import 'package:uditflix/screens/catalogo_screen.dart';
import 'package:uditflix/screens/ficha_screen.dart';
import 'package:uditflix/screens/reproductor_screen.dart';

/// El catálogo es largo; se amplía la superficie de test para que todos sus
/// sectores estén montados y se puedan pulsar.
void configurarPantalla(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('El catálogo muestra el contenido destacado', (
    WidgetTester tester,
  ) async {
    configurarPantalla(tester);
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CatalogoScreen), findsOneWidget);
    expect(find.text('La Última Frontera'), findsWidgets);
    expect(find.text('Todo el catálogo'), findsOneWidget);
    expect(find.byTooltip('Abrir UDIT Arcade'), findsOneWidget);
  });

  testWidgets('La ficha conserva la navegación al reproductor', (
    WidgetTester tester,
  ) async {
    configurarPantalla(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Más información'));
    await tester.pumpAndSettle();

    expect(find.byType(FichaScreen), findsOneWidget);
    expect(find.text('Sinopsis'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Reproducir'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byType(ReproductorScreen), findsOneWidget);
  });

  testWidgets('El catálogo da acceso a UDIT Arcade', (
    WidgetTester tester,
  ) async {
    configurarPantalla(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Abrir UDIT Arcade'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byType(ArcadeScreen), findsOneWidget);
    expect(find.textContaining('Minas:'), findsOneWidget);
    expect(find.textContaining('Toca para descubrir'), findsOneWidget);
  });

  testWidgets('El buscaminas marca banderas y reinicia la partida', (
    WidgetTester tester,
  ) async {
    configurarPantalla(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Abrir UDIT Arcade'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byType(ArcadeScreen), findsOneWidget);
    expect(find.text('Minas: 10'), findsOneWidget);
    expect(find.byKey(const Key('celda-0-0')), findsOneWidget);

    await tester.longPress(find.byKey(const Key('celda-0-0')));
    await tester.pump();
    expect(find.text('Minas: 9'), findsOneWidget);

    // La primera casilla descubierta nunca es una mina.
    await tester.tap(find.byKey(const Key('celda-4-4')));
    await tester.pump();
    expect(find.textContaining('Has pisado una mina'), findsNothing);

    await tester.tap(find.byTooltip('Nueva partida'));
    await tester.pump();
    expect(find.text('Minas: 10'), findsOneWidget);
  });
}

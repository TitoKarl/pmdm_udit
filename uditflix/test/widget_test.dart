import 'package:flutter_test/flutter_test.dart';

import 'package:uditflix/main.dart';
import 'package:uditflix/screens/catalogo_screen.dart';

void main() {
  testWidgets('El catálogo muestra el contenido destacado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UditflixApp());

    expect(find.byType(CatalogoScreen), findsOneWidget);
    expect(find.text('La Última Frontera'), findsWidgets);
    expect(find.text('Todo el catálogo'), findsOneWidget);
  });
}

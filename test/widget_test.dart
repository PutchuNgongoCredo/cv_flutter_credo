import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cv_flutter_credo/main.dart';

void main() {
  testWidgets(
    'la connexion masque le mot de passe et refuse un accès invalide',
    (tester) async {
      await tester.pumpWidget(const CvApp());

      expect(find.text('Se connecter'), findsOneWidget);
      final editableFields = tester.widgetList<EditableText>(
        find.byType(EditableText),
      );
      expect(editableFields.last.obscureText, isTrue);

      await tester.enterText(
        find.byKey(const Key('login-username')),
        'inconnu',
      );
      await tester.enterText(
        find.byKey(const Key('login-password')),
        'incorrect',
      );
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();

      expect(
        find.text('Identifiant ou mot de passe incorrect.'),
        findsOneWidget,
      );
      expect(find.text('Connexion'), findsOneWidget);
    },
  );

  testWidgets('la connexion valide ouvre les trois pages de navigation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CvApp());

    await tester.enterText(find.byKey(const Key('login-username')), 'credo');
    await tester.enterText(find.byKey(const Key('login-password')), '123456');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Formation à renseigner'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-family')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Mulenda RAPHAEL'), findsOneWidget);
    expect(find.text('Ashimba COLETTE'), findsOneWidget);
    expect(find.text('MAGNIFIQUE'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-contact')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('credomulenda002@gmail.com'), findsOneWidget);
    expect(find.text('credo___mld'), findsOneWidget);
  });
}

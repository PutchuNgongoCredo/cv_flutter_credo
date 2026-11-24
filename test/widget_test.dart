import 'dart:convert';

import 'package:cv_flutter_credo/api_service.dart';
import 'package:cv_flutter_credo/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('la connexion envoie les identifiants à l’API', () async {
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api-test/public/accounts/login');
        expect(jsonDecode(request.body), {
          'email': 'credo@example.com',
          'password': 'secret123',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'id': 7, 'email': 'credo@example.com'},
          }),
          200,
        );
      }),
    );

    final account = await service.login('credo@example.com', 'secret123');

    expect(account.id, 7);
    expect(account.email, 'credo@example.com');
    service.close();
  });

  test(
    'la liste des membres est décodée et les erreurs API sont remontées',
    () async {
      final service = ApiService(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/famille-membres')) {
            return http.Response(
              jsonEncode({
                'success': true,
                'data': [
                  {
                    'id': 3,
                    'nom': 'Baraka',
                    'postnom': 'Bigega',
                    'prenom': 'Papa',
                    'lieu_naissance': 'Goma',
                    'date_naissance': '1970-05-12',
                    'parente': 'Père',
                    'image_url': null,
                  },
                ],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'Email ou mot de passe incorrect',
            }),
            401,
          );
        }),
      );

      final members = await service.getFamilyMembers();
      expect(members.single.fullName, 'Papa Baraka Bigega');
      expect(members.single.parente, 'Père');
      await expectLater(
        service.login('nope@example.com', 'incorrect'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      service.close();
    },
  );

  test(
    'les opérations famille utilisent les routes et méthodes REST',
    () async {
      final requests = <http.Request>[];
      final service = ApiService(
        client: MockClient((request) async {
          requests.add(request);
          final responseData = request.method == 'DELETE'
              ? null
              : {
                  'id': 5,
                  'nom': 'Baraka',
                  'postnom': 'Bigega',
                  'prenom': 'Papa',
                  'lieu_naissance': 'Goma',
                  'date_naissance': '1970-05-12',
                  'parente': 'Père',
                  'image_url': null,
                };
          return http.Response(
            jsonEncode({'success': true, 'data': responseData}),
            request.method == 'POST' ? 201 : 200,
          );
        }),
      );
      const member = FamilyMemberPayload(
        nom: 'Baraka',
        postnom: 'Bigega',
        prenom: 'Papa',
        lieuNaissance: 'Goma',
        dateNaissance: '1970-05-12',
        parente: 'Père',
      );

      await service.createFamilyMember(member);
      await service.updateFamilyMember(5, member);
      await service.deleteFamilyMember(5);

      expect(
        requests.map((request) => '${request.method} ${request.url.path}'),
        [
          'POST /api-test/public/famille-membres',
          'PUT /api-test/public/famille-membres/5',
          'DELETE /api-test/public/famille-membres/5',
        ],
      );
      expect(jsonDecode(requests.first.body)['date_naissance'], '1970-05-12');
      service.close();
    },
  );

  testWidgets('la connexion confirmée par l’API ouvre le CV et la famille', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final service = ApiService(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/accounts/login')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'id': 7, 'email': 'credo@example.com'},
            }),
            200,
          );
        }
        return http.Response(jsonEncode({'success': true, 'data': []}), 200);
      }),
    );
    addTearDown(service.close);

    await tester.pumpWidget(CvApp(apiService: service));
    await tester.enterText(
      find.byKey(const Key('login-email')),
      'credo@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'secret123',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Formation à renseigner'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-family')));
    await tester.pumpAndSettle();
    expect(find.text('Aucun membre enregistré'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

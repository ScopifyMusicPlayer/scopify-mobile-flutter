import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';

void main() {
  group('BackendEndpoint', () {
    test(
      'normalizes an address without query, fragment, or trailing slash',
      () {
        final endpoint = BackendEndpoint.parse(
          ' https://music.example.test/api/ ',
        );

        expect(endpoint.baseUrl, 'https://music.example.test/api');
        expect(endpoint.id, endpoint.baseUrl);
      },
    );

    test('rejects incomplete and non-http addresses', () {
      expect(
        () => BackendEndpoint.parse('127.0.0.1:3838'),
        throwsFormatException,
      );
      expect(
        () => BackendEndpoint.parse('ftp://music.example.test'),
        throwsFormatException,
      );
      expect(
        () => BackendEndpoint.parse('https://music.example.test?token=secret'),
        throwsFormatException,
      );
      expect(
        () => BackendEndpoint.parse('http://music.example.test'),
        throwsFormatException,
      );
    });

    test('allows HTTP only for local and private network hosts', () {
      expect(
        BackendEndpoint.parse('http://10.0.2.2:3838').baseUrl,
        contains('10.0.2.2'),
      );
      expect(
        BackendEndpoint.parse('http://192.168.1.10:3838').baseUrl,
        contains('192.168.1.10'),
      );
      expect(
        BackendEndpoint.parse('http://172.16.0.1:3838').baseUrl,
        contains('172.16.0.1'),
      );
    });
  });
}

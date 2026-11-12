import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/app/router.dart';
import 'package:inkverse/models/models.dart';
import 'package:inkverse/providers/auth_provider.dart';
import 'package:inkverse/repositories/mock/mock_repositories.dart';

void main() {
  group('Phase 3 Route Path Generators & Profile Recovery', () {
    test('Route path helpers generate correct path strings', () {
      expect(AppRoutes.novelDetailPath('novel_123'), '/novel/novel_123');
      expect(
        AppRoutes.readingPath('novel_123', 'chap_456'),
        '/novel/novel_123/chapter/chap_456',
      );
      expect(
        AppRoutes.authorNovelEditPath('novel_123'),
        '/author/novel/novel_123',
      );
      expect(
        AppRoutes.authorChaptersPath('novel_123'),
        '/author/novel/novel_123/chapters',
      );
      expect(
        AppRoutes.authorChapterNewPath('novel_123'),
        '/author/novel/novel_123/chapter/new',
      );
    });

    test(
      'AuthProvider safely recovers missing user profile as reader',
      () async {
        final mockAuth = MockAuthService(
          initialUserId: 'orphan_uid',
          initialUserEmail: 'orphan@test.com',
        );
        final mockUser = MockUserRepository();
        // Ensure orphan_uid is not present in mock user records
        expect(await mockUser.getUserProfile('orphan_uid'), isNull);

        final authProvider = AuthProvider(
          authService: mockAuth,
          userRepository: mockUser,
        );

        // Wait for auth listener and profile recovery
        await Future.delayed(const Duration(milliseconds: 50));

        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser!.uid, 'orphan_uid');
        expect(authProvider.currentUser!.email, 'orphan@test.com');
        expect(authProvider.currentUser!.role, UserRole.reader);
        expect(authProvider.currentUser!.isActive, isTrue);

        authProvider.dispose();
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkverse/models/models.dart';
import 'package:inkverse/widgets/novel_card.dart';
import 'package:inkverse/widgets/novel_cover.dart';
import 'package:inkverse/widgets/status_chip.dart';
import 'package:inkverse/widgets/user_avatar.dart';

void main() {
  group('Phase 6 Reader UI & Component Tests', () {
    testWidgets(
      'NovelCover renders deterministic fallback when coverUrl is empty',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NovelCover(
                title: 'Echoes Beyond the Gate',
                authorName: 'Elena Hart',
                coverUrl: '',
                genres: ['Fantasy', 'Adventure'],
                width: 120,
                height: 180,
              ),
            ),
          ),
        );

        // Verify initials 'EB' are generated
        expect(find.text('EB'), findsOneWidget);
        expect(find.text('Echoes Beyond the Gate'), findsOneWidget);
        expect(find.text('Elena Hart'), findsOneWidget);
        expect(find.text('FANTASY'), findsOneWidget);
      },
    );

    testWidgets('NovelCard renders title, author, and status chip', (
      WidgetTester tester,
    ) async {
      const sampleNovel = Novel(
        id: 'test_novel_1',
        authorId: 'author_1',
        authorName: 'Marcus Vale',
        title: 'Midnight at Hollow Street',
        genres: ['Mystery'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 5,
        viewCount: 3940,
        followerCount: 720,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NovelCard(novel: sampleNovel, width: 160)),
        ),
      );

      expect(find.text('Midnight at Hollow Street'), findsOneWidget);
      expect(find.text('Marcus Vale'), findsOneWidget);
      expect(find.text('Ongoing'), findsOneWidget);
      expect(find.text('5 ch'), findsOneWidget);
      expect(find.text('3.9k'), findsOneWidget);
    });

    testWidgets(
      'StatusChip renders correct labels and icons for all statuses',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  StatusChip(status: NovelStatus.ongoing),
                  StatusChip(status: NovelStatus.completed),
                  StatusChip(status: NovelStatus.hiatus),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Ongoing'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('On Hiatus'), findsOneWidget);
      },
    );

    testWidgets(
      'UserAvatar handles single-character display names and emails gracefully',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  UserAvatar(name: '1', email: '1@example.com'),
                  UserAvatar(name: '', email: 'reader@inkverse.com'),
                ],
              ),
            ),
          ),
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('R'), findsOneWidget);
      },
    );
  });
}

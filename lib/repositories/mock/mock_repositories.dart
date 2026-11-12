import 'dart:async';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../chapter_repository.dart';
import '../comment_repository.dart';
import '../genre_repository.dart';
import '../library_repository.dart';
import '../novel_repository.dart';
import '../report_repository.dart';
import '../user_repository.dart';

/// ============================================================================
/// DEVELOPMENT ONLY: Mock In-Memory Repository Suite
///
/// Implements the exact same contracts as Firebase repositories to enable:
/// - Instant offline/demo development without Firebase credentials
/// - UI prototyping and verification for Member 2 (Reader) & Member 3 (Author/Admin)
/// - Robust automated and manual test flows
/// ============================================================================

/// In-memory mock authentication service.
class MockAuthService implements AuthService {
  final StreamController<String?> _authController =
      StreamController<String?>.broadcast();
  String? _currentUserId;
  String? _currentUserEmail;

  final Map<String, String> _passwords = {
    'reader@inkverse.com': 'password123',
    'author@inkverse.com': 'password123',
    'admin@inkverse.com': 'password123',
    'disabled@inkverse.com': 'password123',
  };

  final Map<String, String> _emailToUid = {
    'reader@inkverse.com': 'mock_user_reader',
    'author@inkverse.com': 'mock_user_author',
    'admin@inkverse.com': 'mock_user_admin',
    'disabled@inkverse.com': 'mock_user_disabled',
  };

  MockAuthService({String? initialUserId, String? initialUserEmail})
    : _currentUserId = initialUserId,
      _currentUserEmail = initialUserEmail;

  @override
  Stream<String?> get authStateChanges {
    Timer.run(() {
      if (!_authController.isClosed) {
        _authController.add(_currentUserId);
      }
    });
    return _authController.stream;
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  String? get currentUserEmail => _currentUserEmail;

  @override
  Future<String> register({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_passwords.containsKey(cleanEmail)) {
      throw const AuthException('This email is already registered.');
    }
    if (password.length < 6) {
      throw const AuthException('The password must be at least 6 characters.');
    }

    final newUid = 'mock_uid_${DateTime.now().millisecondsSinceEpoch}';
    _passwords[cleanEmail] = password;
    _emailToUid[cleanEmail] = newUid;
    _currentUserId = newUid;
    _currentUserEmail = cleanEmail;
    _authController.add(newUid);
    return newUid;
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_passwords.containsKey(cleanEmail) ||
        _passwords[cleanEmail] != password) {
      throw const AuthException('Invalid email or password.');
    }

    final uid = _emailToUid[cleanEmail]!;
    _currentUserId = uid;
    _currentUserEmail = cleanEmail;
    _authController.add(uid);
    return uid;
  }

  @override
  Future<void> logout() async {
    _currentUserId = null;
    _currentUserEmail = null;
    _authController.add(null);
  }

  @override
  Future<void> reloadUser() async {}

  void dispose() {
    _authController.close();
  }
}

/// In-memory mock User Repository
class MockUserRepository implements UserRepository {
  final Map<String, AppUser> _users = {};
  final StreamController<AppUser?> _profileStreamController =
      StreamController<AppUser?>.broadcast();

  MockUserRepository() {
    _seedUsers();
  }

  void _seedUsers() {
    _users['mock_user_reader'] = const AppUser(
      uid: 'mock_user_reader',
      fullName: 'Alice Reader',
      email: 'reader@inkverse.com',
      role: UserRole.reader,
      bio: 'Avid sci-fi & fantasy reader.',
      isActive: true,
    );
    _users['mock_user_author'] = const AppUser(
      uid: 'mock_user_author',
      fullName: 'Bob Novelist',
      email: 'author@inkverse.com',
      role: UserRole.author,
      bio: 'Author of epic fantasy sagas.',
      isActive: true,
    );
    _users['mock_user_admin'] = const AppUser(
      uid: 'mock_user_admin',
      fullName: 'Carol Admin',
      email: 'admin@inkverse.com',
      role: UserRole.admin,
      bio: 'InkVerse Platform Administrator.',
      isActive: true,
    );
    _users['mock_user_disabled'] = const AppUser(
      uid: 'mock_user_disabled',
      fullName: 'David Disabled',
      email: 'disabled@inkverse.com',
      role: UserRole.reader,
      bio: 'Suspended account.',
      isActive: false,
    );
  }

  @override
  Future<void> createUserProfile(AppUser user) async {
    if (!_users.containsKey(user.uid)) {
      _users[user.uid] = user;
      _profileStreamController.add(user);
    }
  }

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    return _users[uid];
  }

  @override
  Stream<AppUser?> streamUserProfile(String uid) {
    return _profileStreamController.stream.where((u) => u?.uid == uid);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) async {
    final existing = _users[uid];
    if (existing == null) {
      throw const NotFoundException('User profile not found.');
    }
    if (fullName.trim().isEmpty) {
      throw const ValidationException('Full name cannot be empty.');
    }

    final updated = existing.copyWith(
      fullName: fullName.trim(),
      bio: bio.trim(),
      avatarUrl: avatarUrl.trim(),
      updatedAt: DateTime.now(),
    );
    _users[uid] = updated;
    _profileStreamController.add(updated);
  }

  @override
  Future<void> becomeAuthor(String uid) async {
    final existing = _users[uid];
    if (existing == null) {
      throw const NotFoundException('User profile not found.');
    }
    if (existing.role != UserRole.reader) {
      throw const ConflictException(
        'Only readers can transition to the author role.',
      );
    }
    final updated = existing.copyWith(
      role: UserRole.author,
      updatedAt: DateTime.now(),
    );
    _users[uid] = updated;
    _profileStreamController.add(updated);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    return _users.values.toList();
  }

  @override
  Future<void> setUserActive({
    required String uid,
    required bool isActive,
  }) async {
    final existing = _users[uid];
    if (existing != null) {
      final updated = existing.copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      _users[uid] = updated;
      _profileStreamController.add(updated);
    }
  }
}

/// In-memory mock Novel Repository
class MockNovelRepository implements NovelRepository {
  final Map<String, Novel> _novels = {};
  final StreamController<List<Novel>> _publishedNovelsController =
      StreamController<List<Novel>>.broadcast();

  MockNovelRepository() {
    _seedNovels();
  }

  void _notify() {
    _publishedNovelsController.add(
      _novels.values
          .where((n) => n.visibility == NovelVisibility.published)
          .toList(),
    );
  }

  void _seedNovels() {
    final now = DateTime.now();
    final seeds = [
      Novel(
        id: 'novel_1',
        authorId: 'mock_user_author',
        authorName: 'Bob Novelist',
        title: 'The Last Star Keeper',
        description: 'When the ancient celestial lanterns begin flickering out one by one, an apprentice starlight weaver embarks on a dangerous cosmic journey across dying nebulae.',
        coverUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600',
        genres: const ['Sci-Fi', 'Adventure'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 3,
        viewCount: 1420,
        followerCount: 284,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
        publishedAt: now.subtract(const Duration(days: 25)),
      ),
      Novel(
        id: 'novel_2',
        authorId: 'mock_user_author',
        authorName: 'Bob Novelist',
        title: 'Echoes Beyond Midnight',
        description: 'A detective with the ability to hear lingering auditory memories uncovers an unsolved murder deep within an abandoned Victorian asylum.',
        coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
        genres: const ['Mystery', 'Horror'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 2,
        viewCount: 890,
        followerCount: 165,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
        publishedAt: now.subtract(const Duration(days: 18)),
      ),
      Novel(
        id: 'novel_3',
        authorId: 'mock_user_author',
        authorName: 'Bob Novelist',
        title: "The Clockmaker's Daughter",
        description: 'In a steampunk metropolis where time is strictly rationed by the governing guild, a rebellious artisan builds a mechanism that can bend seconds into hours.',
        coverUrl:
            'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=600',
        genres: const ['Fantasy', 'Romance'],
        status: NovelStatus.completed,
        visibility: NovelVisibility.published,
        chapterCount: 2,
        viewCount: 3200,
        followerCount: 540,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 10)),
        publishedAt: now.subtract(const Duration(days: 80)),
      ),
      Novel(
        id: 'novel_4',
        authorId: 'mock_user_author',
        authorName: 'Bob Novelist',
        title: 'Ashes of the Northern Crown',
        description: 'A fallen prince must unite rival mountain clans when a frozen blight awakens from the glacial depths of the forbidden peaks.',
        coverUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600',
        genres: const ['Fantasy', 'Adventure', 'Drama'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 2,
        viewCount: 2150,
        followerCount: 412,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 40)),
      ),
      Novel(
        id: 'novel_5',
        authorId: 'mock_user_author',
        authorName: 'Bob Novelist',
        title: 'Seven Days Before Tomorrow',
        description: 'Trapped in a recursive temporal loop spanning a single fateful summer week, two childhood rivals must make peace before time collapses entirely.',
        coverUrl: 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=600',
        genres: const ['Drama', 'Slice of Life', 'Comedy'],
        status: NovelStatus.hiatus,
        visibility: NovelVisibility.published,
        chapterCount: 1,
        viewCount: 760,
        followerCount: 98,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 5)),
        publishedAt: now.subtract(const Duration(days: 14)),
      ),
      Novel(
        id: 'novel_draft_1',
        authorId: 'mock_user_author',
        authorName: 'Bob Novelist',
        title: 'Whispers from the Void (Unpublished Draft)',
        description: 'An author work-in-progress draft novel.',
        coverUrl: '',
        genres: const ['Sci-Fi'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.draft,
        chapterCount: 0,
        viewCount: 0,
        followerCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final novel in seeds) {
      _novels[novel.id] = novel;
    }
  }

  @override
  Stream<List<Novel>> streamPublishedNovels() {
    Timer.run(_notify);
    return _publishedNovelsController.stream;
  }

  @override
  Future<List<Novel>> getPublishedNovels() async {
    return _novels.values
        .where((n) => n.visibility == NovelVisibility.published)
        .toList();
  }

  @override
  Future<Novel?> getNovel(String id) async {
    return _novels[id];
  }

  @override
  Future<void> incrementViewCount(String id) async {
    final existing = _novels[id];
    if (existing != null) {
      _novels[id] = existing.copyWith(viewCount: existing.viewCount + 1);
      _notify();
    }
  }

  @override
  Future<String> createNovel(Novel novel) async {
    if (novel.title.trim().isEmpty) {
      throw const ValidationException('Novel title cannot be empty.');
    }
    if (novel.description.trim().isEmpty) {
      throw const ValidationException('Novel description cannot be empty.');
    }
    if (novel.genres.isEmpty) {
      throw const ValidationException('At least one genre is required.');
    }

    final id = novel.id.isNotEmpty
        ? novel.id
        : 'novel_${DateTime.now().millisecondsSinceEpoch}';
    final created = novel.copyWith(
      id: id,
      visibility: NovelVisibility.draft,
      chapterCount: 0,
      viewCount: 0,
      followerCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _novels[id] = created;
    _notify();
    return id;
  }

  @override
  Future<void> updateNovel(Novel novel) async {
    final existing = _novels[novel.id];
    if (existing == null) {
      throw const NotFoundException('Novel not found.');
    }
    if (novel.title.trim().isEmpty ||
        novel.description.trim().isEmpty ||
        novel.genres.isEmpty) {
      throw const ValidationException('Required novel fields cannot be empty.');
    }

    _novels[novel.id] = existing.copyWith(
      title: novel.title.trim(),
      description: novel.description.trim(),
      coverUrl: novel.coverUrl.trim(),
      genres: novel.genres,
      status: novel.status,
      updatedAt: DateTime.now(),
    );
    _notify();
  }

  @override
  Future<List<Novel>> getNovelsByAuthor(String authorId) async {
    return _novels.values.where((n) => n.authorId == authorId).toList();
  }

  @override
  Future<void> archiveNovel(
    String id,
    String authorId, {
    bool isAdmin = false,
  }) async {
    final existing = _novels[id];
    if (existing == null) {
      throw const NotFoundException('Novel not found.');
    }
    if (!isAdmin && existing.authorId != authorId) {
      throw const PermissionDeniedException(
        'You can only archive your own novel.',
      );
    }

    _novels[id] = existing.copyWith(
      visibility: NovelVisibility.hidden,
      updatedAt: DateTime.now(),
    );
    _notify();
  }

  @override
  Future<void> publishNovel(
    String id,
    String authorId, {
    bool isAdmin = false,
  }) async {
    final existing = _novels[id];
    if (existing == null) {
      throw const NotFoundException('Novel not found.');
    }
    if (!isAdmin && existing.authorId != authorId) {
      throw const PermissionDeniedException(
        'You can only publish your own novel.',
      );
    }

    _novels[id] = existing.copyWith(
      visibility: NovelVisibility.published,
      publishedAt: existing.publishedAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notify();
  }

  @override
  Future<List<Novel>> getAllNovels() async {
    return _novels.values.toList();
  }

  @override
  Future<void> hideNovel(String id) async {
    final existing = _novels[id];
    if (existing != null) {
      _novels[id] = existing.copyWith(
        visibility: NovelVisibility.hidden,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }

  @override
  Future<void> restoreNovel(String id) async {
    final existing = _novels[id];
    if (existing != null) {
      _novels[id] = existing.copyWith(
        visibility: NovelVisibility.published,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }

  void updateChapterCount(String novelId, int count) {
    final existing = _novels[novelId];
    if (existing != null) {
      _novels[novelId] = existing.copyWith(chapterCount: count);
      _notify();
    }
  }

  void updateFollowerCount(String novelId, int delta) {
    final existing = _novels[novelId];
    if (existing != null) {
      final updated = (existing.followerCount + delta).clamp(0, 9999999);
      _novels[novelId] = existing.copyWith(followerCount: updated);
      _notify();
    }
  }
}

/// In-memory mock Chapter Repository
class MockChapterRepository implements ChapterRepository {
  final Map<String, Chapter> _chapters = {};
  final MockNovelRepository _novelRepo;

  MockChapterRepository(this._novelRepo) {
    _seedChapters();
  }

  void _seedChapters() {
    final now = DateTime.now();

    // Novel 1 chapters
    _chapters['chap_1_1'] = Chapter(
      id: 'chap_1_1',
      novelId: 'novel_1',
      authorId: 'mock_user_author',
      title: 'Chapter 1: The Dying Lantern',
      chapterNumber: 1,
      content: 'In the vast silence of the Aetherium, the stars do not simply vanish; they sigh.\n\nLyra stood upon the obsidian balustrade of the observatory, clutching her copper spools. Three miles above the sea of clouds, the Great Loom hummed with an uneasy, shuddering vibration. Through the brass lens, she watched the twelfth lantern of the Cygnus sector shudder once, flicker into dull amber, and extinguish entirely.\n\n"Master Donald," she called softly, her voice barely carrying over the wind. "Another beacon has ceased."\n\nThe old weaver did not turn immediately. His hands moved methodically across the prism threads, each stroke pulling tension from the dying constellations. "Then the shadow tide has crossed the ridge," he murmured. "Pack the celestial needles, child. Tonight, we do not mend the sky. Tonight, we run."',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 25)),
      updatedAt: now.subtract(const Duration(days: 25)),
      publishedAt: now.subtract(const Duration(days: 25)),
      wordCount: 135,
    );
    _chapters['chap_1_2'] = Chapter(
      id: 'chap_1_2',
      novelId: 'novel_1',
      authorId: 'mock_user_author',
      title: 'Chapter 2: The Weave of Shadows',
      chapterNumber: 2,
      content: 'The road down the precipice was paved in frost and broken glass. As the solar winds surged, Lyra had to brace against the mountain wall. Her knapsack rattled with crystalline vials, each holding a pinch of condensed stardust.\n\nBehind them, the Great Loom fell silent for the first time in four hundred years. In its absence, the sky felt dangerously low and suffocatingly dark.\n\n"Keep your lantern shuttered," Donald warned from ahead. "Creatures of the lower rim navigate by light. Give them none, and we might reach the canyon gate before sunrise."',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now.subtract(const Duration(days: 15)),
      publishedAt: now.subtract(const Duration(days: 15)),
      wordCount: 96,
    );
    _chapters['chap_1_3'] = Chapter(
      id: 'chap_1_3',
      novelId: 'novel_1',
      authorId: 'mock_user_author',
      title: 'Chapter 3: Obsidian Harbor',
      chapterNumber: 3,
      content: 'The docks smelled of sulfur, ozone, and salt. Iron-clad skiffs rocked against the black piers, their sails wrapped tight against the howling squall.\n\nA hooded helmsman stepped out from the cargo hold of an old cutter. "Two passengers for the outer rift?" he asked, surveying their soot-stained cloaks.\n\n"We bring seed light," Lyra replied, showing the crest on her bronze signet. The helmsman went rigid, then bowed low. "Board quickly. The shadow ships have already passed the harbor light."',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
      publishedAt: now.subtract(const Duration(days: 1)),
      wordCount: 88,
    );

    // Novel 2 chapters
    _chapters['chap_2_1'] = Chapter(
      id: 'chap_2_1',
      novelId: 'novel_2',
      authorId: 'mock_user_author',
      title: 'Chapter 1: The Frequency of Guilt',
      chapterNumber: 1,
      content: 'To most ears, the abandoned corridors of St. Jude Asylum were dead silent. But to Inspector Vance, every cracked ceramic tile was screaming.\n\nHe pulled down the brass diaphragm of his resonator. Sound has memory; stone absorbs fear. At 440 Hertz, he could hear the faint chime of grandfather clocks long removed. At 320 Hertz, the terrified gasps of a young woman trapped behind the east wing partition seven decades ago.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 18)),
      updatedAt: now.subtract(const Duration(days: 18)),
      publishedAt: now.subtract(const Duration(days: 18)),
      wordCount: 77,
    );
    _chapters['chap_2_2'] = Chapter(
      id: 'chap_2_2',
      novelId: 'novel_2',
      authorId: 'mock_user_author',
      title: 'Chapter 2: Sub-Level Seven',
      chapterNumber: 2,
      content: 'The floorboards gave way beneath Vance’s right boot, showering rusted iron coils into the basement. He caught himself on a cold water pipe, his resonator vibrating wildly against his ribcage. Below, in the darkness, came a sound that should have been impossible: the rhythmic ticking of a pocket watch.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
      publishedAt: now.subtract(const Duration(days: 2)),
      wordCount: 56,
    );

    // Novel 3 chapters
    _chapters['chap_3_1'] = Chapter(
      id: 'chap_3_1',
      novelId: 'novel_3',
      authorId: 'mock_user_author',
      title: 'Chapter 1: Borrowed Minutes',
      chapterNumber: 1,
      content: 'In Veridia, a second was worth three copper bits, and an hour was a luxury for barons. Clara watched the copper meter strapped to her forearm tick down to seven minutes remaining on her daily stipend. With steady fingers, she slipped a hairspring into the secret aperture beneath the gauge.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 80)),
      updatedAt: now.subtract(const Duration(days: 80)),
      publishedAt: now.subtract(const Duration(days: 80)),
      wordCount: 59,
    );
    _chapters['chap_3_2'] = Chapter(
      id: 'chap_3_2',
      novelId: 'novel_3',
      authorId: 'mock_user_author',
      title: 'Chapter 2: The Stolen Hour',
      chapterNumber: 2,
      content: 'Click. The escapement wheel engaged backwards. Around her, falling drops of rainwater froze mid-air like crystalline beads. Clara smiled, took a deep breath of the suspended afternoon air, and walked freely past the frozen guild enforcers.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 10)),
      publishedAt: now.subtract(const Duration(days: 10)),
      wordCount: 41,
    );

    // Novel 4 chapters
    _chapters['chap_4_1'] = Chapter(
      id: 'chap_4_1',
      novelId: 'novel_4',
      authorId: 'mock_user_author',
      title: 'Chapter 1: Frostbite and Fealty',
      chapterNumber: 1,
      content: 'The mountain passes had frozen shut three weeks earlier than usual. Kael stood on the battlements of Winterhold, his fur mantle stiff with rime. Below in the valley, the banners of Clan Raven crest were planted in the snow.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 40)),
      updatedAt: now.subtract(const Duration(days: 40)),
      publishedAt: now.subtract(const Duration(days: 40)),
      wordCount: 42,
    );
    _chapters['chap_4_2'] = Chapter(
      id: 'chap_4_2',
      novelId: 'novel_4',
      authorId: 'mock_user_author',
      title: 'Chapter 2: The Pale Horde',
      chapterNumber: 2,
      content: 'They did not march like men. They glided across the drifts without leaving footprints, their blue eyes glowing through the blizzard like will-o-wisps.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 3)),
      publishedAt: now.subtract(const Duration(days: 3)),
      wordCount: 26,
    );

    // Novel 5 chapters
    _chapters['chap_5_1'] = Chapter(
      id: 'chap_5_1',
      novelId: 'novel_5',
      authorId: 'mock_user_author',
      title: 'Chapter 1: Monday, Again',
      chapterNumber: 1,
      content: 'The alarm clock buzzed at 7:00 AM on Monday, July 14. For the fourth time this week. Maya groaned, slapped the snooze button, and wondered why she was the only person in town who remembered that yesterday was Sunday.',
      status: ChapterStatus.published,
      createdAt: now.subtract(const Duration(days: 14)),
      updatedAt: now.subtract(const Duration(days: 14)),
      publishedAt: now.subtract(const Duration(days: 14)),
      wordCount: 43,
    );
  }

  @override
  Future<List<Chapter>> getPublishedChapters(String novelId) async {
    final list = _chapters.values
        .where(
          (c) => c.novelId == novelId && c.status == ChapterStatus.published,
        )
        .toList();
    list.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    return list;
  }

  @override
  Future<List<Chapter>> getAuthorChapters(String novelId) async {
    final list = _chapters.values.where((c) => c.novelId == novelId).toList();
    list.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    return list;
  }

  @override
  Future<Chapter?> getChapter(String chapterId) async {
    return _chapters[chapterId];
  }

  @override
  Future<String> createChapter(Chapter chapter) async {
    if (chapter.chapterNumber <= 0) {
      throw const ValidationException(
        'Chapter number must be a positive number.',
      );
    }
    if (chapter.title.trim().isEmpty || chapter.content.trim().isEmpty) {
      throw const ValidationException(
        'Chapter title and content cannot be empty.',
      );
    }

    final exists = _chapters.values.any(
      (c) =>
          c.novelId == chapter.novelId &&
          c.chapterNumber == chapter.chapterNumber,
    );
    if (exists) {
      throw const ConflictException(
        'A chapter with this number already exists.',
      );
    }

    final id = chapter.id.isNotEmpty
        ? chapter.id
        : 'chap_${DateTime.now().millisecondsSinceEpoch}';
    final created = chapter.copyWith(
      id: id,
      status: ChapterStatus.draft,
      wordCount: Chapter.calculateWordCount(chapter.content),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _chapters[id] = created;
    _syncNovelCount(chapter.novelId);
    return id;
  }

  @override
  Future<void> updateChapter(Chapter chapter) async {
    final existing = _chapters[chapter.id];
    if (existing == null) {
      throw const NotFoundException('Chapter not found.');
    }
    if (chapter.chapterNumber <= 0) {
      throw const ValidationException(
        'Chapter number must be a positive number.',
      );
    }

    final conflict = _chapters.values.any(
      (c) =>
          c.id != chapter.id &&
          c.novelId == chapter.novelId &&
          c.chapterNumber == chapter.chapterNumber,
    );
    if (conflict) {
      throw const ConflictException(
        'A chapter with this number already exists.',
      );
    }

    _chapters[chapter.id] = existing.copyWith(
      title: chapter.title.trim(),
      chapterNumber: chapter.chapterNumber,
      content: chapter.content.trim(),
      wordCount: Chapter.calculateWordCount(chapter.content),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> publishChapter(String novelId, String chapterId) async {
    final existing = _chapters[chapterId];
    if (existing == null) {
      throw const NotFoundException('Chapter not found.');
    }

    _chapters[chapterId] = existing.copyWith(
      status: ChapterStatus.published,
      publishedAt: existing.publishedAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _syncNovelCount(novelId);
  }

  @override
  Future<void> unpublishChapter(String novelId, String chapterId) async {
    final existing = _chapters[chapterId];
    if (existing != null) {
      _chapters[chapterId] = existing.copyWith(
        status: ChapterStatus.draft,
        updatedAt: DateTime.now(),
      );
      _syncNovelCount(novelId);
    }
  }

  @override
  Future<void> deleteDraftChapter(String novelId, String chapterId) async {
    final existing = _chapters[chapterId];
    if (existing == null) {
      throw const NotFoundException('Chapter not found.');
    }
    if (existing.status != ChapterStatus.draft) {
      throw const ConflictException('Only draft chapters can be deleted.');
    }
    _chapters.remove(chapterId);
    _syncNovelCount(novelId);
  }

  void _syncNovelCount(String novelId) {
    final publishedCount = _chapters.values
        .where(
          (c) => c.novelId == novelId && c.status == ChapterStatus.published,
        )
        .length;
    _novelRepo.updateChapterCount(novelId, publishedCount);
  }

  @override
  Future<Chapter?> getPreviousChapter(
    String novelId,
    int currentChapterNumber,
  ) async {
    final list = await getPublishedChapters(novelId);
    final prev = list
        .where((c) => c.chapterNumber < currentChapterNumber)
        .toList();
    if (prev.isEmpty) return null;
    return prev.last;
  }

  @override
  Future<Chapter?> getNextChapter(
    String novelId,
    int currentChapterNumber,
  ) async {
    final list = await getPublishedChapters(novelId);
    final next = list
        .where((c) => c.chapterNumber > currentChapterNumber)
        .toList();
    if (next.isEmpty) return null;
    return next.first;
  }
}

/// In-memory mock Library Repository
class MockLibraryRepository implements LibraryRepository {
  final Map<String, Follow> _follows = {};
  final Map<String, Bookmark> _bookmarks = {};
  final Map<String, ReadingProgress> _reading = {};
  final MockNovelRepository _novelRepo;

  MockLibraryRepository(this._novelRepo) {
    _seedLibrary();
  }

  void _seedLibrary() {
    // Initial mock follow for reader
    _follows['mock_user_reader_novel_1'] = Follow.create(
      userId: 'mock_user_reader',
      novelId: 'novel_1',
    );
    // Initial mock bookmark
    _bookmarks['mock_user_reader_novel_1_chap_1_1'] = Bookmark.create(
      userId: 'mock_user_reader',
      novelId: 'novel_1',
      chapterId: 'chap_1_1',
      chapterNumber: 1,
      novelTitle: 'The Last Star Keeper',
      chapterTitle: 'Chapter 1: The Dying Lantern',
    );
    // Initial reading progress
    _reading['mock_user_reader_novel_1'] = ReadingProgress.create(
      userId: 'mock_user_reader',
      novelId: 'novel_1',
      novelTitle: 'The Last Star Keeper',
      coverUrl:
          'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600',
      chapterId: 'chap_1_2',
      chapterTitle: 'Chapter 2: The Weave of Shadows',
      chapterNumber: 2,
      progressPercent: 1.0,
    );
  }

  @override
  Future<void> followNovel(String userId, String novelId) async {
    final docId = Follow.generateId(userId, novelId);
    if (!_follows.containsKey(docId)) {
      _follows[docId] = Follow.create(userId: userId, novelId: novelId);
      _novelRepo.updateFollowerCount(novelId, 1);
    }
  }

  @override
  Future<void> unfollowNovel(String userId, String novelId) async {
    final docId = Follow.generateId(userId, novelId);
    if (_follows.containsKey(docId)) {
      _follows.remove(docId);
      _novelRepo.updateFollowerCount(novelId, -1);
    }
  }

  @override
  Future<bool> isFollowing(String userId, String novelId) async {
    return _follows.containsKey(Follow.generateId(userId, novelId));
  }

  @override
  Future<List<String>> getFollowedNovelIds(String userId) async {
    return _follows.values
        .where((f) => f.userId == userId)
        .map((f) => f.novelId)
        .toList();
  }

  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    final docId = Bookmark.generateId(
      bookmark.userId,
      bookmark.novelId,
      bookmark.chapterId,
    );
    _bookmarks[docId] = bookmark;
  }

  @override
  Future<void> removeBookmark(
    String userId,
    String novelId,
    String chapterId,
  ) async {
    final docId = Bookmark.generateId(userId, novelId, chapterId);
    _bookmarks.remove(docId);
  }

  @override
  Future<bool> isBookmarked(
    String userId,
    String novelId,
    String chapterId,
  ) async {
    final docId = Bookmark.generateId(userId, novelId, chapterId);
    return _bookmarks.containsKey(docId);
  }

  @override
  Future<List<Bookmark>> getBookmarks(String userId) async {
    final list = _bookmarks.values.where((b) => b.userId == userId).toList();
    list.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return list;
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    final docId = ReadingProgress.generateId(progress.userId, progress.novelId);
    _reading[docId] = progress;
  }

  @override
  Future<ReadingProgress?> getReadingProgress(
    String userId,
    String novelId,
  ) async {
    return _reading[ReadingProgress.generateId(userId, novelId)];
  }

  @override
  Future<List<ReadingProgress>> getReadingHistory(String userId) async {
    final list = _reading.values.where((r) => r.userId == userId).toList();
    list.sort(
      (a, b) =>
          (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)),
    );
    return list;
  }
}

/// In-memory mock Comment Repository
class MockCommentRepository implements CommentRepository {
  final Map<String, ChapterComment> _comments = {};

  MockCommentRepository() {
    _seedComments();
  }

  void _seedComments() {
    _comments['comment_1'] = ChapterComment(
      id: 'comment_1',
      userId: 'mock_user_reader',
      userName: 'Alice Reader',
      novelId: 'novel_1',
      chapterId: 'chap_1_1',
      content: 'The imagery of the dying lanterns is breathtaking!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  @override
  Future<List<ChapterComment>> getCommentsForChapter(String chapterId) async {
    final list = _comments.values
        .where((c) => c.chapterId == chapterId && !c.isDeleted)
        .toList();
    list.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return list;
  }

  @override
  Future<String> addComment(ChapterComment comment) async {
    if (comment.content.trim().isEmpty) {
      throw const ValidationException('Comment content cannot be empty.');
    }
    final id = comment.id.isNotEmpty
        ? comment.id
        : 'comment_${DateTime.now().millisecondsSinceEpoch}';
    final created = comment.copyWith(
      id: id,
      content: comment.content.trim(),
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _comments[id] = created;
    return id;
  }

  @override
  Future<void> editOwnComment({
    required String commentId,
    required String userId,
    required String content,
  }) async {
    final existing = _comments[commentId];
    if (existing == null) {
      throw const NotFoundException('Comment not found.');
    }
    if (existing.userId != userId) {
      throw const PermissionDeniedException(
        'You can only edit your own comment.',
      );
    }
    if (content.trim().isEmpty) {
      throw const ValidationException('Comment content cannot be empty.');
    }

    _comments[commentId] = existing.copyWith(
      content: content.trim(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteOwnComment({
    required String commentId,
    required String userId,
  }) async {
    final existing = _comments[commentId];
    if (existing == null) {
      throw const NotFoundException('Comment not found.');
    }
    if (existing.userId != userId) {
      throw const PermissionDeniedException(
        'You can only delete your own comment.',
      );
    }
    // Soft delete
    _comments[commentId] = existing.copyWith(isDeleted: true);
  }

  @override
  Future<void> adminHideComment(String commentId) async {
    final existing = _comments[commentId];
    if (existing != null) {
      _comments[commentId] = existing.copyWith(isDeleted: true);
    }
  }

  @override
  Future<int> countTotalComments() async => _comments.length;
}

/// In-memory mock Report Repository
class MockReportRepository implements ReportRepository {
  final Map<String, ContentReport> _reports = {};

  MockReportRepository() {
    _seedReports();
  }

  void _seedReports() {
    _reports['report_1'] = ContentReport(
      id: 'report_1',
      reporterId: 'mock_user_reader',
      targetType: 'comment',
      targetId: 'comment_spam_123',
      reason: 'Spam / Advertising',
      description: 'Suspicious external link in comment section.',
      status: ReportStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    );
  }

  @override
  Future<String> submitReport(ContentReport report) async {
    if (report.reason.trim().isEmpty) {
      throw const ValidationException('Reason for report is required.');
    }
    final id = report.id.isNotEmpty
        ? report.id
        : 'report_${DateTime.now().millisecondsSinceEpoch}';
    final created = report.copyWith(
      id: id,
      status: ReportStatus.pending,
      reviewedAt: null,
      reviewedBy: '',
      createdAt: DateTime.now(),
    );
    _reports[id] = created;
    return id;
  }

  @override
  Future<List<ContentReport>> getReports({ReportStatus? status}) async {
    final list = status != null
        ? _reports.values.where((r) => r.status == status).toList()
        : _reports.values.toList();
    list.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return list;
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String adminId,
  }) async {
    final existing = _reports[reportId];
    if (existing != null) {
      _reports[reportId] = existing.copyWith(
        status: ReportStatus.resolved,
        reviewedAt: DateTime.now(),
        reviewedBy: adminId,
      );
    }
  }

  @override
  Future<void> dismissReport({
    required String reportId,
    required String adminId,
  }) async {
    final existing = _reports[reportId];
    if (existing != null) {
      _reports[reportId] = existing.copyWith(
        status: ReportStatus.dismissed,
        reviewedAt: DateTime.now(),
        reviewedBy: adminId,
      );
    }
  }

  @override
  Future<int> countPendingReports() async {
    return _reports.values
        .where((r) => r.status == ReportStatus.pending)
        .length;
  }
}

/// In-memory mock Genre Repository
class MockGenreRepository implements GenreRepository {
  final Map<String, Genre> _genres = {};

  MockGenreRepository() {
    seedDefaultGenres();
  }

  @override
  Future<List<Genre>> getActiveGenres() async {
    final list = _genres.values.where((g) => g.isActive).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  Future<List<Genre>> getAllGenres() async {
    final list = _genres.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  Future<String> addGenre(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Genre name cannot be empty.');
    }
    final exists = _genres.values.any(
      (g) => g.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      throw const ConflictException('A genre with this name already exists.');
    }

    final id = 'genre_${DateTime.now().millisecondsSinceEpoch}';
    _genres[id] = Genre(
      id: id,
      name: trimmed,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return id;
  }

  @override
  Future<void> renameGenre({
    required String id,
    required String newName,
  }) async {
    final existing = _genres[id];
    if (existing == null) {
      throw const NotFoundException('Genre not found.');
    }
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Genre name cannot be empty.');
    }

    _genres[id] = existing.copyWith(name: trimmed, updatedAt: DateTime.now());
  }

  @override
  Future<void> setGenreActive({
    required String id,
    required bool isActive,
  }) async {
    final existing = _genres[id];
    if (existing != null) {
      _genres[id] = existing.copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> seedDefaultGenres() async {
    if (_genres.isNotEmpty) return;
    for (int i = 0; i < AppConstants.defaultGenres.length; i++) {
      final name = AppConstants.defaultGenres[i];
      final id = 'genre_seed_$i';
      _genres[id] = Genre(
        id: id,
        name: name,
        isActive: true,
        createdAt: DateTime.now(),
      );
    }
  }
}

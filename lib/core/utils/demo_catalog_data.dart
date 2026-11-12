import '../../models/chapter.dart';
import '../../models/chapter_comment.dart';
import '../../models/novel.dart';

/// Centralized repository of realistic demo serial novels, chapters, and comments.
///
/// Shared between Cloud Firestore [DevSeeder] and in-memory [MockNovelRepository]
/// to guarantee consistent demo presentation across all environments.
class DemoCatalogData {
  DemoCatalogData._();

  static List<Novel> getDemoNovels(DateTime now) {
    return [
      // 1. Hero Showcase Novel 1 - Fantasy
      Novel(
        id: 'demo_novel_echoes_gate',
        authorId: 'author_evelyn_hart',
        authorName: 'Evelyn Hart',
        title: 'Echoes Beyond the Gate',
        description: 'When an ancient stone archway awakens on the outskirts of Oakhaven, archivist Lyra Vance discovers a passage to a dying realm held together by forgotten hymns. Pursued by an enigmatic order of silent wardens, she must decipher the gate’s celestial runes before the doorway collapses permanently.',
        coverUrl: '',
        genres: const ['Fantasy', 'Adventure'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 5,
        viewCount: 4820,
        followerCount: 864,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        publishedAt: now.subtract(const Duration(days: 40)),
      ),

      // 2. Romance - Completed
      Novel(
        id: 'demo_novel_last_letter',
        authorId: 'author_clara_winters',
        authorName: 'Clara Winters',
        title: 'The Last Letter in Winter',
        description: 'In the snow-locked alpine village of Saint-Moritz during 1912, an unaddressed bundle of handwritten letters is uncovered beneath the floorboards of an antique clock shop. Two strangers bound by family secrets unite to deliver the messages before spring thaw reveals the truth.',
        coverUrl: '',
        genres: const ['Romance', 'Historical'],
        status: NovelStatus.completed,
        visibility: NovelVisibility.published,
        chapterCount: 4,
        viewCount: 2890,
        followerCount: 542,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 12)),
        publishedAt: now.subtract(const Duration(days: 55)),
      ),

      // 3. Hero Showcase Novel 2 - Mystery Noir
      Novel(
        id: 'demo_novel_midnight_hollow',
        authorId: 'author_marcus_vale',
        authorName: 'Marcus Vale',
        title: 'Midnight at Hollow Street',
        description: 'Private investigator Julian Gray can hear the lingering auditory echoes of traumatic events left behind in rain-soaked cobblestone alleyways. When a prominent city magistrate vanishes without a trace from Hollow Street, Julian follows a trail of whispering shadows into high-society conspiracies.',
        coverUrl: '',
        genres: const ['Mystery', 'Thriller'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 5,
        viewCount: 3940,
        followerCount: 728,
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(hours: 18)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),

      // 4. Hero Showcase Novel 3 - Sci-Fi
      Novel(
        id: 'demo_novel_orbit_silence',
        authorId: 'author_naomi_reed',
        authorName: 'Naomi Reed',
        title: 'Orbit of Silence',
        description: 'Stationed aboard the deep-space research platform Daedalus-9 near Saturn’s icy rings, communications officer Kaelen intercepts an impossible mathematical pulse originating from inside an empty sector. When all incoming telemetry feeds go black, Kaelen realizes the crew is not as alone as the stars suggest.',
        coverUrl: '',
        genres: const ['Science Fiction', 'Mystery'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 5,
        viewCount: 4210,
        followerCount: 785,
        createdAt: now.subtract(const Duration(days: 28)),
        updatedAt: now.subtract(const Duration(days: 1)),
        publishedAt: now.subtract(const Duration(days: 25)),
      ),

      // 5. Historical Fantasy - Completed
      Novel(
        id: 'demo_novel_crown_no_king',
        authorId: 'author_theo_blackwood',
        authorName: 'Theo Blackwood',
        title: 'The Crown Without a King',
        description: 'Following the sudden demise of the high sovereign without a named heir, the fractured provincial duchies enter a cold war fought with poisoned goblets and subtle pacts. A disgraced captain of the royal guard becomes the sole protector of the kingdom’s forgotten decree.',
        coverUrl: '',
        genres: const ['Historical', 'Fantasy'],
        status: NovelStatus.completed,
        visibility: NovelVisibility.published,
        chapterCount: 4,
        viewCount: 3450,
        followerCount: 618,
        createdAt: now.subtract(const Duration(days: 75)),
        updatedAt: now.subtract(const Duration(days: 8)),
        publishedAt: now.subtract(const Duration(days: 70)),
      ),

      // 6. Cyber / Urban Thriller - Ongoing
      Novel(
        id: 'demo_novel_seven_days',
        authorId: 'author_adrian_cross',
        authorName: 'Adrian Cross',
        title: 'Seven Days Before Dawn',
        description: 'A cyber forensics analyst wakes up with a synchronized countdown timer etched into her wrist terminal and seven encrypted access drives in her trench coat. Every 24 hours unlocks a new target unless she exposes the syndicate responsible for the city’s power grid collapse.',
        coverUrl: '',
        genres: const ['Thriller', 'Action'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 3,
        viewCount: 2150,
        followerCount: 432,
        createdAt: now.subtract(const Duration(days: 16)),
        updatedAt: now.subtract(const Duration(hours: 36)),
        publishedAt: now.subtract(const Duration(days: 14)),
      ),

      // 7. Slice of Life - Completed
      Novel(
        id: 'demo_novel_coffee_rain',
        authorId: 'author_june_holloway',
        authorName: 'June Holloway',
        title: 'Coffee After the Rain',
        description: 'Nestled in a quiet alley off the rainy tram lines of Kyoto, a small second-floor café serves hand-dripped roasts accompanied by handwritten stories left behind by patrons. A weary graphic designer finds unexpected solace and genuine friendship across the mahogany counter.',
        coverUrl: '',
        genres: const ['Slice of Life', 'Romance'],
        status: NovelStatus.completed,
        visibility: NovelVisibility.published,
        chapterCount: 4,
        viewCount: 2680,
        followerCount: 512,
        createdAt: now.subtract(const Duration(days: 50)),
        updatedAt: now.subtract(const Duration(days: 15)),
        publishedAt: now.subtract(const Duration(days: 45)),
      ),

      // 8. Seafaring Adventure - Hiatus
      Novel(
        id: 'demo_novel_cartographer_curse',
        authorId: 'author_elias_rowan',
        authorName: 'Elias Rowan',
        title: "The Cartographer's Curse",
        description: 'Every island charted on Master Corin’s living parchment mysteriously mirrors the shifting geology of the uncharted Southern Expanse. When a phantom archipelago appears on the map overnight, a crew of seafaring outcasts sails toward coordinates that defy ocean currents.',
        coverUrl: '',
        genres: const ['Adventure', 'Fantasy'],
        status: NovelStatus.hiatus,
        visibility: NovelVisibility.published,
        chapterCount: 3,
        viewCount: 1920,
        followerCount: 384,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 40)),
        publishedAt: now.subtract(const Duration(days: 85)),
      ),

      // 9. Space Romance - Ongoing
      Novel(
        id: 'demo_novel_stars_forgot',
        authorId: 'author_evelyn_hart',
        authorName: 'Evelyn Hart',
        title: 'When the Stars Forgot Us',
        description: 'Separated by light-years aboard generation colony vessels travelling toward the Gliese system, two childhood astronomers communicate through delayed tachyon radio transmissions. As their ships drift further apart, their letters chronicle hope, isolation, and an enduring bond.',
        coverUrl: '',
        genres: const ['Romance', 'Science Fiction'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 3,
        viewCount: 2750,
        followerCount: 492,
        createdAt: now.subtract(const Duration(days: 22)),
        updatedAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 20)),
      ),

      // 10. Underground Mystery - Ongoing
      Novel(
        id: 'demo_novel_glass_city',
        authorId: 'author_naomi_reed',
        authorName: 'Naomi Reed',
        title: 'Beneath the Glass City',
        description: 'Above lies Aethelgard, a glistening metropolis of spun crystalline towers; below lurk the Sunless Canals where subterranean water-keepers maintain the city’s foundations. When strange bioluminescent fractures crack the central cathedral floor, a young canal scout uncovers a buried history.',
        coverUrl: '',
        genres: const ['Mystery', 'Fantasy'],
        status: NovelStatus.ongoing,
        visibility: NovelVisibility.published,
        chapterCount: 3,
        viewCount: 3100,
        followerCount: 586,
        createdAt: now.subtract(const Duration(days: 32)),
        updatedAt: now.subtract(const Duration(days: 5)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  static List<Chapter> getDemoChapters(DateTime now) {
    return [
      // ------------------------------------------------------------------------
      // Echoes Beyond the Gate (Hero 1 - 5 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_echoes_ch_001',
        novelId: 'demo_novel_echoes_gate',
        authorId: 'author_evelyn_hart',
        title: "The Door That Shouldn't Exist",
        chapterNumber: 1,
        content: '''The rain in Oakhaven had a way of turning parchment to pulp if you weren't careful. Lyra Vance pulled her oilcloth coat tighter around her shoulders as she navigated the overgrown flagstones behind the municipal archives. In seventy years of township surveys, the low granite ridge behind St. Jude’s cemetery had always been marked as solid bedrock. 

Yet beneath the weeping willow roots, where the earth had eroded during the autumn storms, stood an archway.

It wasn't built of local grey slate. The masonry was dark and lustrous, like polished basalt cooled beneath a foreign sea. When Lyra pressed the sleeve of her wool cardigan against the lintel to wipe away the clinging moss, the carved glyphs beneath didn't scrape—they chimed. A faint, harmonic vibration traveled up her wrist and settled in the hollow of her collarbone.

"Curious," she whispered, exhaling a plume of white vapor into the dusk.

The gate was no taller than a man, its threshold choked with dry birch leaves. But when she angled her brass lantern toward the interior, the golden light did not illuminate earth or bedrock. It stretched forward into an impossible corridor lined with hexagonal pillars of luminescent crystal. Far in the distance, beyond the scent of wet soil and autumn decay, came the cool aroma of ozone and blooming nightshade.

Lyra took a notebook from her satchel, dipped her steel nib into waterproof ink, and wrote three words: *Threshold is awake.*

From somewhere deep within the stone corridor, a sound answered her ink on paper. It was not wind. It was the sustained, singing note of a bronze tuning fork, striking a chord that human ears had not heard in five hundred years. Lyra stepped across the threshold, and the rain behind her abruptly ceased.''',
        wordCount: 320,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 40)),
        publishedAt: now.subtract(const Duration(days: 40)),
      ),
      Chapter(
        id: 'demo_echoes_ch_002',
        novelId: 'demo_novel_echoes_gate',
        authorId: 'author_evelyn_hart',
        title: 'A Map Written in Ash',
        chapterNumber: 2,
        content: '''The silence of the transit corridor was heavier than water. With every footstep Lyra took, the glowing crystals embedded in the floor pulsed with pale cyan light, tracking her weight like luminous footsteps upon new snow.

She had walked for twenty minutes by her pocket chronometer when the passage opened onto a wide, circular mezzanine overlooking a vast subterranean expanse. Above her, suspended in an enormous natural dome, floated an artificial sun—a shattered sphere of brass rings cradling a pale amber core that spun with the slow dignity of a dying star.

Below lay a city. Not a ruin, but a slumbering metropolis of slender spires, terraced aqueducts, and bridges carved from white quartz. No lamps flickered in the windows, but a fine mist of glowing silver pollen drifted through the quiet boulevards.

"A sanctuary," Lyra murmured, leaning over the balustrade.

Beside the balustrade stood an altar of blackened silver. Resting upon it was a cylinder of hammered copper containing a scroll of pale vellum. When Lyra carefully unfurled it, she found the cartography was rendered entirely in charred soot. As her fingertips hovered over the contours of the mountain ranges, the soot shifted, rearranging itself to display red glowing conduits that mirrored the pulse of her own heartbeat.

A shadow fell across the vellum.

Lyra spun around, reaching instinctively for the small pocket revolver in her coat. Standing on the marble stairs twenty paces away was a figure draped in layered robes of midnight wool, their face concealed behind a lacquered porcelain mask painted with a closed golden eye.

The figure held a stave tipped with a spinning gyroscope. When they spoke, the voice did not come through the air, but resonated directly within Lyra’s temples:

*Turn back, Daughter of Oakhaven. The seventh seal is cracked, and what sleeps beneath the silver canals must not be sung awake.*''',
        wordCount: 345,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 35)),
        publishedAt: now.subtract(const Duration(days: 35)),
      ),
      Chapter(
        id: 'demo_echoes_ch_003',
        novelId: 'demo_novel_echoes_gate',
        authorId: 'author_evelyn_hart',
        title: 'The Name Beneath the Stone',
        chapterNumber: 3,
        content: '''The masked guardian did not raise the stave in aggression. Instead, the gyroscope slowed, emitting a rhythmic clicking like a telegraph receiver in an empty station.

"Who sealed this place?" Lyra asked, refusing to lower her gaze. "The municipal archives date back to 1842. There is no record of an excavation beneath Oakhaven."

The warden’s porcelain mask tilted downward toward the map of ash still resting in Lyra's hands. *Your people did not dig this sanctuary, archivist. You built your town upon its ceiling. The bedrock of Oakhaven is the keystone of our sepulcher.*

With a measured gesture, the warden extended a gloved hand. The soot upon the scroll responded instantly, flowing like liquid iron toward the perimeter of the parchment. It formed characters in an archaic High Valen dialect that Lyra had only ever seen stamped on pre-imperial coinage in the museum basement.

"Valen-Korr," Lyra translated slowly. "The Gate of First Departure."

*The wardens have kept vigil for three centuries,* the mental voice continued, touched with an exhaustion that made Lyra’s shoulders ache in sympathy. *We maintained the resonance dampers so the upper world could plant orchards, raise brick chimneys, and sleep without hearing the chorus beneath the floorboards. But yesterday, the south anchor failed. One of your surface wells penetrated the secondary conduit.*

Lyra felt the blood drain from her face. "The Miller family. They contracted a rotary drill three days ago on the ridge."

*The vibration has awakened the Spires,* said the warden. *And when the five spires harmonize, the threshold will cease to be a door. It will become a cataract.*''',
        wordCount: 310,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 30)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
      Chapter(
        id: 'demo_echoes_ch_004',
        novelId: 'demo_novel_echoes_gate',
        authorId: 'author_evelyn_hart',
        title: 'Song of the Quiet Spire',
        chapterNumber: 4,
        content: '''Descending into the crystalline valley required traversing a spiral staircase that coiled down the exterior of a hollow quartz tower. Every few hundred feet, Lyra observed vast water-wheels made of glass turning through dark, viscous channels of mineral-rich water. The fluid hummed in a gentle B-flat, soothing the raw tension behind her eyes.

"Why hymns?" Lyra asked as they reached the valley floor. Her boots crunched on powdered mica.

The warden, whom Lyra had learned to address as Scribe Otheus, gestured toward the five needle-like towers flanking the slumbering city. *Because stone remembers rhythm better than thought. A command can be forgotten, a written word can rot, but a melody locked in crystal will vibrate until the world grows cold.*

They approached the First Spire—a monolith of dark sapphire glass that rose four hundred feet toward the vaulted ceiling. At its base stood an amphitheater carved with hundreds of hemispherical niches. Each niche held a bronze chime of varying size, from tiny thimbles to cauldrons that would take four men to lift.

"The damper here is choked with surface debris," Lyra observed, pointing her lantern at a jagged wedge of grey limestone lodged between the central tuning fork and its magnetic housing. "That's limestone from the Miller well. The drill bit must have shattered the ceiling vault."

*If we attempt to dislodge it with brute force,* Otheus warned, *the recoil will detonate the dampening field. We must sing the counter-frequency.*

Lyra looked down at her satchel. She had no bronze chimes. But tucked in her notebook was the pocket pitch pipe her father had given her when she joined the Oakhaven parish choir fifteen years ago.

She blew a steady, clear C-sharp into the gloom. The sapphire monolith flared with violet lightning.''',
        wordCount: 330,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 20)),
        publishedAt: now.subtract(const Duration(days: 20)),
      ),
      Chapter(
        id: 'demo_echoes_ch_005',
        novelId: 'demo_novel_echoes_gate',
        authorId: 'author_evelyn_hart',
        title: 'Where the Horizon Fractures',
        chapterNumber: 5,
        content: '''The sound that erupted from the First Spire shook the dust from Lyra's eyelashes. It was not music in any traditional human sense; it was geometry made audible. Lines of blue phosphorescence raced up the spire's flanks like rising sparks, converging at the apex where a lens of polished obsidian refocused the sound into a blinding beam of coherent acoustic force.

The limestone boulder cracked with the sharp report of a rifle shot and disintegrated into harmless grey talc.

For a heartbeat, peace returned to the cavern.

Then the artificial sun suspended in the dome shuddered. A hairline fracture appeared across its spinning brass equator, leaking a thread of iridescent white fire that spilled downward toward the silver canal below.

*The secondary anchor,* Otheus said, their voice tightening with unprecedented alarm. *The third spire on the western ridge has not harmonized. It is pulling the celestial core out of alignment.*

Lyra tightened the straps of her satchel and wiped sweat from her brow. "Where is the western ridge?"

The warden pointed with the gyroscope stave toward an impossible suspension bridge spanning a chasm of endless violet clouds. Far beyond the bridge, silhouetted against the fracturing light of the dying core, rose the silhouette of a cathedral built inside the ribcage of an incomprehensible prehistoric beast.

"Then we have three miles to run," Lyra said, stepping onto the swaying quartz bridge. "Before the roof falls into Oakhaven."''',
        wordCount: 305,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 10)),
        publishedAt: now.subtract(const Duration(days: 10)),
      ),

      // ------------------------------------------------------------------------
      // Midnight at Hollow Street (Hero 2 - 5 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_midnight_ch_001',
        novelId: 'demo_novel_midnight_hollow',
        authorId: 'author_marcus_vale',
        title: 'Rain Upon the Cobbles',
        chapterNumber: 1,
        content: '''The rain in New Corinth never washed anything clean; it merely coated the soot in a glistening varnish. Julian Gray stood beneath the dripping eaves of an apothecary on Hollow Street, lighting a clove cigarette with his brass trench lighter. The flame flickered, casting shadows against the blood-stained bricks of the alley.

Other investigators looked for footprints, discarded weapons, or stray fibers. Julian closed his eyes and listened.

The residue was faint, but unmistakable. High-pitched, like the ringing of fine crystal struck with a silver fork: the auditory memory of a woman’s terrified intake of breath, followed by the dull, hollow thud of a heavy cedar cane dropping onto wet stone.

"Magistrate Vance didn't leave voluntarily," Julian muttered to his assistant, Thomas, who was busy taking chalk rubbings of the wall.

"The constabulary says he took the late omnibus to Highgate," Thomas replied without looking up, his fingers stained black with powdered charcoal. "Said he had private family business."

"The constabulary didn't stand here three hours after midnight," Julian said, flicking the match into a puddle. "The sound of his cane hitting the ground is still bouncing off these bricks. And there were three sets of boots waiting for him. Not gentlemen’s leather—heavy dockworker rubber with iron hobnails."

He knelt beside the storm drain and reached his gloved hand into the grate. When he withdrew it, pinched between his fingers was an enameled lapel pin depicting an owl perched atop an open compass.

The insignia of the Silent Guild. The magistrate had walked into a trap arranged by his own fraternal order.''',
        wordCount: 305,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 30)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
      Chapter(
        id: 'demo_midnight_ch_002',
        novelId: 'demo_novel_midnight_hollow',
        authorId: 'author_marcus_vale',
        title: 'Echoes of the Gilded Parlor',
        chapterNumber: 2,
        content: '''The Vance estate on King’s Crescent smelled of lavender water, damp hound, and old money. Julian was escorted into the conservatory by a butler whose starched collar looked stiff enough to sever an artery.

Clara Vance, the magistrate’s only daughter, sat beside a table laden with untouched tea and cold scones. Her eyes were red-rimmed, but her posture was rigid.

"You're the man who hears ghosts," she said before Julian could offer his condolences.

"I hear memories, Miss Vance," Julian replied softly, taking an armchair across from her. "Strong emotional upheavals leave impressions on physical materials, much like a stylus cutting grooves into a wax phonograph cylinder. Traumatic sounds decay slower than quiet ones."

"Then tell me what my father heard before he disappeared."

Julian removed his pigskin gloves and placed his bare palm against the mahogany writing desk where Magistrate Vance had drafted his final judicial brief. He closed his eyes.

The room faded into a wash of white noise. Through the static came the sound of a fountain pen scratching furiously across paper, the clinking of amber liquor in a cut-glass tumbler, and then a voice—rough, cultured, and laced with suppressed fury:

*Sign the requisition order, Vance. The lower docks belong to the Maritime Trust now, whether your municipal charter approves or not.*

And Vance’s reply: *Over my dead body, Henderson.*

*That can be arranged before midnight.*

Julian opened his eyes and exhaled slowly. "Your father didn't go to Highgate, Miss Vance. He went to confront Alderman Henderson at the salt warehouses."''',
        wordCount: 295,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 25)),
        publishedAt: now.subtract(const Duration(days: 25)),
      ),
      Chapter(
        id: 'demo_midnight_ch_003',
        novelId: 'demo_novel_midnight_hollow',
        authorId: 'author_marcus_vale',
        title: 'A Pocket Watch Frozen in Time',
        chapterNumber: 3,
        content: '''The salt warehouses at Pier 14 loomed like decaying mammoths against the greasy fog of the harbor. Julian and Thomas ducked beneath a rusted crane and squeezed through a broken window into Warehouse Three.

The air was dense with brine and cured cod. On the salt-crusted floor, Julian found the magistrate’s silver pocket watch. The crystal was shattered, the hands stopped precisely at twelve minutes past one.

When Julian picked up the watch, the sensory recoil hit him like a physical blow.

A deafening detonation of gunfire echoed in his skull. The sound of splintering crates, the choking gasp of a drowning man, and the mechanical whir of an iron hoist descending into the salt vats.

"Thomas," Julian gasped, bracing himself against a wooden stanchion as blood trickled from his left nostril. "Get the lanterns. The vats. Check the third brine vat."

Thomas hurried across the catwalk, swinging his storm lantern over the vat’s murky surface. He froze, his face turning the color of wet parchment.

"Mr. Gray... he isn't in the brine."

"What is in there?"

"The municipal treasury ledger for 1898," Thomas whispered. "And fifty cases of unrecorded naval dynamite."''',
        wordCount: 285,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 20)),
        publishedAt: now.subtract(const Duration(days: 20)),
      ),
      Chapter(
        id: 'demo_midnight_ch_004',
        novelId: 'demo_novel_midnight_hollow',
        authorId: 'author_marcus_vale',
        title: 'Whispers Behind Heavy Curtains',
        chapterNumber: 4,
        content: '''The Gentlemen’s Exchange on Threadneedle Street was the true throne room of New Corinth. While parliament debated tariffs across the river, the men in silk cravats who controlled the rail lines and shipping cartels settled the city’s debts over port wine.

Julian adjusted his borrowed cravat and stepped into the smoking lounge. Alderman Henderson was holding court near the marble fireplace, his round, ruddy face flushed with brandy.

"A toast to industrial progress," Henderson roared, raising a snifter. "The new deep-water harbor will triple our tonnage by autumn."

Julian stepped into the circle of light. "Even with the treasury books submerged in salt water, Alderman?"

The room went tomb-silent. Henderson’s glass remained suspended midway to his lips, his small porcine eyes narrowing as he took in Julian’s damp coat and the silver pocket watch dangling casually from Julian’s fingers.

"You must be the parlor-trick detective," Henderson chuckled, though the tremor in his jowls gave away his panic. "A man who claims to eavesdrop on brick walls."

"Bricks don't lie to protect their parliamentary pensions," Julian said quietly. "And Magistrate Vance's watch has a great deal to say about where you were at twelve minutes past one."''',
        wordCount: 290,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 15)),
        publishedAt: now.subtract(const Duration(days: 15)),
      ),
      Chapter(
        id: 'demo_midnight_ch_005',
        novelId: 'demo_novel_midnight_hollow',
        authorId: 'author_marcus_vale',
        title: "The Magistrate's Last Witness",
        chapterNumber: 5,
        content: '''The confrontation at the exchange ended not with gunfire, but with the dry, bureaucratic rustle of arrest warrants issued by the High Court of Admiralty.

Standing on the steps of the municipal courthouse as morning fog burned off the river, Julian watched constables load Henderson into a barred paddy wagon. Beside Julian stood Magistrate Vance—alive, bruised, but unbowed—having been liberated from an abandoned coal tender in the railyards by Thomas and an armed squad of harbor police.

"I thought I was dead in that warehouse, Gray," Vance said, leaning heavily on a new ash cane. "When Henderson’s thugs threw me down, I dropped my watch hoping someone with good eyes would find it."

"Your watch had good ears, Magistrate," Julian smiled faintly, tapping his temple.

"What will you do with the reward?"

Julian looked across the river toward the smoky chimneys of Hollow Street. Another cold autumn was settling into the city, and in every dark doorway and damp brick basement, centuries of secrets were waiting to be heard.

"Pay my tobacco bill," Julian said, turning up his collar. "And buy a thicker pair of gloves."''',
        wordCount: 280,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 5)),
        publishedAt: now.subtract(const Duration(days: 5)),
      ),

      // ------------------------------------------------------------------------
      // Orbit of Silence (Hero 3 - 5 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_orbit_ch_001',
        novelId: 'demo_novel_orbit_silence',
        authorId: 'author_naomi_reed',
        title: 'The Frequency Beyond the Ring',
        chapterNumber: 1,
        content: '''At three hundred thousand kilometers above Saturn’s C-ring, the solar wind didn't roar; it whistled against Daedalus-9’s composite hull like sand sprayed against frozen glass. Communications Officer Kaelen sat with his headset clamped over his ears, watching the green phosphors of the spectrum analyzer dance in erratic sine waves.

The scheduled telemetry burst from Earth was four hours late.

In the vacuum of deep space, late transmissions usually meant a transmitter relay on Ganymede had dipped into Jupiter’s magnetosphere. But when Kaelen ran the sub-space diagnostic, the Ganymede carrier wave was completely flat.

"Commander Zhao," Kaelen called over the intercom, his throat dry. "I’ve got anomalous noise on channel eighteen."

"Is it solar flares, Kaelen?" Zhao’s voice crackled back from hydroponics.

"No, sir. Flares have Gaussian distribution. This signal has primes. Two, three, five, seven, eleven... repeating in triplets."

Kaelen filtered the signal through the station's analog decoder. A sound pushed through the static. Not the metallic click of automated beacons, but a slow, rhythmic intake of atmospheric pressure. Like the bellows of a forge breathing deep in the cold dark between the rings.

And then, in clean digital telemetry, the station's orbital collision radar painted a ghost: a thermal signature three kilometers wide, decelerating toward Daedalus-9 with zero reaction-mass exhaust.''',
        wordCount: 300,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 25)),
        publishedAt: now.subtract(const Duration(days: 25)),
      ),
      Chapter(
        id: 'demo_orbit_ch_002',
        novelId: 'demo_novel_orbit_silence',
        authorId: 'author_naomi_reed',
        title: 'Cold Telemetry',
        chapterNumber: 2,
        content: '''The emergency claxon sounded throughout the habitat ring with the harsh squawk of an electric crow. Red strobe lights bathed the narrow access ladders in crimson as Kaelen sprinted toward the observation deck.

Outside the triple-paned quartz viewport, Saturn filled half the sky—a golden, banded giant encircled by razor-thin rings of ice particles. But silhouetted against the bright reflection of the B-ring floated an object that defied every rule of aerospace engineering.

It was not metallic. It resembled an elongated spindle of porous black pumice, its surface pitted with hexagonal chambers that glowed with a faint, bioluminescent indigo.

"What in God's name is that?" whispered Dr. Aris Thorne, the station astrophysicist, clutching his telemetry pad against his chest.

"It isn't transmitting on any registered military or civilian band," Kaelen reported, adjusting the long-range optical sensor. "And it's shedding orbital velocity without firing thrusters. It’s matching our trajectory by dampening its own inertia."

"That violates three laws of thermodynamics," Aris muttered, his eyes wide behind his glasses.

"Tell that to our gravitational sensors," Kaelen said grimly. "Because its mass reading just jumped from ten metric tons to fifty thousand."''',
        wordCount: 285,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 20)),
        publishedAt: now.subtract(const Duration(days: 20)),
      ),
      Chapter(
        id: 'demo_orbit_ch_003',
        novelId: 'demo_novel_orbit_silence',
        authorId: 'author_naomi_reed',
        title: 'Echoes in Sector Nine',
        chapterNumber: 3,
        content: '''By eighteen hundred hours ship time, the alien vessel had stationed itself exactly twelve hundred meters off the starboard docking hub.

Every communication attempt—binary handshakes, mathematical greetings, radio pulses, modulated lasers—had been absorbed by the pumice hull without a single reflected photon.

Then the lights inside Daedalus-9 began to flicker.

"Main reactor output is dropping," Chief Engineer Novak reported over the emergency line. "Something is siphoning our magnetic containment field! If the coils drop below eighty percent, the fusion core will quench!"

Kaelen remained in communications, his fingers flying across the terminal. "It isn't draining the power, Novak. It's translating it. Look at the power fluctuation frequency."

He fed the reactor’s output curve through the audio monitors. The rhythmic drop in wattage matched the pulse he had heard four hours earlier: *two, three, five, seven, eleven.*

"It's talking to the reactor," Kaelen said in wonder and dread. "It thinks our fusion containment is a vocal organ."''',
        wordCount: 275,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 15)),
        publishedAt: now.subtract(const Duration(days: 15)),
      ),
      Chapter(
        id: 'demo_orbit_ch_004',
        novelId: 'demo_novel_orbit_silence',
        authorId: 'author_naomi_reed',
        title: 'When the Beacon Died',
        chapterNumber: 4,
        content: '''Commander Zhao gathered the remaining five crew members in the command module. The air was already chilling as life support throttled down non-essential heating to preserve emergency battery reserves.

"We have one escape shuttle fueled," Zhao announced, her face set in stone. "It can carry four people to the automated orbital shelter on Titan. Two must stay behind to keep the thruster alignment locks manual."

"No one is leaving," Kaelen said, stepping forward.

"Officer Kaelen, this is a direct military order—"

"Commander, look at the telemetry!" Kaelen brought up the external sensor feeds on the main holo-table. "The ship isn't attacking us. When Novak cut the reactor power five minutes ago, its indigo luminescence dimmed. It thought we were dying. It’s extending an umbilical made of carbon nanotubes toward our airlock."

Silence fell over the bridge, broken only by the hiss of recirculated oxygen.

"It isn't a predator," Aris whispered. "It’s a rescue vessel."''',
        wordCount: 260,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 10)),
        publishedAt: now.subtract(const Duration(days: 10)),
      ),
      Chapter(
        id: 'demo_orbit_ch_005',
        novelId: 'demo_novel_orbit_silence',
        authorId: 'author_naomi_reed',
        title: 'A Shadow Against Saturn',
        chapterNumber: 5,
        content: '''Kaelen suited up in his heavy EVA pressure suit and stepped into the airlock alone. When the outer hatch rolled back, the silence of Saturn’s orbit rushed to greet him—vast, frigid, and crowned in golden light.

Waiting at the end of the airlock gantry was an aperture in the pumice hull, framed in soft blue light.

As Kaelen floated across the tether, his suit radio crackled with a voice that was neither human nor machine. It was a synthesis of every transmission that had ever drifted into Saturn’s rings since Marconi first sent a radio wave across the Atlantic: snippets of Morse code, orchestral symphonies from the 1930s, astronaut chatter from the Apollo moon landings, and children’s laughter.

*You have been calling into the dark for a long time,* the voice conveyed through his helmet speakers. *We heard your small fire.*

Kaelen looked back one last time at the blue marble of Earth, a tiny speck of light lost in the vast gulf of space. Then he reached out his gloved hand and crossed the threshold into the deep.''',
        wordCount: 285,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 3)),
      ),

      // ------------------------------------------------------------------------
      // The Last Letter in Winter (Romance - 4 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_letter_ch_001',
        novelId: 'demo_novel_last_letter',
        authorId: 'author_clara_winters',
        title: 'The Dust of Saint-Moritz',
        chapterNumber: 1,
        content: '''The blizzard of 1912 arrived with the suddenness of an avalanche, cutting off the mountain railway and sealing the high valley of Saint-Moritz beneath three feet of drift snow. Inside the clockmaker’s atelier on the Rue des Horloges, the only sound was the synchronized ticking of eighty-four pendulum clocks.

Matthias Brand leaned over a disassembled pocket chronometer, his jeweler’s loupe screwed into his right eye. When his apprentice pulled up a rotted pine floorboard near the chimney to inspect for dry rot, the iron crowbar clattered against a bundle tied with faded green silk ribbon.

"What is that, Henri?" Matthias asked without raising his head.

"Letters, Monsieur. Addressed to Mademoiselle Vivienne Laurent. None of the wax seals have been broken."

Matthias set down his tweezers. Vivienne Laurent had been the daughter of the village doctor, a girl whose laughter in the town square fifty years ago was still remembered by the elders. She had departed for Vienna in the winter of 1862 and had never returned.

The return address on the parchment bore the name of Julian Moreau—a sculptor whose bronze statues still decorated the village fountain.''',
        wordCount: 270,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 55)),
        publishedAt: now.subtract(const Duration(days: 55)),
      ),
      Chapter(
        id: 'demo_letter_ch_002',
        novelId: 'demo_novel_last_letter',
        authorId: 'author_clara_winters',
        title: 'Ink and Dried Edelweiss',
        chapterNumber: 2,
        content: '''When Mademoiselle Camille Laurent arrived at the shop in response to Matthias's telegram, she brought with her the sharp scent of winter pine and wool. As the grandniece of Vivienne Laurent, she had inherited the family chalet on the high ridge.

"My grandmother told stories of these letters," Camille said softly, her gloved fingers resting on the brittle parchment. "She believed Julian had abandoned her without a word when his father lost the family vineyard."

Matthias carefully slit the green ribbon with a silver penknife. Inside the first envelope was a pressed edelweiss blossom, its white petals dried to the color of antique lace, and three pages written in a bold, passionate hand:

*My darling Vivienne. If the snow prevents me from reaching the pass tonight, know that every stroke of my chisel has had no purpose other than to capture the line of your jaw...*

"He never left her," Matthias realized, meeting Camille's eyes across the cedar counter. "Someone intercepted his letters."''',
        wordCount: 260,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 45)),
        publishedAt: now.subtract(const Duration(days: 45)),
      ),
      Chapter(
        id: 'demo_letter_ch_003',
        novelId: 'demo_novel_last_letter',
        authorId: 'author_clara_winters',
        title: 'The Secret of the Postmaster',
        chapterNumber: 3,
        content: '''Together through the quiet snowbound days, Matthias and Camille unraveled the correspondence. There were seventeen letters in all, spanning the harsh winter of 1862.

In the ninth letter, Julian wrote of his confrontation with the village postmaster—Camille’s own great-grandfather, a stern magistrate who deemed a penniless sculptor unworthy of his family line.

"My family chose pride over love," Camille whispered, sitting by the workshop stove as Matthias poured hot spiced cider into ceramic mugs.

"Perhaps," Matthias said gently, sitting beside her. "But the letters survived fifty winters in the dark. And here we are, reading them together."

Outside, the blizzard raged against the glass, but inside the warmth of the wood stove and the gentle rhythm of the clocks, an unspoken closeness was beginning to bloom between the clockmaker and the doctor’s descendant.''',
        wordCount: 250,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 30)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
      Chapter(
        id: 'demo_letter_ch_004',
        novelId: 'demo_novel_last_letter',
        authorId: 'author_clara_winters',
        title: 'Spring Thaw at Last',
        chapterNumber: 4,
        content: '''When the April thaw finally reopened the railway pass, Camille and Matthias traveled together to the cemetery in Lausanne where Julian Moreau was buried beneath a simple granite headstone overlooking Lake Geneva.

Beside the headstone, Camille placed the bundle of letters, sealed with fresh wax and tied with the original green silk ribbon.

"Rest in peace, Julian," she whispered. "Your words finally reached her family."

As they walked back along the promenade beneath the budding chestnut trees, Matthias reached out and took Camille’s hand. For the first time in his quiet, regimented life as a keeper of mechanical time, Matthias Brand was not counting seconds. He was savoring them.''',
        wordCount: 245,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 12)),
        publishedAt: now.subtract(const Duration(days: 12)),
      ),

      // ------------------------------------------------------------------------
      // The Crown Without a King (Historical - 4 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_crown_ch_001',
        novelId: 'demo_novel_crown_no_king',
        authorId: 'author_theo_blackwood',
        title: 'The Empty Dais',
        chapterNumber: 1,
        content: '''The iron bell of the High Cathedral of Morvath tolled forty times before dusk, once for each year King Alden had held the sovereign scepter. In the Great Hall, two hundred lords and prelates stood in stunned silence around the carved throne of black oak.

The King had died without a queen, without an heir, and without signing the charter of succession.

Captain Donald Vance stood at the foot of the dais with twenty iron-clad guardsmen of the Royal Ward. He could feel the eyes of Duke Charles of Valois boring into his back—a man whose mercenaries were already massing at the south river crossing.

"Captain," the Lord Chancellor whispered, approaching Donald with trembling hands. "The regalia must be locked in the crypts until the Council of Regency votes."

"The regalia does not belong to the council, my Lord," Donald replied, resting his hand on his broadsword pommel. "It belongs to the kingdom. And my oath is to prevent civil war before sunset."''',
        wordCount: 260,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 70)),
        publishedAt: now.subtract(const Duration(days: 70)),
      ),
      Chapter(
        id: 'demo_crown_ch_002',
        novelId: 'demo_novel_crown_no_king',
        authorId: 'author_theo_blackwood',
        title: 'Poison in the Chalice',
        chapterNumber: 2,
        content: '''The first council banquet was held under heavy guard in the Hall of Tapestries. While servants served roast venison and spiced wine, Donald watched the cups.

A good captain of the guard knew that civil wars are rarely declared on open battlefields; they are inaugurated in small sips.

When Duke Charles offered a toast to the memory of King Alden, Donald noticed the steward's sleeve tremble as he poured for Count Renard of the Western Marches. Donald stepped forward, his mailed fist catching the goblet mid-air.

"My Lord Count," Donald announced before the assembled nobility. "Allow me to test the vintage for our honored guest."

The steward turned pale and bolted for the service corridor. Donald threw the wine into the fire grate—the flames roared green with the unmistakable scent of bitter aconite.

The council erupted into drawing steel.''',
        wordCount: 250,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 50)),
        publishedAt: now.subtract(const Duration(days: 50)),
      ),
      Chapter(
        id: 'demo_crown_ch_003',
        novelId: 'demo_novel_crown_no_king',
        authorId: 'author_theo_blackwood',
        title: 'The Forgotten Child',
        chapterNumber: 3,
        content: '''In the dead of night, while factions fortified their wings of the castle, Donald took two trusted men and descended into the low cloisters of the Sisters of Mercy outside the city walls.

There, working in the herb garden, was twelve-year-old Brian—the son of King Alden’s younger brother who had died in the eastern crusades. The boy had been hidden here since infancy to protect him from court intrigues.

"Are you taking me to be hanged, Captain?" the boy asked, wiping soil from his knees.

Donald knelt on one knee in the damp earth, unbuckled his sword belt, and laid it before the child.

"No, Your Grace. I am taking you to save a kingdom from tearing itself apart."''',
        wordCount: 240,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 30)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
      Chapter(
        id: 'demo_crown_ch_004',
        novelId: 'demo_novel_crown_no_king',
        authorId: 'author_theo_blackwood',
        title: 'Dawn Over Morvath',
        chapterNumber: 4,
        content: '''At dawn, before Duke Charles could launch his mercenaries across the river, the great bronze gates of the cathedral swung wide.

Donald escorted young Brian up the aisle in front of the entire assembly of prelates, knights, and citizens. In his hands, the boy carried King Alden’s personal signet ring, verified by the grand seal of the abbey.

When Duke Charles stepped forward with drawn blade to contest the boy’s lineage, the two hundred knights of the Royal Guard raised their shields in unison, forming an impenetrable wall of iron.

"Long live Prince Brian!" the people cried from the galleries.

The crown had found its heir, and the realm was saved from the flames.''',
        wordCount: 235,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 8)),
        publishedAt: now.subtract(const Duration(days: 8)),
      ),

      // ------------------------------------------------------------------------
      // Seven Days Before Dawn (Thriller - 3 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_seven_ch_001',
        novelId: 'demo_novel_seven_days',
        authorId: 'author_adrian_cross',
        title: 'The Digital Mark',
        chapterNumber: 1,
        content: '''Maya Kane woke up on the subway platform at 4th Avenue with a throbbing headache and the taste of zinc in her mouth. When she checked her wrist terminal, the display was frozen on a countdown timer glowing in harsh amber: *167:59:58*.

Exactly seven days.

In her leather jacket pocket were seven biometric encrypted memory drives, each labeled with a Roman numeral from I to VII. A push notification appeared on her optical overlay:

*Every 24 hours at 06:00, one drive decrypts. If you do not broadcast its payload to the public network within sixty minutes, your neural interface will detonate. Welcome to the audit, Maya.*

Maya staggered to the nearest public console and jacked in. The entire city power grid was already experiencing brownouts, and the sirens of tactical police units were converging on 4th Avenue.''',
        wordCount: 240,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 14)),
        publishedAt: now.subtract(const Duration(days: 14)),
      ),
      Chapter(
        id: 'demo_seven_ch_002',
        novelId: 'demo_novel_seven_days',
        authorId: 'author_adrian_cross',
        title: 'The Blackout Protocol',
        chapterNumber: 2,
        content: '''Drive I contained the private surveillance logs of the OmniGrid Energy Corporation, revealing that the recent regional power outages were not equipment failures—they were deliberate blackouts designed to drive up municipal energy shares.

Maya knew that broadcasting the files would put a million-credit bounty on her head, but withholding them meant instant death when the timer expired.

From the roof of an abandoned cooling tower in the industrial district, she spliced her terminal into a commercial microwave relay tower. At 06:58, with two minutes remaining on the first deadline, she hit transmit.

Every digital screen across eight city boroughs flashed red with OmniGrid’s leaked internal communications. Below her, the stock tickers on the financial towers plummeted in seconds.

And her wrist timer chirped: *Drive II armed. 23:59:59.*''',
        wordCount: 235,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 7)),
        publishedAt: now.subtract(const Duration(days: 7)),
      ),
      Chapter(
        id: 'demo_seven_ch_003',
        novelId: 'demo_novel_seven_days',
        authorId: 'author_adrian_cross',
        title: 'Ghosts in the Machine',
        chapterNumber: 3,
        content: '''With tactical bounty hunters scouring the lower subway tunnels, Maya sought refuge in the server farms beneath the abandoned naval yards.

There she met Kovic, a rogue former OmniGrid network architect who had spent five years living off-grid.

"They didn't give you those drives to audit the city, Maya," Kovic warned, patching her bleeding shoulder wound. "They gave them to you because you're the only analyst who can bypass the core firewall. You aren't their whistleblower. You're their delivery system."

Maya looked down at Drive III in her palm. The timer on her wrist was ticking down to hour seventy-two.

"Then we change the delivery address," she said.''',
        wordCount: 230,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(hours: 36)),
        publishedAt: now.subtract(const Duration(hours: 36)),
      ),

      // ------------------------------------------------------------------------
      // Coffee After the Rain (Slice of Life - 4 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_coffee_ch_001',
        novelId: 'demo_novel_coffee_rain',
        authorId: 'author_june_holloway',
        title: 'The Second Floor on Teramachi',
        chapterNumber: 1,
        content: '''The rain in Kyoto during June smelled of wet cedar and sweet daphne flowers. Kenji climbed the narrow wooden stairs to Café Sazanami, shaking his dripping umbrella before placing it in the pottery urn by the door.

Inside, the brass kettle on the gas burner whistled a quiet, steady note. Mrs. Takahashi, her silver hair pinned neatly with a bamboo hairpin, looked up from grinding Ethiopian beans and smiled.

"Welcome in from the storm, Kenji-san. Your corner seat by the rainy window is waiting."

Kenji sank into the deep green velvet armchair with a sigh. After eighty hours of debugging advertising campaign graphics for an demanding client in Osaka, the scent of fresh pour-over coffee felt like medicine.

On the small wooden table sat the notebook: a leather-bound journal where customers wrote down one memory before leaving.''',
        wordCount: 250,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 45)),
        publishedAt: now.subtract(const Duration(days: 45)),
      ),
      Chapter(
        id: 'demo_coffee_ch_002',
        novelId: 'demo_novel_coffee_rain',
        authorId: 'author_june_holloway',
        title: 'Messages in a Ceramic Cup',
        chapterNumber: 2,
        content: '''The coffee arrived in a speckled ceramic cup glazed in deep cobalt. Alongside it, Mrs. Takahashi had placed a small slice of warm castella sponge cake.

Kenji flipped open the journal to the previous day’s entry.

*June 14. To whoever reads this: I passed my nursing board exams this morning after three years of night classes. If you are having a difficult day, remember that rain never lasts forever, but tea tastes best when it pours outside.*

Kenji smiled, his shoulders relaxing for the first time in a month. He took out his favorite ink pen and turned to a fresh page.''',
        wordCount: 215,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 35)),
        publishedAt: now.subtract(const Duration(days: 35)),
      ),
      Chapter(
        id: 'demo_coffee_ch_003',
        novelId: 'demo_novel_coffee_rain',
        authorId: 'author_june_holloway',
        title: 'The Girl with the Sketchbook',
        chapterNumber: 3,
        content: '''The bell above the door chimed softly, admitting a young woman with a rain-spattered yellow raincoat and an oversized portfolio case.

She took the seat across the aisle, ordered a hot hojicha latte, and immediately opened a sketchbook filled with vibrant watercolor illustrations of Kyoto’s rainy temple gardens.

When Kenji’s elbow accidentally brushed his coffee spoon, causing it to clatter against the ceramic saucer, she looked up and laughed—a bright, warm sound that made the grey afternoon feel ten degrees warmer.

"Are you an illustrator too?" she asked, noticing his drawing pens on the table.

"I used to be," Kenji said honestly. "Lately I just make corporate banners."

"Then let's make something real today," she smiled, sliding a sheet of heavy cold-press watercolor paper across the table.''',
        wordCount: 245,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 25)),
        publishedAt: now.subtract(const Duration(days: 25)),
      ),
      Chapter(
        id: 'demo_coffee_ch_004',
        novelId: 'demo_novel_coffee_rain',
        authorId: 'author_june_holloway',
        title: 'Sunlight on the Tram Rails',
        chapterNumber: 4,
        content: '''By late afternoon, the clouds parted, casting long golden beams of sunlight across the wet asphalt of Teramachi Street. The tram bells chimed in the distance like church chimes.

Kenji walked down the wooden stairs of Café Sazanami carrying a roll of sketches and a light heart. His client in Osaka would still need revisions tomorrow, but tonight, he was going to draw because his hands loved making lines on paper.

In the cafe's leather journal, a new entry dried in blue ink:

*June 15. Today I remembered that art is not about perfection. It is about drinking warm coffee with someone who understands why rain makes the world quiet.*''',
        wordCount: 235,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 15)),
        publishedAt: now.subtract(const Duration(days: 15)),
      ),

      // ------------------------------------------------------------------------
      // The Cartographer's Curse (Adventure - 3 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_cartographer_ch_001',
        novelId: 'demo_novel_cartographer_curse',
        authorId: 'author_elias_rowan',
        title: 'The Living Map',
        chapterNumber: 1,
        content: '''Master Corin’s parchment had a pulse. It was faint—less than the flutter of a moth trapped beneath a wine glass—but whenever his quill touched the black squid ink, the boundary lines of the uncharted Southern Expanse redrew themselves.

"A phantom reef at forty-two degrees south," Corin muttered to his bosun, a one-eyed veteran named Jax who was busy splicing rigging on the quarterdeck of the *Seagull*.

"Maps don't bleed, Captain," Jax spat a mouthful of tobacco over the rail.

"This one does," Corin answered, showing him the paper. Where the ink had settled, the parchment was warm to the touch, and tiny ripples of indigo seawater were bleeding through the fibers.''',
        wordCount: 230,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 85)),
        publishedAt: now.subtract(const Duration(days: 85)),
      ),
      Chapter(
        id: 'demo_cartographer_ch_002',
        novelId: 'demo_novel_cartographer_curse',
        authorId: 'author_elias_rowan',
        title: 'Through the Boiling Shoals',
        chapterNumber: 2,
        content: '''Three days south of the trade winds, the sea turned the color of green jade, and plumes of volcanic sulfur hissed from underwater vents.

Every compass aboard spun like a top. The only navigational guide was the parchment, which now displayed a mountain range rising straight out of the open ocean where all previous imperial charts indicated five miles of fathomless depth.

"All hands aloft!" Corin bellowed as the ship surged forward on an unnatural current. "Prepare for landfall!"

Through the sulfur mist, the silhouette of towering black basalt cliffs emerged from the breakers—exactly as Corin had drawn them the night before.''',
        wordCount: 220,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 60)),
        publishedAt: now.subtract(const Duration(days: 60)),
      ),
      Chapter(
        id: 'demo_cartographer_ch_003',
        novelId: 'demo_novel_cartographer_curse',
        authorId: 'author_elias_rowan',
        title: 'The Island That Was Not on the Map',
        chapterNumber: 3,
        content: '''They dropped anchor in a lagoon sheltered by curved obsidian ridges. When Corin stepped onto the black sand beach, he realized the ground beneath his boots was vibrating with the exact same rhythm as his quill.

He opened his satchel and withdrew the blank sheet of parchment.

Before his eyes, the ink began flowing across the paper on its own, charting an ancient temple in the center of the jungle.

"It isn't a map of where we are," Corin realized with mounting terror. "It's a map of what the island wants us to do."''',
        wordCount: 215,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 40)),
        publishedAt: now.subtract(const Duration(days: 40)),
      ),

      // ------------------------------------------------------------------------
      // When the Stars Forgot Us (Romance / Sci-Fi - 3 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_stars_ch_001',
        novelId: 'demo_novel_stars_forgot',
        authorId: 'author_evelyn_hart',
        title: 'Ten Light-Years Between Us',
        chapterNumber: 1,
        content: '''The delay on our radio transmission is now two thousand four hundred days. When I speak your name into the microphone in communications pod C, I know that my voice will not vibrate against your eardrum until you have lived through six Earth birthdays.

I wonder if your hair is still cut short, or if you let it grow past your collar like the colony botanists do.

Aboard the *Vanguard*, our fusion reactors are quiet tonight. Outside my observation hatch, the star field toward Gliese 667 is dense with cold, unblinking eyes. I keep your silver constellation pendant in my palm, warming it against my skin until the metal feels like human touch.''',
        wordCount: 235,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 20)),
        publishedAt: now.subtract(const Duration(days: 20)),
      ),
      Chapter(
        id: 'demo_stars_ch_002',
        novelId: 'demo_novel_stars_forgot',
        authorId: 'author_evelyn_hart',
        title: 'A Letter from Six Years Ago',
        chapterNumber: 2,
        content: '''Your response arrived this morning, accompanied by seven seconds of audio telemetry recorded when our ships were still in the Kuiper Belt.

Your voice sounded younger than I remembered, vibrant with the nervous excitement of leaving the solar system. You told me about planting the apple saplings in Hydroponics Bay 4 and how the soil smelled like autumn in New Hampshire.

I listened to those seven seconds forty times today while calibration drills ran in the reactor bay. Out here where time stretches like cold rubber, your voice is the only anchor keeping my thoughts from drifting into the vacuum.''',
        wordCount: 220,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 10)),
        publishedAt: now.subtract(const Duration(days: 10)),
      ),
      Chapter(
        id: 'demo_stars_ch_003',
        novelId: 'demo_novel_stars_forgot',
        authorId: 'author_evelyn_hart',
        title: 'The Rendezvous Orbit',
        chapterNumber: 3,
        content: '''Telemetry from the planetary survey confirms that our two sister vessels will enter synchronous parking orbit around Gliese 667Cc on the same solar cycle.

It will take another twelve years of relativistic drift, but for the first time in our adult lives, the delay counter is counting down rather than up.

Every morning I look out toward the target star. Somewhere along that vector of golden light, your ship is burning its deceleration thrusters. We will meet on the new world, my love, and the silence of ten light-years will finally end.''',
        wordCount: 225,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 3)),
        publishedAt: now.subtract(const Duration(days: 3)),
      ),

      // ------------------------------------------------------------------------
      // Beneath the Glass City (Mystery - 3 Chapters)
      // ------------------------------------------------------------------------
      Chapter(
        id: 'demo_glass_ch_001',
        novelId: 'demo_novel_glass_city',
        authorId: 'author_naomi_reed',
        title: 'The Sunless Canals',
        chapterNumber: 1,
        content: '''The citizens of Aethelgard walked upon streets of spun borosilicate glass, watching the sunlight refract into rainbow prisms across their gilded carriages. They never looked down at their feet.

If they had looked, they would have seen Silas Vance navigating his flat-bottomed punt through the black subterranean canals twelve fathoms below the pavement.

As a canal scout of the Third Water Guild, Silas's duty was to inspect the massive hydraulic pillars that supported the city’s crystal foundations. But today, the brackish water was glowing with an unnatural bioluminescent amber, and the stone pilings were vibrating with the force of an earthquake that never reached the surface.''',
        wordCount: 230,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 30)),
        publishedAt: now.subtract(const Duration(days: 30)),
      ),
      Chapter(
        id: 'demo_glass_ch_002',
        novelId: 'demo_novel_glass_city',
        authorId: 'author_naomi_reed',
        title: 'The Crack in the Cathedral',
        chapterNumber: 2,
        content: '''At the intersection of Canal Seven and the Grand Siphon, directly beneath the High Cathedral of St. Lys, Silas found the fracture.

It was not a structural crack caused by shifting soil. The glass foundation had been sliced through with surgical precision by a tool that melted crystal like tallow.

Floating inside the fissure was a brass cylinder bearing the seal of the Grand Inquisitor.

When Silas pried the cylinder open, he found a ledger detailing three hundred years of political dissidents who had supposedly "emigrated to the New World." They had never left Aethelgard; their bodies had been incorporated into the hydraulic slurry that kept the glass spires aloft.''',
        wordCount: 235,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 18)),
        publishedAt: now.subtract(const Duration(days: 18)),
      ),
      Chapter(
        id: 'demo_glass_ch_003',
        novelId: 'demo_novel_glass_city',
        authorId: 'author_naomi_reed',
        title: 'When the Foundation Trembles',
        chapterNumber: 3,
        content: '''Silas pole-vaulted onto the maintenance catwalk as the sound of armed steam-launches echoed through the canal tunnel. The Inquisitor’s guards had caught his scent.

With the ledger tucked beneath his oilskin jacket, Silas ran toward the freight lift that led to the city square above.

Behind him, the amber light in the canal surged like a rising tide. The glass city was about to learn that its beauty was built upon bones, and the sun was setting on Aethelgard’s golden age.''',
        wordCount: 215,
        status: ChapterStatus.published,
        createdAt: now.subtract(const Duration(days: 5)),
        publishedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<ChapterComment> getDemoComments(DateTime now) {
    return [
      ChapterComment(
        id: 'demo_comment_echoes_1',
        userId: 'demo_reader_clara',
        userName: 'Clara Winters',
        novelId: 'demo_novel_echoes_gate',
        chapterId: 'demo_echoes_ch_001',
        content: 'The atmosphere in this chapter is superb! The imagery of the glowing stone archway and the harmonic chime gave me chills.',
        createdAt: now.subtract(const Duration(days: 38)),
      ),
      ChapterComment(
        id: 'demo_comment_echoes_2',
        userId: 'demo_reader_tuan',
        userName: 'Minh Tuấn',
        novelId: 'demo_novel_echoes_gate',
        chapterId: 'demo_echoes_ch_002',
        content: 'I did not expect that ending with the masked warden on the marble stairs. Scribe Otheus is such an intriguing character!',
        createdAt: now.subtract(const Duration(days: 32)),
      ),
      ChapterComment(
        id: 'demo_comment_midnight_1',
        userId: 'demo_reader_alex',
        userName: 'Alex Mercer',
        novelId: 'demo_novel_midnight_hollow',
        chapterId: 'demo_midnight_ch_001',
        content: 'A detective who hears the auditory echoes of past crimes is an incredible premise. The noir atmosphere feels so tangible.',
        createdAt: now.subtract(const Duration(days: 28)),
      ),
      ChapterComment(
        id: 'demo_comment_orbit_1',
        userId: 'demo_reader_sam',
        userName: 'Samantha Lee',
        novelId: 'demo_novel_orbit_silence',
        chapterId: 'demo_orbit_ch_001',
        content: 'Classic hard sci-fi suspense done right. The silence of deep space around Saturn feels palpably terrifying and wondrous.',
        createdAt: now.subtract(const Duration(days: 22)),
      ),
      ChapterComment(
        id: 'demo_comment_letter_1',
        userId: 'demo_reader_sophie',
        userName: 'Sophie Dubois',
        novelId: 'demo_novel_last_letter',
        chapterId: 'demo_letter_ch_001',
        content: 'The setting in 1912 Saint-Moritz with eighty clocks ticking in unison is so poetic. Beautiful prose.',
        createdAt: now.subtract(const Duration(days: 50)),
      ),
    ];
  }
}

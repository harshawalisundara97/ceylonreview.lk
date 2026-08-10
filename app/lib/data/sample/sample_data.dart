import '../../domain/models/category.dart';
import '../../domain/models/place.dart';
import '../../domain/models/review.dart';

/// Realistic sample content. Per the design system: always real Sri Lankan
/// places, never Lorem Ipsum. Most image URLs are direct third-party links
/// (hotel/attraction sites, TripAdvisor, Facebook) chosen for the specific
/// place; a handful still use freely-licensed Wikimedia Commons photos where
/// no better direct source was available. Some direct links may break or
/// stop loading if the source site changes/removes the asset.
abstract final class SampleData {
  static const _images = <String, String>{
    'ministry-of-crab':
        'https://i0.wp.com/seeingtheworldinsteps.com/wp-content/uploads/2025/08/img_9845.jpg?ssl=1',
    'nuga-gama':
        'https://upload.wikimedia.org/wikipedia/commons/6/6f/Sri_Lankan_Rice_and_Curry.jpg',
    'beach-wadiya':
        'https://lookaside.fbsbx.com/lookaside/crawler/media/?media_id=508303821298563',
    'mirissa-beach':
        'https://ceylonroute.com/images/blog/mirissa-beach.jpg',
    'unawatuna-beach':
        'https://miradasnomadas.com/wp-content/uploads/2024/03/sunset-rock-unawatuna.jpg',
    'hiriketiya-beach':
        'https://whysrilanka.com/wp-content/uploads/2023/03/hiriketiya-beach-srilanka.jpg',
    'arugam-bay':
        'https://lookaside.fbsbx.com/lookaside/crawler/media/?media_id=1272613958200406',
    'heritance-kandalama':
        'https://upload.wikimedia.org/wikipedia/commons/c/ca/Heritance_Kandalama_Exterior_View.JPG',
    'cinnamon-grand':
        'https://ik.imgkit.net/3vlqs5axxjf/external/http://images.ntmllc.com/v4/hotel/H08/H08326/H08326_EXT_Z7AC17.JPG?tr=w-1200,fo-auto',
    'tri-hotel':
        'https://images.mrandmrssmith.com/images/767x288/6796391-tri-galle-sri-lanka.jpg',
    'temple-of-the-tooth':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/SL_Kandy_asv2020-01_img33_Sacred_Tooth_Temple.jpg/1280px-SL_Kandy_asv2020-01_img33_Sacred_Tooth_Temple.jpg',
    'dambulla-cave-temple':
        'https://upload.wikimedia.org/wikipedia/commons/6/6a/Dhambulla_Cave_Interior.JPG',
    'kelaniya-temple':
        'https://media-cdn.tripadvisor.com/media/attractions-splice-spp-674x446/09/36/fa/1c.jpg',
    'sinharaja-forest':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/20160128_Sri_Lanka_4132_Sinharaja_Forest_Preserve_sRGB_%2825674474901%29.jpg/1280px-20160128_Sri_Lanka_4132_Sinharaja_Forest_Preserve_sRGB_%2825674474901%29.jpg',
    'horton-plains':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Sri_Lanka%2C_World%27s_End_at_Horton_Plains.jpg/1280px-Sri_Lanka%2C_World%27s_End_at_Horton_Plains.jpg',
    'ravana-falls':
        'https://ellatours.com/wp-content/uploads/2017/01/E_pmsIxWEAIMVpx-1.jpg',
    'odel':
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/11/02/c6/f1/1507037291077-largejpg.jpg?w=1200&h=-1&s=1',
    'dutch-hospital':
        'https://r.profitroom.pl/fairwaycolombo/images/attractions/thumbs/1920x900/1753084682.57072-1%20(1).jpg?updated=2026-01-09_11-20',
    'pettah-market':
        'https://nynehotels.com/lake-lodge/wp-content/uploads/sites/2/2025/02/Pettah-Market-1200x630-1.jpg',
  };

  static String _img(String id) => _images[id]!;

  static final places = <Place>[
    // ---- Food ----
    Place(
      id: 'ministry-of-crab',
      name: 'Ministry of Crab',
      category: PlaceCategory.food,
      district: 'Colombo',
      latitude: 6.9355,
      longitude: 79.8424,
      rating: 4.8,
      reviewCount: 2300,
      description:
          'World-famous crab restaurant inside the historic Dutch Hospital, '
          'celebrating Sri Lankan lagoon crab at its freshest.',
      imageUrl: _img('ministry-of-crab'),
      trending: true,
    ),
    Place(
      id: 'nuga-gama',
      name: 'Nuga Gama',
      category: PlaceCategory.food,
      district: 'Colombo',
      latitude: 6.9171,
      longitude: 79.8487,
      rating: 4.6,
      reviewCount: 870,
      description:
          'A traditional Sri Lankan village recreated under a giant banyan '
          'tree, serving authentic village-style rice and curry.',
      imageUrl: _img('nuga-gama'),
    ),
    Place(
      id: 'beach-wadiya',
      name: 'Beach Wadiya',
      category: PlaceCategory.food,
      district: 'Colombo',
      latitude: 6.8830,
      longitude: 79.8553,
      rating: 4.4,
      reviewCount: 650,
      description:
          'Legendary seafood shack on Wellawatte beach — toes in the sand, '
          'fresh prawns and devilled fish on the table.',
      imageUrl: _img('beach-wadiya'),
    ),
    // ---- Beaches ----
    Place(
      id: 'mirissa-beach',
      name: 'Mirissa Beach',
      category: PlaceCategory.beach,
      district: 'Matara',
      latitude: 5.9440,
      longitude: 80.4586,
      rating: 4.7,
      reviewCount: 3100,
      description:
          'Crescent golden bay famous for whale watching, Coconut Tree Hill '
          'sunsets and a laid-back surf scene.',
      imageUrl: _img('mirissa-beach'),
      trending: true,
    ),
    Place(
      id: 'unawatuna-beach',
      name: 'Unawatuna Beach',
      category: PlaceCategory.beach,
      district: 'Galle',
      latitude: 6.0098,
      longitude: 80.2492,
      rating: 4.5,
      reviewCount: 2700,
      description:
          'Sheltered turquoise bay minutes from Galle Fort, ideal for '
          'swimming year-round, with the Japanese Peace Pagoda nearby.',
      imageUrl: _img('unawatuna-beach'),
    ),
    Place(
      id: 'hiriketiya-beach',
      name: 'Hiriketiya Beach',
      category: PlaceCategory.beach,
      district: 'Matara',
      latitude: 5.9633,
      longitude: 80.7044,
      rating: 4.6,
      reviewCount: 980,
      description:
          'Horseshoe jungle cove beloved by surfers — mellow waves, '
          'smoothie bowls and palm-fringed calm.',
      imageUrl: _img('hiriketiya-beach'),
      trending: true,
    ),
    Place(
      id: 'arugam-bay',
      name: 'Arugam Bay',
      category: PlaceCategory.beach,
      district: 'Ampara',
      latitude: 6.8390,
      longitude: 81.8344,
      rating: 4.7,
      reviewCount: 1900,
      description:
          'World-class surf point on the east coast with a long golden '
          'beach and an easy-going traveller town.',
      imageUrl: _img('arugam-bay'),
    ),
    // ---- Hotels ----
    Place(
      id: 'heritance-kandalama',
      name: 'Heritance Kandalama',
      category: PlaceCategory.hotels,
      district: 'Matale',
      latitude: 7.8742,
      longitude: 80.7041,
      rating: 4.8,
      reviewCount: 1400,
      description:
          'Geoffrey Bawa masterpiece built into a cliff face, overlooking '
          'the Kandalama reservoir and Sigiriya rock.',
      imageUrl: _img('heritance-kandalama'),
      trending: true,
    ),
    Place(
      id: 'cinnamon-grand',
      name: 'Cinnamon Grand Colombo',
      category: PlaceCategory.hotels,
      district: 'Colombo',
      latitude: 6.9176,
      longitude: 79.8486,
      rating: 4.6,
      reviewCount: 2100,
      description:
          'Grand city hotel in the heart of Colombo with more than ten '
          'restaurants, lush gardens and warm island hospitality.',
      imageUrl: _img('cinnamon-grand'),
    ),
    Place(
      id: 'tri-hotel',
      name: 'Tri Lake Lodge',
      category: PlaceCategory.hotels,
      district: 'Galle',
      latitude: 6.0463,
      longitude: 80.1862,
      rating: 4.7,
      reviewCount: 320,
      description:
          'Sustainable boutique lodge spiralling around Koggala Lake — '
          'living roofs, lake views and serene design.',
      imageUrl: _img('tri-hotel'),
    ),
    // ---- Temples ----
    Place(
      id: 'temple-of-the-tooth',
      name: 'Temple of the Tooth Relic',
      category: PlaceCategory.temples,
      district: 'Kandy',
      latitude: 7.2936,
      longitude: 80.6413,
      rating: 4.9,
      reviewCount: 5200,
      description:
          'Sri Lanka\'s most sacred Buddhist temple, home of the Sacred '
          'Tooth Relic, beside Kandy Lake in the royal palace complex.',
      imageUrl: _img('temple-of-the-tooth'),
      trending: true,
    ),
    Place(
      id: 'dambulla-cave-temple',
      name: 'Dambulla Cave Temple',
      category: PlaceCategory.temples,
      district: 'Matale',
      latitude: 7.8567,
      longitude: 80.6492,
      rating: 4.8,
      reviewCount: 2900,
      description:
          'Five painted rock caves with more than 150 Buddha statues — a '
          'UNESCO World Heritage site over 2,000 years old.',
      imageUrl: _img('dambulla-cave-temple'),
    ),
    Place(
      id: 'kelaniya-temple',
      name: 'Kelaniya Raja Maha Vihara',
      category: PlaceCategory.temples,
      district: 'Gampaha',
      latitude: 6.9553,
      longitude: 79.9216,
      rating: 4.7,
      reviewCount: 1100,
      description:
          'Ancient riverside temple renowned for its Solias Mendis murals '
          'and the vibrant Duruthu Perahera each January.',
      imageUrl: _img('kelaniya-temple'),
    ),
    // ---- Nature ----
    Place(
      id: 'sinharaja-forest',
      name: 'Sinharaja Forest Reserve',
      category: PlaceCategory.nature,
      district: 'Ratnapura',
      latitude: 6.4068,
      longitude: 80.4992,
      rating: 4.8,
      reviewCount: 1600,
      description:
          'The island\'s last primary rainforest — endemic birds, misty '
          'trails and an unmatched chorus of wildlife.',
      imageUrl: _img('sinharaja-forest'),
      trending: true,
    ),
    Place(
      id: 'horton-plains',
      name: 'Horton Plains',
      category: PlaceCategory.nature,
      district: 'Nuwara Eliya',
      latitude: 6.8021,
      longitude: 80.8055,
      rating: 4.7,
      reviewCount: 2200,
      description:
          'Cloud-forest plateau ending at World\'s End — an 870 m sheer '
          'drop with views to the southern coast on clear mornings.',
      imageUrl: _img('horton-plains'),
    ),
    Place(
      id: 'ravana-falls',
      name: 'Ravana Falls',
      category: PlaceCategory.nature,
      district: 'Badulla',
      latitude: 6.8500,
      longitude: 81.0510,
      rating: 4.5,
      reviewCount: 1300,
      description:
          'Iconic 25 m cascade beside the Ella–Wellawaya road, tied to the '
          'legend of King Ravana and the Ramayana.',
      imageUrl: _img('ravana-falls'),
    ),
    // ---- Shopping ----
    Place(
      id: 'odel',
      name: 'Odel',
      category: PlaceCategory.shopping,
      district: 'Colombo',
      latitude: 6.9146,
      longitude: 79.8631,
      rating: 4.5,
      reviewCount: 1800,
      description:
          'Sri Lanka\'s iconic department store — fashion, homeware, books '
          'and souvenirs in a stylish colonial-era building.',
      imageUrl: _img('odel'),
    ),
    Place(
      id: 'dutch-hospital',
      name: 'Dutch Hospital Shopping Precinct',
      category: PlaceCategory.shopping,
      district: 'Colombo',
      latitude: 6.9344,
      longitude: 79.8428,
      rating: 4.6,
      reviewCount: 1500,
      description:
          'The oldest building in Colombo Fort, reborn as a courtyard of '
          'boutiques, cafés and restaurants.',
      imageUrl: _img('dutch-hospital'),
      trending: true,
    ),
    Place(
      id: 'pettah-market',
      name: 'Pettah Market',
      category: PlaceCategory.shopping,
      district: 'Colombo',
      latitude: 6.9396,
      longitude: 79.8529,
      rating: 4.3,
      reviewCount: 920,
      description:
          'A maze of bustling bazaar streets — spices, textiles, '
          'electronics and the energy of old Colombo trade.',
      imageUrl: _img('pettah-market'),
    ),
  ];

  static final reviews = <Review>[
    Review(
      id: 'r1',
      placeId: 'ministry-of-crab',
      authorId: 'sample-user',
      authorName: 'Nadeesha Perera',
      rating: 5,
      text:
          'We had the garlic chilli crab and it was unforgettable. Worth '
          'booking weeks ahead!',
      createdAt: DateTime(2026, 5, 18),
    ),
    Review(
      id: 'r2',
      placeId: 'ministry-of-crab',
      authorId: 'sample-user',
      authorName: 'Tom Whitfield',
      rating: 4,
      text:
          'I visited on a Friday night — superb food, slightly long wait '
          'between courses, but the crab liver pâté alone justifies the trip.',
      createdAt: DateTime(2026, 4, 2),
    ),
    Review(
      id: 'r3',
      placeId: 'mirissa-beach',
      authorId: 'sample-user',
      authorName: 'Ishara Fernando',
      rating: 5,
      text:
          'We watched blue whales in the morning and the sunset from '
          'Coconut Tree Hill in the evening. Perfect day.',
      createdAt: DateTime(2026, 3, 11),
    ),
    Review(
      id: 'r4',
      placeId: 'mirissa-beach',
      authorId: 'sample-user',
      authorName: 'Clara Jensen',
      rating: 4,
      text:
          'Beautiful bay and great food shacks. It gets busy in season — '
          'go early for a quiet swim.',
      createdAt: DateTime(2026, 2, 24),
    ),
    Review(
      id: 'r5',
      placeId: 'temple-of-the-tooth',
      authorId: 'sample-user',
      authorName: 'Ruwan Jayasuriya',
      rating: 5,
      text:
          'The evening puja is deeply moving. Dress modestly and allow at '
          'least two hours to take it all in.',
      createdAt: DateTime(2026, 5, 30),
    ),
    Review(
      id: 'r6',
      placeId: 'heritance-kandalama',
      authorId: 'sample-user',
      authorName: 'Amaya Wickramasinghe',
      rating: 5,
      text:
          'We woke to monkeys outside the window and Sigiriya on the '
          'horizon. Bawa\'s architecture is pure magic.',
      createdAt: DateTime(2026, 1, 15),
    ),
    Review(
      id: 'r7',
      placeId: 'sinharaja-forest',
      authorId: 'sample-user',
      authorName: 'Daniel Okafor',
      rating: 5,
      text:
          'Our guide spotted a blue magpie within the first hour. Bring '
          'leech socks and a rain jacket — worth every step.',
      createdAt: DateTime(2026, 4, 19),
    ),
    Review(
      id: 'r8',
      placeId: 'odel',
      authorId: 'sample-user',
      authorName: 'Shanika de Silva',
      rating: 4,
      text:
          'My favourite spot for gifts before flying out. Lovely tea and '
          'linen sections, fair prices.',
      createdAt: DateTime(2026, 3, 5),
    ),
  ];
}

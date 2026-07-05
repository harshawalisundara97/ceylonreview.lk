import '../../domain/models/category.dart';
import '../../domain/models/place.dart';
import '../../domain/models/review.dart';

/// Realistic sample content. Per the design system: always real Sri Lankan
/// places, never Lorem Ipsum. Image URLs are real, freely-licensed photos
/// sourced from Wikimedia Commons (same set used to seed the live Supabase
/// `places.image_url` column).
abstract final class SampleData {
  // A handful of entries have no exact business photo on Commons, so they
  // use the closest well-known real-world subject instead (documented inline).
  static const _images = <String, String>{
    // Crab curry dish (no Commons photo of the restaurant itself).
    'ministry-of-crab':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Colombo_restaurant_visit_to_enjoy_crab_curry_-_Oct_2022.jpg/1280px-Colombo_restaurant_visit_to_enjoy_crab_curry_-_Oct_2022.jpg',
    'nuga-gama':
        'https://upload.wikimedia.org/wikipedia/commons/6/6f/Sri_Lankan_Rice_and_Curry.jpg',
    'beach-wadiya':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Wellawatte.jpg/1280px-Wellawatte.jpg',
    'mirissa-beach':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Mirissa-Plage_%283%29.jpg/1280px-Mirissa-Plage_%283%29.jpg',
    'unawatuna-beach':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Unawatuna.jpg/1280px-Unawatuna.jpg',
    'hiriketiya-beach':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Baydickwella.jpg/1280px-Baydickwella.jpg',
    'arugam-bay':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Beach_of_Arugam_Bay.jpg/1280px-Beach_of_Arugam_Bay.jpg',
    // Kandalama Reservoir (no Commons photo of the hotel building itself).
    'heritance-kandalama':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/KandalamaReservoir-June2008-2.jpg/1280px-KandalamaReservoir-June2008-2.jpg',
    'cinnamon-grand':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Cinnamon_Grand%2C_Colombo%2C_Reception.jpg/1280px-Cinnamon_Grand%2C_Colombo%2C_Reception.jpg',
    // Koggala Lake, which the lodge spirals around (no direct hotel photo).
    'tri-hotel':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Lake_Koggala.jpg/1280px-Lake_Koggala.jpg',
    'temple-of-the-tooth':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/SL_Kandy_asv2020-01_img33_Sacred_Tooth_Temple.jpg/1280px-SL_Kandy_asv2020-01_img33_Sacred_Tooth_Temple.jpg',
    'dambulla-cave-temple':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Dambulla-buddhastupa.jpg/1280px-Dambulla-buddhastupa.jpg',
    'kelaniya-temple':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Colombo._Kelaniya_Raja_Maha_Vihara_temple_%284%29.jpg/1280px-Colombo._Kelaniya_Raja_Maha_Vihara_temple_%284%29.jpg',
    'sinharaja-forest':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/20160128_Sri_Lanka_4132_Sinharaja_Forest_Preserve_sRGB_%2825674474901%29.jpg/1280px-20160128_Sri_Lanka_4132_Sinharaja_Forest_Preserve_sRGB_%2825674474901%29.jpg',
    'horton-plains':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Sri_Lanka%2C_World%27s_End_at_Horton_Plains.jpg/1280px-Sri_Lanka%2C_World%27s_End_at_Horton_Plains.jpg',
    'ravana-falls':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Ravana_Falls_%28Ella%29.jpg/1280px-Ravana_Falls_%28Ella%29.jpg',
    // A Colombo retail/shopping complex (no Commons photo of the Odel store).
    'odel':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/One_Galle_Face%2C_Colombo.jpg/1280px-One_Galle_Face%2C_Colombo.jpg',
    'dutch-hospital':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Dutch_Hospital.jpg/1280px-Dutch_Hospital.jpg',
    'pettah-market':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Colombo_02.jpg/1280px-Colombo_02.jpg',
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
      authorName: 'Shanika de Silva',
      rating: 4,
      text:
          'My favourite spot for gifts before flying out. Lovely tea and '
          'linen sections, fair prices.',
      createdAt: DateTime(2026, 3, 5),
    ),
  ];
}

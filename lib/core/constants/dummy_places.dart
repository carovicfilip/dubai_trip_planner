class DummyPlace {
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? openingHours;
  final String? location;
  final String? reviewSummary;

  const DummyPlace({
    this.name,
    this.description,
    this.imageUrl,
    this.openingHours,
    this.location,
    this.reviewSummary,
  });
}

const Map<String, List<DummyPlace>> dummyPlacesByCategory = {
  'must_see': [
    DummyPlace(
      name: 'Burj Khalifa',
      description:
          'The Burj Khalifa is an architectural masterpiece and the tallest building in the world, rising an incredible 828 meters above the heart of Dubai. Its sleek, tapering design draws inspiration from Islamic architecture, while its engineering represents the pinnacle of modern innovation. Visitors can explore its high-speed elevators, world-famous observation decks on levels 124, 125, and 148, and enjoy sweeping views that stretch across the city, the coastline, and the vast desert beyond. Surrounded by the Dubai Fountain and luxury attractions, the Burj Khalifa stands not only as a record-breaking structure but also as a symbol of Dubai\'s ambition, creativity, and futuristic vision.',
      imageUrl: 'assets/places_images/must_see_1.jpg',
      openingHours: 'Observation decks: hours vary by ticket and season',
      location: '1 Sheikh Mohammed bin Rashid Boulevard, Downtown',
      reviewSummary: '4.7 (171k reviews)',
    ),
    DummyPlace(
      name: 'Palm Jumeirah',
      description:
          'Palm Jumeirah is an iconic, man-made island shaped like a palm tree, symbolizing Dubai\'s creativity and engineering ambition. Built on reclaimed land, it stretches into the Arabian Gulf and is home to luxurious resorts, waterfront villas, and upscale dining and entertainment options. The island features landmarks like Atlantis, The Palm and scenic boardwalks that offer beautiful sea views. With its mix of relaxation, adventure, and world-class hospitality, Palm Jumeirah stands as one of Dubai\'s most impressive and recognizable destinations.',
      imageUrl: 'assets/places_images/must_see_2.jpg',
      location: 'Palm Jumeirah, Jumeirah',
      reviewSummary: '4.7 (7.2k reviews)',
    ),
    DummyPlace(
      name: 'The Dubai Fountain',
      imageUrl: 'assets/places_images/must_see_3.jpg',
      description:
          'The Dubai Fountain is the world\'s largest choreographed fountain system, set on the Burj Khalifa Lake in Downtown Dubai. Its powerful water jets shoot up to 140 meters high, moving in harmony with music and vibrant lights to create a captivating, must-see performance. Shows take place daily, transforming the waterfront into a mesmerizing spectacle that reflects beautifully against the backdrop of the Burj Khalifa. Whether viewed from the promenade, nearby restaurants, or an abra boat on the lake, the Dubai Fountain delivers an unforgettable experience.',
      openingHours: 'Shows daily: 1:00 PM & 1:30 PM (Fri: 2:00 PM & 2:30 PM), Evenings: every 30 min from 6:00 PM to 11:00 PM',
      reviewSummary: '4.8 (139k reviews)',
      location: 'Downtown Dubai',
    ),
    DummyPlace(
      name: 'Museum of the Future',
      imageUrl: 'assets/places_images/must_see_4.jpg',
      openingHours: 'Temporarily closed, Expected to reopen in Q1 2027',
      description:
          'The Museum of the Future is one of Dubai\'s most striking landmarks, known for its futuristic torus-shaped design covered in flowing Arabic calligraphy. More than just a museum, it serves as an immersive exploration of future possibilities in technology, sustainability, space, and human innovation. Inside, visitors experience interactive exhibits that blend science, imagination, and cutting-edge design, offering a glimpse into what the world could look like decades from now. The Museum of the Future stands as a symbol of progress and creativity, inspiring visitors to think boldly about tomorrow. The museum is temporarily closed while its next generation of exhibitions is prepared, and is expected to reopen in the first quarter of 2027.',
      reviewSummary: '4.4 (55k reviews)',
      location: 'Sheikh Zayed Road, Trade Centre 2',
    ),
    DummyPlace(
      name: 'The Dubai Frame',
      imageUrl: 'assets/places_images/must_see_5.jpg',
      openingHours: 'Daily: 8:00 AM - 9:00 PM',
      description:
          'The Dubai Frame is a striking architectural landmark designed to resemble a giant picture frame, symbolically connecting Dubai\'s past and future. Standing 150 meters tall in Zabeel Park, it offers two unique perspectives: one side overlooks the historic districts of Old Dubai, while the other showcases the modern skyline of Downtown. Inside, visitors walk through immersive galleries that highlight the city\'s transformation, and the sky deck features a glass-floored bridge with panoramic views. The Dubai Frame beautifully captures the story of Dubai\'s evolution in a single, iconic structure.',
      reviewSummary: '4.6 (74k reviews)',
      location: 'Zabeel Park, Gate 4, Al Kifaf',
    ),
    DummyPlace(
      name: 'Dubai Miracle Garden',
      imageUrl: 'assets/places_images/must_see_6.jpg',
      openingHours: 'Daily: 9:00 AM - 9:00 PM, Season: 8 Oct 2026 - 31 May 2027',
      description:
          'Dubai Miracle Garden is the world\'s largest natural flower garden, showcasing more than 200 million blooming flowers arranged in breathtaking shapes and vibrant patterns. Open seasonally, it features life-size floral sculptures, heart-shaped pathways, and record-breaking displays like the Emirates A380 covered entirely in flowers. The garden combines artistic creativity with natural beauty, offering a colorful, immersive escape perfect for photos, leisurely strolls, and family visits. It stands as one of Dubai\'s most enchanting outdoor attractions.',
      location: 'Al Barsha South 3',
      reviewSummary: '4.6 (95k reviews)',
    ),
    DummyPlace(
      name: 'Dubai Aquarium & Underwater Zoo',
      imageUrl: 'assets/places_images/must_see_7.jpg',
      openingHours: 'Mon-Thu: 11:00 AM - 9:00 PM, Fri-Sun: 10:00 AM - 9:00 PM',
      description:
          'Dubai Aquarium & Underwater Zoo is one of the city\'s most captivating attractions, located inside The Dubai Mall. It features one of the world\'s largest suspended aquariums, home to thousands of marine animals including sharks, rays, and vibrant fish species. Visitors can walk through the 48-meter tunnel for an immersive underwater experience or explore the Underwater Zoo above, which showcases unique creatures like otters, crocodiles, penguins, and jellyfish. With interactive exhibits and thrilling experiences such as cage snorkeling and shark dives, the Dubai Aquarium & Underwater Zoo offers a fascinating journey into the marine world for all ages.',
      reviewSummary: '4.5 (80k reviews)',
      location: 'Ground & Level 2, The Dubai Mall, 1 Sheikh Mohammed bin Rashid Boulevard',
    ),
    DummyPlace(
      name: 'Al Fahidi Historical Neighbourhood',
      imageUrl: 'assets/places_images/must_see_8.jpg',
      openingHours: 'Daily: 7:00 AM - 8:00 PM',
      description:
          'Al Fahidi Historical Neighbourhood, also known as Al Bastakiya, is one of Dubai\'s oldest and most culturally rich districts. Its narrow alleyways, traditional wind-tower houses, and beautifully restored courtyards offer a glimpse into life in Dubai before the modern skyscrapers. The area is filled with art galleries, museums, cafés, and cultural centers like the Sheikh Mohammed Centre for Cultural Understanding, making it a peaceful and authentic place to explore. Walking through Al Fahidi feels like stepping back in time, showcasing the emirate\'s heritage, craftsmanship, and enduring traditions.',
      location: 'Al Souq Al Kabeer, Al Fahidi',
      reviewSummary: '4.6 (17k reviews)',
    ),
    DummyPlace(
      name: 'Dubai Mall',
      imageUrl: 'assets/places_images/must_see_9.webp',
      openingHours: 'Mon-Thu 10:00 AM - 11:00 PM, Fri-Sun 10:00 AM - 12:00 AM',
      description:
          'Dubai Mall is one of the world\'s largest shopping and entertainment destinations, home to more than 1,200 stores. It also houses major attractions like Dubai Aquarium, PLAY DXB, and an Olympic-sized ice rink. Located next to Burj Khalifa, it attracts millions of visitors each year.',
      reviewSummary: '4.7 (289k reviews)',
      location: 'Downtown, Sheikh Mohammed bin Rashid Boulevard',
    ),
  ],
  'restaurants': [
    DummyPlace(
      name: 'Trèsind Studio',
      imageUrl: 'assets/places_images/restaurants_1.png',
      openingHours: 'Mon-Sat: 6:00 PM - 11:00 PM',
      description:
          'Trèsind Studio is a three-Michelin-star fine-dining restaurant in Dubai, renowned for its intimate setting and innovative approach to modern Indian cuisine. Led by Chef Himanshu Saini, it offers a multi-course tasting menu that blends traditional flavors with bold, contemporary techniques, creating a culinary journey that feels both artistic and deeply personal. With only a limited number of seats, the experience is highly immersive, allowing guests to engage with the chefs and enjoy beautifully plated dishes that highlight creativity, storytelling, and exceptional craftsmanship. Trèsind Studio stands among Dubai\'s most prestigious gastronomic destinations.',
      reviewSummary: '4.7 (407 reviews)',
      location: 'St. Regis Gardens, The Palm Jumeirah',
    ),
    DummyPlace(
      name: 'FZN by Björn Frantzén',
      imageUrl: 'assets/places_images/restaurants_2.webp',
      openingHours: 'Tue-Sat: 7:00 PM - 11:00 PM',
      description:
          'FZN by Björn Frantzén is a three-Michelin-star dining experience in Dubai inspired by the culinary vision of acclaimed Swedish chef Björn Frantzén. Known for blending Nordic techniques with global influences, the restaurant offers an elegant, contemporary tasting menu that highlights precision, seasonal ingredients, and bold yet balanced flavors. The ambiance is refined and immersive, with meticulous attention to detail in both presentation and service. FZN delivers a sophisticated gastronomic journey that reflects Frantzén\'s signature style—innovative, expressive, and rooted in world-class culinary craft.',
      reviewSummary: '4.6 (95 reviews)',
      location: 'Atlantis The Palm, Crescent Road, The Palm Jumeirah',
    ),
    DummyPlace(
      name: 'Zuma',
      imageUrl: 'assets/places_images/restaurants_3.webp',
      openingHours: 'Daily: 12:00 PM - 2:00 AM',
      description:
          'Zuma Dubai is a globally acclaimed contemporary Japanese restaurant offering a stylish, high-energy dining experience in the heart of DIFC. Known for its izakaya-style sharing dishes, the menu features signature items like miso-marinated black cod, premium sushi, robata-grilled meats, and inventive small plates. The atmosphere blends modern luxury with a lively social vibe, making it a favorite for both business dinners and nights out. With exceptional service, sophisticated design, and consistently high culinary standards, Zuma remains one of Dubai\'s most iconic dining destinations.',
      reviewSummary: '4.4 (4.5k reviews)',
      location: 'Gate Village 06, Dubai International Financial Centre',
    ),
    DummyPlace(
      name: 'Il Ristorante – Niko Romito',
      imageUrl: 'assets/places_images/restaurants_4.webp',
      openingHours: 'Tue-Sat: 7:00 PM - 12:00 AM',
      description:
          'Il Ristorante – Niko Romito is a refined, two-Michelin-star Italian dining experience located at Bulgari Resort Dubai, crafted by the celebrated chef Niko Romito. The restaurant showcases a minimalist yet sophisticated approach to Italian cuisine, focusing on purity of flavor, precise techniques, and exceptional ingredients sourced from Italy. Its elegant interiors, serene marina views, and warm hospitality create a luxurious atmosphere. With beautifully balanced dishes that honor Italian tradition while embracing modern creativity, Il Ristorante offers one of Dubai\'s most exquisite and memorable fine-dining journeys.',
      reviewSummary: '3.9 (309 reviews)',
      location: 'Bvlgari Resort, Jumeirah Bay Island',
    ),
    DummyPlace(
        name: 'Ossiano',
        imageUrl: 'assets/places_images/restaurants_5.jpg',
        openingHours: 'Temporarily closed, Reopening date not announced',
        description:
            'Ossiano Dubai is an extraordinary underwater dining experience located in Atlantis, The Palm, offering a Michelin-starred journey inspired by the ocean. Set beside the magnificent Ambassador Lagoon, the restaurant surrounds guests with floor-to-ceiling views of marine life, creating a serene and immersive atmosphere. Led by acclaimed chefs, Ossiano presents an imaginative tasting menu that blends refined techniques with ocean-inspired flavors, telling a story through each beautifully crafted course. With its dramatic setting, exceptional service, and avant-garde cuisine, Ossiano stands as one of Dubai\'s most unique and unforgettable fine-dining destinations. The restaurant has been temporarily closed since April 2026, and its reopening date has not been announced.',
        reviewSummary: '4.5 (1.3k reviews)',
        location: 'Atlantis The Palm, Crescent Road, The Palm Jumeirah'),
    DummyPlace(
      name: 'Moonrise',
      imageUrl: 'assets/places_images/restaurants_6.webp',
      openingHours: 'Tue-Sat: seatings at 6:00 PM & 9:30 PM',
      description:
          'Moonrise is an intimate, Michelin-starred, chef-driven dining experience in Dubai known for its modern, Middle Eastern–inspired tasting menu. Set on a rooftop with an open-kitchen counter, it allows guests to watch the chefs prepare each course with precision and creativity. Led by Chef Solemann Haddad, Moonrise blends local flavors with international techniques, resulting in dishes that are imaginative yet deeply rooted in regional culture. With limited seating, a minimalist setting, and a focus on storytelling through food, Moonrise offers a unique and personal gastronomic journey unlike anywhere else in the city.',
      reviewSummary: '4.8 (354 reviews)',
      location: 'Eden House, Al Satwa',
    ),
    DummyPlace(
      name: 'CÉ LA VI',
      imageUrl: 'assets/places_images/restaurants_7.jpg',
      openingHours: 'Daily: 12:00 PM - 3:00 AM',
      description:
          'CÉ LA VI Dubai is a stylish rooftop dining and entertainment destination located atop Address Sky View, offering breathtaking views of the Burj Khalifa and the city skyline. Known for its modern Asian cuisine, the restaurant serves beautifully crafted dishes that blend bold flavors with elegant presentation. The venue features a chic indoor dining area, a lively lounge, and an outdoor terrace perfect for sunset cocktails and photo-worthy moments. With its vibrant atmosphere, refined dishes, and iconic Burj Khalifa backdrop, CÉ LA VI delivers a memorable, upscale Dubai experience.',
      reviewSummary: '4.6 (8.4k reviews)',
      location: 'Tower 2, Level 54, Address Sky View, Sheikh Mohammed bin Rashid Boulevard',
    ),
    DummyPlace(
      name: 'Arabian Tea House',
      imageUrl: 'assets/places_images/restaurants_8.jpg',
      openingHours: 'Daily: 7:00 AM - 11:00 PM',
      description:
          'Arabian Tea House is one of Old Dubai\'s best-loved cafés, welcoming guests in the Al Fahidi Historical Neighbourhood since 1997. Its charming courtyard is the place for a traditional Emirati breakfast, Karak tea, Arabic coffee, and dates cake, surrounded by the calm of the historic district. With its preserved design and warm hospitality, it offers one of the most authentic tastes of Emirati culture in the city.',
      reviewSummary: '4.8 (20k reviews)',
      location: 'Bastakiya, Al Fahidi Street, Bur Dubai',
    ),
    DummyPlace(
      name: 'At.mosphere',
      imageUrl: 'assets/places_images/restaurants_9.jpg',
      openingHours: 'Daily from 7:00 AM, Reservations recommended',
      description:
          'At.mosphere sits on Level 122 of the Burj Khalifa, about 442 meters above the ground, and is billed as the world\'s highest restaurant. Its restaurant and lounge serve everything from breakfast and afternoon tea to dinner and late-night drinks, all with sweeping views over Downtown Dubai. It is a favorite for special occasions, especially at sunset, when the city lights begin to glow far below.',
      reviewSummary: '4.5 (4.6k reviews)',
      location: 'Burj Khalifa, Level 122, Downtown Dubai',
    ),
    DummyPlace(
      name: 'Pai Thai',
      imageUrl: 'assets/places_images/restaurants_10.jpg',
      openingHours: 'Mon-Fri: 12:30 PM - 3:00 PM and 5:00 PM - 11:00 PM, Sat-Sun: 12:30 PM - 11:00 PM',
      description:
          'Pai Thai is a romantic, award-winning Thai restaurant at Jumeirah Al Qasr in Madinat Jumeirah, reached by a traditional abra along the resort\'s tranquil waterways. Its menu brings Thailand\'s vibrant culinary culture to life with bold flavors, aromatic spices, and refined presentation, while the arrival by boat makes every dinner feel like an occasion.',
      reviewSummary: '4.5 (2k reviews)',
      location: 'Jumeirah Al Qasr, Madinat Jumeirah, Al Sufouh 1',
    ),
    // DummyPlace(
    //   name: 'OCCO Restaurant Dubai',
    //   imageUrl: '',
    //   openingHours: 'Daily: 10:00 AM - 4:00 AM',
    //   description:
    //       'OCCO Restaurant Dubai is an elegant dining destination offering a modern interpretation of classic Mediterranean and Levantine cuisine. With its chic, dimly lit interiors and stylish ambience, the restaurant blends contemporary luxury with warm, inviting character. The menu features a refined selection of mezze, grilled specialties, and fresh, flavorful dishes crafted with high-quality ingredients. Known for its smooth service, sophisticated atmosphere, and vibrant evening energy, OCCO provides a memorable dining experience perfect for both intimate dinners and lively gatherings.',
    //   reviewSummary: '4.8 (1.6k reviews)',
    //   location: 'Hessa St - Al Barsha',
    // ),
  ],
  'nightlife': [
    DummyPlace(
        name: 'O Dubai - Lounge & Club',
        imageUrl: 'assets/places_images/nightlife_1.webp',
        openingHours: 'Daily: 8:00 PM - 4:00 AM',
        description:
            'O Dubai – Lounge & Club is a stylish nightlife spot combining upscale dining with high-energy club vibes. Known for its stunning city views, vibrant music, and luxurious atmosphere, it\'s a go-to destination for premium cocktails, live entertainment, and late-night parties.',
        reviewSummary: '4.8 (5.8k reviews)',
        location: 'voco Dubai, 50th Floor, Sheikh Zayed Road'),
    DummyPlace(
      name: 'Soho Garden DXB',
      imageUrl: 'assets/places_images/nightlife_2.webp',
      openingHours: 'Thu-Sun: 10:00 PM - 4:00 AM',
      description:
          'Soho Garden combines restaurants, lounges, clubs, and outdoor spaces into one nightlife complex. It hosts international DJs and themed parties across club rooms such as CODE, Playroom, and Black. The venue blends European garden aesthetics with Dubai nightlife energy.',
      reviewSummary: '4.1 (4.1k reviews)',
      location: 'Racecourse, Grand Stand - Al Meydan Rd - Nad Al Sheba 1',
    ),
    DummyPlace(
      name: 'BLU Dubai',
      imageUrl: 'assets/places_images/nightlife_3.jpeg',
      openingHours: 'Daily: 10:00 PM - 4:00 AM',
      description:
          'BLU is a rooftop lounge and nightclub offering panoramic views of Sheikh Zayed Road. It hosts international artists, themed nights, and high-energy music events. Its elevated location makes it a standout late-night venue.',
      reviewSummary: '4 (1.6k reviews)',
      location: 'V Hotel Dubai, Al Habtoor City - 260 Sheikh Zayed Rd - Business Bay',
    ),
    DummyPlace(
      name: 'Secret Room Dubai',
      imageUrl: 'assets/places_images/nightlife_4.jpg',
      openingHours: 'Reported temporarily closed (October 2026), Regular hours: Wed-Sat 11:00 PM - 4:00 AM',
      description:
          'Secret Room is an exclusive hip-hop-focused nightclub known for its luxury automotive entrance concept. The interior features graffiti-style decor and high-end bottle service. It attracts a trendy crowd and international DJs. It was reported as temporarily closed in October 2026, so confirm before visiting.',
      reviewSummary: '4.4 (238 reviews)',
      location: 'Downtown Dubai',
    ),
    DummyPlace(
      name: 'The Penthouse Dubai',
      imageUrl: 'assets/places_images/nightlife_5.webp',
      openingHours: 'Daily: 5:00 PM - 4:00 AM',
      description:
          'The Penthouse Dubai – Rooftop Lounge & Nightclub at FIVE Palm Jumeirah offers a glamorous rooftop experience with panoramic skyline views. Known for its stylish décor, lively nightlife, and world-class DJs, it blends upscale dining, signature cocktails, and vibrant parties in a chic, adults-only setting.',
      reviewSummary: '4.6 (4.1k reviews)',
      location: 'No 1 Palm Jumeirah',
    ),
  ],
  'beaches_pools': [
    DummyPlace(
        name: 'Barasti Beach',
        imageUrl: 'assets/places_images/beaches_pools_1.jpg',
        openingHours: 'Temporarily closed for redevelopment, Expected to reopen in 2027',
        description:
            'Barasti Beach is a lively beach bar known for its relaxed tropical vibe, beachfront views, and upbeat atmosphere. Offering great music, casual dining, and day-to-night entertainment, it\'s a popular spot for sunbathing, sports screenings, and energetic weekend parties right on the sand. The venue closed for redevelopment on 21 June 2026 and is expected to reopen in 2027.',
        reviewSummary: '4.3 (15k reviews)',
        location: 'Le Méridien Mina Seyahi Beach Resort & Marina'),
    DummyPlace(
        name: 'Nikki Beach Dubai',
        imageUrl: 'assets/places_images/beaches_pools_2.webp',
        openingHours: 'Tuesday - Sunday 11:00 AM - 7:00 PM',
        description:
            'Nikki Beach Dubai – Beach Club & Restaurant delivers a chic, contemporary beachfront experience with signature white décor, live music, and a stylish crowd. Known for its luxury cabanas, gourmet cuisine, and upbeat poolside parties, it offers a perfect blend of relaxation and vibrant beachside entertainment.',
        reviewSummary: '4.4 (2.1k reviews)',
        location: 'Nikki Beach Dubai, Pearl - Jumeirah'),
    DummyPlace(
      name: 'Beach by FIVE | FIVE Palm Jumeirah',
      imageUrl: 'assets/places_images/beaches_pools_3.webp',
      openingHours: 'Daily: 9:00 AM - Sunset',
      description:
          'Beach by FIVE – FIVE Palm Jumeirah Dubai is a vibrant beach club offering a blend of luxury lounging and energetic party vibes. With its private beach, stylish sunbeds, gourmet bites, and live DJ sets, it\'s known for hosting some of the city\'s most lively daytime and sunset events in a glamorous beachfront setting.',
      reviewSummary: '4.8 (2.4k reviews)',
      location: 'No 1 Palm Jumeirah',
    ),
    DummyPlace(
      name: 'February 30',
      imageUrl: 'assets/places_images/beaches_pools_4.webp',
      openingHours: 'Monday–Thursday 12:00–02:00, Friday–Saturday 10:00–03:00, Sunday 10:00–02:00',
      description:
          'February 30 Dubai is a trendy beach bar and restaurant on Palm West Beach, known for its contemporary design, upbeat music, and stylish seaside atmosphere. Offering creative cocktails, international dishes, and a lively day-to-night vibe, it\'s a popular spot for beachfront dining and social lounging.',
      reviewSummary: '4.6 (5.1k reviews)',
      location: 'West beach Palm - Jumeirah',
    ),
    DummyPlace(
      name: 'Bla Bla Dubai',
      imageUrl: 'assets/places_images/beaches_pools_5.webp',
      openingHours: 'Sun-Thu: 9:00 AM - 2:00 AM, Fri-Sat: 9:00 AM - 3:00 AM',
      description:
          'Bla Bla Dubai, also known as Bla Bla by McGettigan\'s, is a dynamic beachside venue on JBR featuring multiple bars, lounges, and dining concepts all in one place. Known for its lively atmosphere, beachfront views, and diverse entertainment, it offers everything from casual daytime chilling to vibrant nightlife with DJ sets and rooftop vibes.',
      reviewSummary: '4.3 (8.4k reviews)',
      location: 'The Beach, JBR - 5101 Messer Street - Marsa Dubai - Jumeirah Beach Residence',
    ),
    DummyPlace(
      name: 'Kite Beach',
      imageUrl: 'assets/places_images/beaches_pools_6.jpg',
      description:
          'Kite Beach is one of Dubai\'s most popular public beaches, with free entry and clear views of the Burj Al Arab. Known for its kitesurfing, it also offers a 14-km jogging and cycling track, free volleyball courts, an outdoor gym, and a lively mix of food trucks and cafés, making it a favorite for both active days and relaxed sunsets.',
      reviewSummary: '4.6 (23k reviews)',
      location: 'Umm Suqeim - Jumeirah',
    ),
    DummyPlace(
      name: 'Nobu by the Beach',
      imageUrl: 'assets/places_images/beaches_pools_7.jpg',
      openingHours: 'Pool: daily 10:00 AM - 7:00 PM, Restaurant: daily 12:00 PM - 10:00 PM, Bar: daily 12:00 PM - 11:00 PM',
      description:
          'Nobu by the Beach is the first pool and beach club from the celebrated Japanese brand, set at Atlantis The Royal on Palm Jumeirah. Known for its infinity pool, private daybeds, and cabanas, it pairs a relaxed, chilled-music atmosphere with Nobu\'s signature dishes right by the sea. The pool area is for guests aged 21 and over.',
      reviewSummary: '4.3 (838 reviews)',
      location: 'Atlantis The Royal, Crescent Road, The Palm Jumeirah',
    ),
    DummyPlace(
      name: 'Summersalt Beach Club',
      imageUrl: 'assets/places_images/beaches_pools_8.jpg',
      openingHours: 'Beach club: daily 9:00 AM - Sunset, Restaurant: daily 12:30 PM - 12:00 AM',
      description:
          'Summersalt Beach Club is a stylish beachfront spot at Jumeirah Al Naseem, with the Burj Al Arab right in view. Guests spend the day between its private beach and pool, with DJs setting the mood and a Latin American-inspired menu served from lunch until late.',
      reviewSummary: '4.4 (1.4k reviews)',
      location: 'Jumeirah Al Naseem, Madinat Jumeirah, Umm Suqeim 3',
    ),
  ],
  'culture_museums': [
    DummyPlace(
      name: 'Al Fahidi Historical Neighbourhood',
      imageUrl: 'assets/places_images/culture_museums_1.webp',
      openingHours: 'Daily: 7:00 AM - 8:00 PM',
      reviewSummary: '4.6 (17k reviews)',
      description:
          'Al Fahidi Historical Neighbourhood, often called Al Bastakiya, is one of Dubai\'s most atmospheric and culturally significant districts. Characterized by its narrow lanes, traditional wind-tower architecture, and restored courtyard homes, it offers a rare look into Dubai\'s life before the modern skyline emerged. The neighborhood is filled with museums, art galleries, cafés, and cultural centers like the Sheikh Mohammed Centre for Cultural Understanding, where visitors can learn about Emirati traditions firsthand. With its peaceful ambiance, sandy pathways, and heritage-rich buildings, Al Fahidi provides a meaningful journey into the city\'s past and remains a must-visit destination for history, culture, and art enthusiasts.',
      location: 'Al Souq Al Kabeer - Al Fahidi',
    ),
    DummyPlace(
      name: 'Etihad Museum',
      imageUrl: 'assets/places_images/culture_museums_2.jpeg',
      openingHours: 'Daily: 10:00 AM - 8:00 PM',
      description:
          'The Etihad Museum is a modern, beautifully designed cultural landmark in Dubai that tells the story of the UAE\'s formation and national identity. Located at the historic site where the Union Agreement was signed in 1971, the museum features interactive exhibits, archival photos, films, and artifacts that bring the country\'s unification journey to life. Its sleek, contemporary architecture—shaped like a manuscript—symbolizes the signing of the constitution. With immersive galleries and thoughtfully curated displays, the Etihad Museum offers a rich and engaging look into the UAE\'s political history, heritage, and visionary leadership.',
      reviewSummary: '4.6 (3.3k reviews)',
      location: '1 Jumeira St - Jumeirah 1',
    ),
    DummyPlace(
      name: 'Dubai Opera',
      imageUrl: 'assets/places_images/culture_museums_3.jpg',
      description:
          'Dubai Opera is a world-class performing arts venue located in Downtown Dubai, known for its striking dhow-inspired architecture and dynamic cultural programming. The venue hosts a diverse lineup of performances, including opera, ballet, concerts, theater, comedy, and family shows. Inside, the flexible auditorium can transform from a traditional theater to a concert hall or flat-floor event space, offering exceptional acoustics and an intimate viewing experience. With its stunning location near the Burj Khalifa and Dubai Fountain, Dubai Opera serves as a vibrant cultural hub, bringing global artistry and entertainment to the heart of the city.',
      reviewSummary: '4.7 (9.9k reviews)',
      location: 'Sheikh Mohammed bin Rashid Blvd - Burj Khalifa',
    ),
    DummyPlace(
      name: 'Museum of the Future',
      imageUrl: 'assets/places_images/culture_museums_4.jpg',
      openingHours: 'Temporarily closed, Expected to reopen in Q1 2027',
      description:
          'The Museum of the Future is one of Dubai\'s most striking landmarks, known for its futuristic torus-shaped design covered in flowing Arabic calligraphy. More than just a museum, it serves as an immersive exploration of future possibilities in technology, sustainability, space, and human innovation. Inside, visitors experience interactive exhibits that blend science, imagination, and cutting-edge design, offering a glimpse into what the world could look like decades from now. The Museum of the Future stands as a symbol of progress and creativity, inspiring visitors to think boldly about tomorrow. The museum is temporarily closed while its next generation of exhibitions is prepared, and is expected to reopen in the first quarter of 2027.',
      reviewSummary: '4.4 (55k reviews)',
      location: 'Sheikh Zayed Road, Trade Centre 2',
    ),
    DummyPlace(
      name: 'Jumeirah Mosque',
      imageUrl: 'assets/places_images/culture_museums_5.jpg',
      openingHours: 'Guided visits: Sat-Thu at 10:00 AM & 2:00 PM',
      description:
          'Jumeirah Mosque is one of Dubai\'s most loved landmarks and one of the few mosques in the city open to non-Muslim visitors. Opened in 1979 and built in a blend of historical Islamic styles, including Fatimid and Mamluk, it is known for its elegant dome and twin minarets. Guided visits run by the Sheikh Mohammed bin Rashid Al Maktoum Centre for Cultural Understanding explain Islamic traditions and Emirati culture, and include light Emirati refreshments. No prior booking is needed, and modest dress is requested, with traditional clothing available on site.',
      reviewSummary: '4.6 (7.5k reviews)',
      location: 'Jumeirah Beach Road, Jumeirah 1',
    ),
  ],
  'shopping': [
    DummyPlace(
      name: 'Dubai Mall',
      imageUrl: 'assets/places_images/shopping_1.webp',
      openingHours: 'Mon-Thu 10:00 AM - 11:00 PM, Fri-Sun 10:00 AM - 12:00 AM',
      description:
          'Dubai Mall is one of the world\'s largest shopping and entertainment destinations, home to more than 1,200 stores. It also houses major attractions like Dubai Aquarium, PLAY DXB, and an Olympic-sized ice rink. Located next to Burj Khalifa, it attracts millions of visitors each year.',
      reviewSummary: '4.7 (289k reviews)',
      location: 'Burj Khalifa - Downtown Dubai',
    ),
    DummyPlace(
      name: 'Mall of the Emirates',
      imageUrl: 'assets/places_images/shopping_2.webp',
      openingHours: 'Mon-Thu: 10:00 AM - 11:00 PM, Fri-Sun: 10:00 AM - 12:00 AM',
      description:
          'Mall of the Emirates is famous for Ski Dubai, the Middle East\'s first indoor ski resort. It offers luxury shopping, gourmet dining, and diverse entertainment options. The mall blends leisure and retail in an upscale environment.',
      reviewSummary: '4.7 (146k reviews)',
      location: 'Sheikh Zayed Rd - Al Barsha - Al Barsha 1',
    ),
    DummyPlace(
      name: 'City Walk',
      imageUrl: 'assets/places_images/shopping_3.jpeg',
      openingHours: 'Mon-Fri: 10:00 AM - 11:00 PM, Sat-Sun: 10:00 AM - 12:00 AM',
      description:
          'City Walk is an outdoor urban lifestyle destination featuring boutiques, cafés, street art, and entertainment venues. It blends European-style boulevards with modern Dubai design. The area is popular for evening strolls and family outings.',
      reviewSummary: '4.6 (36k reviews)',
      location: 'Al Safa St - Al Wasl',
    ),
    DummyPlace(
      name: 'Souk Madinat Jumeirah',
      imageUrl: 'assets/places_images/shopping_4.webp',
      openingHours: 'Daily: 10:00 AM - 11:00 PM',
      description:
          'Souk Madinat is a modern reinterpretation of a traditional Arabian marketplace. It features boutiques, waterfront dining, and picturesque canals with abra boats. The venue offers atmospheric views of Burj Al Arab.',
      reviewSummary: '4.5 (26k reviews)',
      location: 'King Salman Bin Abdulaziz Al Saud St - Al Sufouh 1',
    ),
    DummyPlace(
      name: 'Dubai Festival City Mall',
      imageUrl: 'assets/places_images/shopping_5.webp',
      openingHours: 'Monday–Thursday 10:00 AM - 10:00 PM, Friday–Sunday 10:00 AM – 12:00 AM',
      description:
          'Dubai Festival City Mall is a waterfront shopping destination known for the IMAGINE laser, fountain, and fire show. It offers a wide selection of retail brands and family attractions. The location along the creek adds scenic value to the experience.',
      reviewSummary: '4.6 (58k reviews)',
      location: 'Crescent Rd - Al Kheeran - Dubai Festival City',
    ),
    DummyPlace(
      name: 'Dubai Gold Souk',
      imageUrl: 'assets/places_images/shopping_6.jpg',
      openingHours: 'Hours vary by shop, Typically 10:00 AM - 10:00 PM, Many shops open later on Fridays',
      description:
          'Dubai Gold Souk is a traditional covered bazaar in Deira, home to more than 300 jewellery shops and recognized by its wooden entrance arch. Visitors can browse gold, gemstones, and precious metals, and bargaining is part of the experience. The nearby Spice Souk and abra crossing over Dubai Creek make it an easy stop for exploring old Dubai.',
      reviewSummary: '4.4 (10.7k reviews)',
      location: 'Al Ras - Deira',
    ),
  ],
  'desert_adventure': [
    DummyPlace(
      name: 'Skydive Dubai',
      imageUrl: 'assets/places_images/desert_adventure_1.jpg',
      openingHours: 'Palm Dropzone: Thu-Mon 7:00 AM - 11:00 AM, Desert Campus: Wed-Sun 7:00 AM - 2:00 PM',
      description:
          'Skydive Dubai offers tandem skydives that let you freefall at over 200 km/h from up to 13,000 feet, securely harnessed to an experienced instructor. You can jump over Palm Jumeirah and the city\'s iconic landmarks from the Palm Dropzone in Dubai Marina, or over the sandy dunes of the desert from the Desert Campus in Margham. Tandem jumps are open to ages 18 to 75, with weight and BMI limits, so check the requirements before you book.',
      reviewSummary: '4.7 (8.1k reviews)',
      location: 'Al Seyahi Street, Dubai Marina',
    ),
    DummyPlace(
      name: 'Hero Balloon Flights Dubai',
      imageUrl: 'assets/places_images/desert_adventure_2.webp',
      openingHours: 'Daily sunrise flights, Season: 1 Oct - 31 May',
      description:
          'Hero Balloon Flights Dubai offers a serene and magical hot air balloon experience over the Dubai Desert Conservation Reserve at sunrise. As you gently ascend, you\'re treated to panoramic views of rolling sand dunes, roaming wildlife, and the soft golden glow of the early morning sky. Guided by expert pilots, the flight is smooth, safe, and open to guests aged 7 and over, making it a memorable adventure for couples, families, and photographers alike. With its combination of breathtaking scenery and peaceful airborne moments, Hero Balloon Flights delivers one of Dubai\'s most unforgettable desert experiences.',
      reviewSummary: '4.5 (271 reviews)',
      location: 'Office: 1303 Control Tower, Motor City',
    ),
    DummyPlace(
      name: 'Ski Dubai',
      imageUrl: 'assets/places_images/desert_adventure_3.jpg',
      openingHours: 'Mon-Thu: 10:00 AM - 11:00 PM, Fri: 10:00 AM - 12:00 AM, Sat-Sun: 9:00 AM - 12:00 AM',
      description:
          'Ski Dubai is a unique indoor winter wonderland located inside Mall of the Emirates, offering a full snow and ski experience in the heart of the desert. The attraction features real snow, ski slopes for all skill levels, a snow park with slides and climbing areas, and even the chance to meet adorable penguins. Visitors can enjoy skiing, snowboarding, tobogganing, or simply playing in the snow—no matter the weather outside. With its immersive alpine atmosphere and fun activities for all ages, Ski Dubai delivers a refreshing escape and one of the city\'s most iconic family-friendly adventures.',
      reviewSummary: '4.5 (43k reviews)',
      location: 'Sheikh Zayed Rd - Al Barsha - Al Barsha 1',
    ),
    DummyPlace(
      name: 'Dubai Desert Conservation Reserve',
      imageUrl: 'assets/places_images/desert_adventure_4.jpg',
      openingHours: 'Access with licensed safari operators only',
      description:
          'Dubai Desert Conservation Reserve protects 225 square kilometers of dunes, about 5% of Dubai\'s land area, and is home to the largest free-roaming herd of Arabian oryx in the UAE. Visitors can enter only on a tour with a licensed operator, such as Platinum Heritage or Arabian Adventures, or as guests of the Al Maha resort. Safaris here combine desert drives with wildlife spotting, falconry, and camel rides. Away from the city, it offers one of the most authentic ways to experience Dubai\'s desert.',
      reviewSummary: '4.6 (1k reviews)',
      location: 'Dubai - Al Ain Road (E66)',
    ),
  ],
  'family_fun': [
    DummyPlace(
      name: 'Dubai Parks and Resorts',
      imageUrl: 'assets/places_images/family_fun_1.webp',
      openingHours: 'Hours vary by park',
      description:
          'Dubai Parks and Resorts feels like a full day of excitement wrapped into one destination. Each park has its own world of characters, rides, and cinematic moments that bring families together. It\'s the kind of place where both kids and adults end up smiling more than they expected.',
      reviewSummary: '4.5 (8k reviews)',
      location: 'Sheikh Zayed Rd - Saih Shuaib 1',
    ),
    DummyPlace(
      name: 'IMG Worlds of Adventure',
      imageUrl: 'assets/places_images/family_fun_2.webp',
      openingHours: 'Sun-Thu: 12:00 PM - 10:00 PM, Fri-Sat: 12:00 PM - 11:00 PM',
      description:
          'Stepping into IMG Worlds feels like entering a giant indoor universe built just for fun. The themed zones pull you into stories you grew up with, from Marvel heroes to cartoon classics. It\'s the perfect escape when you want big thrills without the desert heat.',
      reviewSummary: '4.3 (34k reviews)',
      location: 'Wadi Al Safa 4 - City of Arabia',
    ),
    DummyPlace(
      name: 'Legoland Dubai',
      imageUrl: 'assets/places_images/family_fun_3.webp',
      openingHours: 'Daily from 11:00 AM, Closing time varies by date',
      description:
          'Legoland Dubai feels like a world built with imagination at every turn. The rides are gentle, colorful, and designed to make younger kids feel brave and excited. It\'s one of the easiest places for families to spend a full day without rushing.',
      reviewSummary: '4.4 (20k reviews)',
      location: 'Parks & Resorts - Sheikh Zayed Rd - Saih Shuaib 1',
    ),
    DummyPlace(
      name: 'Global Village',
      imageUrl: 'assets/places_images/family_fun_4.jpg',
      openingHours: 'Sun-Wed: 4:00 PM - 12:00 AM, Thu-Sat: 4:00 PM - 1:00 AM, Season: 14 Oct 2026 - May 2027',
      description:
          'Global Village feels like a trip around the world packed into one evening. More than 90 cultures come together through colorful pavilions, street food, rides, and live shows, so every age finds something to enjoy. It opens seasonally, and Tuesdays are reserved for families, couples, and ladies, except on public holidays.',
      reviewSummary: '4.6 (144k reviews)',
      location: 'Wadi Al Safa 4 - Dubailand',
    ),
  ],
};

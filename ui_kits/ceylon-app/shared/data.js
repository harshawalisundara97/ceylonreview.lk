// Ceylon Review — shared data
// Plain JS — no Babel needed. Exports to window.CeylonData.

window.CeylonData = {
  categories: [
    { id: 'food',     label: 'Food',     icon: 'restaurant',    cssClass: 'cat-food',     color: '#C0512C', bg: 'linear-gradient(140deg,#E05D38 0%,#F5A62390 100%)' },
    { id: 'nature',   label: 'Nature',   icon: 'forest',        cssClass: 'cat-nature',   color: '#43811F', bg: 'linear-gradient(140deg,#2D6A4F 0%,#52B78890 100%)' },
    { id: 'beach',    label: 'Beach',    icon: 'beach_access',  cssClass: 'cat-beach',    color: '#00788F', bg: 'linear-gradient(140deg,#0E7C9D 0%,#47C4E090 100%)' },
    { id: 'hotels',   label: 'Hotels',   icon: 'hotel',         cssClass: 'cat-hotels',   color: '#7A4F9E', bg: 'linear-gradient(140deg,#6B3FA0 0%,#9B59B690 100%)' },
    { id: 'temples',  label: 'Temples',  icon: 'temple_buddhist', cssClass: 'cat-temples', color: '#9A5B00', bg: 'linear-gradient(140deg,#9A5B00 0%,#EF9F2790 100%)' },
    { id: 'shopping', label: 'Shopping', icon: 'shopping_bag',  cssClass: 'cat-shopping', color: '#B11A60', bg: 'linear-gradient(140deg,#B11A60 0%,#E91E8C90 100%)' },
  ],

  places: [
    { id:1, name:'Ministry of Crab',         category:'food',    location:'Colombo Fort', rating:4.9, reviews:'2.3k', distance:'0.8 km', bg:'linear-gradient(140deg,#D94F35 0%,#F5A62380 60%,#E8653050 100%)', description:'Sri Lanka\'s most celebrated seafood restaurant, famous for its giant mud crabs. Set inside the stunning Dutch Hospital Shopping Precinct.', tags:['Seafood','Fine Dining','Crab','Upscale'], verified:true },
    { id:2, name:'Mirissa Beach',             category:'beach',   location:'Matara District', rating:4.7, reviews:'1.8k', distance:'158 km', bg:'linear-gradient(140deg,#0E7C9D 0%,#47C4E070 60%,#0093BB50 100%)', description:'A stunning crescent-shaped beach famous for whale watching, surfing, and spectacular sunsets on the southern coast.', tags:['Whale Watching','Surfing','Sunset','Swimming'], verified:false },
    { id:3, name:'Ravana Falls',              category:'nature',  location:'Ella', rating:4.6, reviews:'987', distance:'196 km', bg:'linear-gradient(140deg,#1D6B42 0%,#52B78870 60%,#2E9B5A50 100%)', description:'One of the widest falls in Sri Lanka, steeped in the legend of King Ravana. A spectacular cascade in the central highlands.', tags:['Waterfall','Hiking','Scenic','History'], verified:true },
    { id:4, name:'Temple of the Tooth',       category:'temples', location:'Kandy', rating:4.8, reviews:'3.1k', distance:'115 km', bg:'linear-gradient(140deg,#9A5B00 0%,#EF9F2770 60%,#D4930A50 100%)', description:'Sri Lanka\'s most sacred Buddhist site, housing a relic of the tooth of the Buddha. A UNESCO World Heritage Site.', tags:['UNESCO','Buddhist','Sacred','Heritage'], verified:true },
    { id:5, name:'Heritance Kandalama',       category:'hotels',  location:'Dambulla', rating:4.9, reviews:'2.7k', distance:'148 km', bg:'linear-gradient(140deg,#6B3FA0 0%,#9B59B670 60%,#7D3FAE50 100%)', description:'A masterpiece of sustainable architecture by Geoffrey Bawa, built into a rock face overlooking Kandalama Lake.', tags:['Luxury','Bawa','Nature Views','Pool'], verified:true },
    { id:6, name:'Odel Colombo',              category:'shopping', location:'Colombo 3', rating:4.3, reviews:'543', distance:'3.2 km', bg:'linear-gradient(140deg,#B11A60 0%,#E91E8C70 60%,#C2185B50 100%)', description:'Sri Lanka\'s premier fashion and lifestyle destination with local and international brands, a food court, and more.', tags:['Fashion','Brands','Food Court','Lifestyle'], verified:false },
    { id:7, name:'The Arcade Restaurant',     category:'food',    location:'Colombo 7', rating:4.7, reviews:'1.2k', distance:'4.1 km', bg:'linear-gradient(140deg,#D9534F 0%,#F0A50070 60%,#E2603050 100%)', description:'Multi-cuisine restaurant set in the stunning Arcade Independence Square. Colonial architecture meets contemporary Sri Lankan hospitality.', tags:['Multi-Cuisine','Colonial','Brunch','Ambience'], verified:false },
    { id:8, name:'Sinharaja Forest Reserve',  category:'nature',  location:'Ratnapura', rating:4.8, reviews:'765', distance:'123 km', bg:'linear-gradient(140deg,#1A5C3A 0%,#3DB78B70 60%,#27856050 100%)', description:'Sri Lanka\'s last primary rainforest and a UNESCO World Heritage Site. Home to rare endemic birds and biodiversity.', tags:['UNESCO','Rainforest','Birdwatching','Trekking'], verified:true },
    { id:9, name:'Unawatuna Beach',           category:'beach',   location:'Galle District', rating:4.5, reviews:'1.4k', distance:'128 km', bg:'linear-gradient(140deg,#007A94 0%,#38C8E870 60%,#009AB250 100%)', description:'A sheltered bay with calm turquoise waters, white sand, and a lively beach strip. Great for snorkelling and swimming.', tags:['Snorkelling','Swimming','Beach Bars','Calm Waters'], verified:false },
    { id:10, name:'Dutch Hospital Colombo',   category:'shopping', location:'Colombo Fort', rating:4.4, reviews:'892', distance:'2.1 km', bg:'linear-gradient(140deg,#A01555 0%,#E0207770 60%,#C0185A50 100%)', description:'One of the oldest buildings in Colombo, converted into a premium dining and shopping precinct.', tags:['Heritage','Dining','Boutiques','Colonial'], verified:false },
    { id:11, name:'Nuga Gama',                category:'food',    location:'Cinnamon Grand', rating:4.6, reviews:'678', distance:'2.3 km', bg:'linear-gradient(140deg,#C06020 0%,#F5A62370 60%,#D4830050 100%)', description:'Village dining under a 200-year-old banyan tree inside Cinnamon Grand. Traditional rice and curry in an authentic rural setting.', tags:['Sri Lankan','Outdoor','Traditional','Curry'], verified:true },
    { id:12, name:'Dambulla Cave Temple',     category:'temples', location:'Dambulla', rating:4.7, reviews:'2.1k', distance:'148 km', bg:'linear-gradient(140deg,#8A4E00 0%,#D4930A70 60%,#A05E0050 100%)', description:'Five cave temples with 153 Buddha statues and 80 documented paintings. A UNESCO World Heritage Site.', tags:['UNESCO','Cave','Buddhist','Paintings'], verified:true },
    { id:13, name:'Cinnamon Grand Colombo',   category:'hotels',  location:'Colombo 3', rating:4.8, reviews:'1.9k', distance:'2.6 km', bg:'linear-gradient(140deg,#5C3290 0%,#8E63CF70 60%,#6B3FAE50 100%)', description:"Colombo's iconic five-star hotel, home to 13 award-winning restaurants. A landmark of Sri Lankan hospitality with a rooftop pool.", tags:['5-Star','Rooftop Pool','Restaurants','City Centre'], verified:true },
    { id:14, name:'Hiriketiya Bay',           category:'beach',   location:'Dikwella', rating:4.6, reviews:'543', distance:'172 km', bg:'linear-gradient(140deg,#006D85 0%,#29B5D570 60%,#008BA250 100%)', description:"A horseshoe-shaped bay beloved by surfers and yoga retreats. Lush hills, palm trees, and a relaxed bohemian vibe.", tags:['Surfing','Yoga','Horseshoe Bay','Laid-back'], verified:false },
    { id:15, name:'Bambarakanda Falls',       category:'nature',  location:'Badulla', rating:4.5, reviews:'432', distance:'184 km', bg:'linear-gradient(140deg,#1D5C2E 0%,#4AAA6E70 60%,#29854450 100%)', description:"At 263 metres, Sri Lanka's tallest waterfall. Surrounded by pine forests and spectacular highland scenery.", tags:['Tallest Waterfall','Hiking','Highlands','Photography'], verified:false },
  ],

  reviews: [
    { id:1, placeId:1, user:'Dilshan Perera',  initials:'DP', rating:5, date:'2 days ago', text:'Absolutely stunning experience! The giant mud crab in chilli sauce was cooked to perfection. Service was exceptional and the Dutch Hospital setting adds so much character. Worth every rupee.' },
    { id:2, placeId:1, user:'Sarah Mitchell',  initials:'SM', rating:5, date:'1 week ago',  text:"One of the best restaurants I've visited in all of Southeast Asia. The crab flies in fresh daily. Book well in advance — it fills up fast. Five stars without hesitation." },
    { id:3, placeId:1, user:'Nuwan Fernando',  initials:'NF', rating:4, date:'2 weeks ago', text:'Ministry of Crab lives up to the hype. Garlic chilli crab is divine. A bit pricey but a must-visit. The colonial setting is absolutely gorgeous in the evening.' },
    { id:4, placeId:2, user:'Amaya Silva',     initials:'AS', rating:5, date:'3 days ago',  text:'Mirissa is magical at sunset. We saw blue whales on the morning boat trip — an experience I will never forget. The beach itself is postcard perfect.' },
    { id:5, placeId:3, user:'Ravindu Jayasinghe', initials:'RJ', rating:4, date:'5 days ago', text:'Ravana Falls is impressive especially after the rains. Easy trek down. A bit busy on weekends but the scenery is absolutely worth it. Very Sri Lankan experience.' },
  ],

  userProfile: {
    name: 'Harsha Walisundara',
    username: '@harshawa',
    bio: 'Exploring every corner of Sri Lanka 🇱🇰 | Food lover | Amateur photographer',
    reviewCount: 47,
    placesCount: 23,
    followerCount: 128,
    followingCount: 89,
    initials: 'HW',
    topCategories: ['food', 'nature', 'beach'],
  }
};

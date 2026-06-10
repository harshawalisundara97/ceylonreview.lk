/* @ds-bundle: {"format":3,"namespace":"CeylonReviewDesignSystem_bbbadd","components":[],"sourceHashes":{"ui_kits/ceylon-app/App.jsx":"106ca932c817","ui_kits/ceylon-app/screens/CategoryScreen.jsx":"47748196b474","ui_kits/ceylon-app/screens/HomeScreen.jsx":"33faba4230ff","ui_kits/ceylon-app/screens/LoginScreen.jsx":"4af432fe8da7","ui_kits/ceylon-app/screens/MapScreen.jsx":"c48a548028ff","ui_kits/ceylon-app/screens/PlaceDetailScreen.jsx":"85a1f3ab5464","ui_kits/ceylon-app/screens/ProfileScreen.jsx":"5deb27177ea4","ui_kits/ceylon-app/screens/WriteReviewScreen.jsx":"dd413df8810e","ui_kits/ceylon-app/shared/components.jsx":"43fcee1b452b","ui_kits/ceylon-app/shared/data.js":"48d319005c53"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.CeylonReviewDesignSystem_bbbadd = window.CeylonReviewDesignSystem_bbbadd || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// ui_kits/ceylon-app/App.jsx
try { (() => {
// Ceylon Review — App root (navigation + theming controller)

const {
  useState,
  useEffect
} = React;
const {
  Icon,
  StatusBar,
  TopBar,
  BottomNav,
  Stars,
  CategoryPillRow,
  PlaceCardHero,
  PlaceCardRow,
  ReviewCard
} = window;
function App() {
  const [screen, setScreen] = useState('login');
  const [tab, setTab] = useState('home');
  const [category, setCategory] = useState('all');
  const [selectedPlace, setSelectedPlace] = useState(null);
  const [isDark, setIsDark] = useState(false);

  // Persist state across refreshes
  useEffect(() => {
    const s = localStorage.getItem('cr_screen');
    const c = localStorage.getItem('cr_category');
    const d = localStorage.getItem('cr_dark');
    if (s) setScreen(s);
    if (c) setCategory(c);
    if (d) setIsDark(d === '1');
  }, []);
  useEffect(() => {
    localStorage.setItem('cr_screen', screen);
  }, [screen]);
  useEffect(() => {
    localStorage.setItem('cr_category', category);
  }, [category]);
  useEffect(() => {
    localStorage.setItem('cr_dark', isDark ? '1' : '0');
  }, [isDark]);
  function navigate(screenName, place) {
    setSelectedPlace(place || null);
    setScreen(screenName);
    if (screenName === 'home') setTab('home');
    if (screenName === 'map') setTab('map');
    if (screenName === 'profile') setTab('profile');
    if (screenName === 'post') setTab('post');
  }
  function handleTabChange(tabId) {
    setTab(tabId);
    if (tabId === 'home') {
      setScreen('home');
    }
    if (tabId === 'map') {
      setScreen('map');
    }
    if (tabId === 'post') {
      setScreen('post');
    }
    if (tabId === 'feed') {
      setScreen('home');
    }
    if (tabId === 'profile') {
      setScreen('profile');
    }
  }
  function handleCategoryChange(catId) {
    setCategory(catId);
    if (screen === 'home' || screen === 'category') setScreen('category');
  }
  const catClass = category !== 'all' ? `cat-${category}` : '';
  const showBottomNav = screen !== 'login';
  const screenProps = {
    onNavigate: navigate,
    activeCategory: category,
    onCategoryChange: handleCategoryChange
  };
  const {
    categories
  } = window.CeylonData;
  const allCategories = [{
    id: 'all',
    label: 'Default',
    color: '#0F6E56'
  }, ...categories];
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    className: "phone-shell",
    "data-theme": isDark ? 'dark' : undefined
  }, /*#__PURE__*/React.createElement("div", {
    className: `app-root${catClass ? ` ${catClass}` : ''}`
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      minHeight: 0,
      overflow: 'hidden'
    }
  }, screen === 'login' && /*#__PURE__*/React.createElement(LoginScreen, {
    onNavigate: navigate
  }), screen === 'home' && /*#__PURE__*/React.createElement(HomeScreen, screenProps), screen === 'category' && /*#__PURE__*/React.createElement(CategoryScreen, screenProps), screen === 'placeDetail' && /*#__PURE__*/React.createElement(PlaceDetailScreen, {
    place: selectedPlace,
    onNavigate: navigate,
    onWriteReview: p => navigate('post', p)
  }), screen === 'post' && /*#__PURE__*/React.createElement(WriteReviewScreen, {
    place: selectedPlace,
    onNavigate: navigate
  }), screen === 'map' && /*#__PURE__*/React.createElement(MapScreen, screenProps), screen === 'profile' && /*#__PURE__*/React.createElement(ProfileScreen, {
    onNavigate: navigate
  })), showBottomNav && /*#__PURE__*/React.createElement(BottomNav, {
    active: tab,
    onChange: handleTabChange
  }), /*#__PURE__*/React.createElement("div", {
    className: "home-indicator"
  }))), /*#__PURE__*/React.createElement("div", {
    className: "controls"
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "ctrl-label"
  }, "Appearance"), /*#__PURE__*/React.createElement("button", {
    className: `ctrl-btn${isDark ? ' active-ctrl' : ''}`,
    onClick: () => setIsDark(d => !d)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: isDark ? 'dark_mode' : 'light_mode',
    size: 18,
    style: {
      color: isDark ? '#EF9F27' : '#fff'
    }
  }), isDark ? 'Dark Mode' : 'Light Mode')), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "ctrl-label"
  }, "Category Theme"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6
    }
  }, allCategories.map(c => /*#__PURE__*/React.createElement("button", {
    key: c.id,
    className: `ctrl-btn${category === c.id ? ' active-ctrl' : ''}`,
    onClick: () => {
      setCategory(c.id);
      if (c.id !== 'all' && (screen === 'home' || screen === 'category')) {
        setScreen('category');
      }
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "ctrl-swatch",
    style: {
      background: c.color
    }
  }), c.label)))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "ctrl-label"
  }, "Screens"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6
    }
  }, [{
    id: 'login',
    label: 'Login'
  }, {
    id: 'home',
    label: 'Home'
  }, {
    id: 'category',
    label: 'Category'
  }, {
    id: 'map',
    label: 'Map'
  }, {
    id: 'profile',
    label: 'Profile'
  }].map(s => /*#__PURE__*/React.createElement("button", {
    key: s.id,
    className: `ctrl-btn${screen === s.id ? ' active-ctrl' : ''}`,
    onClick: () => navigate(s.id)
  }, s.label)), /*#__PURE__*/React.createElement("button", {
    className: `ctrl-btn${screen === 'placeDetail' ? ' active-ctrl' : ''}`,
    onClick: () => navigate('placeDetail', window.CeylonData.places[0])
  }, "Place Detail"), /*#__PURE__*/React.createElement("button", {
    className: `ctrl-btn${screen === 'post' ? ' active-ctrl' : ''}`,
    onClick: () => navigate('post', window.CeylonData.places[0])
  }, "Write Review")))));
}
ReactDOM.createRoot(document.getElementById('root')).render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/App.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/CategoryScreen.jsx
try { (() => {
// CategoryScreen — Browse places by category with grid layout

function CategoryScreen({
  onNavigate,
  activeCategory,
  onCategoryChange
}) {
  const {
    places,
    categories
  } = window.CeylonData;
  const {
    useState
  } = React;
  const [sortBy, setSortBy] = useState('rating');
  const activeCat = activeCategory || 'all';
  const catMeta = categories.find(c => c.id === activeCat);
  const filtered = activeCat === 'all' ? places : places.filter(p => p.category === activeCat);
  const sorted = [...filtered].sort((a, b) => sortBy === 'rating' ? b.rating - a.rating : a.distance.localeCompare(b.distance));
  const sortOptions = [{
    id: 'rating',
    label: 'Top Rated'
  }, {
    id: 'distance',
    label: 'Nearest'
  }, {
    id: 'reviews',
    label: 'Most Reviewed'
  }];
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      background: catMeta ? `linear-gradient(135deg, var(--primary) 0%, var(--primary-container) 100%)` : 'var(--surface-container)',
      padding: '16px 16px 20px',
      transition: 'var(--theme-transition)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    onClick: () => onNavigate('home'),
    style: {
      color: catMeta ? 'var(--on-primary)' : 'var(--on-surface)',
      background: 'rgba(255,255,255,0.15)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow_back"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '400 11px/1 var(--font-text)',
      color: catMeta ? 'var(--on-primary)' : 'var(--on-surface-variant)',
      opacity: 0.75,
      letterSpacing: '0.08em',
      textTransform: 'uppercase',
      marginBottom: 3
    }
  }, "Browse"), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '700 22px/1 var(--font-display)',
      color: catMeta ? 'var(--on-primary)' : 'var(--on-surface)'
    }
  }, catMeta ? catMeta.label : 'All Places')), catMeta && /*#__PURE__*/React.createElement("div", {
    style: {
      width: 48,
      height: 48,
      borderRadius: '50%',
      background: 'rgba(255,255,255,0.2)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: catMeta.icon,
    size: 26,
    style: {
      color: 'var(--on-primary)'
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      overflowX: 'auto',
      display: 'flex',
      gap: 8
    }
  }, [{
    id: 'all',
    label: 'All',
    icon: 'apps'
  }, ...categories].map(c => /*#__PURE__*/React.createElement("button", {
    key: c.id,
    className: "chip",
    style: {
      flexShrink: 0,
      background: activeCat === c.id ? 'rgba(255,255,255,0.9)' : 'rgba(255,255,255,0.15)',
      borderColor: activeCat === c.id ? 'transparent' : 'rgba(255,255,255,0.35)',
      color: activeCat === c.id ? 'var(--primary)' : catMeta ? 'var(--on-primary)' : 'var(--on-surface-variant)'
    },
    onClick: () => onCategoryChange(c.id)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: c.icon,
    size: 16
  }), c.label)))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '12px 16px 8px',
      background: 'var(--surface)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body-sm)',
      color: 'var(--on-surface-variant)',
      flex: 1
    }
  }, sorted.length, " places"), sortOptions.map(s => /*#__PURE__*/React.createElement("button", {
    key: s.id,
    className: `chip${sortBy === s.id ? ' active' : ''}`,
    style: {
      height: 28,
      fontSize: 12
    },
    onClick: () => setSortBy(s.id)
  }, s.label))), /*#__PURE__*/React.createElement("div", {
    className: "scrollable",
    style: {
      padding: '8px 16px 24px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 12
    }
  }, sorted.map(place => {
    const cat = categories.find(c => c.id === place.category);
    return /*#__PURE__*/React.createElement("div", {
      key: place.id,
      className: "place-card",
      onClick: () => onNavigate('placeDetail', place)
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        height: 120,
        background: place.bg,
        position: 'relative',
        overflow: 'hidden'
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "place-img-scrim"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        position: 'absolute',
        top: 8,
        right: 8,
        width: 28,
        height: 28,
        borderRadius: '50%',
        background: 'rgba(0,0,0,0.3)',
        backdropFilter: 'blur(6px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: cat?.icon || 'place',
      size: 14,
      style: {
        color: 'white'
      }
    })), /*#__PURE__*/React.createElement("div", {
      style: {
        position: 'absolute',
        bottom: 8,
        left: 8,
        display: 'flex',
        alignItems: 'center',
        gap: 3
      }
    }, /*#__PURE__*/React.createElement(Stars, {
      rating: place.rating,
      size: 11
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 11,
        fontWeight: 600,
        color: 'white'
      }
    }, place.rating))), /*#__PURE__*/React.createElement("div", {
      style: {
        padding: '10px 12px 12px'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        font: '600 13px/1.3 var(--font-text)',
        color: 'var(--on-surface)',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        marginBottom: 4
      }
    }, place.name), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 3,
        color: 'var(--on-surface-variant)',
        fontSize: 11
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "location_on",
      size: 11
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap'
      }
    }, place.location))));
  }))));
}
window.CategoryScreen = CategoryScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/CategoryScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/HomeScreen.jsx
try { (() => {
// HomeScreen — Trending carousel + nearby list + category pills

function HomeScreen({
  onNavigate,
  activeCategory,
  onCategoryChange
}) {
  const {
    places,
    categories
  } = window.CeylonData;
  const {
    useState
  } = React;
  const [searchVal, setSearchVal] = useState('');
  const activeCat = activeCategory || 'all';
  const filtered = activeCat === 'all' ? places : places.filter(p => p.category === activeCat);
  const trending = filtered.slice(0, 5);
  const nearby = filtered.slice(0, 6);
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter"
  }, /*#__PURE__*/React.createElement("div", {
    className: "top-bar",
    style: {
      padding: '0 8px 0 16px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 32,
      height: 32,
      borderRadius: '50%',
      background: 'var(--primary)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_on",
    fill: true,
    size: 18,
    style: {
      color: 'white'
    }
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '400 11px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginBottom: 2
    }
  }, "Discover in"), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '700 16px/1 var(--font-display)',
      color: 'var(--on-surface)'
    }
  }, "Sri Lanka \uD83C\uDDF1\uD83C\uDDF0"))), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    "aria-label": "Notifications"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "notifications"
  })), /*#__PURE__*/React.createElement("div", {
    className: "avatar",
    style: {
      width: 38,
      height: 38,
      fontSize: 14,
      cursor: 'pointer'
    },
    onClick: () => onNavigate('profile')
  }, "HW")), /*#__PURE__*/React.createElement("div", {
    className: "scrollable"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '8px 16px 16px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "search-bar",
    onClick: () => {}
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "search",
    style: {
      color: 'var(--on-surface-variant)'
    }
  }), /*#__PURE__*/React.createElement("input", {
    placeholder: "Search places in Sri Lanka\u2026",
    value: searchVal,
    onChange: e => setSearchVal(e.target.value),
    style: {
      fontSize: 15
    }
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "tune",
    size: 20,
    style: {
      color: 'var(--on-surface-variant)'
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      overflowX: 'auto',
      display: 'flex',
      gap: 8,
      padding: '0 16px 4px'
    },
    className: "scrollable"
  }, [{
    id: 'all',
    label: 'All',
    icon: 'apps'
  }, ...categories].map(c => /*#__PURE__*/React.createElement("button", {
    key: c.id,
    className: `chip${activeCat === c.id ? ' active' : ''}`,
    style: {
      flexShrink: 0
    },
    onClick: () => onCategoryChange(c.id)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: c.icon,
    size: 16
  }), c.label)))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-header"
  }, /*#__PURE__*/React.createElement("span", {
    className: "section-title"
  }, "Trending This Week"), /*#__PURE__*/React.createElement("button", {
    className: "section-link"
  }, "See all")), /*#__PURE__*/React.createElement("div", {
    style: {
      overflowX: 'auto',
      display: 'flex',
      gap: 12,
      padding: '0 16px 8px'
    }
  }, trending.map(place => /*#__PURE__*/React.createElement(PlaceCardHero, {
    key: place.id,
    place: place,
    onClick: () => onNavigate('placeDetail', place)
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-header"
  }, /*#__PURE__*/React.createElement("span", {
    className: "section-title"
  }, "Popular Nearby"), /*#__PURE__*/React.createElement("button", {
    className: "section-link",
    onClick: () => onNavigate('category')
  }, "See all")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10,
      padding: '0 16px'
    }
  }, nearby.map(place => /*#__PURE__*/React.createElement(PlaceCardRow, {
    key: place.id,
    place: place,
    onClick: () => onNavigate('placeDetail', place)
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 24
    }
  })));
}
window.HomeScreen = HomeScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/HomeScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/LoginScreen.jsx
try { (() => {
// LoginScreen — Login and register with tabs

function LoginScreen({
  onNavigate
}) {
  const {
    useState
  } = React;
  const [mode, setMode] = useState('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);
  function handleAuth() {
    if (!email || !password) return;
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      onNavigate('home');
    }, 1200);
  }
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter",
    style: {
      background: 'var(--surface)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "scrollable",
    style: {
      padding: '0 24px 40px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      padding: '48px 0 40px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 72,
      height: 72,
      borderRadius: 'var(--radius-xl)',
      background: 'var(--primary)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      margin: '0 auto 16px',
      boxShadow: '0 8px 24px rgba(15,110,86,0.3)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_on",
    fill: true,
    size: 36,
    style: {
      color: 'white'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '800 32px/1 var(--font-display)',
      color: 'var(--on-surface)',
      marginBottom: 4
    }
  }, "Ceylon Review"), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '400 15px/1.5 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, "Discover the best of Sri Lanka")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      background: 'var(--surface-container)',
      borderRadius: 'var(--radius-pill)',
      padding: 4,
      marginBottom: 28
    }
  }, ['login', 'register'].map(m => /*#__PURE__*/React.createElement("button", {
    key: m,
    onClick: () => setMode(m),
    style: {
      flex: 1,
      height: 44,
      borderRadius: 'var(--radius-pill)',
      border: 'none',
      cursor: 'pointer',
      font: '600 15px/1 var(--font-text)',
      transition: 'all 220ms ease',
      background: mode === m ? 'var(--surface)' : 'transparent',
      color: mode === m ? 'var(--on-surface)' : 'var(--on-surface-variant)',
      boxShadow: mode === m ? 'var(--elev-1)' : 'none'
    }
  }, m === 'login' ? 'Sign In' : 'Register'))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14,
      marginBottom: 20
    }
  }, mode === 'register' && /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 13px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginBottom: 8,
      letterSpacing: '0.02em'
    }
  }, "Full Name"), /*#__PURE__*/React.createElement("input", {
    className: "input-field",
    type: "text",
    placeholder: "Dilshan Perera",
    value: name,
    onChange: e => setName(e.target.value)
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 13px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginBottom: 8,
      letterSpacing: '0.02em'
    }
  }, "Email"), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("input", {
    className: "input-field",
    type: "email",
    placeholder: "you@example.com",
    value: email,
    onChange: e => setEmail(e.target.value),
    style: {
      paddingLeft: 48
    }
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "mail",
    size: 20,
    style: {
      position: 'absolute',
      left: 14,
      top: 18,
      color: 'var(--on-surface-variant)'
    }
  }))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 13px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginBottom: 8,
      letterSpacing: '0.02em'
    }
  }, "Password"), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("input", {
    className: "input-field",
    type: showPass ? 'text' : 'password',
    placeholder: "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022",
    value: password,
    onChange: e => setPassword(e.target.value),
    style: {
      paddingLeft: 48,
      paddingRight: 48
    }
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "lock",
    size: 20,
    style: {
      position: 'absolute',
      left: 14,
      top: 18,
      color: 'var(--on-surface-variant)'
    }
  }), /*#__PURE__*/React.createElement("button", {
    onClick: () => setShowPass(s => !s),
    style: {
      position: 'absolute',
      right: 14,
      top: 14,
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--on-surface-variant)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: showPass ? 'visibility_off' : 'visibility',
    size: 22
  }))))), mode === 'login' && /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'right',
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("button", {
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      font: '600 14px/1 var(--font-text)',
      color: 'var(--primary)'
    }
  }, "Forgot password?")), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary btn-full",
    onClick: handleAuth,
    style: {
      marginBottom: 20,
      opacity: !email || !password ? 0.5 : 1
    },
    disabled: !email || !password
  }, loading ? /*#__PURE__*/React.createElement(Icon, {
    name: "autorenew",
    size: 20,
    style: {
      color: 'var(--on-primary)',
      animation: 'spin 1s linear infinite'
    }
  }) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Icon, {
    name: mode === 'login' ? 'login' : 'person_add',
    size: 20,
    style: {
      color: 'var(--on-primary)'
    }
  }), mode === 'login' ? 'Sign In' : 'Create Account')), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "divider",
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: '400 13px/1 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, "or continue with"), /*#__PURE__*/React.createElement("div", {
    className: "divider",
    style: {
      flex: 1
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      marginBottom: 32
    }
  }, [{
    icon: 'g_mobiledata',
    label: 'Google'
  }, {
    icon: 'smartphone',
    label: 'Apple'
  }].map(s => /*#__PURE__*/React.createElement("button", {
    key: s.label,
    style: {
      flex: 1,
      height: 52,
      borderRadius: 'var(--radius-md)',
      border: '1.5px solid var(--outline-variant)',
      background: 'var(--surface-container-low)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 10,
      cursor: 'pointer',
      font: '600 15px/1 var(--font-text)',
      color: 'var(--on-surface)',
      transition: 'background 160ms ease'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: s.icon,
    size: 22
  }), s.label))), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: '400 14px/1 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, mode === 'login' ? "Don't have an account? " : 'Already have an account? '), /*#__PURE__*/React.createElement("button", {
    onClick: () => setMode(mode === 'login' ? 'register' : 'login'),
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      font: '600 14px/1 var(--font-text)',
      color: 'var(--primary)'
    }
  }, mode === 'login' ? 'Sign up' : 'Sign in')), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      marginTop: 20
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: '400 12px/1.4 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, "By continuing you agree to our", ' ', /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--primary)',
      cursor: 'pointer'
    }
  }, "Terms of Service"), ' and ', /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--primary)',
      cursor: 'pointer'
    }
  }, "Privacy Policy")))), /*#__PURE__*/React.createElement("style", null, `@keyframes spin { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }`));
}
window.LoginScreen = LoginScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/LoginScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/MapScreen.jsx
try { (() => {
// MapScreen — Interactive map view with bottom sheet

function MapScreen({
  onNavigate,
  activeCategory
}) {
  const {
    places,
    categories
  } = window.CeylonData;
  const {
    useState
  } = React;
  const [selectedPin, setSelectedPin] = useState(null);
  const [sheetExpanded, setSheetExpanded] = useState(false);
  const nearby = places.slice(0, 8);

  // Pseudo map pins — distributed across a 375x360 grid
  const pins = [{
    id: 1,
    x: 72,
    y: 90,
    placeId: 1
  }, {
    id: 2,
    x: 180,
    y: 60,
    placeId: 4
  }, {
    id: 3,
    x: 290,
    y: 110,
    placeId: 5
  }, {
    id: 4,
    x: 130,
    y: 180,
    placeId: 2
  }, {
    id: 5,
    x: 240,
    y: 200,
    placeId: 3
  }, {
    id: 6,
    x: 60,
    y: 260,
    placeId: 7
  }, {
    id: 7,
    x: 310,
    y: 280,
    placeId: 8
  }, {
    id: 8,
    x: 185,
    y: 310,
    placeId: 6
  }];
  function Pin({
    pin
  }) {
    const place = places.find(p => p.id === pin.placeId);
    if (!place) return null;
    const cat = categories.find(c => c.id === place.category);
    const isSelected = selectedPin?.placeId === pin.placeId;
    return /*#__PURE__*/React.createElement("g", {
      transform: `translate(${pin.x},${pin.y})`,
      style: {
        cursor: 'pointer'
      },
      onClick: () => setSelectedPin(isSelected ? null : pin)
    }, /*#__PURE__*/React.createElement("ellipse", {
      cx: 0,
      cy: 24,
      rx: 10,
      ry: 4,
      fill: "rgba(0,0,0,0.2)"
    }), /*#__PURE__*/React.createElement("path", {
      d: "M0,-24 C-14,-24 -14,-8 -14,0 C-14,12 0,26 0,26 C0,26 14,12 14,0 C14,-8 14,-24 0,-24 Z",
      fill: isSelected ? 'var(--primary)' : cat ? cat.color : '#0F6E56',
      stroke: isSelected ? 'white' : 'rgba(255,255,255,0.6)',
      strokeWidth: isSelected ? 2.5 : 1.5
    }), /*#__PURE__*/React.createElement("circle", {
      cx: 0,
      cy: -4,
      r: 8,
      fill: "rgba(255,255,255,0.25)"
    }), /*#__PURE__*/React.createElement("text", {
      x: 0,
      y: -4,
      textAnchor: "middle",
      dominantBaseline: "middle",
      fontSize: 10,
      fill: "white",
      fontFamily: "Material Symbols Rounded",
      style: {
        fontVariationSettings: "'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 20"
      }
    }, "\u2605"), isSelected && /*#__PURE__*/React.createElement("g", {
      transform: "translate(-52,-58)"
    }, /*#__PURE__*/React.createElement("rect", {
      x: 0,
      y: 0,
      width: 104,
      height: 32,
      rx: 8,
      fill: "var(--surface)",
      stroke: "var(--outline-variant)",
      strokeWidth: 1
    }), /*#__PURE__*/React.createElement("text", {
      x: 8,
      y: 12,
      fontSize: 11,
      fontWeight: 600,
      fill: "var(--on-surface)",
      fontFamily: "'Plus Jakarta Sans', sans-serif"
    }, place.name.length > 16 ? place.name.slice(0, 16) + '…' : place.name), /*#__PURE__*/React.createElement("text", {
      x: 8,
      y: 24,
      fontSize: 10,
      fill: "var(--on-surface-variant)",
      fontFamily: "'Plus Jakarta Sans', sans-serif"
    }, "\u2605 ", place.rating, " \xB7 ", place.distance)));
  }

  // Draw simple road grid
  const roads = [];
  for (let y = 60; y < 400; y += 70) {
    roads.push(/*#__PURE__*/React.createElement("line", {
      key: `h${y}`,
      x1: 0,
      y1: y,
      x2: 375,
      y2: y,
      stroke: "var(--outline-variant)",
      strokeWidth: 1.5,
      opacity: 0.6
    }));
  }
  for (let x = 55; x < 375; x += 80) {
    roads.push(/*#__PURE__*/React.createElement("line", {
      key: `v${x}`,
      x1: x,
      y1: 0,
      x2: x,
      y2: 400,
      stroke: "var(--outline-variant)",
      strokeWidth: 1.5,
      opacity: 0.6
    }));
  }
  // A few diagonal roads
  roads.push(/*#__PURE__*/React.createElement("line", {
    key: "d1",
    x1: 0,
    y1: 200,
    x2: 180,
    y2: 40,
    stroke: "var(--outline-variant)",
    strokeWidth: 2,
    opacity: 0.4
  }));
  roads.push(/*#__PURE__*/React.createElement("line", {
    key: "d2",
    x1: 200,
    y1: 400,
    x2: 375,
    y2: 150,
    stroke: "var(--outline-variant)",
    strokeWidth: 2,
    opacity: 0.4
  }));
  const bottomSheetHeight = sheetExpanded ? 380 : 200;
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter",
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      background: 'var(--surface-container-low)',
      position: 'relative',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: "375",
    height: "100%",
    style: {
      position: 'absolute',
      inset: 0
    }
  }, /*#__PURE__*/React.createElement("rect", {
    x: 0,
    y: 0,
    width: 375,
    height: 400,
    fill: "var(--surface-container-low)"
  }), /*#__PURE__*/React.createElement("ellipse", {
    cx: 300,
    cy: 80,
    rx: 90,
    ry: 50,
    fill: "var(--surface-container)",
    opacity: 0.7
  }), /*#__PURE__*/React.createElement("ellipse", {
    cx: 60,
    cy: 300,
    rx: 70,
    ry: 40,
    fill: "var(--surface-container)",
    opacity: 0.5
  }), /*#__PURE__*/React.createElement("ellipse", {
    cx: 180,
    cy: 240,
    rx: 50,
    ry: 35,
    fill: "var(--primary-container)",
    opacity: 0.25
  }), roads, pins.map(pin => /*#__PURE__*/React.createElement(Pin, {
    key: pin.id,
    pin: pin
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 12,
      left: 16,
      right: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "search-bar",
    style: {
      boxShadow: 'var(--elev-3)',
      background: 'var(--surface)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "search",
    style: {
      color: 'var(--on-surface-variant)'
    }
  }), /*#__PURE__*/React.createElement("input", {
    placeholder: "Search on map\u2026",
    style: {
      fontSize: 15,
      background: 'transparent'
    },
    readOnly: true
  }), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    style: {
      width: 36,
      height: 36
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "my_location",
    size: 20,
    style: {
      color: 'var(--primary)'
    }
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 76,
      left: 0,
      right: 0,
      overflowX: 'auto',
      display: 'flex',
      gap: 8,
      padding: '0 16px'
    }
  }, [{
    id: 'all',
    label: 'All',
    icon: 'apps'
  }, ...categories].slice(0, 5).map(c => /*#__PURE__*/React.createElement("button", {
    key: c.id,
    className: `chip${(activeCategory || 'all') === c.id ? ' active' : ''}`,
    style: {
      flexShrink: 0,
      boxShadow: 'var(--elev-1)',
      background: 'var(--surface)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: c.icon,
    size: 16
  }), c.label))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: bottomSheetHeight + 16,
      right: 16,
      width: 48,
      height: 48,
      borderRadius: '50%',
      background: 'var(--surface)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      boxShadow: 'var(--elev-3)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "my_location",
    style: {
      color: 'var(--primary)'
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      height: bottomSheetHeight,
      background: 'var(--surface)',
      borderRadius: '28px 28px 0 0',
      boxShadow: 'var(--elev-4)',
      display: 'flex',
      flexDirection: 'column',
      transition: 'height 360ms var(--ease-emphasized)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '12px 0 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 36,
      height: 4,
      borderRadius: 2,
      background: 'var(--outline-variant)',
      cursor: 'pointer'
    },
    onClick: () => setSheetExpanded(e => !e)
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '8px 16px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '700 18px/1 var(--font-display)',
      color: 'var(--on-surface)'
    }
  }, selectedPin ? places.find(p => p.id === selectedPin.placeId)?.name : 'Nearby Places'), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '400 13px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginTop: 4
    }
  }, nearby.length, " places around you")), /*#__PURE__*/React.createElement("button", {
    className: "chip active"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "filter_list",
    size: 16
  }), "Filter")), /*#__PURE__*/React.createElement("div", {
    className: "scrollable",
    style: {
      padding: '0 16px',
      flex: 1
    }
  }, (sheetExpanded ? nearby : nearby.slice(0, 2)).map(place => /*#__PURE__*/React.createElement(PlaceCardRow, {
    key: place.id,
    place: place,
    onClick: () => onNavigate('placeDetail', place)
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 16
    }
  }))));
}
window.MapScreen = MapScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/MapScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/PlaceDetailScreen.jsx
try { (() => {
// PlaceDetailScreen — Full detail view with reviews and actions

function PlaceDetailScreen({
  place,
  onNavigate,
  onWriteReview
}) {
  const {
    reviews,
    categories
  } = window.CeylonData;
  const {
    useState
  } = React;
  const [saved, setSaved] = useState(false);
  if (!place) return null;
  const cat = categories.find(c => c.id === place.category);
  const placeReviews = reviews.filter(r => r.placeId === place.id);
  const allReviews = placeReviews.length ? placeReviews : reviews.slice(0, 3);
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      height: 260,
      background: place.bg,
      flexShrink: 0,
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.1) 55%, transparent 100%)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      display: 'flex',
      justifyContent: 'space-between',
      padding: '8px 8px 0'
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    onClick: () => onNavigate('home'),
    style: {
      background: 'rgba(0,0,0,0.35)',
      backdropFilter: 'blur(8px)',
      color: 'white'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow_back"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    onClick: () => setSaved(s => !s),
    style: {
      background: 'rgba(0,0,0,0.35)',
      backdropFilter: 'blur(8px)',
      color: 'white'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: saved ? 'bookmark' : 'bookmark_border',
    fill: saved
  })), /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    style: {
      background: 'rgba(0,0,0,0.35)',
      backdropFilter: 'blur(8px)',
      color: 'white'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "ios_share"
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      padding: '0 16px 16px'
    }
  }, cat && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      height: 24,
      padding: '0 10px',
      borderRadius: '999px',
      background: 'var(--primary)',
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: cat.icon,
    size: 13,
    style: {
      color: 'var(--on-primary)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: '600 11px/1 var(--font-text)',
      letterSpacing: '0.06em',
      textTransform: 'uppercase',
      color: 'var(--on-primary)'
    }
  }, cat.label)), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '700 24px/1.15 var(--font-display)',
      color: 'white',
      marginBottom: 6,
      textWrap: 'pretty'
    }
  }, place.name), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(Stars, {
    rating: place.rating,
    size: 15
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontWeight: 700,
      color: 'white',
      fontSize: 15
    }
  }, place.rating), /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'rgba(255,255,255,0.7)',
      fontSize: 13
    }
  }, "(", place.reviews, " reviews)"), place.verified && /*#__PURE__*/React.createElement(Icon, {
    name: "verified",
    fill: true,
    size: 16,
    style: {
      color: '#4FC3F7',
      marginLeft: 2
    }
  })))), /*#__PURE__*/React.createElement("div", {
    className: "scrollable"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '16px 16px 8px',
      borderBottom: '1px solid var(--outline-variant)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_on",
    fill: true,
    size: 18,
    style: {
      color: 'var(--primary)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body-md)',
      color: 'var(--on-surface)',
      flex: 1
    }
  }, place.location), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body-sm)',
      color: 'var(--on-surface-variant)'
    }
  }, place.distance, " away")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10,
      padding: '16px 16px',
      borderBottom: '1px solid var(--outline-variant)'
    }
  }, [{
    icon: 'directions',
    label: 'Directions'
  }, {
    icon: 'call',
    label: 'Call'
  }, {
    icon: 'language',
    label: 'Website'
  }].map(a => /*#__PURE__*/React.createElement("button", {
    key: a.label,
    style: {
      flex: 1,
      height: 64,
      borderRadius: 'var(--radius-lg)',
      border: '1.5px solid var(--outline-variant)',
      background: 'var(--surface-container-low)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 6,
      cursor: 'pointer',
      color: 'var(--primary)',
      transition: 'background 160ms ease'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: a.icon,
    size: 22,
    style: {
      color: 'var(--primary)'
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: '600 12px/1 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, a.label)))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '16px 16px 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-md)',
      color: 'var(--on-surface)',
      marginBottom: 8
    }
  }, "About"), /*#__PURE__*/React.createElement("p", {
    style: {
      font: 'var(--type-body-md)',
      color: 'var(--on-surface-variant)',
      lineHeight: 1.6
    }
  }, place.description)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      flexWrap: 'wrap',
      padding: '12px 16px 16px'
    }
  }, place.tags.map(tag => /*#__PURE__*/React.createElement("span", {
    key: tag,
    className: "tag"
  }, tag))), /*#__PURE__*/React.createElement("div", {
    className: "divider"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '16px 16px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 20,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '800 48px/1 var(--font-display)',
      color: 'var(--on-surface)'
    }
  }, place.rating), /*#__PURE__*/React.createElement(Stars, {
    rating: place.rating,
    size: 16
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-body-sm)',
      color: 'var(--on-surface-variant)',
      marginTop: 4
    }
  }, place.reviews, " reviews")), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      gap: 6
    }
  }, [5, 4, 3, 2, 1].map(n => {
    const pct = n === 5 ? 72 : n === 4 ? 18 : n === 3 ? 7 : n === 2 ? 2 : 1;
    return /*#__PURE__*/React.createElement("div", {
      key: n,
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 8
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        font: '400 12px/1 var(--font-text)',
        color: 'var(--on-surface-variant)',
        width: 8
      }
    }, n), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        height: 6,
        borderRadius: 3,
        background: 'var(--outline-variant)',
        overflow: 'hidden'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        width: `${pct}%`,
        height: '100%',
        background: 'var(--star)',
        borderRadius: 3
      }
    })));
  })))), /*#__PURE__*/React.createElement("div", {
    className: "divider"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '16px 0 0'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "section-header"
  }, /*#__PURE__*/React.createElement("span", {
    className: "section-title"
  }, "Reviews"), /*#__PURE__*/React.createElement("button", {
    className: "section-link"
  }, "See all")), allReviews.map(r => /*#__PURE__*/React.createElement(ReviewCard, {
    key: r.id,
    review: r
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '20px 16px 32px'
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary btn-full",
    onClick: () => onWriteReview(place)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "rate_review",
    size: 20,
    style: {
      color: 'var(--on-primary)'
    }
  }), "Write a Review"))));
}
window.PlaceDetailScreen = PlaceDetailScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/PlaceDetailScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/ProfileScreen.jsx
try { (() => {
// ProfileScreen — User profile with stats, tabs and reviews

function ProfileScreen({
  onNavigate
}) {
  const {
    useState
  } = React;
  const {
    places,
    reviews,
    userProfile,
    categories
  } = window.CeylonData;
  const [activeTab, setActiveTab] = useState('reviews');
  const [following, setFollowing] = useState(false);
  const userReviews = reviews.slice(0, 3);
  const savedPlaces = places.filter(p => ['food', 'beach', 'nature'].includes(p.category)).slice(0, 4);
  const visitedPlaces = places.slice(2, 7);
  const tabs = [{
    id: 'reviews',
    label: 'Reviews',
    icon: 'rate_review',
    count: userProfile.reviewCount
  }, {
    id: 'saved',
    label: 'Saved',
    icon: 'bookmark',
    count: userProfile.placesCount
  }, {
    id: 'visited',
    label: 'Visited',
    icon: 'location_on',
    count: userProfile.placesCount + 5
  }];
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter"
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "Profile",
    onBack: () => onNavigate('home'),
    actions: [{
      icon: 'settings',
      label: 'Settings',
      onPress: () => {}
    }, {
      icon: 'more_vert',
      label: 'More',
      onPress: () => {}
    }]
  }), /*#__PURE__*/React.createElement("div", {
    className: "scrollable"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--category-tint)',
      padding: '20px 16px 24px',
      borderBottom: '1px solid var(--outline-variant)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 16,
      alignItems: 'flex-start',
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 72,
      height: 72,
      borderRadius: '50%',
      background: 'var(--primary)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: 26,
      fontWeight: 700,
      color: 'var(--on-primary)',
      fontFamily: 'var(--font-display)',
      flexShrink: 0,
      border: '3px solid var(--surface)'
    }
  }, userProfile.initials), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      paddingTop: 4
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '700 20px/1.2 var(--font-display)',
      color: 'var(--on-surface)',
      marginBottom: 4
    }
  }, userProfile.name), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '400 14px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginBottom: 10
    }
  }, userProfile.username), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary",
    style: {
      height: 36,
      padding: '0 20px',
      borderRadius: 'var(--radius-pill)',
      background: following ? 'var(--surface-container-high)' : 'var(--primary)',
      color: following ? 'var(--on-surface)' : 'var(--on-primary)',
      fontSize: 14
    },
    onClick: () => setFollowing(f => !f)
  }, following ? 'Following' : 'Follow'), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-outline",
    style: {
      height: 36,
      padding: '0 16px',
      borderRadius: 'var(--radius-pill)',
      fontSize: 14
    }
  }, "Message")))), /*#__PURE__*/React.createElement("p", {
    style: {
      font: 'var(--type-body-sm)',
      color: 'var(--on-surface-variant)',
      marginBottom: 16,
      lineHeight: 1.5
    }
  }, userProfile.bio), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-around',
      padding: '16px 0 0',
      borderTop: '1px solid var(--outline-variant)'
    }
  }, [{
    value: userProfile.reviewCount,
    label: 'Reviews'
  }, {
    value: userProfile.placesCount,
    label: 'Places'
  }, {
    value: userProfile.followerCount,
    label: 'Followers'
  }, {
    value: userProfile.followingCount,
    label: 'Following'
  }].map(s => /*#__PURE__*/React.createElement("div", {
    key: s.label,
    className: "stat-item"
  }, /*#__PURE__*/React.createElement("span", {
    className: "stat-value"
  }, s.value), /*#__PURE__*/React.createElement("span", {
    className: "stat-label"
  }, s.label))))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '16px 16px 0',
      marginBottom: 4
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-label-sm)',
      color: 'var(--on-surface-variant)',
      letterSpacing: '0.08em',
      textTransform: 'uppercase',
      marginBottom: 10
    }
  }, "Favourite Categories"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8
    }
  }, userProfile.topCategories.map(cid => {
    const cat = categories.find(c => c.id === cid);
    return cat ? /*#__PURE__*/React.createElement("div", {
      key: cid,
      className: "chip active",
      style: {
        flexShrink: 0
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: cat.icon,
      size: 16
    }), cat.label) : null;
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      borderBottom: '2px solid var(--outline-variant)',
      margin: '16px 0 0',
      padding: '0 4px'
    }
  }, tabs.map(t => /*#__PURE__*/React.createElement("button", {
    key: t.id,
    onClick: () => setActiveTab(t.id),
    style: {
      flex: 1,
      height: 44,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 6,
      border: 'none',
      background: 'none',
      cursor: 'pointer',
      color: activeTab === t.id ? 'var(--primary)' : 'var(--on-surface-variant)',
      font: '600 13px/1 var(--font-text)',
      borderBottom: activeTab === t.id ? '2px solid var(--primary)' : '2px solid transparent',
      marginBottom: -2,
      transition: 'color 160ms ease, border-color 160ms ease'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: t.icon,
    size: 18,
    fill: activeTab === t.id
  }), t.count))), activeTab === 'reviews' && /*#__PURE__*/React.createElement("div", null, userReviews.map(r => /*#__PURE__*/React.createElement("div", {
    key: r.id,
    className: "review-card"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      gap: 10,
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 14px/1.2 var(--font-text)',
      color: 'var(--on-surface)',
      marginBottom: 3
    }
  }, places.find(p => p.id === r.placeId)?.name || 'Unknown Place'), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(Stars, {
    rating: r.rating,
    size: 12
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: '400 12px/1 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, r.date))), /*#__PURE__*/React.createElement(Icon, {
    name: "more_horiz",
    size: 20,
    style: {
      color: 'var(--on-surface-variant)',
      marginTop: 2
    }
  })), /*#__PURE__*/React.createElement("p", {
    className: "review-text"
  }, r.text)))), activeTab === 'saved' && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 12,
      padding: '16px'
    }
  }, savedPlaces.map(place => {
    const cat = categories.find(c => c.id === place.category);
    return /*#__PURE__*/React.createElement("div", {
      key: place.id,
      className: "place-card",
      onClick: () => onNavigate('placeDetail', place)
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        height: 100,
        background: place.bg,
        position: 'relative'
      }
    }, /*#__PURE__*/React.createElement("div", {
      className: "place-img-scrim"
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        position: 'absolute',
        bottom: 8,
        left: 10
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        font: '600 12px/1.3 var(--font-text)',
        color: 'white',
        textShadow: '0 1px 4px rgba(0,0,0,0.5)'
      }
    }, place.name))), /*#__PURE__*/React.createElement("div", {
      style: {
        padding: '8px 10px 10px',
        display: 'flex',
        alignItems: 'center',
        gap: 4
      }
    }, /*#__PURE__*/React.createElement(Stars, {
      rating: place.rating,
      size: 11
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        font: '600 12px/1 var(--font-text)',
        color: 'var(--on-surface)'
      }
    }, place.rating)));
  })), activeTab === 'visited' && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10,
      padding: '16px'
    }
  }, visitedPlaces.map(place => /*#__PURE__*/React.createElement(PlaceCardRow, {
    key: place.id,
    place: place,
    onClick: () => onNavigate('placeDetail', place)
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 32
    }
  })));
}
window.ProfileScreen = ProfileScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/ProfileScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/screens/WriteReviewScreen.jsx
try { (() => {
// WriteReviewScreen — Star picker, photo upload, review form

function WriteReviewScreen({
  place,
  onNavigate
}) {
  const {
    useState
  } = React;
  const [rating, setRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [visitType, setVisitType] = useState('');
  const [reviewText, setReviewText] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const {
    categories
  } = window.CeylonData;
  const targetPlace = place || window.CeylonData.places[0];
  const cat = categories.find(c => c.id === targetPlace.category);
  const visitTypes = ['Solo', 'Couple', 'Family', 'Friends', 'Business'];
  const displayRating = hoverRating || rating;
  const ratingLabels = ['', 'Terrible', 'Poor', 'Okay', 'Good', 'Excellent!'];
  function handleSubmit() {
    if (rating === 0) return;
    setSubmitted(true);
  }
  if (submitted) {
    return /*#__PURE__*/React.createElement("div", {
      className: "screen screen-enter",
      style: {
        background: 'var(--surface)'
      }
    }, /*#__PURE__*/React.createElement(TopBar, {
      title: "Review Posted",
      onBack: () => onNavigate('home')
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 32,
        gap: 20,
        textAlign: 'center'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        width: 80,
        height: 80,
        borderRadius: '50%',
        background: 'var(--primary-container)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: "check_circle",
      fill: true,
      size: 48,
      style: {
        color: 'var(--primary)'
      }
    })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
      style: {
        font: '700 24px/1.2 var(--font-display)',
        color: 'var(--on-surface)',
        marginBottom: 8
      }
    }, "Review Posted!"), /*#__PURE__*/React.createElement("p", {
      style: {
        font: 'var(--type-body-md)',
        color: 'var(--on-surface-variant)'
      }
    }, "Thank you for sharing your experience at ", targetPlace.name, ". Your review helps others discover Sri Lanka's best places.")), /*#__PURE__*/React.createElement(Stars, {
      rating: rating,
      size: 28
    }), /*#__PURE__*/React.createElement("button", {
      className: "btn btn-primary btn-full",
      onClick: () => onNavigate('home')
    }, "Back to Home")));
  }
  return /*#__PURE__*/React.createElement("div", {
    className: "screen screen-enter"
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "Write a Review",
    onBack: () => onNavigate('placeDetail', targetPlace),
    actions: [{
      icon: 'close',
      label: 'Cancel',
      onPress: () => onNavigate('home')
    }]
  }), /*#__PURE__*/React.createElement("div", {
    className: "scrollable",
    style: {
      padding: '0 16px 32px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '12px 0 16px',
      borderBottom: '1px solid var(--outline-variant)',
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 52,
      height: 52,
      borderRadius: 'var(--radius-md)',
      background: targetPlace.bg,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      flexShrink: 0,
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: cat?.icon || 'place',
    size: 24,
    style: {
      color: 'rgba(255,255,255,0.85)'
    }
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 15px/1.3 var(--font-text)',
      color: 'var(--on-surface)'
    }
  }, targetPlace.name), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 4,
      font: '400 12px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      marginTop: 3
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_on",
    size: 12
  }), targetPlace.location))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-md)',
      color: 'var(--on-surface)',
      marginBottom: 16
    }
  }, "Your Rating"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "star-picker"
  }, [1, 2, 3, 4, 5].map(n => /*#__PURE__*/React.createElement("button", {
    key: n,
    className: "star-pick",
    onMouseEnter: () => setHoverRating(n),
    onMouseLeave: () => setHoverRating(0),
    onClick: () => setRating(n),
    "aria-label": `Rate ${n} stars`
  }, /*#__PURE__*/React.createElement("span", {
    className: `material-symbols-rounded${n <= displayRating ? ' fill' : ''}`,
    style: {
      fontSize: 44,
      color: n <= displayRating ? 'var(--star)' : 'var(--star-empty)',
      fontVariationSettings: n <= displayRating ? "'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 48" : "'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 48",
      transition: 'color 120ms ease, transform 120ms ease',
      display: 'block'
    }
  }, "star")))), displayRating > 0 && /*#__PURE__*/React.createElement("span", {
    style: {
      font: '600 16px/1 var(--font-text)',
      color: 'var(--primary)',
      animation: 'fadeIn 160ms ease'
    }
  }, ratingLabels[displayRating]), displayRating === 0 && /*#__PURE__*/React.createElement("span", {
    style: {
      font: '400 14px/1 var(--font-text)',
      color: 'var(--on-surface-variant)'
    }
  }, "Tap a star to rate"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-md)',
      color: 'var(--on-surface)',
      marginBottom: 12
    }
  }, "Who did you visit with?"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 8
    }
  }, visitTypes.map(t => /*#__PURE__*/React.createElement("button", {
    key: t,
    className: `chip${visitType === t ? ' active' : ''}`,
    onClick: () => setVisitType(t)
  }, t)))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-md)',
      color: 'var(--on-surface)',
      marginBottom: 12
    }
  }, "Add Photos"), /*#__PURE__*/React.createElement("div", {
    className: "photo-upload",
    style: {
      height: 100
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "add_photo_alternate",
    size: 32
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body-sm)',
      color: 'var(--on-surface-variant)'
    }
  }, "Tap to add photos"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-md)',
      color: 'var(--on-surface)',
      marginBottom: 12
    }
  }, "Share Your Experience"), /*#__PURE__*/React.createElement("textarea", {
    className: "review-textarea",
    rows: 5,
    placeholder: "What did you love? What could be better? Be specific to help others\u2026",
    value: reviewText,
    onChange: e => setReviewText(e.target.value)
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      font: '400 12px/1 var(--font-text)',
      color: 'var(--on-surface-variant)',
      textAlign: 'right',
      marginTop: 6
    }
  }, reviewText.length, " / 1000")), /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 32
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-md)',
      color: 'var(--on-surface)',
      marginBottom: 12
    }
  }, "Quick Tags"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: 8
    }
  }, (targetPlace.tags || []).map(tag => /*#__PURE__*/React.createElement("span", {
    key: tag,
    className: "tag",
    style: {
      cursor: 'pointer'
    }
  }, tag)))), /*#__PURE__*/React.createElement("button", {
    className: "btn btn-primary btn-full",
    onClick: handleSubmit,
    style: {
      opacity: rating === 0 ? 0.4 : 1
    },
    disabled: rating === 0
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "send",
    size: 20,
    style: {
      color: 'var(--on-primary)'
    }
  }), "Post Review")));
}
window.WriteReviewScreen = WriteReviewScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/screens/WriteReviewScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/shared/components.jsx
try { (() => {
// Ceylon Review — Shared UI Components
// Exports: StatusBar, TopBar, BottomNav, Stars, CategoryPillRow, PlaceCardHero, PlaceCardRow, ReviewCard

const {
  useState,
  useEffect
} = React;

/* ---- Icon shorthand ---- */
function Icon({
  name,
  fill = false,
  size = 24,
  style = {}
}) {
  const cls = `material-symbols-rounded${fill ? ' fill' : ''}${size === 20 ? ' sz20' : ''}`;
  return /*#__PURE__*/React.createElement("span", {
    className: cls,
    style: {
      fontSize: size,
      ...style
    }
  }, name);
}

/* ---- Status bar ---- */
function StatusBar({
  transparent = false,
  light = false
}) {
  const [time, setTime] = useState(() => {
    const d = new Date();
    return d.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true
    });
  });
  useEffect(() => {
    const t = setInterval(() => {
      const d = new Date();
      setTime(d.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
      }));
    }, 30000);
    return () => clearInterval(t);
  }, []);
  const c = light ? 'rgba(255,255,255,0.92)' : 'var(--on-surface)';
  return /*#__PURE__*/React.createElement("div", {
    className: "status-bar",
    style: {
      background: transparent ? 'transparent' : 'var(--surface)',
      color: c
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "status-bar-time",
    style: {
      color: c
    }
  }, time), /*#__PURE__*/React.createElement("div", {
    className: "status-bar-icons",
    style: {
      color: c
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "signal_cellular_alt",
    size: 16
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "wifi",
    size: 16
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "battery_5_bar",
    size: 16
  })));
}

/* ---- Top App Bar ---- */
function TopBar({
  title,
  logo = false,
  onBack,
  actions = []
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "top-bar"
  }, onBack && /*#__PURE__*/React.createElement("button", {
    className: "icon-btn",
    onClick: onBack,
    "aria-label": "Back"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "arrow_back"
  })), logo ? /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/logo-icon.svg",
    alt: "Ceylon Review",
    style: {
      height: 32
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-title-lg)',
      color: 'var(--primary)'
    }
  }, "Ceylon Review")) : /*#__PURE__*/React.createElement("span", {
    className: "top-bar-title"
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 4
    }
  }, actions.map((a, i) => /*#__PURE__*/React.createElement("button", {
    key: i,
    className: "icon-btn",
    onClick: a.onPress,
    "aria-label": a.label
  }, /*#__PURE__*/React.createElement(Icon, {
    name: a.icon,
    fill: a.fill
  })))));
}

/* ---- Bottom Navigation ---- */
function BottomNav({
  active,
  onChange
}) {
  const tabs = [{
    id: 'home',
    label: 'Home',
    icon: 'home'
  }, {
    id: 'map',
    label: 'Map',
    icon: 'map'
  }, {
    id: 'post',
    label: 'Post',
    icon: 'add_circle'
  }, {
    id: 'feed',
    label: 'Feed',
    icon: 'dynamic_feed'
  }, {
    id: 'profile',
    label: 'Profile',
    icon: 'person'
  }];
  return /*#__PURE__*/React.createElement("nav", {
    className: "bottom-nav"
  }, tabs.map(t => {
    if (t.id === 'post') {
      return /*#__PURE__*/React.createElement("button", {
        key: "post",
        className: "nav-fab",
        onClick: () => onChange('post'),
        "aria-label": "Post Review"
      }, /*#__PURE__*/React.createElement("div", {
        className: "nav-fab-btn"
      }, /*#__PURE__*/React.createElement(Icon, {
        name: "add_circle",
        fill: true,
        size: 28
      })), /*#__PURE__*/React.createElement("span", {
        className: "nav-item-label",
        style: {
          color: 'var(--on-surface-variant)',
          fontSize: 11
        }
      }, "Post"));
    }
    const isActive = active === t.id;
    return /*#__PURE__*/React.createElement("button", {
      key: t.id,
      className: `nav-item${isActive ? ' active' : ''}`,
      onClick: () => onChange(t.id),
      "aria-label": t.label
    }, /*#__PURE__*/React.createElement("div", {
      className: "nav-item-indicator"
    }, /*#__PURE__*/React.createElement(Icon, {
      name: t.icon,
      fill: isActive,
      size: 24
    })), /*#__PURE__*/React.createElement("span", {
      className: "nav-item-label"
    }, t.label));
  }));
}

/* ---- Star display ---- */
function Stars({
  rating,
  size = 14
}) {
  const full = Math.floor(rating);
  const hasHalf = rating % 1 >= 0.5;
  const empty = 5 - full - (hasHalf ? 1 : 0);
  const s = {
    fontSize: size,
    color: 'var(--star)',
    fontVariationSettings: "'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24",
    fontFamily: "'Material Symbols Rounded'",
    lineHeight: 1
  };
  const e = {
    ...s,
    color: 'var(--star-empty)',
    fontVariationSettings: "'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 24"
  };
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 1
    }
  }, [...Array(full)].map((_, i) => /*#__PURE__*/React.createElement("span", {
    key: `f${i}`,
    className: "material-symbols-rounded fill",
    style: s
  }, "star")), hasHalf && /*#__PURE__*/React.createElement("span", {
    className: "material-symbols-rounded fill",
    style: {
      ...s,
      fontVariationSettings: "'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24"
    }
  }, "star_half"), [...Array(empty)].map((_, i) => /*#__PURE__*/React.createElement("span", {
    key: `e${i}`,
    className: "material-symbols-rounded",
    style: e
  }, "star")));
}

/* ---- Category pill row ---- */
function CategoryPillRow({
  active,
  onChange,
  scrollable = true
}) {
  const {
    categories
  } = window.CeylonData;
  const allCats = [{
    id: 'all',
    label: 'All',
    icon: 'apps'
  }, ...categories];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      padding: '0 16px 2px',
      overflowX: scrollable ? 'auto' : 'visible'
    },
    className: scrollable ? 'scrollable' : ''
  }, allCats.map(c => /*#__PURE__*/React.createElement("button", {
    key: c.id,
    className: `chip${active === c.id ? ' active' : ''}`,
    style: {
      flexShrink: 0
    },
    onClick: () => onChange(c.id)
  }, /*#__PURE__*/React.createElement(Icon, {
    name: c.icon,
    size: 16
  }), c.label)));
}

/* ---- Place card — hero (vertical, for carousels) ---- */
function PlaceCardHero({
  place,
  onClick,
  width = 220
}) {
  const cat = window.CeylonData.categories.find(c => c.id === place.category);
  return /*#__PURE__*/React.createElement("div", {
    className: "place-card",
    style: {
      width,
      flexShrink: 0,
      cursor: 'pointer'
    },
    onClick: onClick
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: 160,
      background: place.bg,
      position: 'relative',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "place-img-scrim"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 12,
      right: 12,
      width: 36,
      height: 36,
      borderRadius: '50%',
      background: 'rgba(0,0,0,0.35)',
      backdropFilter: 'blur(8px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: cat?.icon || 'place',
    size: 18,
    style: {
      color: 'white'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: 10,
      left: 12,
      display: 'flex',
      alignItems: 'center',
      gap: 4
    }
  }, /*#__PURE__*/React.createElement(Stars, {
    rating: place.rating,
    size: 12
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      fontWeight: 600,
      color: 'white'
    }
  }, place.rating))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 14px 14px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: 'var(--type-title-sm)',
      color: 'var(--on-surface)',
      marginBottom: 4,
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, place.name), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 4,
      color: 'var(--on-surface-variant)',
      fontSize: 13
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_on",
    size: 13
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, place.location), /*#__PURE__*/React.createElement("span", {
    style: {
      marginLeft: 'auto',
      flexShrink: 0
    }
  }, place.distance)), cat && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "cat-label"
  }, cat.label.toUpperCase()))));
}

/* ---- Place card — row (horizontal list) ---- */
function PlaceCardRow({
  place,
  onClick
}) {
  const cat = window.CeylonData.categories.find(c => c.id === place.category);
  return /*#__PURE__*/React.createElement("div", {
    className: "place-card",
    style: {
      display: 'flex',
      cursor: 'pointer',
      overflow: 'hidden',
      height: 88
    },
    onClick: onClick
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 88,
      flexShrink: 0,
      background: place.bg,
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "place-img-scrim"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: cat?.icon || 'place',
    size: 28,
    style: {
      color: 'rgba(255,255,255,0.7)'
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      padding: '12px 14px',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 14px/1.3 var(--font-text)',
      color: 'var(--on-surface)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      marginBottom: 2
    }
  }, place.name), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--on-surface-variant)',
      display: 'flex',
      alignItems: 'center',
      gap: 3
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_on",
    size: 12
  }), place.location)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "rating-row"
  }, /*#__PURE__*/React.createElement(Stars, {
    rating: place.rating,
    size: 12
  }), /*#__PURE__*/React.createElement("span", {
    className: "rating-number",
    style: {
      fontSize: 12
    }
  }, place.rating), /*#__PURE__*/React.createElement("span", {
    className: "rating-count"
  }, "(", place.reviews, ")")), place.verified && /*#__PURE__*/React.createElement(Icon, {
    name: "verified",
    size: 14,
    fill: true,
    style: {
      color: 'var(--primary)'
    }
  }))));
}

/* ---- Review Card ---- */
function ReviewCard({
  review
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "review-card"
  }, /*#__PURE__*/React.createElement("div", {
    className: "review-header"
  }, /*#__PURE__*/React.createElement("div", {
    className: "avatar",
    style: {
      width: 36,
      height: 36,
      fontSize: 13
    }
  }, review.initials), /*#__PURE__*/React.createElement("div", {
    className: "review-meta"
  }, /*#__PURE__*/React.createElement("div", {
    className: "review-name"
  }, review.user), /*#__PURE__*/React.createElement("div", {
    className: "review-date"
  }, review.date)), /*#__PURE__*/React.createElement(Stars, {
    rating: review.rating,
    size: 13
  })), /*#__PURE__*/React.createElement("p", {
    className: "review-text"
  }, review.text));
}

/* ---- Exports ---- */
Object.assign(window, {
  Icon,
  StatusBar,
  TopBar,
  BottomNav,
  Stars,
  CategoryPillRow,
  PlaceCardHero,
  PlaceCardRow,
  ReviewCard
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/shared/components.jsx", error: String((e && e.message) || e) }); }

// ui_kits/ceylon-app/shared/data.js
try { (() => {
// Ceylon Review — shared data
// Plain JS — no Babel needed. Exports to window.CeylonData.

window.CeylonData = {
  categories: [{
    id: 'food',
    label: 'Food',
    icon: 'restaurant',
    cssClass: 'cat-food',
    color: '#C0512C',
    bg: 'linear-gradient(140deg,#E05D38 0%,#F5A62390 100%)'
  }, {
    id: 'nature',
    label: 'Nature',
    icon: 'forest',
    cssClass: 'cat-nature',
    color: '#43811F',
    bg: 'linear-gradient(140deg,#2D6A4F 0%,#52B78890 100%)'
  }, {
    id: 'beach',
    label: 'Beach',
    icon: 'beach_access',
    cssClass: 'cat-beach',
    color: '#00788F',
    bg: 'linear-gradient(140deg,#0E7C9D 0%,#47C4E090 100%)'
  }, {
    id: 'hotels',
    label: 'Hotels',
    icon: 'hotel',
    cssClass: 'cat-hotels',
    color: '#7A4F9E',
    bg: 'linear-gradient(140deg,#6B3FA0 0%,#9B59B690 100%)'
  }, {
    id: 'temples',
    label: 'Temples',
    icon: 'temple_buddhist',
    cssClass: 'cat-temples',
    color: '#9A5B00',
    bg: 'linear-gradient(140deg,#9A5B00 0%,#EF9F2790 100%)'
  }, {
    id: 'shopping',
    label: 'Shopping',
    icon: 'shopping_bag',
    cssClass: 'cat-shopping',
    color: '#B11A60',
    bg: 'linear-gradient(140deg,#B11A60 0%,#E91E8C90 100%)'
  }],
  places: [{
    id: 1,
    name: 'Ministry of Crab',
    category: 'food',
    location: 'Colombo Fort',
    rating: 4.9,
    reviews: '2.3k',
    distance: '0.8 km',
    bg: 'linear-gradient(140deg,#D94F35 0%,#F5A62380 60%,#E8653050 100%)',
    description: 'Sri Lanka\'s most celebrated seafood restaurant, famous for its giant mud crabs. Set inside the stunning Dutch Hospital Shopping Precinct.',
    tags: ['Seafood', 'Fine Dining', 'Crab', 'Upscale'],
    verified: true
  }, {
    id: 2,
    name: 'Mirissa Beach',
    category: 'beach',
    location: 'Matara District',
    rating: 4.7,
    reviews: '1.8k',
    distance: '158 km',
    bg: 'linear-gradient(140deg,#0E7C9D 0%,#47C4E070 60%,#0093BB50 100%)',
    description: 'A stunning crescent-shaped beach famous for whale watching, surfing, and spectacular sunsets on the southern coast.',
    tags: ['Whale Watching', 'Surfing', 'Sunset', 'Swimming'],
    verified: false
  }, {
    id: 3,
    name: 'Ravana Falls',
    category: 'nature',
    location: 'Ella',
    rating: 4.6,
    reviews: '987',
    distance: '196 km',
    bg: 'linear-gradient(140deg,#1D6B42 0%,#52B78870 60%,#2E9B5A50 100%)',
    description: 'One of the widest falls in Sri Lanka, steeped in the legend of King Ravana. A spectacular cascade in the central highlands.',
    tags: ['Waterfall', 'Hiking', 'Scenic', 'History'],
    verified: true
  }, {
    id: 4,
    name: 'Temple of the Tooth',
    category: 'temples',
    location: 'Kandy',
    rating: 4.8,
    reviews: '3.1k',
    distance: '115 km',
    bg: 'linear-gradient(140deg,#9A5B00 0%,#EF9F2770 60%,#D4930A50 100%)',
    description: 'Sri Lanka\'s most sacred Buddhist site, housing a relic of the tooth of the Buddha. A UNESCO World Heritage Site.',
    tags: ['UNESCO', 'Buddhist', 'Sacred', 'Heritage'],
    verified: true
  }, {
    id: 5,
    name: 'Heritance Kandalama',
    category: 'hotels',
    location: 'Dambulla',
    rating: 4.9,
    reviews: '2.7k',
    distance: '148 km',
    bg: 'linear-gradient(140deg,#6B3FA0 0%,#9B59B670 60%,#7D3FAE50 100%)',
    description: 'A masterpiece of sustainable architecture by Geoffrey Bawa, built into a rock face overlooking Kandalama Lake.',
    tags: ['Luxury', 'Bawa', 'Nature Views', 'Pool'],
    verified: true
  }, {
    id: 6,
    name: 'Odel Colombo',
    category: 'shopping',
    location: 'Colombo 3',
    rating: 4.3,
    reviews: '543',
    distance: '3.2 km',
    bg: 'linear-gradient(140deg,#B11A60 0%,#E91E8C70 60%,#C2185B50 100%)',
    description: 'Sri Lanka\'s premier fashion and lifestyle destination with local and international brands, a food court, and more.',
    tags: ['Fashion', 'Brands', 'Food Court', 'Lifestyle'],
    verified: false
  }, {
    id: 7,
    name: 'The Arcade Restaurant',
    category: 'food',
    location: 'Colombo 7',
    rating: 4.7,
    reviews: '1.2k',
    distance: '4.1 km',
    bg: 'linear-gradient(140deg,#D9534F 0%,#F0A50070 60%,#E2603050 100%)',
    description: 'Multi-cuisine restaurant set in the stunning Arcade Independence Square. Colonial architecture meets contemporary Sri Lankan hospitality.',
    tags: ['Multi-Cuisine', 'Colonial', 'Brunch', 'Ambience'],
    verified: false
  }, {
    id: 8,
    name: 'Sinharaja Forest Reserve',
    category: 'nature',
    location: 'Ratnapura',
    rating: 4.8,
    reviews: '765',
    distance: '123 km',
    bg: 'linear-gradient(140deg,#1A5C3A 0%,#3DB78B70 60%,#27856050 100%)',
    description: 'Sri Lanka\'s last primary rainforest and a UNESCO World Heritage Site. Home to rare endemic birds and biodiversity.',
    tags: ['UNESCO', 'Rainforest', 'Birdwatching', 'Trekking'],
    verified: true
  }, {
    id: 9,
    name: 'Unawatuna Beach',
    category: 'beach',
    location: 'Galle District',
    rating: 4.5,
    reviews: '1.4k',
    distance: '128 km',
    bg: 'linear-gradient(140deg,#007A94 0%,#38C8E870 60%,#009AB250 100%)',
    description: 'A sheltered bay with calm turquoise waters, white sand, and a lively beach strip. Great for snorkelling and swimming.',
    tags: ['Snorkelling', 'Swimming', 'Beach Bars', 'Calm Waters'],
    verified: false
  }, {
    id: 10,
    name: 'Dutch Hospital Colombo',
    category: 'shopping',
    location: 'Colombo Fort',
    rating: 4.4,
    reviews: '892',
    distance: '2.1 km',
    bg: 'linear-gradient(140deg,#A01555 0%,#E0207770 60%,#C0185A50 100%)',
    description: 'One of the oldest buildings in Colombo, converted into a premium dining and shopping precinct.',
    tags: ['Heritage', 'Dining', 'Boutiques', 'Colonial'],
    verified: false
  }, {
    id: 11,
    name: 'Nuga Gama',
    category: 'food',
    location: 'Cinnamon Grand',
    rating: 4.6,
    reviews: '678',
    distance: '2.3 km',
    bg: 'linear-gradient(140deg,#C06020 0%,#F5A62370 60%,#D4830050 100%)',
    description: 'Village dining under a 200-year-old banyan tree inside Cinnamon Grand. Traditional rice and curry in an authentic rural setting.',
    tags: ['Sri Lankan', 'Outdoor', 'Traditional', 'Curry'],
    verified: true
  }, {
    id: 12,
    name: 'Dambulla Cave Temple',
    category: 'temples',
    location: 'Dambulla',
    rating: 4.7,
    reviews: '2.1k',
    distance: '148 km',
    bg: 'linear-gradient(140deg,#8A4E00 0%,#D4930A70 60%,#A05E0050 100%)',
    description: 'Five cave temples with 153 Buddha statues and 80 documented paintings. A UNESCO World Heritage Site.',
    tags: ['UNESCO', 'Cave', 'Buddhist', 'Paintings'],
    verified: true
  }, {
    id: 13,
    name: 'Cinnamon Grand Colombo',
    category: 'hotels',
    location: 'Colombo 3',
    rating: 4.8,
    reviews: '1.9k',
    distance: '2.6 km',
    bg: 'linear-gradient(140deg,#5C3290 0%,#8E63CF70 60%,#6B3FAE50 100%)',
    description: "Colombo's iconic five-star hotel, home to 13 award-winning restaurants. A landmark of Sri Lankan hospitality with a rooftop pool.",
    tags: ['5-Star', 'Rooftop Pool', 'Restaurants', 'City Centre'],
    verified: true
  }, {
    id: 14,
    name: 'Hiriketiya Bay',
    category: 'beach',
    location: 'Dikwella',
    rating: 4.6,
    reviews: '543',
    distance: '172 km',
    bg: 'linear-gradient(140deg,#006D85 0%,#29B5D570 60%,#008BA250 100%)',
    description: "A horseshoe-shaped bay beloved by surfers and yoga retreats. Lush hills, palm trees, and a relaxed bohemian vibe.",
    tags: ['Surfing', 'Yoga', 'Horseshoe Bay', 'Laid-back'],
    verified: false
  }, {
    id: 15,
    name: 'Bambarakanda Falls',
    category: 'nature',
    location: 'Badulla',
    rating: 4.5,
    reviews: '432',
    distance: '184 km',
    bg: 'linear-gradient(140deg,#1D5C2E 0%,#4AAA6E70 60%,#29854450 100%)',
    description: "At 263 metres, Sri Lanka's tallest waterfall. Surrounded by pine forests and spectacular highland scenery.",
    tags: ['Tallest Waterfall', 'Hiking', 'Highlands', 'Photography'],
    verified: false
  }],
  reviews: [{
    id: 1,
    placeId: 1,
    user: 'Dilshan Perera',
    initials: 'DP',
    rating: 5,
    date: '2 days ago',
    text: 'Absolutely stunning experience! The giant mud crab in chilli sauce was cooked to perfection. Service was exceptional and the Dutch Hospital setting adds so much character. Worth every rupee.'
  }, {
    id: 2,
    placeId: 1,
    user: 'Sarah Mitchell',
    initials: 'SM',
    rating: 5,
    date: '1 week ago',
    text: "One of the best restaurants I've visited in all of Southeast Asia. The crab flies in fresh daily. Book well in advance — it fills up fast. Five stars without hesitation."
  }, {
    id: 3,
    placeId: 1,
    user: 'Nuwan Fernando',
    initials: 'NF',
    rating: 4,
    date: '2 weeks ago',
    text: 'Ministry of Crab lives up to the hype. Garlic chilli crab is divine. A bit pricey but a must-visit. The colonial setting is absolutely gorgeous in the evening.'
  }, {
    id: 4,
    placeId: 2,
    user: 'Amaya Silva',
    initials: 'AS',
    rating: 5,
    date: '3 days ago',
    text: 'Mirissa is magical at sunset. We saw blue whales on the morning boat trip — an experience I will never forget. The beach itself is postcard perfect.'
  }, {
    id: 5,
    placeId: 3,
    user: 'Ravindu Jayasinghe',
    initials: 'RJ',
    rating: 4,
    date: '5 days ago',
    text: 'Ravana Falls is impressive especially after the rains. Easy trek down. A bit busy on weekends but the scenery is absolutely worth it. Very Sri Lankan experience.'
  }],
  userProfile: {
    name: 'Harsha Walisundara',
    username: '@harshawa',
    bio: 'Exploring every corner of Sri Lanka 🇱🇰 | Food lover | Amateur photographer',
    reviewCount: 47,
    placesCount: 23,
    followerCount: 128,
    followingCount: 89,
    initials: 'HW',
    topCategories: ['food', 'nature', 'beach']
  }
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/ceylon-app/shared/data.js", error: String((e && e.message) || e) }); }

})();

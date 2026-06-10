// Ceylon Review — App root (navigation + theming controller)

const { useState, useEffect } = React;
const {
  Icon, StatusBar, TopBar, BottomNav,
  Stars, CategoryPillRow, PlaceCardHero, PlaceCardRow, ReviewCard,
} = window;

function App() {
  const [screen,        setScreen]        = useState('login');
  const [tab,           setTab]           = useState('home');
  const [category,      setCategory]      = useState('all');
  const [selectedPlace, setSelectedPlace] = useState(null);
  const [isDark,        setIsDark]        = useState(false);

  // Persist state across refreshes
  useEffect(() => {
    const s = localStorage.getItem('cr_screen');
    const c = localStorage.getItem('cr_category');
    const d = localStorage.getItem('cr_dark');
    if (s) setScreen(s);
    if (c) setCategory(c);
    if (d) setIsDark(d === '1');
  }, []);

  useEffect(() => { localStorage.setItem('cr_screen',   screen);           }, [screen]);
  useEffect(() => { localStorage.setItem('cr_category', category);         }, [category]);
  useEffect(() => { localStorage.setItem('cr_dark',     isDark ? '1':'0'); }, [isDark]);

  function navigate(screenName, place) {
    setSelectedPlace(place || null);
    setScreen(screenName);
    if (screenName === 'home')    setTab('home');
    if (screenName === 'map')     setTab('map');
    if (screenName === 'profile') setTab('profile');
    if (screenName === 'post')    setTab('post');
  }

  function handleTabChange(tabId) {
    setTab(tabId);
    if (tabId === 'home')    { setScreen('home'); }
    if (tabId === 'map')     { setScreen('map'); }
    if (tabId === 'post')    { setScreen('post'); }
    if (tabId === 'feed')    { setScreen('home'); }
    if (tabId === 'profile') { setScreen('profile'); }
  }

  function handleCategoryChange(catId) {
    setCategory(catId);
    if (screen === 'home' || screen === 'category') setScreen('category');
  }

  const catClass     = category !== 'all' ? `cat-${category}` : '';
  const showBottomNav = screen !== 'login';

  const screenProps = {
    onNavigate:        navigate,
    activeCategory:    category,
    onCategoryChange:  handleCategoryChange,
  };

  const { categories } = window.CeylonData;
  const allCategories  = [
    { id:'all', label:'Default', color:'#0F6E56' },
    ...categories,
  ];

  return (
    <>
      {/* ═══ Phone shell ═══ */}
      <div className="phone-shell" data-theme={isDark ? 'dark' : undefined}>
        <div className={`app-root${catClass ? ` ${catClass}` : ''}`}>
          <StatusBar />

          {/* Screen routing */}
          <div style={{ flex:1, display:'flex', flexDirection:'column', minHeight:0, overflow:'hidden' }}>
            {screen === 'login'       && <LoginScreen        onNavigate={navigate} />}
            {screen === 'home'        && <HomeScreen         {...screenProps} />}
            {screen === 'category'    && <CategoryScreen     {...screenProps} />}
            {screen === 'placeDetail' && (
              <PlaceDetailScreen
                place={selectedPlace}
                onNavigate={navigate}
                onWriteReview={p => navigate('post', p)}
              />
            )}
            {screen === 'post'        && <WriteReviewScreen  place={selectedPlace} onNavigate={navigate} />}
            {screen === 'map'         && <MapScreen          {...screenProps} />}
            {screen === 'profile'     && <ProfileScreen      onNavigate={navigate} />}
          </div>

          {showBottomNav && <BottomNav active={tab} onChange={handleTabChange} />}
          <div className="home-indicator" />
        </div>
      </div>

      {/* ═══ External controls panel ═══ */}
      <div className="controls">
        <div>
          <div className="ctrl-label">Appearance</div>
          <button className={`ctrl-btn${isDark ? ' active-ctrl' : ''}`}
            onClick={() => setIsDark(d => !d)}>
            <Icon name={isDark ? 'dark_mode' : 'light_mode'} size={18}
              style={{ color: isDark ? '#EF9F27' : '#fff' }} />
            {isDark ? 'Dark Mode' : 'Light Mode'}
          </button>
        </div>

        <div>
          <div className="ctrl-label">Category Theme</div>
          <div style={{ display:'flex', flexDirection:'column', gap:6 }}>
            {allCategories.map(c => (
              <button key={c.id}
                className={`ctrl-btn${category === c.id ? ' active-ctrl' : ''}`}
                onClick={() => {
                  setCategory(c.id);
                  if (c.id !== 'all' && (screen === 'home' || screen === 'category')) {
                    setScreen('category');
                  }
                }}>
                <span className="ctrl-swatch" style={{ background: c.color }} />
                {c.label}
              </button>
            ))}
          </div>
        </div>

        <div>
          <div className="ctrl-label">Screens</div>
          <div style={{ display:'flex', flexDirection:'column', gap:6 }}>
            {[
              { id:'login',       label:'Login' },
              { id:'home',        label:'Home' },
              { id:'category',    label:'Category' },
              { id:'map',         label:'Map' },
              { id:'profile',     label:'Profile' },
            ].map(s => (
              <button key={s.id}
                className={`ctrl-btn${screen === s.id ? ' active-ctrl' : ''}`}
                onClick={() => navigate(s.id)}>
                {s.label}
              </button>
            ))}
            <button className={`ctrl-btn${screen === 'placeDetail' ? ' active-ctrl' : ''}`}
              onClick={() => navigate('placeDetail', window.CeylonData.places[0])}>
              Place Detail
            </button>
            <button className={`ctrl-btn${screen === 'post' ? ' active-ctrl' : ''}`}
              onClick={() => navigate('post', window.CeylonData.places[0])}>
              Write Review
            </button>
          </div>
        </div>
      </div>
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);

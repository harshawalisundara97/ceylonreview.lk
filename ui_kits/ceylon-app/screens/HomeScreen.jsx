// HomeScreen — Trending carousel + nearby list + category pills

function HomeScreen({ onNavigate, activeCategory, onCategoryChange }) {
  const { places, categories } = window.CeylonData;
  const { useState } = React;
  const [searchVal, setSearchVal] = useState('');

  const activeCat = activeCategory || 'all';
  const filtered = activeCat === 'all' ? places : places.filter(p => p.category === activeCat);
  const trending = filtered.slice(0, 5);
  const nearby   = filtered.slice(0, 6);

  return (
    <div className="screen screen-enter">
      {/* Top bar with logo */}
      <div className="top-bar" style={{ padding:'0 8px 0 16px' }}>
        <div style={{ flex:1, display:'flex', alignItems:'center', gap:8 }}>
          <div style={{ width:32, height:32, borderRadius:'50%', background:'var(--primary)',
            display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Icon name="location_on" fill size={18} style={{ color:'white' }} />
          </div>
          <div>
            <div style={{ font:'400 11px/1 var(--font-text)', color:'var(--on-surface-variant)', marginBottom:2 }}>Discover in</div>
            <div style={{ font:'700 16px/1 var(--font-display)', color:'var(--on-surface)' }}>Sri Lanka 🇱🇰</div>
          </div>
        </div>
        <button className="icon-btn" aria-label="Notifications">
          <Icon name="notifications" />
        </button>
        <div className="avatar" style={{ width:38, height:38, fontSize:14, cursor:'pointer' }}
          onClick={() => onNavigate('profile')}>
          HW
        </div>
      </div>

      <div className="scrollable">
        {/* Search bar */}
        <div style={{ padding:'8px 16px 16px' }}>
          <div className="search-bar" onClick={() => {}}>
            <Icon name="search" style={{ color:'var(--on-surface-variant)' }} />
            <input
              placeholder="Search places in Sri Lanka…"
              value={searchVal}
              onChange={e => setSearchVal(e.target.value)}
              style={{ fontSize:15 }}
            />
            <Icon name="tune" size={20} style={{ color:'var(--on-surface-variant)' }} />
          </div>
        </div>

        {/* Category pills */}
        <div style={{ marginBottom:20 }}>
          <div style={{ overflowX:'auto', display:'flex', gap:8, padding:'0 16px 4px' }}
            className="scrollable" >
            {[{ id:'all', label:'All', icon:'apps' }, ...categories].map(c => (
              <button key={c.id}
                className={`chip${activeCat === c.id ? ' active' : ''}`}
                style={{ flexShrink:0 }}
                onClick={() => onCategoryChange(c.id)}>
                <Icon name={c.icon} size={16} />
                {c.label}
              </button>
            ))}
          </div>
        </div>

        {/* Trending This Week */}
        <div style={{ marginBottom:24 }}>
          <div className="section-header">
            <span className="section-title">Trending This Week</span>
            <button className="section-link">See all</button>
          </div>
          <div style={{ overflowX:'auto', display:'flex', gap:12, padding:'0 16px 8px' }}>
            {trending.map(place => (
              <PlaceCardHero
                key={place.id}
                place={place}
                onClick={() => onNavigate('placeDetail', place)}
              />
            ))}
          </div>
        </div>

        {/* Popular Nearby */}
        <div style={{ marginBottom:16 }}>
          <div className="section-header">
            <span className="section-title">Popular Nearby</span>
            <button className="section-link" onClick={() => onNavigate('category')}>See all</button>
          </div>
          <div style={{ display:'flex', flexDirection:'column', gap:10, padding:'0 16px' }}>
            {nearby.map(place => (
              <PlaceCardRow
                key={place.id}
                place={place}
                onClick={() => onNavigate('placeDetail', place)}
              />
            ))}
          </div>
        </div>

        {/* Bottom spacer */}
        <div style={{ height:24 }} />
      </div>
    </div>
  );
}

window.HomeScreen = HomeScreen;

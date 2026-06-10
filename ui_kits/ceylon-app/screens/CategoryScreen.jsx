// CategoryScreen — Browse places by category with grid layout

function CategoryScreen({ onNavigate, activeCategory, onCategoryChange }) {
  const { places, categories } = window.CeylonData;
  const { useState } = React;
  const [sortBy, setSortBy] = useState('rating');

  const activeCat = activeCategory || 'all';
  const catMeta = categories.find(c => c.id === activeCat);
  const filtered = activeCat === 'all' ? places : places.filter(p => p.category === activeCat);
  const sorted = [...filtered].sort((a, b) =>
    sortBy === 'rating' ? b.rating - a.rating : a.distance.localeCompare(b.distance)
  );

  const sortOptions = [
    { id: 'rating',   label: 'Top Rated' },
    { id: 'distance', label: 'Nearest' },
    { id: 'reviews',  label: 'Most Reviewed' },
  ];

  return (
    <div className="screen screen-enter">
      {/* Category header banner */}
      <div style={{
        background: catMeta ? `linear-gradient(135deg, var(--primary) 0%, var(--primary-container) 100%)` : 'var(--surface-container)',
        padding: '16px 16px 20px',
        transition: 'var(--theme-transition)',
      }}>
        {/* Back + title row */}
        <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:16 }}>
          <button className="icon-btn" onClick={() => onNavigate('home')}
            style={{ color: catMeta ? 'var(--on-primary)' : 'var(--on-surface)', background:'rgba(255,255,255,0.15)' }}>
            <Icon name="arrow_back" />
          </button>
          <div style={{ flex:1 }}>
            <div style={{ font:'400 11px/1 var(--font-text)', color: catMeta ? 'var(--on-primary)' : 'var(--on-surface-variant)',
              opacity:0.75, letterSpacing:'0.08em', textTransform:'uppercase', marginBottom:3 }}>
              Browse
            </div>
            <div style={{ font:'700 22px/1 var(--font-display)', color: catMeta ? 'var(--on-primary)' : 'var(--on-surface)' }}>
              {catMeta ? catMeta.label : 'All Places'}
            </div>
          </div>
          {catMeta && (
            <div style={{ width:48, height:48, borderRadius:'50%', background:'rgba(255,255,255,0.2)',
              display:'flex', alignItems:'center', justifyContent:'center' }}>
              <Icon name={catMeta.icon} size={26} style={{ color:'var(--on-primary)' }} />
            </div>
          )}
        </div>

        {/* Sub-category pills */}
        <div style={{ overflowX:'auto', display:'flex', gap:8 }}>
          {[{ id:'all', label:'All', icon:'apps' }, ...categories].map(c => (
            <button key={c.id}
              className="chip"
              style={{
                flexShrink:0,
                background: activeCat === c.id ? 'rgba(255,255,255,0.9)' : 'rgba(255,255,255,0.15)',
                borderColor: activeCat === c.id ? 'transparent' : 'rgba(255,255,255,0.35)',
                color: activeCat === c.id ? 'var(--primary)' : (catMeta ? 'var(--on-primary)' : 'var(--on-surface-variant)'),
              }}
              onClick={() => onCategoryChange(c.id)}>
              <Icon name={c.icon} size={16} />
              {c.label}
            </button>
          ))}
        </div>
      </div>

      {/* Sort + count bar */}
      <div style={{ display:'flex', alignItems:'center', gap:8, padding:'12px 16px 8px',
        background:'var(--surface)' }}>
        <span style={{ font:'var(--type-body-sm)', color:'var(--on-surface-variant)', flex:1 }}>
          {sorted.length} places
        </span>
        {sortOptions.map(s => (
          <button key={s.id}
            className={`chip${sortBy === s.id ? ' active' : ''}`}
            style={{ height:28, fontSize:12 }}
            onClick={() => setSortBy(s.id)}>
            {s.label}
          </button>
        ))}
      </div>

      {/* Results grid */}
      <div className="scrollable" style={{ padding:'8px 16px 24px' }}>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
          {sorted.map(place => {
            const cat = categories.find(c => c.id === place.category);
            return (
              <div key={place.id} className="place-card"
                onClick={() => onNavigate('placeDetail', place)}>
                {/* Image */}
                <div style={{ height:120, background:place.bg, position:'relative', overflow:'hidden' }}>
                  <div className="place-img-scrim" />
                  <div style={{ position:'absolute', top:8, right:8, width:28, height:28,
                    borderRadius:'50%', background:'rgba(0,0,0,0.3)', backdropFilter:'blur(6px)',
                    display:'flex', alignItems:'center', justifyContent:'center' }}>
                    <Icon name={cat?.icon||'place'} size={14} style={{ color:'white' }} />
                  </div>
                  <div style={{ position:'absolute', bottom:8, left:8, display:'flex', alignItems:'center', gap:3 }}>
                    <Stars rating={place.rating} size={11} />
                    <span style={{ fontSize:11, fontWeight:600, color:'white' }}>{place.rating}</span>
                  </div>
                </div>
                {/* Info */}
                <div style={{ padding:'10px 12px 12px' }}>
                  <div style={{ font:'600 13px/1.3 var(--font-text)', color:'var(--on-surface)',
                    overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap', marginBottom:4 }}>
                    {place.name}
                  </div>
                  <div style={{ display:'flex', alignItems:'center', gap:3, color:'var(--on-surface-variant)', fontSize:11 }}>
                    <Icon name="location_on" size={11} />
                    <span style={{ overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{place.location}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

window.CategoryScreen = CategoryScreen;

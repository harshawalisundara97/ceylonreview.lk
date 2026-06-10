// Ceylon Review — Shared UI Components
// Exports: StatusBar, TopBar, BottomNav, Stars, CategoryPillRow, PlaceCardHero, PlaceCardRow, ReviewCard

const { useState, useEffect } = React;

/* ---- Icon shorthand ---- */
function Icon({ name, fill = false, size = 24, style = {} }) {
  const cls = `material-symbols-rounded${fill ? ' fill' : ''}${size === 20 ? ' sz20' : ''}`;
  return <span className={cls} style={{ fontSize: size, ...style }}>{name}</span>;
}

/* ---- Status bar ---- */
function StatusBar({ transparent = false, light = false }) {
  const [time, setTime] = useState(() => {
    const d = new Date();
    return d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
  });
  useEffect(() => {
    const t = setInterval(() => {
      const d = new Date();
      setTime(d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }));
    }, 30000);
    return () => clearInterval(t);
  }, []);
  const c = light ? 'rgba(255,255,255,0.92)' : 'var(--on-surface)';
  return (
    <div className="status-bar" style={{ background: transparent ? 'transparent' : 'var(--surface)', color: c }}>
      <span className="status-bar-time" style={{ color: c }}>{time}</span>
      <div className="status-bar-icons" style={{ color: c }}>
        <Icon name="signal_cellular_alt" size={16} />
        <Icon name="wifi" size={16} />
        <Icon name="battery_5_bar" size={16} />
      </div>
    </div>
  );
}

/* ---- Top App Bar ---- */
function TopBar({ title, logo = false, onBack, actions = [] }) {
  return (
    <div className="top-bar">
      {onBack && (
        <button className="icon-btn" onClick={onBack} aria-label="Back">
          <Icon name="arrow_back" />
        </button>
      )}
      {logo ? (
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8 }}>
          <img src="../../assets/logo-icon.svg" alt="Ceylon Review" style={{ height: 32 }} />
          <span style={{ font: 'var(--type-title-lg)', color: 'var(--primary)' }}>Ceylon Review</span>
        </div>
      ) : (
        <span className="top-bar-title">{title}</span>
      )}
      <div style={{ display: 'flex', gap: 4 }}>
        {actions.map((a, i) => (
          <button key={i} className="icon-btn" onClick={a.onPress} aria-label={a.label}>
            <Icon name={a.icon} fill={a.fill} />
          </button>
        ))}
      </div>
    </div>
  );
}

/* ---- Bottom Navigation ---- */
function BottomNav({ active, onChange }) {
  const tabs = [
    { id: 'home',    label: 'Home',    icon: 'home' },
    { id: 'map',     label: 'Map',     icon: 'map' },
    { id: 'post',    label: 'Post',    icon: 'add_circle' },
    { id: 'feed',    label: 'Feed',    icon: 'dynamic_feed' },
    { id: 'profile', label: 'Profile', icon: 'person' },
  ];
  return (
    <nav className="bottom-nav">
      {tabs.map(t => {
        if (t.id === 'post') {
          return (
            <button key="post" className="nav-fab" onClick={() => onChange('post')} aria-label="Post Review">
              <div className="nav-fab-btn">
                <Icon name="add_circle" fill size={28} />
              </div>
              <span className="nav-item-label" style={{ color: 'var(--on-surface-variant)', fontSize: 11 }}>Post</span>
            </button>
          );
        }
        const isActive = active === t.id;
        return (
          <button
            key={t.id}
            className={`nav-item${isActive ? ' active' : ''}`}
            onClick={() => onChange(t.id)}
            aria-label={t.label}
          >
            <div className="nav-item-indicator">
              <Icon name={t.icon} fill={isActive} size={24} />
            </div>
            <span className="nav-item-label">{t.label}</span>
          </button>
        );
      })}
    </nav>
  );
}

/* ---- Star display ---- */
function Stars({ rating, size = 14 }) {
  const full  = Math.floor(rating);
  const hasHalf = (rating % 1) >= 0.5;
  const empty = 5 - full - (hasHalf ? 1 : 0);
  const s = { fontSize: size, color: 'var(--star)', fontVariationSettings: "'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24", fontFamily: "'Material Symbols Rounded'", lineHeight: 1 };
  const e = { ...s, color: 'var(--star-empty)', fontVariationSettings: "'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 24" };
  return (
    <span style={{ display:'inline-flex', alignItems:'center', gap:1 }}>
      {[...Array(full)].map((_,i)  => <span key={`f${i}`}  className="material-symbols-rounded fill" style={s}>star</span>)}
      {hasHalf && <span className="material-symbols-rounded fill" style={{ ...s, fontVariationSettings:"'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24" }}>star_half</span>}
      {[...Array(empty)].map((_,i) => <span key={`e${i}`}  className="material-symbols-rounded"      style={e}>star</span>)}
    </span>
  );
}

/* ---- Category pill row ---- */
function CategoryPillRow({ active, onChange, scrollable = true }) {
  const { categories } = window.CeylonData;
  const allCats = [{ id: 'all', label: 'All', icon: 'apps' }, ...categories];
  return (
    <div style={{
      display: 'flex', gap: 8, padding: '0 16px 2px',
      overflowX: scrollable ? 'auto' : 'visible',
    }} className={scrollable ? 'scrollable' : ''}>
      {allCats.map(c => (
        <button
          key={c.id}
          className={`chip${active === c.id ? ' active' : ''}`}
          style={{ flexShrink: 0 }}
          onClick={() => onChange(c.id)}
        >
          <Icon name={c.icon} size={16} />
          {c.label}
        </button>
      ))}
    </div>
  );
}

/* ---- Place card — hero (vertical, for carousels) ---- */
function PlaceCardHero({ place, onClick, width = 220 }) {
  const cat = window.CeylonData.categories.find(c => c.id === place.category);
  return (
    <div
      className="place-card"
      style={{ width, flexShrink: 0, cursor: 'pointer' }}
      onClick={onClick}
    >
      {/* Image area */}
      <div style={{ height: 160, background: place.bg, position: 'relative', overflow: 'hidden' }}>
        <div className="place-img-scrim" />
        {/* Floating icon */}
        <div style={{ position:'absolute', top:12, right:12, width:36, height:36,
          borderRadius:'50%', background:'rgba(0,0,0,0.35)', backdropFilter:'blur(8px)',
          display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon name={cat?.icon || 'place'} size={18} style={{ color:'white' }} />
        </div>
        {/* Rating overlay */}
        <div style={{ position:'absolute', bottom:10, left:12, display:'flex', alignItems:'center', gap:4 }}>
          <Stars rating={place.rating} size={12} />
          <span style={{ fontSize:12, fontWeight:600, color:'white' }}>{place.rating}</span>
        </div>
      </div>
      {/* Info */}
      <div style={{ padding: '12px 14px 14px' }}>
        <div style={{ font:'var(--type-title-sm)', color:'var(--on-surface)', marginBottom:4,
          whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>
          {place.name}
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:4, color:'var(--on-surface-variant)', fontSize:13 }}>
          <Icon name="location_on" size={13} />
          <span style={{ overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{place.location}</span>
          <span style={{ marginLeft:'auto', flexShrink:0 }}>{place.distance}</span>
        </div>
        {cat && (
          <div style={{ marginTop:8 }}>
            <span className="cat-label">{cat.label.toUpperCase()}</span>
          </div>
        )}
      </div>
    </div>
  );
}

/* ---- Place card — row (horizontal list) ---- */
function PlaceCardRow({ place, onClick }) {
  const cat = window.CeylonData.categories.find(c => c.id === place.category);
  return (
    <div
      className="place-card"
      style={{ display:'flex', cursor:'pointer', overflow:'hidden', height:88 }}
      onClick={onClick}
    >
      {/* Thumbnail */}
      <div style={{ width:88, flexShrink:0, background:place.bg, position:'relative' }}>
        <div className="place-img-scrim" />
        <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon name={cat?.icon||'place'} size={28} style={{ color:'rgba(255,255,255,0.7)' }} />
        </div>
      </div>
      {/* Info */}
      <div style={{ flex:1, padding:'12px 14px', display:'flex', flexDirection:'column', justifyContent:'space-between', minWidth:0 }}>
        <div>
          <div style={{ font:'600 14px/1.3 var(--font-text)', color:'var(--on-surface)',
            whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis', marginBottom:2 }}>
            {place.name}
          </div>
          <div style={{ fontSize:12, color:'var(--on-surface-variant)', display:'flex', alignItems:'center', gap:3 }}>
            <Icon name="location_on" size={12} />
            {place.location}
          </div>
        </div>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
          <div className="rating-row">
            <Stars rating={place.rating} size={12} />
            <span className="rating-number" style={{ fontSize:12 }}>{place.rating}</span>
            <span className="rating-count">({place.reviews})</span>
          </div>
          {place.verified && (
            <Icon name="verified" size={14} fill style={{ color:'var(--primary)' }} />
          )}
        </div>
      </div>
    </div>
  );
}

/* ---- Review Card ---- */
function ReviewCard({ review }) {
  return (
    <div className="review-card">
      <div className="review-header">
        <div className="avatar" style={{ width:36, height:36, fontSize:13 }}>
          {review.initials}
        </div>
        <div className="review-meta">
          <div className="review-name">{review.user}</div>
          <div className="review-date">{review.date}</div>
        </div>
        <Stars rating={review.rating} size={13} />
      </div>
      <p className="review-text">{review.text}</p>
    </div>
  );
}

/* ---- Exports ---- */
Object.assign(window, {
  Icon, StatusBar, TopBar, BottomNav, Stars,
  CategoryPillRow, PlaceCardHero, PlaceCardRow, ReviewCard,
});

// PlaceDetailScreen — Full detail view with reviews and actions

function PlaceDetailScreen({ place, onNavigate, onWriteReview }) {
  const { reviews, categories } = window.CeylonData;
  const { useState } = React;
  const [saved, setSaved] = useState(false);

  if (!place) return null;
  const cat = categories.find(c => c.id === place.category);
  const placeReviews = reviews.filter(r => r.placeId === place.id);
  const allReviews = placeReviews.length ? placeReviews : reviews.slice(0, 3);

  return (
    <div className="screen screen-enter">
      {/* Hero image header — full bleed, overlaid controls */}
      <div style={{ position:'relative', height:260, background:place.bg, flexShrink:0, overflow:'hidden' }}>
        {/* Scrim */}
        <div style={{ position:'absolute', inset:0,
          background:'linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.1) 55%, transparent 100%)' }} />

        {/* Top controls */}
        <div style={{ position:'absolute', top:0, left:0, right:0, display:'flex',
          justifyContent:'space-between', padding:'8px 8px 0' }}>
          <button className="icon-btn" onClick={() => onNavigate('home')}
            style={{ background:'rgba(0,0,0,0.35)', backdropFilter:'blur(8px)', color:'white' }}>
            <Icon name="arrow_back" />
          </button>
          <div style={{ display:'flex', gap:8 }}>
            <button className="icon-btn" onClick={() => setSaved(s => !s)}
              style={{ background:'rgba(0,0,0,0.35)', backdropFilter:'blur(8px)', color:'white' }}>
              <Icon name={saved ? 'bookmark' : 'bookmark_border'} fill={saved} />
            </button>
            <button className="icon-btn"
              style={{ background:'rgba(0,0,0,0.35)', backdropFilter:'blur(8px)', color:'white' }}>
              <Icon name="ios_share" />
            </button>
          </div>
        </div>

        {/* Bottom info overlay */}
        <div style={{ position:'absolute', bottom:0, left:0, right:0, padding:'0 16px 16px' }}>
          {cat && (
            <div style={{ display:'inline-flex', alignItems:'center', gap:4, height:24, padding:'0 10px',
              borderRadius:'999px', background:'var(--primary)', marginBottom:8 }}>
              <Icon name={cat.icon} size={13} style={{ color:'var(--on-primary)' }} />
              <span style={{ font:'600 11px/1 var(--font-text)', letterSpacing:'0.06em',
                textTransform:'uppercase', color:'var(--on-primary)' }}>{cat.label}</span>
            </div>
          )}
          <div style={{ font:'700 24px/1.15 var(--font-display)', color:'white', marginBottom:6, textWrap:'pretty' }}>
            {place.name}
          </div>
          <div style={{ display:'flex', alignItems:'center', gap:6 }}>
            <Stars rating={place.rating} size={15} />
            <span style={{ fontWeight:700, color:'white', fontSize:15 }}>{place.rating}</span>
            <span style={{ color:'rgba(255,255,255,0.7)', fontSize:13 }}>({place.reviews} reviews)</span>
            {place.verified && <Icon name="verified" fill size={16} style={{ color:'#4FC3F7', marginLeft:2 }} />}
          </div>
        </div>
      </div>

      {/* Scrollable body */}
      <div className="scrollable">
        {/* Location + distance */}
        <div style={{ display:'flex', alignItems:'center', gap:8, padding:'16px 16px 8px',
          borderBottom:'1px solid var(--outline-variant)' }}>
          <Icon name="location_on" fill size={18} style={{ color:'var(--primary)' }} />
          <span style={{ font:'var(--type-body-md)', color:'var(--on-surface)', flex:1 }}>{place.location}</span>
          <span style={{ font:'var(--type-body-sm)', color:'var(--on-surface-variant)' }}>{place.distance} away</span>
        </div>

        {/* Quick action buttons */}
        <div style={{ display:'flex', gap:10, padding:'16px 16px', borderBottom:'1px solid var(--outline-variant)' }}>
          {[
            { icon:'directions', label:'Directions' },
            { icon:'call',       label:'Call' },
            { icon:'language',   label:'Website' },
          ].map(a => (
            <button key={a.label} style={{
              flex:1, height:64, borderRadius:'var(--radius-lg)', border:'1.5px solid var(--outline-variant)',
              background:'var(--surface-container-low)', display:'flex', flexDirection:'column',
              alignItems:'center', justifyContent:'center', gap:6, cursor:'pointer',
              color:'var(--primary)', transition:'background 160ms ease',
            }}>
              <Icon name={a.icon} size={22} style={{ color:'var(--primary)' }} />
              <span style={{ font:'600 12px/1 var(--font-text)', color:'var(--on-surface-variant)' }}>{a.label}</span>
            </button>
          ))}
        </div>

        {/* About */}
        <div style={{ padding:'16px 16px 0' }}>
          <div style={{ font:'var(--type-title-md)', color:'var(--on-surface)', marginBottom:8 }}>About</div>
          <p style={{ font:'var(--type-body-md)', color:'var(--on-surface-variant)', lineHeight:1.6 }}>
            {place.description}
          </p>
        </div>

        {/* Tags */}
        <div style={{ display:'flex', gap:8, flexWrap:'wrap', padding:'12px 16px 16px' }}>
          {place.tags.map(tag => (
            <span key={tag} className="tag">{tag}</span>
          ))}
        </div>

        <div className="divider" />

        {/* Rating breakdown */}
        <div style={{ padding:'16px 16px' }}>
          <div style={{ display:'flex', alignItems:'center', gap:20, marginBottom:16 }}>
            <div style={{ textAlign:'center' }}>
              <div style={{ font:'800 48px/1 var(--font-display)', color:'var(--on-surface)' }}>{place.rating}</div>
              <Stars rating={place.rating} size={16} />
              <div style={{ font:'var(--type-body-sm)', color:'var(--on-surface-variant)', marginTop:4 }}>
                {place.reviews} reviews
              </div>
            </div>
            {/* Rating bars */}
            <div style={{ flex:1, display:'flex', flexDirection:'column', gap:6 }}>
              {[5,4,3,2,1].map(n => {
                const pct = n === 5 ? 72 : n === 4 ? 18 : n === 3 ? 7 : n === 2 ? 2 : 1;
                return (
                  <div key={n} style={{ display:'flex', alignItems:'center', gap:8 }}>
                    <span style={{ font:'400 12px/1 var(--font-text)', color:'var(--on-surface-variant)', width:8 }}>{n}</span>
                    <div style={{ flex:1, height:6, borderRadius:3, background:'var(--outline-variant)', overflow:'hidden' }}>
                      <div style={{ width:`${pct}%`, height:'100%', background:'var(--star)', borderRadius:3 }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        <div className="divider" />

        {/* Reviews */}
        <div style={{ padding:'16px 0 0' }}>
          <div className="section-header">
            <span className="section-title">Reviews</span>
            <button className="section-link">See all</button>
          </div>
          {allReviews.map(r => <ReviewCard key={r.id} review={r} />)}
        </div>

        {/* Write review CTA */}
        <div style={{ padding:'20px 16px 32px' }}>
          <button className="btn btn-primary btn-full"
            onClick={() => onWriteReview(place)}>
            <Icon name="rate_review" size={20} style={{ color:'var(--on-primary)' }} />
            Write a Review
          </button>
        </div>
      </div>
    </div>
  );
}

window.PlaceDetailScreen = PlaceDetailScreen;

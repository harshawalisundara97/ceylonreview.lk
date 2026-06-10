// ProfileScreen — User profile with stats, tabs and reviews

function ProfileScreen({ onNavigate }) {
  const { useState } = React;
  const { places, reviews, userProfile, categories } = window.CeylonData;
  const [activeTab, setActiveTab] = useState('reviews');
  const [following, setFollowing] = useState(false);

  const userReviews = reviews.slice(0, 3);
  const savedPlaces = places.filter(p => ['food','beach','nature'].includes(p.category)).slice(0, 4);
  const visitedPlaces = places.slice(2, 7);

  const tabs = [
    { id:'reviews',  label:'Reviews',  icon:'rate_review',  count:userProfile.reviewCount },
    { id:'saved',    label:'Saved',    icon:'bookmark',     count:userProfile.placesCount },
    { id:'visited',  label:'Visited',  icon:'location_on',  count:userProfile.placesCount + 5 },
  ];

  return (
    <div className="screen screen-enter">
      <TopBar
        title="Profile"
        onBack={() => onNavigate('home')}
        actions={[
          { icon:'settings', label:'Settings', onPress:() => {} },
          { icon:'more_vert', label:'More', onPress:() => {} },
        ]}
      />

      <div className="scrollable">
        {/* Profile header */}
        <div style={{ background:'var(--category-tint)', padding:'20px 16px 24px', borderBottom:'1px solid var(--outline-variant)' }}>
          <div style={{ display:'flex', gap:16, alignItems:'flex-start', marginBottom:16 }}>
            {/* Avatar */}
            <div style={{ width:72, height:72, borderRadius:'50%', background:'var(--primary)',
              display:'flex', alignItems:'center', justifyContent:'center',
              fontSize:26, fontWeight:700, color:'var(--on-primary)', fontFamily:'var(--font-display)',
              flexShrink:0, border:'3px solid var(--surface)' }}>
              {userProfile.initials}
            </div>
            {/* Name + handle */}
            <div style={{ flex:1, paddingTop:4 }}>
              <div style={{ font:'700 20px/1.2 var(--font-display)', color:'var(--on-surface)', marginBottom:4 }}>
                {userProfile.name}
              </div>
              <div style={{ font:'400 14px/1 var(--font-text)', color:'var(--on-surface-variant)', marginBottom:10 }}>
                {userProfile.username}
              </div>
              <div style={{ display:'flex', gap:8 }}>
                <button className="btn btn-primary"
                  style={{ height:36, padding:'0 20px', borderRadius:'var(--radius-pill)',
                    background: following ? 'var(--surface-container-high)' : 'var(--primary)',
                    color: following ? 'var(--on-surface)' : 'var(--on-primary)', fontSize:14 }}
                  onClick={() => setFollowing(f => !f)}>
                  {following ? 'Following' : 'Follow'}
                </button>
                <button className="btn btn-outline"
                  style={{ height:36, padding:'0 16px', borderRadius:'var(--radius-pill)', fontSize:14 }}>
                  Message
                </button>
              </div>
            </div>
          </div>

          {/* Bio */}
          <p style={{ font:'var(--type-body-sm)', color:'var(--on-surface-variant)', marginBottom:16, lineHeight:1.5 }}>
            {userProfile.bio}
          </p>

          {/* Stats row */}
          <div style={{ display:'flex', justifyContent:'space-around',
            padding:'16px 0 0', borderTop:'1px solid var(--outline-variant)' }}>
            {[
              { value:userProfile.reviewCount, label:'Reviews' },
              { value:userProfile.placesCount, label:'Places' },
              { value:userProfile.followerCount, label:'Followers' },
              { value:userProfile.followingCount, label:'Following' },
            ].map(s => (
              <div key={s.label} className="stat-item">
                <span className="stat-value">{s.value}</span>
                <span className="stat-label">{s.label}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Top categories */}
        <div style={{ padding:'16px 16px 0', marginBottom:4 }}>
          <div style={{ font:'var(--type-label-sm)', color:'var(--on-surface-variant)',
            letterSpacing:'0.08em', textTransform:'uppercase', marginBottom:10 }}>
            Favourite Categories
          </div>
          <div style={{ display:'flex', gap:8 }}>
            {userProfile.topCategories.map(cid => {
              const cat = categories.find(c => c.id === cid);
              return cat ? (
                <div key={cid} className="chip active" style={{ flexShrink:0 }}>
                  <Icon name={cat.icon} size={16} />
                  {cat.label}
                </div>
              ) : null;
            })}
          </div>
        </div>

        {/* Tabs */}
        <div style={{ display:'flex', borderBottom:'2px solid var(--outline-variant)',
          margin:'16px 0 0', padding:'0 4px' }}>
          {tabs.map(t => (
            <button key={t.id} onClick={() => setActiveTab(t.id)}
              style={{ flex:1, height:44, display:'flex', alignItems:'center', justifyContent:'center',
                gap:6, border:'none', background:'none', cursor:'pointer',
                color: activeTab === t.id ? 'var(--primary)' : 'var(--on-surface-variant)',
                font:'600 13px/1 var(--font-text)',
                borderBottom: activeTab === t.id ? '2px solid var(--primary)' : '2px solid transparent',
                marginBottom:-2, transition:'color 160ms ease, border-color 160ms ease' }}>
              <Icon name={t.icon} size={18} fill={activeTab === t.id} />
              {t.count}
            </button>
          ))}
        </div>

        {/* Tab content */}
        {activeTab === 'reviews' && (
          <div>
            {userReviews.map(r => (
              <div key={r.id} className="review-card">
                <div style={{ display:'flex', alignItems:'flex-start', gap:10, marginBottom:8 }}>
                  <div style={{ flex:1 }}>
                    <div style={{ font:'600 14px/1.2 var(--font-text)', color:'var(--on-surface)', marginBottom:3 }}>
                      {places.find(p => p.id === r.placeId)?.name || 'Unknown Place'}
                    </div>
                    <div style={{ display:'flex', alignItems:'center', gap:6 }}>
                      <Stars rating={r.rating} size={12} />
                      <span style={{ font:'400 12px/1 var(--font-text)', color:'var(--on-surface-variant)' }}>
                        {r.date}
                      </span>
                    </div>
                  </div>
                  <Icon name="more_horiz" size={20} style={{ color:'var(--on-surface-variant)', marginTop:2 }} />
                </div>
                <p className="review-text">{r.text}</p>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'saved' && (
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12, padding:'16px' }}>
            {savedPlaces.map(place => {
              const cat = categories.find(c => c.id === place.category);
              return (
                <div key={place.id} className="place-card" onClick={() => onNavigate('placeDetail', place)}>
                  <div style={{ height:100, background:place.bg, position:'relative' }}>
                    <div className="place-img-scrim" />
                    <div style={{ position:'absolute', bottom:8, left:10 }}>
                      <div style={{ font:'600 12px/1.3 var(--font-text)', color:'white', textShadow:'0 1px 4px rgba(0,0,0,0.5)' }}>
                        {place.name}
                      </div>
                    </div>
                  </div>
                  <div style={{ padding:'8px 10px 10px', display:'flex', alignItems:'center', gap:4 }}>
                    <Stars rating={place.rating} size={11} />
                    <span style={{ font:'600 12px/1 var(--font-text)', color:'var(--on-surface)' }}>{place.rating}</span>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {activeTab === 'visited' && (
          <div style={{ display:'flex', flexDirection:'column', gap:10, padding:'16px' }}>
            {visitedPlaces.map(place => (
              <PlaceCardRow key={place.id} place={place} onClick={() => onNavigate('placeDetail', place)} />
            ))}
          </div>
        )}

        <div style={{ height:32 }} />
      </div>
    </div>
  );
}

window.ProfileScreen = ProfileScreen;

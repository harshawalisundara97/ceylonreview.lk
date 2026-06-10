// WriteReviewScreen — Star picker, photo upload, review form

function WriteReviewScreen({ place, onNavigate }) {
  const { useState } = React;
  const [rating, setRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [visitType, setVisitType] = useState('');
  const [reviewText, setReviewText] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const { categories } = window.CeylonData;

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
    return (
      <div className="screen screen-enter" style={{ background:'var(--surface)' }}>
        <TopBar title="Review Posted" onBack={() => onNavigate('home')} />
        <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center',
          justifyContent:'center', padding:32, gap:20, textAlign:'center' }}>
          <div style={{ width:80, height:80, borderRadius:'50%', background:'var(--primary-container)',
            display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Icon name="check_circle" fill size={48} style={{ color:'var(--primary)' }} />
          </div>
          <div>
            <div style={{ font:'700 24px/1.2 var(--font-display)', color:'var(--on-surface)', marginBottom:8 }}>
              Review Posted!
            </div>
            <p style={{ font:'var(--type-body-md)', color:'var(--on-surface-variant)' }}>
              Thank you for sharing your experience at {targetPlace.name}.
              Your review helps others discover Sri Lanka's best places.
            </p>
          </div>
          <Stars rating={rating} size={28} />
          <button className="btn btn-primary btn-full" onClick={() => onNavigate('home')}>
            Back to Home
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="screen screen-enter">
      <TopBar
        title="Write a Review"
        onBack={() => onNavigate('placeDetail', targetPlace)}
        actions={[{ icon:'close', label:'Cancel', onPress: () => onNavigate('home') }]}
      />

      <div className="scrollable" style={{ padding:'0 16px 32px' }}>

        {/* Place reference */}
        <div style={{ display:'flex', alignItems:'center', gap:12, padding:'12px 0 16px',
          borderBottom:'1px solid var(--outline-variant)', marginBottom:24 }}>
          <div style={{ width:52, height:52, borderRadius:'var(--radius-md)', background:targetPlace.bg,
            display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, overflow:'hidden' }}>
            <Icon name={cat?.icon||'place'} size={24} style={{ color:'rgba(255,255,255,0.85)' }} />
          </div>
          <div>
            <div style={{ font:'600 15px/1.3 var(--font-text)', color:'var(--on-surface)' }}>{targetPlace.name}</div>
            <div style={{ display:'flex', alignItems:'center', gap:4, font:'400 12px/1 var(--font-text)',
              color:'var(--on-surface-variant)', marginTop:3 }}>
              <Icon name="location_on" size={12} />
              {targetPlace.location}
            </div>
          </div>
        </div>

        {/* Star rating */}
        <div style={{ marginBottom:24 }}>
          <div style={{ font:'var(--type-title-md)', color:'var(--on-surface)', marginBottom:16 }}>
            Your Rating
          </div>
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', gap:12 }}>
            <div className="star-picker">
              {[1,2,3,4,5].map(n => (
                <button key={n} className="star-pick"
                  onMouseEnter={() => setHoverRating(n)}
                  onMouseLeave={() => setHoverRating(0)}
                  onClick={() => setRating(n)}
                  aria-label={`Rate ${n} stars`}>
                  <span className={`material-symbols-rounded${n <= displayRating ? ' fill' : ''}`}
                    style={{
                      fontSize:44,
                      color: n <= displayRating ? 'var(--star)' : 'var(--star-empty)',
                      fontVariationSettings: n <= displayRating ? "'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 48"
                                                                : "'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 48",
                      transition:'color 120ms ease, transform 120ms ease',
                      display:'block',
                    }}>star</span>
                </button>
              ))}
            </div>
            {displayRating > 0 && (
              <span style={{ font:'600 16px/1 var(--font-text)', color:'var(--primary)',
                animation:'fadeIn 160ms ease' }}>
                {ratingLabels[displayRating]}
              </span>
            )}
            {displayRating === 0 && (
              <span style={{ font:'400 14px/1 var(--font-text)', color:'var(--on-surface-variant)' }}>
                Tap a star to rate
              </span>
            )}
          </div>
        </div>

        {/* Visit type */}
        <div style={{ marginBottom:24 }}>
          <div style={{ font:'var(--type-title-md)', color:'var(--on-surface)', marginBottom:12 }}>
            Who did you visit with?
          </div>
          <div style={{ display:'flex', flexWrap:'wrap', gap:8 }}>
            {visitTypes.map(t => (
              <button key={t}
                className={`chip${visitType === t ? ' active' : ''}`}
                onClick={() => setVisitType(t)}>
                {t}
              </button>
            ))}
          </div>
        </div>

        {/* Photo upload */}
        <div style={{ marginBottom:24 }}>
          <div style={{ font:'var(--type-title-md)', color:'var(--on-surface)', marginBottom:12 }}>
            Add Photos
          </div>
          <div className="photo-upload" style={{ height:100 }}>
            <Icon name="add_photo_alternate" size={32} />
            <span style={{ font:'var(--type-body-sm)', color:'var(--on-surface-variant)' }}>
              Tap to add photos
            </span>
          </div>
        </div>

        {/* Review text */}
        <div style={{ marginBottom:24 }}>
          <div style={{ font:'var(--type-title-md)', color:'var(--on-surface)', marginBottom:12 }}>
            Share Your Experience
          </div>
          <textarea
            className="review-textarea"
            rows={5}
            placeholder="What did you love? What could be better? Be specific to help others…"
            value={reviewText}
            onChange={e => setReviewText(e.target.value)}
          />
          <div style={{ font:'400 12px/1 var(--font-text)', color:'var(--on-surface-variant)',
            textAlign:'right', marginTop:6 }}>
            {reviewText.length} / 1000
          </div>
        </div>

        {/* Tags input */}
        <div style={{ marginBottom:32 }}>
          <div style={{ font:'var(--type-title-md)', color:'var(--on-surface)', marginBottom:12 }}>
            Quick Tags
          </div>
          <div style={{ display:'flex', flexWrap:'wrap', gap:8 }}>
            {(targetPlace.tags || []).map(tag => (
              <span key={tag} className="tag" style={{ cursor:'pointer' }}>{tag}</span>
            ))}
          </div>
        </div>

        {/* Submit */}
        <button
          className="btn btn-primary btn-full"
          onClick={handleSubmit}
          style={{ opacity: rating === 0 ? 0.4 : 1 }}
          disabled={rating === 0}>
          <Icon name="send" size={20} style={{ color:'var(--on-primary)' }} />
          Post Review
        </button>
      </div>
    </div>
  );
}

window.WriteReviewScreen = WriteReviewScreen;

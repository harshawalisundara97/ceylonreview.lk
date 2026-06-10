// MapScreen — Interactive map view with bottom sheet

function MapScreen({ onNavigate, activeCategory }) {
  const { places, categories } = window.CeylonData;
  const { useState } = React;
  const [selectedPin, setSelectedPin] = useState(null);
  const [sheetExpanded, setSheetExpanded] = useState(false);

  const nearby = places.slice(0, 8);

  // Pseudo map pins — distributed across a 375x360 grid
  const pins = [
    { id:1,  x:72,  y:90,  placeId:1  },
    { id:2,  x:180, y:60,  placeId:4  },
    { id:3,  x:290, y:110, placeId:5  },
    { id:4,  x:130, y:180, placeId:2  },
    { id:5,  x:240, y:200, placeId:3  },
    { id:6,  x:60,  y:260, placeId:7  },
    { id:7,  x:310, y:280, placeId:8  },
    { id:8,  x:185, y:310, placeId:6  },
  ];

  function Pin({ pin }) {
    const place = places.find(p => p.id === pin.placeId);
    if (!place) return null;
    const cat = categories.find(c => c.id === place.category);
    const isSelected = selectedPin?.placeId === pin.placeId;
    return (
      <g transform={`translate(${pin.x},${pin.y})`}
        style={{ cursor:'pointer' }}
        onClick={() => setSelectedPin(isSelected ? null : pin)}>
        {/* Drop shadow */}
        <ellipse cx={0} cy={24} rx={10} ry={4} fill="rgba(0,0,0,0.2)" />
        {/* Pin body */}
        <path d="M0,-24 C-14,-24 -14,-8 -14,0 C-14,12 0,26 0,26 C0,26 14,12 14,0 C14,-8 14,-24 0,-24 Z"
          fill={isSelected ? 'var(--primary)' : (cat ? cat.color : '#0F6E56')}
          stroke={isSelected ? 'white' : 'rgba(255,255,255,0.6)'}
          strokeWidth={isSelected ? 2.5 : 1.5} />
        {/* Icon placeholder - circle */}
        <circle cx={0} cy={-4} r={8} fill="rgba(255,255,255,0.25)" />
        <text x={0} y={-4} textAnchor="middle" dominantBaseline="middle"
          fontSize={10} fill="white" fontFamily="Material Symbols Rounded"
          style={{ fontVariationSettings:"'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 20" }}>
          ★
        </text>
        {/* Callout on selection */}
        {isSelected && (
          <g transform="translate(-52,-58)">
            <rect x={0} y={0} width={104} height={32} rx={8}
              fill="var(--surface)" stroke="var(--outline-variant)" strokeWidth={1} />
            <text x={8} y={12} fontSize={11} fontWeight={600} fill="var(--on-surface)"
              fontFamily="'Plus Jakarta Sans', sans-serif">
              {place.name.length > 16 ? place.name.slice(0,16)+'…' : place.name}
            </text>
            <text x={8} y={24} fontSize={10} fill="var(--on-surface-variant)"
              fontFamily="'Plus Jakarta Sans', sans-serif">
              ★ {place.rating} · {place.distance}
            </text>
          </g>
        )}
      </g>
    );
  }

  // Draw simple road grid
  const roads = [];
  for (let y = 60; y < 400; y += 70) {
    roads.push(<line key={`h${y}`} x1={0} y1={y} x2={375} y2={y} stroke="var(--outline-variant)" strokeWidth={1.5} opacity={0.6}/>);
  }
  for (let x = 55; x < 375; x += 80) {
    roads.push(<line key={`v${x}`} x1={x} y1={0} x2={x} y2={400} stroke="var(--outline-variant)" strokeWidth={1.5} opacity={0.6}/>);
  }
  // A few diagonal roads
  roads.push(<line key="d1" x1={0} y1={200} x2={180} y2={40} stroke="var(--outline-variant)" strokeWidth={2} opacity={0.4}/>);
  roads.push(<line key="d2" x1={200} y1={400} x2={375} y2={150} stroke="var(--outline-variant)" strokeWidth={2} opacity={0.4}/>);

  const bottomSheetHeight = sheetExpanded ? 380 : 200;

  return (
    <div className="screen screen-enter" style={{ position:'relative' }}>
      {/* Map area */}
      <div style={{ flex:1, background:'var(--surface-container-low)', position:'relative', overflow:'hidden' }}>
        {/* Base map */}
        <svg width="375" height="100%" style={{ position:'absolute', inset:0 }}>
          {/* Water-like areas */}
          <rect x={0} y={0} width={375} height={400} fill="var(--surface-container-low)" />
          <ellipse cx={300} cy={80} rx={90} ry={50} fill="var(--surface-container)" opacity={0.7}/>
          <ellipse cx={60} cy={300} rx={70} ry={40} fill="var(--surface-container)" opacity={0.5}/>
          {/* Green zones */}
          <ellipse cx={180} cy={240} rx={50} ry={35} fill="var(--primary-container)" opacity={0.25}/>
          {/* Roads */}
          {roads}
          {/* Pins */}
          {pins.map(pin => <Pin key={pin.id} pin={pin} />)}
        </svg>

        {/* Search bar floating */}
        <div style={{ position:'absolute', top:12, left:16, right:16 }}>
          <div className="search-bar" style={{ boxShadow:'var(--elev-3)', background:'var(--surface)' }}>
            <Icon name="search" style={{ color:'var(--on-surface-variant)' }} />
            <input placeholder="Search on map…" style={{ fontSize:15, background:'transparent' }} readOnly />
            <button className="icon-btn" style={{ width:36, height:36 }}>
              <Icon name="my_location" size={20} style={{ color:'var(--primary)' }} />
            </button>
          </div>
        </div>

        {/* Category filter pills floating */}
        <div style={{ position:'absolute', top:76, left:0, right:0,
          overflowX:'auto', display:'flex', gap:8, padding:'0 16px' }}>
          {[{ id:'all', label:'All', icon:'apps' }, ...categories].slice(0, 5).map(c => (
            <button key={c.id}
              className={`chip${(activeCategory||'all') === c.id ? ' active' : ''}`}
              style={{ flexShrink:0, boxShadow:'var(--elev-1)', background:'var(--surface)' }}>
              <Icon name={c.icon} size={16} />
              {c.label}
            </button>
          ))}
        </div>

        {/* My location FAB */}
        <div style={{ position:'absolute', bottom: bottomSheetHeight + 16, right:16,
          width:48, height:48, borderRadius:'50%', background:'var(--surface)',
          display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:'var(--elev-3)', cursor:'pointer' }}>
          <Icon name="my_location" style={{ color:'var(--primary)' }} />
        </div>
      </div>

      {/* Bottom sheet */}
      <div style={{
        position:'absolute', bottom:0, left:0, right:0,
        height: bottomSheetHeight,
        background:'var(--surface)',
        borderRadius:'28px 28px 0 0',
        boxShadow:'var(--elev-4)',
        display:'flex', flexDirection:'column',
        transition:'height 360ms var(--ease-emphasized)',
      }}>
        {/* Handle */}
        <div style={{ display:'flex', alignItems:'center', justifyContent:'center', padding:'12px 0 0' }}>
          <div style={{ width:36, height:4, borderRadius:2, background:'var(--outline-variant)',
            cursor:'pointer' }} onClick={() => setSheetExpanded(e => !e)} />
        </div>

        {/* Header */}
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between',
          padding:'8px 16px 12px' }}>
          <div>
            <div style={{ font:'700 18px/1 var(--font-display)', color:'var(--on-surface)' }}>
              {selectedPin ? places.find(p => p.id === selectedPin.placeId)?.name : 'Nearby Places'}
            </div>
            <div style={{ font:'400 13px/1 var(--font-text)', color:'var(--on-surface-variant)', marginTop:4 }}>
              {nearby.length} places around you
            </div>
          </div>
          <button className="chip active">
            <Icon name="filter_list" size={16} />
            Filter
          </button>
        </div>

        {/* Place list */}
        <div className="scrollable" style={{ padding:'0 16px', flex:1 }}>
          {(sheetExpanded ? nearby : nearby.slice(0,2)).map(place => (
            <PlaceCardRow key={place.id} place={place}
              onClick={() => onNavigate('placeDetail', place)} />
          ))}
          <div style={{ height:16 }} />
        </div>
      </div>
    </div>
  );
}

window.MapScreen = MapScreen;

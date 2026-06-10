// LoginScreen — Login and register with tabs

function LoginScreen({ onNavigate }) {
  const { useState } = React;
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

  return (
    <div className="screen screen-enter" style={{ background:'var(--surface)' }}>
      <div className="scrollable" style={{ padding:'0 24px 40px' }}>

        {/* Logo block */}
        <div style={{ textAlign:'center', padding:'48px 0 40px' }}>
          <div style={{ width:72, height:72, borderRadius:'var(--radius-xl)', background:'var(--primary)',
            display:'flex', alignItems:'center', justifyContent:'center', margin:'0 auto 16px',
            boxShadow:'0 8px 24px rgba(15,110,86,0.3)' }}>
            <Icon name="location_on" fill size={36} style={{ color:'white' }} />
          </div>
          <div style={{ font:'800 32px/1 var(--font-display)', color:'var(--on-surface)', marginBottom:4 }}>
            Ceylon Review
          </div>
          <div style={{ font:'400 15px/1.5 var(--font-text)', color:'var(--on-surface-variant)' }}>
            Discover the best of Sri Lanka
          </div>
        </div>

        {/* Tab toggle */}
        <div style={{ display:'flex', background:'var(--surface-container)', borderRadius:'var(--radius-pill)',
          padding:4, marginBottom:28 }}>
          {['login','register'].map(m => (
            <button key={m} onClick={() => setMode(m)}
              style={{ flex:1, height:44, borderRadius:'var(--radius-pill)', border:'none', cursor:'pointer',
                font:'600 15px/1 var(--font-text)', transition:'all 220ms ease',
                background: mode === m ? 'var(--surface)' : 'transparent',
                color: mode === m ? 'var(--on-surface)' : 'var(--on-surface-variant)',
                boxShadow: mode === m ? 'var(--elev-1)' : 'none' }}>
              {m === 'login' ? 'Sign In' : 'Register'}
            </button>
          ))}
        </div>

        {/* Form */}
        <div style={{ display:'flex', flexDirection:'column', gap:14, marginBottom:20 }}>
          {mode === 'register' && (
            <div>
              <div style={{ font:'600 13px/1 var(--font-text)', color:'var(--on-surface-variant)',
                marginBottom:8, letterSpacing:'0.02em' }}>Full Name</div>
              <input className="input-field" type="text" placeholder="Dilshan Perera"
                value={name} onChange={e => setName(e.target.value)} />
            </div>
          )}
          <div>
            <div style={{ font:'600 13px/1 var(--font-text)', color:'var(--on-surface-variant)',
              marginBottom:8, letterSpacing:'0.02em' }}>Email</div>
            <div style={{ position:'relative' }}>
              <input className="input-field" type="email" placeholder="you@example.com"
                value={email} onChange={e => setEmail(e.target.value)}
                style={{ paddingLeft:48 }} />
              <Icon name="mail" size={20} style={{ position:'absolute', left:14, top:18,
                color:'var(--on-surface-variant)' }} />
            </div>
          </div>
          <div>
            <div style={{ font:'600 13px/1 var(--font-text)', color:'var(--on-surface-variant)',
              marginBottom:8, letterSpacing:'0.02em' }}>Password</div>
            <div style={{ position:'relative' }}>
              <input className="input-field" type={showPass ? 'text' : 'password'} placeholder="••••••••"
                value={password} onChange={e => setPassword(e.target.value)}
                style={{ paddingLeft:48, paddingRight:48 }} />
              <Icon name="lock" size={20} style={{ position:'absolute', left:14, top:18,
                color:'var(--on-surface-variant)' }} />
              <button onClick={() => setShowPass(s => !s)}
                style={{ position:'absolute', right:14, top:14, background:'none', border:'none',
                  cursor:'pointer', color:'var(--on-surface-variant)' }}>
                <Icon name={showPass ? 'visibility_off' : 'visibility'} size={22} />
              </button>
            </div>
          </div>
        </div>

        {/* Forgot password */}
        {mode === 'login' && (
          <div style={{ textAlign:'right', marginBottom:24 }}>
            <button style={{ background:'none', border:'none', cursor:'pointer',
              font:'600 14px/1 var(--font-text)', color:'var(--primary)' }}>
              Forgot password?
            </button>
          </div>
        )}

        {/* CTA button */}
        <button className="btn btn-primary btn-full" onClick={handleAuth}
          style={{ marginBottom:20, opacity: (!email || !password) ? 0.5 : 1 }}
          disabled={!email || !password}>
          {loading ? (
            <Icon name="autorenew" size={20} style={{ color:'var(--on-primary)',
              animation:'spin 1s linear infinite' }} />
          ) : (
            <>
              <Icon name={mode === 'login' ? 'login' : 'person_add'} size={20}
                style={{ color:'var(--on-primary)' }} />
              {mode === 'login' ? 'Sign In' : 'Create Account'}
            </>
          )}
        </button>

        {/* Divider */}
        <div style={{ display:'flex', alignItems:'center', gap:12, marginBottom:20 }}>
          <div className="divider" style={{ flex:1 }} />
          <span style={{ font:'400 13px/1 var(--font-text)', color:'var(--on-surface-variant)' }}>or continue with</span>
          <div className="divider" style={{ flex:1 }} />
        </div>

        {/* Social auth */}
        <div style={{ display:'flex', gap:12, marginBottom:32 }}>
          {[
            { icon:'g_mobiledata', label:'Google' },
            { icon:'smartphone',   label:'Apple' },
          ].map(s => (
            <button key={s.label}
              style={{ flex:1, height:52, borderRadius:'var(--radius-md)', border:'1.5px solid var(--outline-variant)',
                background:'var(--surface-container-low)', display:'flex', alignItems:'center',
                justifyContent:'center', gap:10, cursor:'pointer', font:'600 15px/1 var(--font-text)',
                color:'var(--on-surface)', transition:'background 160ms ease' }}>
              <Icon name={s.icon} size={22} />
              {s.label}
            </button>
          ))}
        </div>

        {/* Switch mode link */}
        <div style={{ textAlign:'center' }}>
          <span style={{ font:'400 14px/1 var(--font-text)', color:'var(--on-surface-variant)' }}>
            {mode === 'login' ? "Don't have an account? " : 'Already have an account? '}
          </span>
          <button onClick={() => setMode(mode === 'login' ? 'register' : 'login')}
            style={{ background:'none', border:'none', cursor:'pointer',
              font:'600 14px/1 var(--font-text)', color:'var(--primary)' }}>
            {mode === 'login' ? 'Sign up' : 'Sign in'}
          </button>
        </div>

        {/* Terms */}
        <div style={{ textAlign:'center', marginTop:20 }}>
          <span style={{ font:'400 12px/1.4 var(--font-text)', color:'var(--on-surface-variant)' }}>
            By continuing you agree to our{' '}
            <span style={{ color:'var(--primary)', cursor:'pointer' }}>Terms of Service</span>
            {' and '}
            <span style={{ color:'var(--primary)', cursor:'pointer' }}>Privacy Policy</span>
          </span>
        </div>
      </div>

      <style>{`@keyframes spin { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }`}</style>
    </div>
  );
}

window.LoginScreen = LoginScreen;

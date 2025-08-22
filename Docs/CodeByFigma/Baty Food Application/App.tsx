import React, { useState, useEffect } from 'react';
import { CustomerApp } from './components/CustomerApp';
import { CookApp } from './components/CookApp';
import { WebApp } from './components/WebApp';
import { AuthScreen } from './components/AuthScreen';
import { SplashScreen } from './components/SplashScreen';
import { supabase } from './utils/supabase/client';

type ViewMode = 'splash' | 'auth' | 'customer' | 'cook' | 'web';
type UserType = 'customer' | 'cook' | null;

export default function App() {
  const [currentView, setCurrentView] = useState<ViewMode>('splash');
  const [userType, setUserType] = useState<UserType>(null);
  const [user, setUser] = useState<any>(null);
  const [isMobile, setIsMobile] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if it's mobile view
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);

    // Check for existing session
    const checkSession = async () => {
      try {
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
          console.error('Session check error:', error);
        }
        
        if (session?.user) {
          const userMetadata = session.user.user_metadata;
          setUser(session.user);
          setUserType(userMetadata?.userType || 'customer');
          setCurrentView(userMetadata?.userType === 'cook' ? 'cook' : (isMobile ? 'customer' : 'web'));
        } else {
          // Show splash screen for 2 seconds, then auth
          setTimeout(() => {
            setCurrentView('auth');
          }, 2000);
        }
      } catch (error) {
        console.error('Session check failed:', error);
        // Show splash screen for 2 seconds, then auth
        setTimeout(() => {
          setCurrentView('auth');
        }, 2000);
      } finally {
        setLoading(false);
      }
    };

    checkSession();

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state changed:', event, session?.user?.id);
        
        if (event === 'SIGNED_IN' && session?.user) {
          const userMetadata = session.user.user_metadata;
          setUser(session.user);
          setUserType(userMetadata?.userType || 'customer');
          setCurrentView(userMetadata?.userType === 'cook' ? 'cook' : (isMobile ? 'customer' : 'web'));
        } else if (event === 'SIGNED_OUT') {
          setUser(null);
          setUserType(null);
          setCurrentView('auth');
        }
      }
    );

    return () => {
      window.removeEventListener('resize', checkMobile);
      subscription.unsubscribe();
    };
  }, [isMobile]);

  const handleAuth = (user: any, type: UserType) => {
    setUser(user);
    setUserType(type);
    if (type === 'cook') {
      setCurrentView('cook');
    } else {
      setCurrentView(isMobile ? 'customer' : 'web');
    }
  };

  const handleLogout = async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error('Logout error:', error);
      }
      setUser(null);
      setUserType(null);
      setCurrentView('auth');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  const switchToWeb = () => {
    setCurrentView('web');
  };

  const switchToMobile = () => {
    setCurrentView('customer');
  };

  if (loading || currentView === 'splash') {
    return <SplashScreen />;
  }

  if (currentView === 'auth') {
    return <AuthScreen onAuth={handleAuth} />;
  }

  if (currentView === 'customer') {
    return (
      <CustomerApp 
        user={user} 
        onLogout={handleLogout} 
        onSwitchToWeb={switchToWeb}
      />
    );
  }

  if (currentView === 'cook') {
    return (
      <CookApp 
        user={user} 
        onLogout={handleLogout}
        isMobile={isMobile}
      />
    );
  }

  return (
    <WebApp 
      user={user} 
      userType={userType}
      onLogout={handleLogout} 
      onSwitchToMobile={switchToMobile}
    />
  );
}
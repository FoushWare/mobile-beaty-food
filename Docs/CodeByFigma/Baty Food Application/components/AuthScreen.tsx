import React, { useState } from 'react';
import { supabase } from '../utils/supabase/client';
import { projectId, publicAnonKey } from '../utils/supabase/info';

interface AuthScreenProps {
  onAuth: (user: any, userType: 'customer' | 'cook') => void;
}

export function AuthScreen({ onAuth }: AuthScreenProps) {
  const [isSignUp, setIsSignUp] = useState(false);
  const [userType, setUserType] = useState<'customer' | 'cook'>('customer');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (isSignUp) {
        await handleSignUp();
      } else {
        await handleSignIn();
      }
    } catch (error: any) {
      console.error('Auth error:', error);
      setError(error.message || 'Authentication failed');
    }

    setLoading(false);
  };

  const handleSignUp = async () => {
    console.log('Creating new user:', { email, name, userType });
    
    try {
      const response = await fetch(`https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/signup`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${publicAnonKey}`
        },
        body: JSON.stringify({
          email,
          password,
          name,
          userType
        })
      });

      const result = await response.json();
      console.log('Signup response:', result);
      
      if (!response.ok) {
        // Handle specific error cases
        if (result.error && result.error.includes('already been registered')) {
          throw new Error('This email is already registered. Please sign in instead or use a different email address.');
        } else if (result.error && result.error.includes('User already registered')) {
          throw new Error('This email is already registered. Please sign in instead.');
        } else {
          throw new Error(result.error || 'Sign up failed');
        }
      }

      // After successful signup, try to get the session
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        console.error('Session error after signup:', sessionError);
        // Try to sign in manually if no session is found
        await handleSignIn();
      } else if (session?.user) {
        onAuth(session.user, userType);
      } else {
        // If no session, try signing in with the credentials
        console.log('No session found after signup, attempting sign in...');
        await handleSignIn();
      }
    } catch (error: any) {
      // If it's a "user already exists" error, suggest switching to sign in
      if (error.message.includes('already registered') || error.message.includes('already been registered')) {
        setError(`${error.message} Would you like to sign in instead?`);
        
        // Auto-switch to sign in mode after a delay
        setTimeout(() => {
          setIsSignUp(false);
          setError('Switched to sign in. Please enter your password.');
        }, 3000);
      } else {
        throw error; // Re-throw other errors
      }
    }
  };

  const handleSignIn = async () => {
    console.log('Signing in user:', email);
    
    const { data: { user }, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      console.error('Sign in error:', error);
      if (error.message === 'Invalid login credentials') {
        throw new Error('Invalid email or password. Please check your credentials and try again.');
      } else {
        throw new Error(error.message);
      }
    }

    if (user) {
      const userMetadata = user.user_metadata;
      onAuth(user, userMetadata?.userType || 'customer');
    } else {
      throw new Error('Sign in failed - no user returned');
    }
  };

  const handleSwitchMode = () => {
    setIsSignUp(!isSignUp);
    setError('');
    // Don't clear the email, but clear password and name
    setPassword('');
    if (!isSignUp) {
      setName('');
    }
  };

  const handleForgotPassword = async () => {
    if (!email) {
      setError('Please enter your email address first, then click "Forgot Password".');
      return;
    }

    try {
      setLoading(true);
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}`,
      });

      if (error) {
        setError(`Password reset error: ${error.message}`);
      } else {
        setError(''); // Clear any existing errors
        alert(`Password reset email sent to ${email}. Please check your inbox.`);
      }
    } catch (error: any) {
      setError(`Failed to send reset email: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-green-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md">
        <div className="text-center mb-8">
          <div className="text-6xl mb-4">🍽️</div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">
            {userType === 'cook' ? 'Cook' : 'Customer'} {isSignUp ? 'Sign Up' : 'Sign In'}
          </h1>
          <p className="text-gray-600">Welcome to Baty Food</p>
        </div>

        {/* User Type Selector */}
        <div className="flex rounded-lg bg-gray-100 p-1 mb-6">
          <button
            type="button"
            onClick={() => setUserType('customer')}
            className={`flex-1 py-2 px-4 rounded-md transition-colors ${
              userType === 'customer'
                ? 'bg-white shadow-sm text-orange-600'
                : 'text-gray-600 hover:text-gray-800'
            }`}
          >
            Customer
          </button>
          <button
            type="button"
            onClick={() => setUserType('cook')}
            className={`flex-1 py-2 px-4 rounded-md transition-colors ${
              userType === 'cook'
                ? 'bg-white shadow-sm text-orange-600'
                : 'text-gray-600 hover:text-gray-800'
            }`}
          >
            Cook
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {isSignUp && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Full Name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                placeholder="Enter your full name"
                required
              />
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Email Address
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
              placeholder="Enter your email"
              required
            />
          </div>

          <div>
            <div className="flex justify-between items-center mb-1">
              <label className="block text-sm font-medium text-gray-700">
                Password
              </label>
              {!isSignUp && (
                <button
                  type="button"
                  onClick={handleForgotPassword}
                  className="text-sm text-orange-600 hover:text-orange-700"
                  disabled={loading}
                >
                  Forgot Password?
                </button>
              )}
            </div>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
              placeholder="Enter your password"
              required
              minLength={6}
            />
            {isSignUp && (
              <p className="text-xs text-gray-500 mt-1">Password must be at least 6 characters long</p>
            )}
          </div>

          {error && (
            <div className={`p-3 rounded-lg text-sm ${
              error.includes('Would you like to sign in') || error.includes('Switched to sign in')
                ? 'bg-blue-50 text-blue-700'
                : error.includes('Password reset email sent')
                ? 'bg-green-50 text-green-700'
                : 'bg-red-50 text-red-700'
            }`}>
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-orange-500 hover:bg-orange-600 disabled:bg-gray-300 disabled:cursor-not-allowed text-white py-3 px-4 rounded-lg transition-colors"
            style={{ backgroundColor: loading ? undefined : '#FF6B35' }}
          >
            {loading ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                {isSignUp ? 'Creating Account...' : 'Signing In...'}
              </div>
            ) : (
              isSignUp ? 'Create Account' : 'Sign In'
            )}
          </button>

          <div className="text-center">
            <button
              type="button"
              onClick={handleSwitchMode}
              className="text-orange-600 hover:text-orange-700 text-sm"
            >
              {isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up"}
            </button>
          </div>
        </form>

        {/* Demo accounts hint */}
        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <p className="text-xs text-gray-600 text-center">
            <strong>Demo Tip:</strong> If you encounter any issues, try using a different email address for signup,
            or use the sign in form if you already have an account.
          </p>
        </div>
      </div>
    </div>
  );
}
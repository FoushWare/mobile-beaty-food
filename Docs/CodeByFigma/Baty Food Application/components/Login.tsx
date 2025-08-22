import React, { useState } from 'react';
import { createClient } from '@supabase/supabase-js';
import { projectId, publicAnonKey } from '../utils/supabase/info';
import { Eye, EyeOff, ArrowLeft } from 'lucide-react';
import LoadingSpinner from './LoadingSpinner';

const supabase = createClient(
  `https://${projectId}.supabase.co`,
  publicAnonKey
);

interface LoginProps {
  onNavigate: (screen: string) => void;
  onLogin: (user: any) => void;
}

const Login: React.FC<LoginProps> = ({ onNavigate, onLogin }) => {
  const [isSignUp, setIsSignUp] = useState(false);
  const [userType, setUserType] = useState<'customer' | 'cook'>('customer');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    name: '',
    phone: '',
    address: ''
  });
  const [error, setError] = useState('');

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (!formData.email || !formData.password || !formData.name) {
        setError('Please fill in all required fields');
        return;
      }

      const response = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/signup`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${publicAnonKey}`,
          },
          body: JSON.stringify({
            email: formData.email,
            password: formData.password,
            name: formData.name,
            role: userType,
            phone: formData.phone,
            address: formData.address
          }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Signup failed');
      }

      // Auto-login after successful signup
      const { data: authData, error: signInError } = await supabase.auth.signInWithPassword({
        email: formData.email,
        password: formData.password,
      });

      if (signInError) {
        throw new Error(signInError.message);
      }

      onLogin(data.user);
    } catch (error: any) {
      console.error('Signup error:', error);
      setError(error.message || 'An error occurred during signup');
    } finally {
      setLoading(false);
    }
  };

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: formData.email,
        password: formData.password,
      });

      if (error) {
        throw new Error(error.message);
      }

      if (data.user) {
        // Fetch user profile
        const response = await fetch(
          `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/user/${data.user.id}`,
          {
            headers: {
              'Authorization': `Bearer ${publicAnonKey}`,
            },
          }
        );

        if (response.ok) {
          const userData = await response.json();
          onLogin(userData);
        } else {
          throw new Error('Failed to load user profile');
        }
      }
    } catch (error: any) {
      console.error('Sign in error:', error);
      setError(error.message || 'Sign in failed');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-green-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div>
          <button
            onClick={() => onNavigate('landing')}
            className="flex items-center text-gray-600 hover:text-gray-900 mb-6"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back to Home
          </button>
          
          <div className="text-center">
            <div className="w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-600 rounded-full flex items-center justify-center mx-auto mb-4">
              <span className="text-white text-2xl">🍽️</span>
            </div>
            <h2 className="text-3xl font-bold text-gray-900">
              {isSignUp ? 'Create Account' : 'Welcome Back'}
            </h2>
            <p className="mt-2 text-gray-600">
              {isSignUp ? 'Join our community of food lovers' : 'Sign in to your account'}
            </p>
          </div>
        </div>

        {/* User Type Selection (for signup) */}
        {isSignUp && (
          <div className="bg-white rounded-lg p-4 shadow-sm">
            <label className="block text-sm font-medium text-gray-700 mb-3">
              I want to join as:
            </label>
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={() => setUserType('customer')}
                className={`p-3 rounded-lg border-2 text-center transition-all ${
                  userType === 'customer'
                    ? 'border-orange-500 bg-orange-50 text-orange-700'
                    : 'border-gray-200 text-gray-600 hover:border-gray-300'
                }`}
              >
                <div className="text-2xl mb-1">🍽️</div>
                <div className="font-medium">Customer</div>
                <div className="text-xs">Order delicious food</div>
              </button>
              <button
                type="button"
                onClick={() => setUserType('cook')}
                className={`p-3 rounded-lg border-2 text-center transition-all ${
                  userType === 'cook'
                    ? 'border-green-500 bg-green-50 text-green-700'
                    : 'border-gray-200 text-gray-600 hover:border-gray-300'
                }`}
              >
                <div className="text-2xl mb-1">👨‍🍳</div>
                <div className="font-medium">Cook</div>
                <div className="text-xs">Share your recipes</div>
              </button>
            </div>
          </div>
        )}

        {/* Form */}
        <form className="mt-8 space-y-6" onSubmit={isSignUp ? handleSignUp : handleSignIn}>
          <div className="bg-white rounded-lg p-6 shadow-sm space-y-4">
            {isSignUp && (
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                  Full Name *
                </label>
                <input
                  id="name"
                  name="name"
                  type="text"
                  required={isSignUp}
                  value={formData.name}
                  onChange={handleInputChange}
                  className="appearance-none relative block w-full px-3 py-3 border border-gray-300 rounded-lg placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                  placeholder="Enter your full name"
                />
              </div>
            )}

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                Email Address *
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                value={formData.email}
                onChange={handleInputChange}
                className="appearance-none relative block w-full px-3 py-3 border border-gray-300 rounded-lg placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="Enter your email"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                Password *
              </label>
              <div className="relative">
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className="appearance-none relative block w-full px-3 py-3 pr-10 border border-gray-300 rounded-lg placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                  placeholder="Enter your password"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                >
                  {showPassword ? (
                    <EyeOff className="h-5 w-5 text-gray-400" />
                  ) : (
                    <Eye className="h-5 w-5 text-gray-400" />
                  )}
                </button>
              </div>
            </div>

            {isSignUp && (
              <>
                <div>
                  <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-1">
                    Phone Number
                  </label>
                  <input
                    id="phone"
                    name="phone"
                    type="tel"
                    value={formData.phone}
                    onChange={handleInputChange}
                    className="appearance-none relative block w-full px-3 py-3 border border-gray-300 rounded-lg placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                    placeholder="Enter your phone number"
                  />
                </div>

                <div>
                  <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-1">
                    Address
                  </label>
                  <textarea
                    id="address"
                    name="address"
                    rows={2}
                    value={formData.address}
                    onChange={handleInputChange}
                    className="appearance-none relative block w-full px-3 py-3 border border-gray-300 rounded-lg placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent resize-none"
                    placeholder="Enter your address"
                  />
                </div>
              </>
            )}
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-3">
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          <div>
            <button
              type="submit"
              disabled={loading}
              className="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-orange-500 hover:bg-orange-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  {isSignUp ? 'Creating Account...' : 'Signing In...'}
                </div>
              ) : (
                isSignUp ? 'Create Account' : 'Sign In'
              )}
            </button>
          </div>

          <div className="text-center">
            <button
              type="button"
              onClick={() => {
                setIsSignUp(!isSignUp);
                setError('');
                setFormData({
                  email: '',
                  password: '',
                  name: '',
                  phone: '',
                  address: ''
                });
              }}
              className="text-orange-600 hover:text-orange-500"
            >
              {isSignUp 
                ? 'Already have an account? Sign in' 
                : "Don't have an account? Sign up"
              }
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Login;
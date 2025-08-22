import React, { useState, useEffect } from 'react';
import { Search, ShoppingCart, User, Heart, Star, Clock, Users, Menu, X } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface WebAppProps {
  user: any;
  userType: 'customer' | 'cook' | null;
  onLogout: () => void;
  onSwitchToMobile: () => void;
}

export function WebApp({ user, userType, onLogout, onSwitchToMobile }: WebAppProps) {
  const [currentPage, setCurrentPage] = useState<'home' | 'browse' | 'cart' | 'profile'>('home');
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [cartItems, setCartItems] = useState<any[]>([]);

  const categories = ['All', 'Arabic', 'Egyptian', 'Lebanese', 'Syrian', 'Turkish'];

  const featuredRecipes = [
    {
      id: '1',
      title: 'Grilled Kebab',
      description: 'Fresh grilled kebab with authentic Arabic spices',
      price: 5,
      image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
      rating: 4.8,
      reviews: 25,
      cookName: 'Um Ali',
      category: 'Arabic'
    },
    {
      id: '2',
      title: 'Grilled Chicken',
      description: 'Tender grilled chicken with Mediterranean herbs',
      price: 6,
      image: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400',
      rating: 4.6,
      reviews: 18,
      cookName: 'Abu Mohamed',
      category: 'Lebanese'
    },
    {
      id: '3',
      title: 'Grilled Fish',
      description: 'Fresh fish grilled with lemon and spices',
      price: 8,
      image: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',
      rating: 4.9,
      reviews: 12,
      cookName: 'Sarah Ahmed',
      category: 'Mediterranean'
    }
  ];

  const featuredCooks = [
    {
      id: '1',
      name: 'Um Ali',
      rating: 4.9,
      avatar: 'https://images.unsplash.com/photo-1607631568010-a87245c0daf8?w=200',
      specialties: ['Arabic', 'Traditional']
    },
    {
      id: '2',
      name: 'Abu Mohamed',
      rating: 4.7,
      avatar: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200',
      specialties: ['Lebanese', 'Grilled']
    },
    {
      id: '3',
      name: 'Sarah Ahmed',
      rating: 4.8,
      avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
      specialties: ['Seafood', 'Mediterranean']
    }
  ];

  const addToCart = (recipe: any) => {
    const existingItem = cartItems.find(item => item.id === recipe.id);
    if (existingItem) {
      setCartItems(cartItems.map(item =>
        item.id === recipe.id
          ? { ...item, quantity: item.quantity + 1 }
          : item
      ));
    } else {
      setCartItems([...cartItems, { ...recipe, quantity: 1 }]);
    }
  };

  if (currentPage === 'home') {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm sticky top-0 z-50">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16">
              <div className="flex items-center space-x-3">
                <div className="text-3xl">🍽️</div>
                <div>
                  <h1 className="text-xl font-bold text-gray-800">Baty Food</h1>
                  <p className="text-sm text-gray-600">Authentic Home Food</p>
                </div>
              </div>

              <nav className="hidden md:flex items-center space-x-8">
                <button
                  onClick={() => setCurrentPage('home')}
                  className="text-orange-600 hover:text-orange-700"
                >
                  Home
                </button>
                <button
                  onClick={() => setCurrentPage('browse')}
                  className="text-gray-600 hover:text-gray-800"
                >
                  Browse Recipes
                </button>
                <button
                  onClick={() => setCurrentPage('cart')}
                  className="relative text-gray-600 hover:text-gray-800"
                >
                  <ShoppingCart size={20} />
                  {cartItems.length > 0 && (
                    <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                      {cartItems.reduce((sum, item) => sum + item.quantity, 0)}
                    </span>
                  )}
                </button>
              </nav>

              <div className="flex items-center space-x-4">
                <button
                  onClick={onSwitchToMobile}
                  className="text-sm text-gray-600 hover:text-gray-800"
                >
                  Mobile View
                </button>
                {user ? (
                  <div className="relative">
                    <button
                      onClick={() => setIsMenuOpen(!isMenuOpen)}
                      className="flex items-center space-x-2 text-gray-600 hover:text-gray-800"
                    >
                      <User size={20} />
                      <span className="hidden md:inline">{user.user_metadata?.name}</span>
                    </button>
                    {isMenuOpen && (
                      <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-2">
                        <button
                          onClick={() => setCurrentPage('profile')}
                          className="block w-full text-left px-4 py-2 text-gray-700 hover:bg-gray-100"
                        >
                          Profile
                        </button>
                        <button
                          onClick={onLogout}
                          className="block w-full text-left px-4 py-2 text-red-600 hover:bg-red-50"
                        >
                          Sign Out
                        </button>
                      </div>
                    )}
                  </div>
                ) : (
                  <button className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg">
                    Sign In
                  </button>
                )}
              </div>
            </div>
          </div>
        </header>

        {/* Hero Section */}
        <section className="bg-gradient-to-r from-orange-500 to-orange-600 text-white py-20">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h1 className="text-5xl font-bold mb-6">
              Authentic Home Food<br />Everywhere
            </h1>
            <p className="text-xl mb-8 opacity-90">
              Discover delicious homemade recipes from talented home cooks in your area
            </p>
            
            <div className="max-w-md mx-auto">
              <div className="relative">
                <Search className="absolute left-4 top-4 text-gray-400" size={20} />
                <input
                  type="text"
                  placeholder="Search recipes..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-12 pr-4 py-4 rounded-lg text-gray-800 focus:ring-2 focus:ring-white"
                />
                <button 
                  onClick={() => setCurrentPage('browse')}
                  className="absolute right-2 top-2 bg-orange-600 hover:bg-orange-700 text-white px-6 py-2 rounded-lg transition-colors"
                >
                  Search
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* Categories */}
        <section className="py-12">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-bold text-gray-800 text-center mb-8">Food Categories</h2>
            <div className="flex justify-center space-x-4 overflow-x-auto">
              {categories.map(category => (
                <button
                  key={category}
                  onClick={() => setSelectedCategory(category)}
                  className={`px-6 py-3 rounded-full whitespace-nowrap transition-colors ${
                    selectedCategory === category
                      ? 'bg-orange-500 text-white'
                      : 'bg-white text-gray-700 border border-gray-200 hover:border-orange-300'
                  }`}
                >
                  {category}
                </button>
              ))}
            </div>
          </div>
        </section>

        {/* Featured Recipes */}
        <section className="py-12 bg-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-bold text-gray-800 text-center mb-12">Featured Recipes</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {featuredRecipes.map(recipe => (
                <div key={recipe.id} className="bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden hover:shadow-xl transition-shadow">
                  <ImageWithFallback
                    src={recipe.image}
                    alt={recipe.title}
                    className="w-full h-48 object-cover"
                  />
                  <div className="p-6">
                    <div className="flex items-start justify-between mb-3">
                      <h3 className="text-xl font-semibold text-gray-800">{recipe.title}</h3>
                      <span className="text-2xl font-bold text-green-600">${recipe.price}</span>
                    </div>
                    <p className="text-gray-600 mb-4">{recipe.description}</p>
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center space-x-1">
                        <Star className="fill-yellow-400 text-yellow-400" size={16} />
                        <span className="font-medium">{recipe.rating}</span>
                        <span className="text-gray-500">({recipe.reviews})</span>
                      </div>
                      <span className="text-sm text-gray-600">{recipe.cookName}</span>
                    </div>
                    <button
                      onClick={() => addToCart(recipe)}
                      className="w-full bg-orange-500 hover:bg-orange-600 text-white py-3 px-4 rounded-lg transition-colors"
                    >
                      Add to Cart - ${recipe.price}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Featured Cooks */}
        <section className="py-12">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-bold text-gray-800 text-center mb-12">Featured Cooks</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {featuredCooks.map(cook => (
                <div key={cook.id} className="bg-white rounded-xl shadow-lg border border-gray-100 p-6 text-center hover:shadow-xl transition-shadow">
                  <ImageWithFallback
                    src={cook.avatar}
                    alt={cook.name}
                    className="w-20 h-20 rounded-full object-cover mx-auto mb-4"
                  />
                  <h3 className="text-xl font-semibold text-gray-800 mb-2">{cook.name}</h3>
                  <div className="flex items-center justify-center space-x-1 mb-3">
                    <Star className="fill-yellow-400 text-yellow-400" size={16} />
                    <span className="font-medium">{cook.rating}</span>
                    <span className="text-gray-500">rating</span>
                  </div>
                  <div className="flex flex-wrap justify-center gap-2 mb-4">
                    {cook.specialties.map((specialty, index) => (
                      <span
                        key={index}
                        className="text-sm bg-green-100 text-green-700 px-3 py-1 rounded-full"
                      >
                        {specialty}
                      </span>
                    ))}
                  </div>
                  <button className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-2 rounded-lg transition-colors">
                    View Profile
                  </button>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Footer */}
        <footer className="bg-gray-800 text-white py-12">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <div className="text-4xl mb-4">🍽️</div>
            <h3 className="text-2xl font-bold mb-2">Baty Food</h3>
            <p className="text-gray-400 mb-6">Authentic Home Food Everywhere</p>
            <div className="flex justify-center space-x-6 text-gray-400">
              <span>© 2024 Baty Food. All rights reserved.</span>
            </div>
          </div>
        </footer>
      </div>
    );
  }

  // Other pages would be rendered here based on currentPage state
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-gray-800 mb-4">
          {currentPage === 'browse' && 'Browse Recipes'}
          {currentPage === 'cart' && 'Shopping Cart'}
          {currentPage === 'profile' && 'User Profile'}
        </h2>
        <button
          onClick={() => setCurrentPage('home')}
          className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg transition-colors"
        >
          Back to Home
        </button>
      </div>
    </div>
  );
}
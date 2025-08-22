import React from 'react';
import { Search, ChefHat, Star, Clock, Users } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface LandingPageProps {
  onNavigate: (screen: string) => void;
}

const LandingPage: React.FC<LandingPageProps> = ({ onNavigate }) => {
  const featuredCategories = [
    { name: 'Arabic', emoji: '🥙', count: '120+ recipes' },
    { name: 'Egyptian', emoji: '🍛', count: '85+ recipes' },
    { name: 'Lebanese', emoji: '🫓', count: '95+ recipes' },
    { name: 'Syrian', emoji: '🍖', count: '70+ recipes' },
    { name: 'Turkish', emoji: '🥘', count: '65+ recipes' }
  ];

  const featuredRecipes = [
    {
      id: '1',
      name: 'Grilled Kebab',
      emoji: '🍖',
      price: '$5',
      rating: 4.8,
      reviews: 25,
      cook: 'Um Ali',
      prepTime: '30 min'
    },
    {
      id: '2',
      name: 'Grilled Chicken',
      emoji: '🍗',
      price: '$6',
      rating: 4.6,
      reviews: 18,
      cook: 'Abu Mohamed',
      prepTime: '25 min'
    },
    {
      id: '3',
      name: 'Grilled Fish',
      emoji: '🐟',
      price: '$8',
      rating: 4.9,
      reviews: 32,
      cook: 'Sarah Ahmed',
      prepTime: '35 min'
    }
  ];

  const featuredCooks = [
    {
      id: '1',
      name: 'Um Ali',
      emoji: '👩',
      rating: 4.8,
      speciality: 'Traditional Arabic',
      totalOrders: 150
    },
    {
      id: '2',
      name: 'Abu Mohamed',
      emoji: '👨',
      rating: 4.6,
      speciality: 'Egyptian Cuisine',
      totalOrders: 120
    },
    {
      id: '3',
      name: 'Sarah Ahmed',
      emoji: '👩',
      rating: 4.9,
      speciality: 'Seafood Specialist',
      totalOrders: 200
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-green-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-full flex items-center justify-center">
                <span className="text-white text-xl">🍽️</span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Baty Food</h1>
                <p className="text-sm text-green-600">Authentic Home Food</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <button
                onClick={() => onNavigate('login')}
                className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md transition-colors"
              >
                Sign In
              </button>
              <button
                onClick={() => onNavigate('login')}
                className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-2 rounded-lg transition-colors"
              >
                Get Started
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="text-center">
          <h1 className="text-5xl lg:text-6xl font-bold text-gray-900 mb-6">
            Authentic Home Food
            <span className="block text-orange-500">Everywhere</span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            Discover delicious homemade recipes from talented local cooks. Fresh, authentic, and made with love.
          </p>
          
          {/* Search Bar */}
          <div className="max-w-2xl mx-auto mb-12">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Search for recipes, cuisines, or cooks..."
                className="block w-full pl-10 pr-3 py-4 border border-gray-300 rounded-xl text-lg focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button className="absolute inset-y-0 right-0 pr-3 flex items-center">
                <div className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-2 rounded-lg transition-colors">
                  Search
                </div>
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Food Categories */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Explore Cuisines</h2>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-6">
          {featuredCategories.map((category) => (
            <button
              key={category.name}
              onClick={() => onNavigate('customer-home')}
              className="bg-white rounded-xl p-6 text-center shadow-sm hover:shadow-md transition-shadow group"
            >
              <div className="text-4xl mb-3 group-hover:scale-110 transition-transform">
                {category.emoji}
              </div>
              <h3 className="font-semibold text-gray-900 mb-1">{category.name}</h3>
              <p className="text-sm text-gray-500">{category.count}</p>
            </button>
          ))}
        </div>
      </section>

      {/* Featured Recipes */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Featured Recipes</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {featuredRecipes.map((recipe) => (
            <div
              key={recipe.id}
              onClick={() => onNavigate('customer-home')}
              className="bg-white rounded-xl shadow-sm hover:shadow-lg transition-shadow cursor-pointer group overflow-hidden"
            >
              <div className="aspect-w-16 aspect-h-12 bg-gradient-to-br from-orange-100 to-green-100">
                <div className="flex items-center justify-center">
                  <span className="text-6xl group-hover:scale-110 transition-transform">
                    {recipe.emoji}
                  </span>
                </div>
              </div>
              <div className="p-6">
                <div className="flex justify-between items-start mb-3">
                  <h3 className="text-xl font-semibold text-gray-900">{recipe.name}</h3>
                  <span className="text-xl font-bold text-orange-500">{recipe.price}</span>
                </div>
                
                <div className="flex items-center space-x-4 text-sm text-gray-600 mb-3">
                  <div className="flex items-center space-x-1">
                    <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    <span>{recipe.rating}</span>
                    <span>({recipe.reviews})</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Clock className="w-4 h-4" />
                    <span>{recipe.prepTime}</span>
                  </div>
                </div>
                
                <div className="flex items-center space-x-2">
                  <ChefHat className="w-4 h-4 text-green-600" />
                  <span className="text-sm text-gray-700">by {recipe.cook}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Featured Cooks */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Featured Cooks</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {featuredCooks.map((cook) => (
            <div
              key={cook.id}
              onClick={() => onNavigate('customer-home')}
              className="bg-white rounded-xl p-6 text-center shadow-sm hover:shadow-lg transition-shadow cursor-pointer group"
            >
              <div className="w-20 h-20 bg-gradient-to-br from-orange-400 to-green-400 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform">
                <span className="text-3xl">{cook.emoji}</span>
              </div>
              
              <h3 className="text-xl font-semibold text-gray-900 mb-2">{cook.name}</h3>
              <p className="text-sm text-gray-600 mb-3">{cook.speciality}</p>
              
              <div className="flex items-center justify-center space-x-1 mb-2">
                {[...Array(5)].map((_, i) => (
                  <Star
                    key={i}
                    className={`w-4 h-4 ${
                      i < Math.floor(cook.rating)
                        ? 'fill-yellow-400 text-yellow-400'
                        : 'text-gray-300'
                    }`}
                  />
                ))}
                <span className="text-sm font-medium text-gray-700 ml-1">
                  {cook.rating}
                </span>
              </div>
              
              <div className="flex items-center justify-center space-x-1 text-sm text-gray-500">
                <Users className="w-4 h-4" />
                <span>{cook.totalOrders} orders completed</span>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Call to Action */}
      <section className="bg-gradient-to-r from-orange-500 to-green-600 py-16">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-white mb-4">
            Ready to taste authentic home cooking?
          </h2>
          <p className="text-xl text-orange-100 mb-8">
            Join thousands of food lovers discovering amazing homemade recipes from local cooks.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button
              onClick={() => onNavigate('login')}
              className="bg-white text-orange-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-50 transition-colors"
            >
              Order Now
            </button>
            <button
              onClick={() => onNavigate('login')}
              className="border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-orange-600 transition-colors"
            >
              Become a Cook
            </button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-8 h-8 bg-gradient-to-br from-orange-500 to-orange-600 rounded-full flex items-center justify-center">
                  <span className="text-white">🍽️</span>
                </div>
                <span className="font-bold text-xl">Baty Food</span>
              </div>
              <p className="text-gray-400">
                Connecting food lovers with talented home cooks for authentic, delicious meals.
              </p>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">For Customers</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Browse Recipes</a></li>
                <li><a href="#" className="hover:text-white transition-colors">How It Works</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Delivery Areas</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">For Cooks</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Start Cooking</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Cook Resources</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Success Stories</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Support</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Help Center</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Contact Us</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Safety</a></li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 Baty Food. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage;
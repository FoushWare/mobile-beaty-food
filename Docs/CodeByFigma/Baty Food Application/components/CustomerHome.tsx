import React, { useState, useEffect } from 'react';
import { Search, ShoppingCart, User, Heart, Star, Clock, Filter, ChefHat } from 'lucide-react';
import { projectId, publicAnonKey } from '../utils/supabase/info';
import LoadingSpinner from './LoadingSpinner';

interface CustomerHomeProps {
  user: any;
  onNavigate: (screen: string) => void;
  onLogout: () => void;
  setSelectedRecipe: (recipe: any) => void;
  addToCart: (recipe: any, quantity: number) => void;
  getCartItemCount: () => number;
}

const CustomerHome: React.FC<CustomerHomeProps> = ({
  user,
  onNavigate,
  onLogout,
  setSelectedRecipe,
  addToCart,
  getCartItemCount
}) => {
  const [recipes, setRecipes] = useState<any[]>([]);
  const [featuredCooks, setFeaturedCooks] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [favorites, setFavorites] = useState<string[]>([]);

  const categories = [
    { name: 'All', emoji: '🍽️', count: 0 },
    { name: 'Arabic', emoji: '🥙', count: 0 },
    { name: 'Egyptian', emoji: '🍛', count: 0 },
    { name: 'Lebanese', emoji: '🫓', count: 0 },
    { name: 'Syrian', emoji: '🍖', count: 0 },
    { name: 'Turkish', emoji: '🥘', count: 0 }
  ];

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Load recipes
      const recipesResponse = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/recipes`,
        {
          headers: {
            'Authorization': `Bearer ${publicAnonKey}`,
          },
        }
      );

      if (recipesResponse.ok) {
        const recipesData = await recipesResponse.json();
        setRecipes(recipesData.filter((recipe: any) => recipe.available));
      }

      // Load featured cooks
      const cooksResponse = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/featured-cooks`,
        {
          headers: {
            'Authorization': `Bearer ${publicAnonKey}`,
          },
        }
      );

      if (cooksResponse.ok) {
        const cooksData = await cooksResponse.json();
        setFeaturedCooks(cooksData);
      }
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleRecipeClick = (recipe: any) => {
    setSelectedRecipe(recipe);
    onNavigate('recipe-detail');
  };

  const toggleFavorite = (recipeId: string) => {
    setFavorites(prev => 
      prev.includes(recipeId)
        ? prev.filter(id => id !== recipeId)
        : [...prev, recipeId]
    );
  };

  const filteredRecipes = recipes.filter(recipe => {
    const matchesSearch = recipe.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         recipe.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         recipe.cookName.toLowerCase().includes(searchQuery.toLowerCase());
    
    const matchesCategory = selectedCategory === 'All' || recipe.cuisine === selectedCategory;
    
    return matchesSearch && matchesCategory;
  });

  const featuredRecipes = recipes
    .filter(recipe => recipe.rating >= 4.5)
    .sort((a, b) => b.totalOrders - a.totalOrders)
    .slice(0, 6);

  if (loading) {
    return <LoadingSpinner />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-full flex items-center justify-center">
                <span className="text-white text-xl">🍽️</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Baty Food</h1>
                <p className="text-xs text-green-600">Welcome, {user?.name}</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <button
                onClick={() => onNavigate('cart')}
                className="relative p-2 text-gray-600 hover:text-gray-900 transition-colors"
              >
                <ShoppingCart className="w-6 h-6" />
                {getCartItemCount() > 0 && (
                  <span className="absolute -top-1 -right-1 bg-orange-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                    {getCartItemCount()}
                  </span>
                )}
              </button>
              <button
                onClick={() => onNavigate('profile')}
                className="p-2 text-gray-600 hover:text-gray-900 transition-colors"
              >
                <User className="w-6 h-6" />
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Search Bar */}
        <div className="mb-8">
          <div className="relative max-w-2xl mx-auto">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search for recipes, cuisines, or cooks..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
            />
          </div>
        </div>

        {/* Categories */}
        <div className="mb-8">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Food Categories</h2>
          <div className="flex space-x-4 overflow-x-auto pb-2">
            {categories.map((category) => (
              <button
                key={category.name}
                onClick={() => setSelectedCategory(category.name)}
                className={`flex-shrink-0 px-6 py-3 rounded-xl transition-all ${
                  selectedCategory === category.name
                    ? 'bg-orange-500 text-white shadow-lg'
                    : 'bg-white text-gray-700 hover:bg-gray-50 shadow-sm'
                }`}
              >
                <div className="flex items-center space-x-2">
                  <span className="text-lg">{category.emoji}</span>
                  <span className="font-medium">{category.name}</span>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Featured Recipes */}
        {featuredRecipes.length > 0 && (
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Featured Recipes</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {featuredRecipes.map((recipe) => (
                <div
                  key={recipe.id}
                  className="bg-white rounded-xl shadow-sm hover:shadow-lg transition-shadow cursor-pointer overflow-hidden group"
                  onClick={() => handleRecipeClick(recipe)}
                >
                  <div className="aspect-w-16 aspect-h-10 bg-gradient-to-br from-orange-100 to-green-100">
                    {recipe.image ? (
                      <img
                        src={recipe.image}
                        alt={recipe.title}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    ) : (
                      <div className="flex items-center justify-center">
                        <span className="text-4xl">🍽️</span>
                      </div>
                    )}
                  </div>
                  
                  <div className="p-4">
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-semibold text-gray-900 line-clamp-1">{recipe.title}</h3>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          toggleFavorite(recipe.id);
                        }}
                        className="p-1 text-gray-400 hover:text-red-500 transition-colors"
                      >
                        <Heart
                          className={`w-5 h-5 ${
                            favorites.includes(recipe.id) ? 'fill-red-500 text-red-500' : ''
                          }`}
                        />
                      </button>
                    </div>
                    
                    <p className="text-sm text-gray-600 mb-3 line-clamp-2">{recipe.description}</p>
                    
                    <div className="flex items-center justify-between text-sm text-gray-600 mb-3">
                      <div className="flex items-center space-x-3">
                        <div className="flex items-center space-x-1">
                          <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                          <span>{recipe.rating.toFixed(1)}</span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <Clock className="w-4 h-4" />
                          <span>{recipe.prepTime}m</span>
                        </div>
                      </div>
                      <span className="font-bold text-orange-500">${recipe.price}</span>
                    </div>
                    
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-2">
                        <ChefHat className="w-4 h-4 text-green-600" />
                        <span className="text-sm text-gray-700">{recipe.cookName}</span>
                      </div>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          addToCart(recipe, 1);
                        }}
                        className="bg-orange-500 hover:bg-orange-600 text-white px-3 py-1 rounded-lg text-sm font-medium transition-colors"
                      >
                        Add to Cart
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* All Recipes */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold text-gray-900">
              {selectedCategory === 'All' ? 'All Recipes' : `${selectedCategory} Recipes`}
            </h2>
            <div className="flex items-center space-x-2">
              <Filter className="w-5 h-5 text-gray-400" />
              <select className="border border-gray-300 rounded-lg px-3 py-2 text-sm">
                <option>Latest</option>
                <option>Highest Rated</option>
                <option>Price: Low to High</option>
                <option>Price: High to Low</option>
              </select>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredRecipes.map((recipe) => (
              <div
                key={recipe.id}
                className="bg-white rounded-xl shadow-sm hover:shadow-lg transition-shadow cursor-pointer overflow-hidden group"
                onClick={() => handleRecipeClick(recipe)}
              >
                <div className="aspect-w-16 aspect-h-10 bg-gradient-to-br from-orange-100 to-green-100">
                  {recipe.image ? (
                    <img
                      src={recipe.image}
                      alt={recipe.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  ) : (
                    <div className="flex items-center justify-center">
                      <span className="text-4xl">🍽️</span>
                    </div>
                  )}
                </div>
                
                <div className="p-4">
                  <div className="flex justify-between items-start mb-2">
                    <h3 className="font-semibold text-gray-900 line-clamp-1">{recipe.title}</h3>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        toggleFavorite(recipe.id);
                      }}
                      className="p-1 text-gray-400 hover:text-red-500 transition-colors"
                    >
                      <Heart
                        className={`w-4 h-4 ${
                          favorites.includes(recipe.id) ? 'fill-red-500 text-red-500' : ''
                        }`}
                      />
                    </button>
                  </div>
                  
                  <div className="flex items-center justify-between text-sm text-gray-600 mb-3">
                    <div className="flex items-center space-x-2">
                      <div className="flex items-center space-x-1">
                        <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                        <span>{recipe.rating.toFixed(1)}</span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Clock className="w-3 h-3" />
                        <span>{recipe.prepTime}m</span>
                      </div>
                    </div>
                    <span className="font-bold text-orange-500">${recipe.price}</span>
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-1">
                      <ChefHat className="w-3 h-3 text-green-600" />
                      <span className="text-xs text-gray-700 truncate">{recipe.cookName}</span>
                    </div>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        addToCart(recipe, 1);
                      }}
                      className="bg-orange-500 hover:bg-orange-600 text-white px-2 py-1 rounded text-xs font-medium transition-colors"
                    >
                      Add
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
          
          {filteredRecipes.length === 0 && (
            <div className="text-center py-12">
              <div className="text-6xl mb-4">🔍</div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">No recipes found</h3>
              <p className="text-gray-600">
                Try adjusting your search or selecting a different category.
              </p>
            </div>
          )}
        </div>

        {/* Featured Cooks */}
        {featuredCooks.length > 0 && (
          <div className="mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Featured Cooks</h2>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
              {featuredCooks.map((cook) => (
                <div
                  key={cook.id}
                  className="bg-white rounded-xl p-4 text-center shadow-sm hover:shadow-lg transition-shadow cursor-pointer group"
                >
                  <div className="w-16 h-16 bg-gradient-to-br from-orange-400 to-green-400 rounded-full flex items-center justify-center mx-auto mb-3 group-hover:scale-110 transition-transform">
                    <span className="text-2xl">👨‍🍳</span>
                  </div>
                  
                  <h3 className="font-semibold text-gray-900 mb-1 truncate">{cook.name}</h3>
                  
                  <div className="flex items-center justify-center space-x-1 mb-2">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`w-3 h-3 ${
                          i < Math.floor(cook.rating || 0)
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-gray-300'
                        }`}
                      />
                    ))}
                  </div>
                  
                  <p className="text-xs text-gray-500">{cook.totalOrders || 0} orders</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default CustomerHome;
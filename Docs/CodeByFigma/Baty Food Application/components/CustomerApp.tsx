import React, { useState, useEffect } from 'react';
import { Search, ShoppingCart, User, Heart, Star, Clock, Users } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { RecipeCard } from './RecipeCard';
import { CookCard } from './CookCard';
import { Cart } from './Cart';
import { Profile } from './Profile';
import { RecipeDetail } from './RecipeDetail';

interface CustomerAppProps {
  user: any;
  onLogout: () => void;
  onSwitchToWeb: () => void;
}

interface Recipe {
  id: string;
  title: string;
  description: string;
  price: number;
  image: string;
  rating: number;
  reviews: number;
  prepTime: number;
  servings: number;
  category: string;
  cookName: string;
  cookId: string;
}

interface Cook {
  id: string;
  name: string;
  rating: number;
  avatar: string;
  specialties: string[];
}

export function CustomerApp({ user, onLogout, onSwitchToWeb }: CustomerAppProps) {
  const [currentView, setCurrentView] = useState<'home' | 'cart' | 'profile' | 'recipe'>('home');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [cartItems, setCartItems] = useState<any[]>([]);
  const [selectedRecipe, setSelectedRecipe] = useState<Recipe | null>(null);
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [cooks, setCooks] = useState<Cook[]>([]);

  const categories = ['All', 'Arabic', 'Egyptian', 'Lebanese', 'Syrian', 'Turkish'];

  useEffect(() => {
    // Load sample data
    const sampleRecipes: Recipe[] = [
      {
        id: '1',
        title: 'Grilled Kebab',
        description: 'Fresh grilled kebab with authentic Arabic spices and herbs',
        price: 5,
        image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        rating: 4.8,
        reviews: 25,
        prepTime: 30,
        servings: 4,
        category: 'Arabic',
        cookName: 'Um Ali',
        cookId: '1'
      },
      {
        id: '2',
        title: 'Grilled Chicken',
        description: 'Tender grilled chicken with Mediterranean herbs',
        price: 6,
        image: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400',
        rating: 4.6,
        reviews: 18,
        prepTime: 25,
        servings: 3,
        category: 'Lebanese',
        cookName: 'Abu Mohamed',
        cookId: '2'
      },
      {
        id: '3',
        title: 'Grilled Fish',
        description: 'Fresh fish grilled with lemon and Mediterranean spices',
        price: 8,
        image: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',
        rating: 4.9,
        reviews: 12,
        prepTime: 20,
        servings: 2,
        category: 'Mediterranean',
        cookName: 'Sarah Ahmed',
        cookId: '3'
      }
    ];

    const sampleCooks: Cook[] = [
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

    setRecipes(sampleRecipes);
    setCooks(sampleCooks);
  }, []);

  const filteredRecipes = recipes.filter(recipe => {
    const matchesCategory = selectedCategory === 'All' || recipe.category === selectedCategory;
    const matchesSearch = recipe.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         recipe.cookName.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const addToCart = (recipe: Recipe, quantity: number = 1) => {
    const existingItem = cartItems.find(item => item.id === recipe.id);
    if (existingItem) {
      setCartItems(cartItems.map(item =>
        item.id === recipe.id
          ? { ...item, quantity: item.quantity + quantity }
          : item
      ));
    } else {
      setCartItems([...cartItems, { ...recipe, quantity }]);
    }
  };

  const removeFromCart = (recipeId: string) => {
    setCartItems(cartItems.filter(item => item.id !== recipeId));
  };

  const updateCartQuantity = (recipeId: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(recipeId);
    } else {
      setCartItems(cartItems.map(item =>
        item.id === recipeId ? { ...item, quantity } : item
      ));
    }
  };

  if (currentView === 'cart') {
    return (
      <Cart
        items={cartItems}
        onUpdateQuantity={updateCartQuantity}
        onRemoveItem={removeFromCart}
        onBack={() => setCurrentView('home')}
      />
    );
  }

  if (currentView === 'profile') {
    return (
      <Profile
        user={user}
        onBack={() => setCurrentView('home')}
        onLogout={onLogout}
      />
    );
  }

  if (currentView === 'recipe' && selectedRecipe) {
    return (
      <RecipeDetail
        recipe={selectedRecipe}
        onBack={() => setCurrentView('home')}
        onAddToCart={addToCart}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="flex items-center justify-between p-4">
          <div className="flex items-center space-x-3">
            <div className="text-2xl">🍽️</div>
            <div>
              <h1 className="font-bold text-gray-800">Baty Food</h1>
              <p className="text-xs text-gray-600">Hello, {user?.user_metadata?.name || 'Customer'}</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-3">
            <button 
              onClick={onSwitchToWeb}
              className="p-2 text-gray-600 text-xs"
            >
              Web View
            </button>
            <button
              onClick={() => setCurrentView('cart')}
              className="relative p-2 text-gray-600"
            >
              <ShoppingCart size={24} />
              {cartItems.length > 0 && (
                <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                  {cartItems.reduce((sum, item) => sum + item.quantity, 0)}
                </span>
              )}
            </button>
            <button
              onClick={() => setCurrentView('profile')}
              className="p-2 text-gray-600"
            >
              <User size={24} />
            </button>
          </div>
        </div>

        {/* Search Bar */}
        <div className="px-4 pb-4">
          <div className="relative">
            <Search className="absolute left-3 top-3 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Search recipes or cooks..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
            />
          </div>
        </div>
      </div>

      {/* Categories */}
      <div className="px-4 py-4">
        <h2 className="font-semibold text-gray-800 mb-3">Food Categories</h2>
        <div className="flex space-x-2 overflow-x-auto">
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
                selectedCategory === category
                  ? 'bg-orange-500 text-white'
                  : 'bg-white text-gray-700 border border-gray-200'
              }`}
              style={selectedCategory === category ? { backgroundColor: '#FF6B35' } : {}}
            >
              {category}
            </button>
          ))}
        </div>
      </div>

      {/* Featured Recipes */}
      <div className="px-4 py-4">
        <h2 className="font-semibold text-gray-800 mb-3">Featured Recipes</h2>
        <div className="grid grid-cols-1 gap-4">
          {filteredRecipes.map(recipe => (
            <RecipeCard
              key={recipe.id}
              recipe={recipe}
              onSelect={(recipe) => {
                setSelectedRecipe(recipe);
                setCurrentView('recipe');
              }}
              onAddToCart={() => addToCart(recipe)}
            />
          ))}
        </div>
      </div>

      {/* Featured Cooks */}
      <div className="px-4 py-4 pb-8">
        <h2 className="font-semibold text-gray-800 mb-3">Featured Cooks</h2>
        <div className="grid grid-cols-1 gap-4">
          {cooks.map(cook => (
            <CookCard key={cook.id} cook={cook} />
          ))}
        </div>
      </div>
    </div>
  );
}
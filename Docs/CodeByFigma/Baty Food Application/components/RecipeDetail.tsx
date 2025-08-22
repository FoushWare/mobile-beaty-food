import React, { useState } from 'react';
import { ArrowLeft, Heart, Star, Clock, Users, ChefHat, Plus, Minus } from 'lucide-react';

interface RecipeDetailProps {
  selectedRecipe: any;
  onNavigate: (screen: string) => void;
  addToCart: (recipe: any, quantity: number) => void;
  user: any;
}

export const RecipeDetail: React.FC<RecipeDetailProps> = ({
  selectedRecipe,
  onNavigate,
  addToCart,
  user
}) => {
  const [quantity, setQuantity] = useState(1);
  const [isFavorite, setIsFavorite] = useState(false);

  if (!selectedRecipe) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-600 mb-4">Recipe not found</p>
          <button
            onClick={() => onNavigate('customer-home')}
            className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
          >
            Back to Recipes
          </button>
        </div>
      </div>
    );
  }

  const handleAddToCart = () => {
    addToCart(selectedRecipe, quantity);
    // Show a success message or navigate to cart
    const confirmed = confirm(`Added ${quantity} ${selectedRecipe.title}(s) to cart!`);
    if (confirmed) {
      onNavigate('cart');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <button
              onClick={() => onNavigate('customer-home')}
              className="flex items-center text-gray-600 hover:text-gray-900"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Back
            </button>
            <button
              onClick={() => setIsFavorite(!isFavorite)}
              className="p-2 text-gray-400 hover:text-red-500 transition-colors"
            >
              <Heart
                className={`w-6 h-6 ${
                  isFavorite ? 'fill-red-500 text-red-500' : ''
                }`}
              />
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Recipe Image */}
          <div className="space-y-4">
            <div className="aspect-w-16 aspect-h-12 bg-gradient-to-br from-orange-100 to-green-100 rounded-xl overflow-hidden">
              {selectedRecipe.image ? (
                <img
                  src={selectedRecipe.image}
                  alt={selectedRecipe.title}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="flex items-center justify-center">
                  <span className="text-8xl">🍽️</span>
                </div>
              )}
            </div>
            
            {/* Quick Info Cards */}
            <div className="grid grid-cols-3 gap-4">
              <div className="bg-white p-4 rounded-lg text-center shadow-sm">
                <Clock className="w-6 h-6 text-orange-500 mx-auto mb-2" />
                <p className="text-sm text-gray-600">Prep Time</p>
                <p className="font-semibold text-gray-900">{selectedRecipe.prepTime} min</p>
              </div>
              <div className="bg-white p-4 rounded-lg text-center shadow-sm">
                <Users className="w-6 h-6 text-green-500 mx-auto mb-2" />
                <p className="text-sm text-gray-600">Servings</p>
                <p className="font-semibold text-gray-900">{selectedRecipe.servings} people</p>
              </div>
              <div className="bg-white p-4 rounded-lg text-center shadow-sm">
                <Star className="w-6 h-6 text-yellow-500 mx-auto mb-2" />
                <p className="text-sm text-gray-600">Rating</p>
                <p className="font-semibold text-gray-900">{selectedRecipe.rating.toFixed(1)}</p>
              </div>
            </div>
          </div>

          {/* Recipe Details */}
          <div className="space-y-6">
            <div>
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h1 className="text-3xl font-bold text-gray-900 mb-2">
                    {selectedRecipe.title}
                  </h1>
                  <div className="flex items-center space-x-4 text-sm text-gray-600">
                    <div className="flex items-center space-x-1">
                      <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                      <span>{selectedRecipe.rating.toFixed(1)}</span>
                      <span>({selectedRecipe.totalOrders} orders)</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <ChefHat className="w-4 h-4 text-green-600" />
                      <span>by {selectedRecipe.cookName}</span>
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-3xl font-bold text-orange-500">
                    ${selectedRecipe.price}
                  </p>
                  <p className="text-sm text-gray-600">per serving</p>
                </div>
              </div>

              <div className="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-6">
                <p className="text-orange-800 font-medium">🍴 {selectedRecipe.cuisine} Cuisine</p>
              </div>
            </div>

            {/* Description */}
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Description</h2>
              <p className="text-gray-700 leading-relaxed">
                {selectedRecipe.description}
              </p>
            </div>

            {/* Ingredients */}
            {selectedRecipe.ingredients && selectedRecipe.ingredients.length > 0 && (
              <div>
                <h2 className="text-xl font-semibold text-gray-900 mb-3">Ingredients</h2>
                <div className="bg-white rounded-lg p-4 shadow-sm">
                  <ul className="space-y-2">
                    {selectedRecipe.ingredients.map((ingredient: string, index: number) => (
                      <li key={index} className="flex items-center space-x-2">
                        <span className="w-2 h-2 bg-orange-500 rounded-full flex-shrink-0"></span>
                        <span className="text-gray-700">{ingredient}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            )}

            {/* Add to Cart Section */}
            <div className="bg-white rounded-xl p-6 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Add to Cart</h3>
                <div className="text-right">
                  <p className="text-2xl font-bold text-orange-500">
                    ${(selectedRecipe.price * quantity).toFixed(2)}
                  </p>
                  <p className="text-sm text-gray-600">
                    {quantity} × ${selectedRecipe.price}
                  </p>
                </div>
              </div>

              <div className="flex items-center space-x-4 mb-4">
                <span className="text-gray-700 font-medium">Quantity:</span>
                <div className="flex items-center space-x-2 bg-gray-100 rounded-lg p-1">
                  <button
                    onClick={() => setQuantity(Math.max(1, quantity - 1))}
                    className="p-2 text-gray-600 hover:text-gray-900 transition-colors"
                    disabled={quantity <= 1}
                  >
                    <Minus className="w-4 h-4" />
                  </button>
                  <span className="w-12 text-center font-medium">{quantity}</span>
                  <button
                    onClick={() => setQuantity(quantity + 1)}
                    className="p-2 text-gray-600 hover:text-gray-900 transition-colors"
                  >
                    <Plus className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <button
                onClick={handleAddToCart}
                className="w-full bg-orange-500 hover:bg-orange-600 text-white py-3 px-4 rounded-lg font-medium transition-colors flex items-center justify-center space-x-2"
              >
                <span>Add to Cart</span>
                <span>•</span>
                <span>${(selectedRecipe.price * quantity).toFixed(2)}</span>
              </button>
            </div>

            {/* Cook Info */}
            <div className="bg-white rounded-xl p-6 shadow-sm">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">About the Cook</h3>
              <div className="flex items-center space-x-4">
                <div className="w-12 h-12 bg-gradient-to-br from-orange-400 to-green-400 rounded-full flex items-center justify-center">
                  <span className="text-xl">👨‍🍳</span>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900">{selectedRecipe.cookName}</h4>
                  <div className="flex items-center space-x-1 mt-1">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`w-4 h-4 ${
                          i < Math.floor(selectedRecipe.rating)
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-gray-300'
                        }`}
                      />
                    ))}
                    <span className="text-sm text-gray-600 ml-2">
                      ({selectedRecipe.totalOrders} orders completed)
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
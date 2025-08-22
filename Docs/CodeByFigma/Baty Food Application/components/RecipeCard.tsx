import React from 'react';
import { Star, Clock, Users, Plus } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

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

interface RecipeCardProps {
  recipe: Recipe;
  onSelect: (recipe: Recipe) => void;
  onAddToCart: () => void;
}

export function RecipeCard({ recipe, onSelect, onAddToCart }: RecipeCardProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div 
        className="cursor-pointer"
        onClick={() => onSelect(recipe)}
      >
        <div className="relative">
          <ImageWithFallback
            src={recipe.image}
            alt={recipe.title}
            className="w-full h-48 object-cover"
          />
          <div className="absolute top-3 right-3 bg-white rounded-full p-2 shadow-sm">
            <span className="text-lg">❤️</span>
          </div>
        </div>

        <div className="p-4">
          <div className="flex items-start justify-between mb-2">
            <h3 className="font-semibold text-gray-800 text-lg">{recipe.title}</h3>
            <span className="text-xl font-bold text-green-600">${recipe.price}</span>
          </div>

          <p className="text-gray-600 text-sm mb-3 line-clamp-2">{recipe.description}</p>

          <div className="flex items-center space-x-4 mb-3 text-sm text-gray-500">
            <div className="flex items-center space-x-1">
              <Star className="fill-yellow-400 text-yellow-400" size={16} />
              <span>{recipe.rating}</span>
              <span>({recipe.reviews})</span>
            </div>
            <div className="flex items-center space-x-1">
              <Clock size={16} />
              <span>{recipe.prepTime} min</span>
            </div>
            <div className="flex items-center space-x-1">
              <Users size={16} />
              <span>{recipe.servings} servings</span>
            </div>
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <ImageWithFallback
                src={`https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop&crop=face`}
                alt={recipe.cookName}
                className="w-8 h-8 rounded-full object-cover"
              />
              <span className="text-sm text-gray-600">{recipe.cookName}</span>
            </div>
            <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded-full">
              {recipe.category}
            </span>
          </div>
        </div>
      </div>

      <div className="px-4 pb-4">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onAddToCart();
          }}
          className="w-full bg-orange-500 hover:bg-orange-600 text-white py-3 px-4 rounded-lg transition-colors flex items-center justify-center space-x-2"
          style={{ backgroundColor: '#FF6B35' }}
        >
          <Plus size={20} />
          <span>Add to Cart</span>
        </button>
      </div>
    </div>
  );
}
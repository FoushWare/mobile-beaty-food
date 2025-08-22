import React, { useState } from 'react';
import { ArrowLeft, Plus, Edit, Trash2, Eye, EyeOff } from 'lucide-react';

interface Recipe {
  id: string;
  title: string;
  description: string;
  price: number;
  category: string;
  prepTime: number;
  servings: number;
  active: boolean;
  orders: number;
}

interface RecipeManagementProps {
  user: any;
  onBack: () => void;
}

export function RecipeManagement({ user, onBack }: RecipeManagementProps) {
  const [recipes, setRecipes] = useState<Recipe[]>([
    {
      id: '1',
      title: 'Grilled Kebab',
      description: 'Fresh grilled kebab with authentic Arabic spices',
      price: 5,
      category: 'Arabic',
      prepTime: 30,
      servings: 4,
      active: true,
      orders: 15
    },
    {
      id: '2',
      title: 'Grilled Chicken',
      description: 'Tender grilled chicken with Mediterranean herbs',
      price: 6,
      category: 'Lebanese',
      prepTime: 25,
      servings: 3,
      active: true,
      orders: 8
    },
    {
      id: '3',
      title: 'Grilled Fish',
      description: 'Fresh fish grilled with lemon and spices',
      price: 8,
      category: 'Mediterranean',
      prepTime: 20,
      servings: 2,
      active: false,
      orders: 3
    }
  ]);

  const [showAddForm, setShowAddForm] = useState(false);
  const [editingRecipe, setEditingRecipe] = useState<Recipe | null>(null);

  const toggleRecipeStatus = (recipeId: string) => {
    setRecipes(recipes.map(recipe =>
      recipe.id === recipeId
        ? { ...recipe, active: !recipe.active }
        : recipe
    ));
  };

  const deleteRecipe = (recipeId: string) => {
    if (confirm('Are you sure you want to delete this recipe?')) {
      setRecipes(recipes.filter(recipe => recipe.id !== recipeId));
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm">
        <div className="flex items-center justify-between p-4">
          <button
            onClick={onBack}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft size={24} />
          </button>
          <h1 className="font-semibold text-gray-800">📝 Recipe Management</h1>
          <div className="w-10"></div>
        </div>
      </div>

      <div className="p-4">
        {/* Add New Recipe Button */}
        <button
          onClick={() => setShowAddForm(true)}
          className="w-full bg-orange-500 hover:bg-orange-600 text-white py-3 px-4 rounded-lg transition-colors mb-6 flex items-center justify-center space-x-2"
          style={{ backgroundColor: '#FF6B35' }}
        >
          <Plus size={20} />
          <span>Add New Recipe</span>
        </button>

        {/* Recipes List */}
        <div className="space-y-4">
          <h2 className="font-semibold text-gray-800">Current Recipes:</h2>
          
          {recipes.map(recipe => (
            <div key={recipe.id} className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <div className="flex items-center space-x-3 mb-2">
                    <h3 className="font-semibold text-gray-800">{recipe.title}</h3>
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      recipe.active
                        ? 'bg-green-100 text-green-700'
                        : 'bg-red-100 text-red-700'
                    }`}>
                      {recipe.active ? 'Available' : 'Disabled'}
                    </span>
                  </div>
                  <p className="text-gray-600 text-sm mb-2">{recipe.description}</p>
                  <div className="flex items-center space-x-4 text-sm text-gray-500">
                    <span>${recipe.price}</span>
                    <span>{recipe.category}</span>
                    <span>{recipe.prepTime} min</span>
                    <span>{recipe.servings} servings</span>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-lg font-semibold text-green-600">${recipe.price}</div>
                  <div className="text-sm text-gray-600">{recipe.orders} orders</div>
                </div>
              </div>

              <div className="flex items-center space-x-2 pt-3 border-t border-gray-100">
                <button
                  onClick={() => setEditingRecipe(recipe)}
                  className="flex-1 bg-blue-500 hover:bg-blue-600 text-white py-2 px-3 rounded-lg transition-colors flex items-center justify-center space-x-1"
                >
                  <Edit size={16} />
                  <span>Edit</span>
                </button>
                
                <button
                  onClick={() => toggleRecipeStatus(recipe.id)}
                  className={`flex-1 py-2 px-3 rounded-lg transition-colors flex items-center justify-center space-x-1 ${
                    recipe.active
                      ? 'bg-orange-500 hover:bg-orange-600 text-white'
                      : 'bg-green-500 hover:bg-green-600 text-white'
                  }`}
                >
                  {recipe.active ? <EyeOff size={16} /> : <Eye size={16} />}
                  <span>{recipe.active ? 'Disable' : 'Enable'}</span>
                </button>
                
                <button
                  onClick={() => deleteRecipe(recipe.id)}
                  className="flex-1 bg-red-500 hover:bg-red-600 text-white py-2 px-3 rounded-lg transition-colors flex items-center justify-center space-x-1"
                >
                  <Trash2 size={16} />
                  <span>Delete</span>
                </button>
              </div>
            </div>
          ))}

          {recipes.length === 0 && (
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 text-center">
              <div className="text-6xl mb-4">🍽️</div>
              <h3 className="font-medium text-gray-800 mb-2">No recipes yet</h3>
              <p className="text-gray-600">Start by adding your first recipe to attract customers!</p>
            </div>
          )}
        </div>
      </div>

      {/* Add/Edit Recipe Modal (simplified) */}
      {(showAddForm || editingRecipe) && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-md">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">
              {editingRecipe ? 'Edit Recipe' : 'Add New Recipe'}
            </h3>
            
            <div className="space-y-4">
              <input
                type="text"
                placeholder="Recipe Title"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500"
                defaultValue={editingRecipe?.title}
              />
              <textarea
                placeholder="Description"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500"
                rows={3}
                defaultValue={editingRecipe?.description}
              />
              <input
                type="number"
                placeholder="Price ($)"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500"
                defaultValue={editingRecipe?.price}
              />
              <select
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500"
                defaultValue={editingRecipe?.category}
              >
                <option value="">Select Category</option>
                <option value="Arabic">Arabic</option>
                <option value="Lebanese">Lebanese</option>
                <option value="Egyptian">Egyptian</option>
                <option value="Turkish">Turkish</option>
              </select>
            </div>

            <div className="flex space-x-3 mt-6">
              <button
                onClick={() => {
                  setShowAddForm(false);
                  setEditingRecipe(null);
                }}
                className="flex-1 bg-gray-300 hover:bg-gray-400 text-gray-700 py-2 px-4 rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  // In a real app, save the recipe here
                  setShowAddForm(false);
                  setEditingRecipe(null);
                }}
                className="flex-1 bg-orange-500 hover:bg-orange-600 text-white py-2 px-4 rounded-lg transition-colors"
              >
                Save Recipe
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
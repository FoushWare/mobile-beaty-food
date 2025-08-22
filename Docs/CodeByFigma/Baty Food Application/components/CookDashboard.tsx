import React, { useState, useEffect } from 'react';
import { User, Settings, Plus, Package, DollarSign, Star, TrendingUp, Eye, Edit, ToggleLeft, ToggleRight } from 'lucide-react';
import { projectId } from '../utils/supabase/info';
import { supabase } from '../utils/supabase/client';
import LoadingSpinner from './LoadingSpinner';

interface CookDashboardProps {
  user: any;
  onNavigate: (screen: string) => void;
  onLogout: () => void;
}

export const CookDashboard: React.FC<CookDashboardProps> = ({
  user,
  onNavigate,
  onLogout
}) => {
  const [recipes, setRecipes] = useState<any[]>([]);
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');
  const [newRecipe, setNewRecipe] = useState({
    title: '',
    description: '',
    price: '',
    prepTime: '',
    servings: '',
    cuisine: 'Arabic',
    ingredients: ''
  });
  const [showAddRecipe, setShowAddRecipe] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const cuisineOptions = ['Arabic', 'Egyptian', 'Lebanese', 'Syrian', 'Turkish'];

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      
      // Load recipes
      const recipesResponse = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/recipes/cook/${user.id}`,
        {
          headers: {
            'Authorization': `Bearer ${(await supabase.auth.getSession()).data.session?.access_token}`,
          },
        }
      );

      if (recipesResponse.ok) {
        const recipesData = await recipesResponse.json();
        setRecipes(recipesData);
      }

      // Load orders
      const { data: { session } } = await supabase.auth.getSession();
      if (session) {
        const ordersResponse = await fetch(
          `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/orders`,
          {
            headers: {
              'Authorization': `Bearer ${session.access_token}`,
            },
          }
        );

        if (ordersResponse.ok) {
          const ordersData = await ordersResponse.json();
          setOrders(ordersData);
        }
      }
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateRecipe = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);

    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        onNavigate('auth');
        return;
      }

      const ingredients = newRecipe.ingredients
        .split('\n')
        .filter(ingredient => ingredient.trim())
        .map(ingredient => ingredient.trim());

      const response = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/recipes`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
          },
          body: JSON.stringify({
            ...newRecipe,
            ingredients
          }),
        }
      );

      if (response.ok) {
        const createdRecipe = await response.json();
        setRecipes(prev => [createdRecipe.recipe, ...prev]);
        setNewRecipe({
          title: '',
          description: '',
          price: '',
          prepTime: '',
          servings: '',
          cuisine: 'Arabic',
          ingredients: ''
        });
        setShowAddRecipe(false);
        alert('Recipe created successfully!');
      } else {
        const error = await response.json();
        alert(`Failed to create recipe: ${error.error}`);
      }
    } catch (error) {
      console.error('Recipe creation error:', error);
      alert('An error occurred. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleUpdateOrderStatus = async (orderId: string, status: string) => {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) return;

      const response = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/orders/${orderId}/status`,
        {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
          },
          body: JSON.stringify({ status }),
        }
      );

      if (response.ok) {
        setOrders(prev =>
          prev.map(order =>
            order.id === orderId ? { ...order, status } : order
          )
        );
      }
    } catch (error) {
      console.error('Failed to update order status:', error);
    }
  };

  // Calculate stats
  const totalOrders = orders.length;
  const totalSales = orders.reduce((sum, order) => sum + order.total, 0);
  const avgRating = recipes.length > 0 
    ? recipes.reduce((sum, recipe) => sum + recipe.rating, 0) / recipes.length 
    : 0;
  const pendingOrders = orders.filter(order => order.status === 'pending').length;

  if (loading) {
    return <LoadingSpinner />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-green-600 rounded-full flex items-center justify-center">
                <span className="text-white text-xl">👨‍🍳</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">Cook Dashboard</h1>
                <p className="text-sm text-green-600">Welcome, {user?.user_metadata?.name || user?.name}</p>
              </div>
            </div>
            
            <div className="flex items-center space-x-4">
              <button
                onClick={() => onNavigate('profile')}
                className="p-2 text-gray-600 hover:text-gray-900 transition-colors"
              >
                <User className="w-6 h-6" />
              </button>
              <button
                onClick={onLogout}
                className="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Orders</p>
                <p className="text-2xl font-bold text-gray-900">{totalOrders}</p>
              </div>
              <Package className="w-8 h-8 text-blue-500" />
            </div>
          </div>
          
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Sales</p>
                <p className="text-2xl font-bold text-gray-900">${totalSales.toFixed(2)}</p>
              </div>
              <DollarSign className="w-8 h-8 text-green-500" />
            </div>
          </div>
          
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Average Rating</p>
                <p className="text-2xl font-bold text-gray-900">{avgRating.toFixed(1)}</p>
              </div>
              <Star className="w-8 h-8 text-yellow-500" />
            </div>
          </div>
          
          <div className="bg-white rounded-xl p-6 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Pending Orders</p>
                <p className="text-2xl font-bold text-gray-900">{pendingOrders}</p>
              </div>
              <TrendingUp className="w-8 h-8 text-orange-500" />
            </div>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="mb-8">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8">
              {[
                { id: 'overview', name: 'Overview' },
                { id: 'recipes', name: 'My Recipes' },
                { id: 'orders', name: 'Orders' }
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                    activeTab === tab.id
                      ? 'border-green-500 text-green-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  {tab.name}
                </button>
              ))}
            </nav>
          </div>
        </div>

        {/* Tab Content */}
        {activeTab === 'overview' && (
          <div className="space-y-8">
            {/* Recent Orders */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Orders</h2>
              {orders.slice(0, 5).length > 0 ? (
                <div className="space-y-4">
                  {orders.slice(0, 5).map((order) => (
                    <div key={order.id} className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
                      <div>
                        <p className="font-medium text-gray-900">Order #{order.id.slice(0, 8)}</p>
                        <p className="text-sm text-gray-600">
                          {order.items.length} items • ${order.total.toFixed(2)}
                        </p>
                      </div>
                      <div className="text-right">
                        <span className={`inline-flex px-2 py-1 rounded-full text-xs font-medium ${
                          order.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                          order.status === 'accepted' ? 'bg-blue-100 text-blue-800' :
                          order.status === 'preparing' ? 'bg-orange-100 text-orange-800' :
                          order.status === 'delivered' ? 'bg-green-100 text-green-800' :
                          'bg-gray-100 text-gray-800'
                        }`}>
                          {order.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-gray-500 text-center py-8">No orders yet</p>
              )}
            </div>

            {/* Top Recipes */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Top Performing Recipes</h2>
              {recipes.slice(0, 3).length > 0 ? (
                <div className="space-y-4">
                  {recipes
                    .sort((a, b) => (b.totalOrders || 0) - (a.totalOrders || 0))
                    .slice(0, 3)
                    .map((recipe) => (
                      <div key={recipe.id} className="flex items-center space-x-4 p-4 border border-gray-200 rounded-lg">
                        <div className="w-16 h-16 bg-gradient-to-br from-orange-100 to-green-100 rounded-lg flex items-center justify-center">
                          <span className="text-2xl">🍽️</span>
                        </div>
                        <div className="flex-1">
                          <h3 className="font-medium text-gray-900">{recipe.title}</h3>
                          <p className="text-sm text-gray-600">{recipe.totalOrders || 0} orders • ${recipe.price}</p>
                        </div>
                        <div className="text-right">
                          <div className="flex items-center space-x-1">
                            <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                            <span className="text-sm font-medium text-gray-900">{recipe.rating?.toFixed(1) || '5.0'}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                </div>
              ) : (
                <p className="text-gray-500 text-center py-8">No recipes yet</p>
              )}
            </div>
          </div>
        )}

        {activeTab === 'recipes' && (
          <div className="space-y-6">
            {/* Add Recipe Button */}
            <div className="flex justify-between items-center">
              <h2 className="text-lg font-semibold text-gray-900">My Recipes ({recipes.length})</h2>
              <button
                onClick={() => setShowAddRecipe(!showAddRecipe)}
                className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg font-medium transition-colors flex items-center space-x-2"
              >
                <Plus className="w-4 h-4" />
                <span>Add Recipe</span>
              </button>
            </div>

            {/* Add Recipe Form */}
            {showAddRecipe && (
              <div className="bg-white rounded-xl shadow-sm p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Add New Recipe</h3>
                <form onSubmit={handleCreateRecipe} className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Recipe Title *</label>
                      <input
                        type="text"
                        required
                        value={newRecipe.title}
                        onChange={(e) => setNewRecipe({...newRecipe, title: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                        placeholder="e.g., Grilled Kebab"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Price ($) *</label>
                      <input
                        type="number"
                        required
                        min="0"
                        step="0.01"
                        value={newRecipe.price}
                        onChange={(e) => setNewRecipe({...newRecipe, price: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                        placeholder="5.00"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Description *</label>
                    <textarea
                      required
                      rows={3}
                      value={newRecipe.description}
                      onChange={(e) => setNewRecipe({...newRecipe, description: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 resize-none"
                      placeholder="Describe your delicious recipe..."
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Prep Time (minutes) *</label>
                      <input
                        type="number"
                        required
                        min="1"
                        value={newRecipe.prepTime}
                        onChange={(e) => setNewRecipe({...newRecipe, prepTime: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                        placeholder="30"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Servings *</label>
                      <input
                        type="number"
                        required
                        min="1"
                        value={newRecipe.servings}
                        onChange={(e) => setNewRecipe({...newRecipe, servings: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                        placeholder="4"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Cuisine *</label>
                      <select
                        required
                        value={newRecipe.cuisine}
                        onChange={(e) => setNewRecipe({...newRecipe, cuisine: e.target.value})}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                      >
                        {cuisineOptions.map((cuisine) => (
                          <option key={cuisine} value={cuisine}>{cuisine}</option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Ingredients (one per line)</label>
                    <textarea
                      rows={4}
                      value={newRecipe.ingredients}
                      onChange={(e) => setNewRecipe({...newRecipe, ingredients: e.target.value})}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 resize-none"
                      placeholder="Ground meat&#10;Onion&#10;Spices&#10;..."
                    />
                  </div>

                  <div className="flex space-x-4">
                    <button
                      type="submit"
                      disabled={submitting}
                      className="bg-green-500 hover:bg-green-600 disabled:bg-gray-300 text-white px-6 py-2 rounded-lg font-medium transition-colors"
                    >
                      {submitting ? 'Creating...' : 'Create Recipe'}
                    </button>
                    <button
                      type="button"
                      onClick={() => setShowAddRecipe(false)}
                      className="bg-gray-500 hover:bg-gray-600 text-white px-6 py-2 rounded-lg font-medium transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* Recipes List */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {recipes.map((recipe) => (
                <div key={recipe.id} className="bg-white rounded-xl shadow-sm overflow-hidden">
                  <div className="aspect-w-16 aspect-h-10 bg-gradient-to-br from-orange-100 to-green-100">
                    <div className="flex items-center justify-center">
                      <span className="text-4xl">🍽️</span>
                    </div>
                  </div>
                  <div className="p-4">
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-semibold text-gray-900 line-clamp-1">{recipe.title}</h3>
                      <span className="text-lg font-bold text-green-500">${recipe.price}</span>
                    </div>
                    <p className="text-sm text-gray-600 mb-3 line-clamp-2">{recipe.description}</p>
                    <div className="flex items-center justify-between text-sm text-gray-600 mb-3">
                      <div className="flex items-center space-x-1">
                        <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                        <span>{recipe.rating?.toFixed(1) || '5.0'}</span>
                      </div>
                      <span>{recipe.totalOrders || 0} orders</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        recipe.available !== false
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {recipe.available !== false ? 'Available' : 'Disabled'}
                      </span>
                      <div className="flex space-x-2">
                        <button className="p-1 text-gray-400 hover:text-gray-600">
                          <Eye className="w-4 h-4" />
                        </button>
                        <button className="p-1 text-gray-400 hover:text-gray-600">
                          <Edit className="w-4 h-4" />
                        </button>
                        <button className="p-1 text-gray-400 hover:text-gray-600">
                          {recipe.available !== false ? (
                            <ToggleRight className="w-4 h-4" />
                          ) : (
                            <ToggleLeft className="w-4 h-4" />
                          )}
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {recipes.length === 0 && (
              <div className="text-center py-12">
                <div className="text-6xl mb-4">📝</div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">No recipes yet</h3>
                <p className="text-gray-600 mb-4">Start by adding your first delicious recipe!</p>
                <button
                  onClick={() => setShowAddRecipe(true)}
                  className="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Add Your First Recipe
                </button>
              </div>
            )}
          </div>
        )}

        {activeTab === 'orders' && (
          <div className="space-y-6">
            <h2 className="text-lg font-semibold text-gray-900">Orders Management</h2>
            
            {orders.length > 0 ? (
              <div className="space-y-4">
                {orders.map((order) => (
                  <div key={order.id} className="bg-white rounded-xl shadow-sm p-6">
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h3 className="font-semibold text-gray-900">Order #{order.id.slice(0, 8)}</h3>
                        <p className="text-sm text-gray-600">
                          {new Date(order.createdAt).toLocaleDateString()} • ${order.total.toFixed(2)}
                        </p>
                      </div>
                      <span className={`inline-flex px-3 py-1 rounded-full text-sm font-medium ${
                        order.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        order.status === 'accepted' ? 'bg-blue-100 text-blue-800' :
                        order.status === 'preparing' ? 'bg-orange-100 text-orange-800' :
                        order.status === 'ready' ? 'bg-purple-100 text-purple-800' :
                        order.status === 'delivering' ? 'bg-indigo-100 text-indigo-800' :
                        order.status === 'delivered' ? 'bg-green-100 text-green-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {order.status.charAt(0).toUpperCase() + order.status.slice(1)}
                      </span>
                    </div>

                    <div className="mb-4">
                      <h4 className="font-medium text-gray-900 mb-2">Items:</h4>
                      <ul className="space-y-1">
                        {order.items.map((item: any, index: number) => (
                          <li key={index} className="text-sm text-gray-600">
                            {item.quantity}x {item.title} - ${(item.price * item.quantity).toFixed(2)}
                          </li>
                        ))}
                      </ul>
                    </div>

                    {order.deliveryAddress && (
                      <div className="mb-4">
                        <h4 className="font-medium text-gray-900 mb-1">Delivery Address:</h4>
                        <p className="text-sm text-gray-600">{order.deliveryAddress}</p>
                      </div>
                    )}

                    {order.status === 'pending' && (
                      <div className="flex space-x-3">
                        <button
                          onClick={() => handleUpdateOrderStatus(order.id, 'accepted')}
                          className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                        >
                          Accept Order
                        </button>
                        <button
                          onClick={() => handleUpdateOrderStatus(order.id, 'cancelled')}
                          className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                        >
                          Decline
                        </button>
                      </div>
                    )}

                    {order.status === 'accepted' && (
                      <button
                        onClick={() => handleUpdateOrderStatus(order.id, 'preparing')}
                        className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                      >
                        Start Preparing
                      </button>
                    )}

                    {order.status === 'preparing' && (
                      <button
                        onClick={() => handleUpdateOrderStatus(order.id, 'ready')}
                        className="bg-purple-500 hover:bg-purple-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                      >
                        Mark as Ready
                      </button>
                    )}

                    {order.status === 'ready' && (
                      <button
                        onClick={() => handleUpdateOrderStatus(order.id, 'delivering')}
                        className="bg-indigo-500 hover:bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                      >
                        Out for Delivery
                      </button>
                    )}

                    {order.status === 'delivering' && (
                      <button
                        onClick={() => handleUpdateOrderStatus(order.id, 'delivered')}
                        className="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
                      >
                        Mark as Delivered
                      </button>
                    )}
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <div className="text-6xl mb-4">📦</div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">No orders yet</h3>
                <p className="text-gray-600">Orders will appear here when customers place them.</p>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};
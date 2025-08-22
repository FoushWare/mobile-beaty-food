import React, { useState } from 'react';
import { ArrowLeft, Plus, Minus, Trash2, ShoppingBag } from 'lucide-react';
import { projectId } from '../utils/supabase/info';
import { supabase } from '../utils/supabase/client';

interface CartProps {
  user: any;
  onNavigate: (screen: string) => void;
  cart: { recipeId: string; quantity: number; recipe: any }[];
  updateCartQuantity: (recipeId: string, quantity: number) => void;
  removeFromCart: (recipeId: string) => void;
  getCartTotal: () => number;
}

export const Cart: React.FC<CartProps> = ({
  user,
  onNavigate,
  cart,
  updateCartQuantity,
  removeFromCart,
  getCartTotal
}) => {
  const [loading, setLoading] = useState(false);
  const [deliveryAddress, setDeliveryAddress] = useState(user?.address || '');

  const deliveryFee = 1;
  const subtotal = getCartTotal();
  const total = subtotal + deliveryFee;

  const handleQuantityChange = (recipeId: string, change: number) => {
    const item = cart.find(item => item.recipeId === recipeId);
    if (item) {
      const newQuantity = item.quantity + change;
      updateCartQuantity(recipeId, newQuantity);
    }
  };

  const handlePlaceOrder = async () => {
    if (cart.length === 0) return;
    
    setLoading(true);
    
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        console.error('No session found');
        onNavigate('auth');
        return;
      }

      const orderItems = cart.map(item => ({
        recipeId: item.recipeId,
        quantity: item.quantity
      }));

      const response = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/orders`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${session.access_token}`,
          },
          body: JSON.stringify({
            items: orderItems,
            deliveryAddress
          }),
        }
      );

      if (response.ok) {
        // Clear cart and navigate to order tracking
        cart.forEach(item => removeFromCart(item.recipeId));
        onNavigate('order-tracking');
      } else {
        const error = await response.json();
        console.error('Order placement failed:', error);
        alert('Failed to place order. Please try again.');
      }
    } catch (error) {
      console.error('Order placement error:', error);
      alert('An error occurred. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm sticky top-0 z-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center h-16">
            <button
              onClick={() => onNavigate('customer-home')}
              className="flex items-center text-gray-600 hover:text-gray-900 mr-4"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Back
            </button>
            <div className="flex items-center space-x-3">
              <ShoppingBag className="w-6 h-6 text-orange-500" />
              <h1 className="text-xl font-semibold text-gray-900">Shopping Cart</h1>
              <span className="bg-orange-100 text-orange-600 px-2 py-1 rounded-full text-sm">
                {cart.length} items
              </span>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {cart.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">🛒</div>
            <h2 className="text-2xl font-semibold text-gray-900 mb-2">Your cart is empty</h2>
            <p className="text-gray-600 mb-6">Discover delicious recipes and add them to your cart!</p>
            <button
              onClick={() => onNavigate('customer-home')}
              className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
            >
              Browse Recipes
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Cart Items */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-xl shadow-sm p-6">
                <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Items</h2>
                <div className="space-y-4">
                  {cart.map((item) => (
                    <div key={item.recipeId} className="flex items-center space-x-4 p-4 border border-gray-200 rounded-lg">
                      <div className="w-16 h-16 bg-gradient-to-br from-orange-100 to-green-100 rounded-lg flex items-center justify-center flex-shrink-0">
                        {item.recipe.image ? (
                          <img
                            src={item.recipe.image}
                            alt={item.recipe.title}
                            className="w-full h-full object-cover rounded-lg"
                          />
                        ) : (
                          <span className="text-2xl">🍽️</span>
                        )}
                      </div>
                      
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-gray-900 truncate">{item.recipe.title}</h3>
                        <p className="text-sm text-gray-600">by {item.recipe.cookName}</p>
                        <p className="text-lg font-bold text-orange-500">${item.recipe.price}</p>
                      </div>
                      
                      <div className="flex items-center space-x-3">
                        <div className="flex items-center space-x-2 bg-gray-100 rounded-lg p-1">
                          <button
                            onClick={() => handleQuantityChange(item.recipeId, -1)}
                            className="p-1 text-gray-600 hover:text-gray-900 transition-colors"
                            disabled={item.quantity <= 1}
                          >
                            <Minus className="w-4 h-4" />
                          </button>
                          <span className="w-8 text-center font-medium">{item.quantity}</span>
                          <button
                            onClick={() => handleQuantityChange(item.recipeId, 1)}
                            className="p-1 text-gray-600 hover:text-gray-900 transition-colors"
                          >
                            <Plus className="w-4 h-4" />
                          </button>
                        </div>
                        
                        <button
                          onClick={() => removeFromCart(item.recipeId)}
                          className="p-2 text-red-500 hover:text-red-700 transition-colors"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                      
                      <div className="text-right">
                        <p className="font-semibold text-gray-900">
                          ${(item.recipe.price * item.quantity).toFixed(2)}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Order Summary */}
            <div className="lg:col-span-1">
              <div className="bg-white rounded-xl shadow-sm p-6 sticky top-24">
                <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Summary</h2>
                
                <div className="space-y-3 mb-6">
                  <div className="flex justify-between text-gray-600">
                    <span>Subtotal</span>
                    <span>${subtotal.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between text-gray-600">
                    <span>Delivery Fee</span>
                    <span>${deliveryFee.toFixed(2)}</span>
                  </div>
                  <div className="border-t border-gray-200 pt-3">
                    <div className="flex justify-between font-semibold text-gray-900">
                      <span>Total</span>
                      <span>${total.toFixed(2)}</span>
                    </div>
                  </div>
                </div>

                <div className="mb-6">
                  <label htmlFor="delivery-address" className="block text-sm font-medium text-gray-700 mb-2">
                    Delivery Address
                  </label>
                  <textarea
                    id="delivery-address"
                    rows={3}
                    value={deliveryAddress}
                    onChange={(e) => setDeliveryAddress(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent resize-none"
                    placeholder="Enter your delivery address"
                  />
                </div>

                <button
                  onClick={handlePlaceOrder}
                  disabled={loading || !deliveryAddress.trim()}
                  className="w-full bg-orange-500 hover:bg-orange-600 disabled:bg-gray-300 disabled:cursor-not-allowed text-white py-3 px-4 rounded-lg font-medium transition-colors"
                >
                  {loading ? (
                    <div className="flex items-center justify-center">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Placing Order...
                    </div>
                  ) : (
                    `Place Order • $${total.toFixed(2)}`
                  )}
                </button>

                <div className="mt-4 text-center">
                  <button
                    onClick={() => onNavigate('customer-home')}
                    className="text-orange-600 hover:text-orange-500 text-sm font-medium"
                  >
                    Continue Shopping
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
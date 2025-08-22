import React, { useState, useEffect } from 'react';
import { ArrowLeft, Package, Clock, CheckCircle, Truck, MapPin, Phone } from 'lucide-react';
import { projectId } from '../utils/supabase/info';
import { supabase } from '../utils/supabase/client';
import LoadingSpinner from './LoadingSpinner';

interface OrderTrackingProps {
  user: any;
  onNavigate: (screen: string) => void;
}

export const OrderTracking: React.FC<OrderTrackingProps> = ({
  user,
  onNavigate
}) => {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      setLoading(true);
      setError('');
      
      const { data: { session } } = await supabase.auth.getSession();
      
      if (!session) {
        console.error('No session found');
        onNavigate('auth');
        return;
      }

      const response = await fetch(
        `https://${projectId}.supabase.co/functions/v1/make-server-d3e0b508/orders`,
        {
          headers: {
            'Authorization': `Bearer ${session.access_token}`,
          },
        }
      );

      if (response.ok) {
        const ordersData = await response.json();
        setOrders(ordersData);
        if (ordersData.length > 0 && !selectedOrder) {
          setSelectedOrder(ordersData[0]);
        }
      } else {
        const errorData = await response.json();
        setError(errorData.error || 'Failed to load orders');
      }
    } catch (error) {
      console.error('Failed to load orders:', error);
      setError('Failed to connect to server');
    } finally {
      setLoading(false);
    }
  };

  const getStatusStep = (status: string) => {
    const steps = ['pending', 'accepted', 'preparing', 'ready', 'delivering', 'delivered'];
    return steps.indexOf(status);
  };

  const getStatusIcon = (status: string, isActive: boolean, isCompleted: boolean) => {
    const iconClass = `w-6 h-6 ${
      isCompleted ? 'text-green-500' : isActive ? 'text-orange-500' : 'text-gray-300'
    }`;

    switch (status) {
      case 'pending':
        return <Clock className={iconClass} />;
      case 'accepted':
        return <CheckCircle className={iconClass} />;
      case 'preparing':
        return <Package className={iconClass} />;
      case 'ready':
        return <CheckCircle className={iconClass} />;
      case 'delivering':
        return <Truck className={iconClass} />;
      case 'delivered':
        return <CheckCircle className={iconClass} />;
      default:
        return <Clock className={iconClass} />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'accepted':
        return 'bg-blue-100 text-blue-800';
      case 'preparing':
        return 'bg-orange-100 text-orange-800';
      case 'ready':
        return 'bg-purple-100 text-purple-800';
      case 'delivering':
        return 'bg-indigo-100 text-indigo-800';
      case 'delivered':
        return 'bg-green-100 text-green-800';
      case 'cancelled':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const statusSteps = [
    { key: 'pending', label: 'Order Placed', description: 'Waiting for cook to accept' },
    { key: 'accepted', label: 'Confirmed', description: 'Cook accepted your order' },
    { key: 'preparing', label: 'Preparing', description: 'Your food is being prepared' },
    { key: 'ready', label: 'Ready', description: 'Food is ready for pickup/delivery' },
    { key: 'delivering', label: 'On the Way', description: 'Your order is being delivered' },
    { key: 'delivered', label: 'Delivered', description: 'Order has been delivered' }
  ];

  if (loading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-semibold text-gray-900 mb-2">Error Loading Orders</h2>
          <p className="text-gray-600 mb-6">{error}</p>
          <button
            onClick={loadOrders}
            className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center h-16">
            <button
              onClick={() => onNavigate(user?.user_metadata?.userType === 'cook' ? 'cook-dashboard' : 'customer-home')}
              className="flex items-center text-gray-600 hover:text-gray-900 mr-4"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Back
            </button>
            <div className="flex items-center space-x-3">
              <Package className="w-6 h-6 text-orange-500" />
              <h1 className="text-xl font-semibold text-gray-900">
                {user?.user_metadata?.userType === 'cook' ? 'Order Management' : 'My Orders'}
              </h1>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {orders.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">📦</div>
            <h2 className="text-2xl font-semibold text-gray-900 mb-2">No orders yet</h2>
            <p className="text-gray-600 mb-6">
              {user?.user_metadata?.userType === 'cook' 
                ? 'Orders from customers will appear here.'
                : 'Your orders will appear here once you place them.'
              }
            </p>
            <button
              onClick={() => onNavigate(user?.user_metadata?.userType === 'cook' ? 'cook-dashboard' : 'customer-home')}
              className="bg-orange-500 hover:bg-orange-600 text-white px-6 py-3 rounded-lg font-medium transition-colors"
            >
              {user?.user_metadata?.userType === 'cook' ? 'Go to Dashboard' : 'Start Shopping'}
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Orders List */}
            <div className="lg:col-span-1">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Orders ({orders.length})</h2>
              <div className="space-y-3">
                {orders.map((order) => (
                  <div
                    key={order.id}
                    onClick={() => setSelectedOrder(order)}
                    className={`p-4 border-2 rounded-lg cursor-pointer transition-colors ${
                      selectedOrder?.id === order.id
                        ? 'border-orange-500 bg-orange-50'
                        : 'border-gray-200 bg-white hover:border-gray-300'
                    }`}
                  >
                    <div className="flex justify-between items-start mb-2">
                      <h3 className="font-medium text-gray-900">
                        Order #{order.id.slice(0, 8)}
                      </h3>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(order.status)}`}>
                        {order.status.charAt(0).toUpperCase() + order.status.slice(1)}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600 mb-2">
                      {order.items.length} items • ${order.total.toFixed(2)}
                    </p>
                    <p className="text-xs text-gray-500">
                      {new Date(order.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* Order Details */}
            <div className="lg:col-span-2">
              {selectedOrder ? (
                <div className="space-y-6">
                  {/* Order Header */}
                  <div className="bg-white rounded-xl shadow-sm p-6">
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h2 className="text-2xl font-bold text-gray-900">
                          Order #{selectedOrder.id.slice(0, 8)}
                        </h2>
                        <p className="text-gray-600">
                          Placed on {new Date(selectedOrder.createdAt).toLocaleDateString()}
                        </p>
                      </div>
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(selectedOrder.status)}`}>
                        {selectedOrder.status.charAt(0).toUpperCase() + selectedOrder.status.slice(1)}
                      </span>
                    </div>

                    {selectedOrder.estimatedDelivery && (
                      <div className="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-4">
                        <div className="flex items-center space-x-2">
                          <Clock className="w-5 h-5 text-orange-600" />
                          <p className="text-orange-800 font-medium">
                            Estimated delivery: {new Date(selectedOrder.estimatedDelivery).toLocaleTimeString()}
                          </p>
                        </div>
                      </div>
                    )}

                    {/* Order Status Timeline */}
                    {selectedOrder.status !== 'cancelled' && (
                      <div className="mb-6">
                        <h3 className="font-medium text-gray-900 mb-4">Order Status</h3>
                        <div className="space-y-4">
                          {statusSteps.map((step, index) => {
                            const currentStep = getStatusStep(selectedOrder.status);
                            const isCompleted = index < currentStep;
                            const isActive = index === currentStep;
                            
                            return (
                              <div key={step.key} className="flex items-start space-x-3">
                                <div className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${
                                  isCompleted ? 'bg-green-100' : isActive ? 'bg-orange-100' : 'bg-gray-100'
                                }`}>
                                  {getStatusIcon(step.key, isActive, isCompleted)}
                                </div>
                                <div className="flex-1 min-w-0">
                                  <p className={`font-medium ${
                                    isCompleted ? 'text-green-700' : isActive ? 'text-orange-700' : 'text-gray-500'
                                  }`}>
                                    {step.label}
                                  </p>
                                  <p className="text-sm text-gray-600">{step.description}</p>
                                </div>
                              </div>
                            );
                          })}
                        </div>
                      </div>
                    )}
                  </div>

                  {/* Order Items */}
                  <div className="bg-white rounded-xl shadow-sm p-6">
                    <h3 className="font-medium text-gray-900 mb-4">Order Items</h3>
                    <div className="space-y-3">
                      {selectedOrder.items.map((item: any, index: number) => (
                        <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                          <div className="flex items-center space-x-3">
                            <div className="w-12 h-12 bg-gradient-to-br from-orange-100 to-green-100 rounded-lg flex items-center justify-center">
                              <span className="text-xl">🍽️</span>
                            </div>
                            <div>
                              <h4 className="font-medium text-gray-900">{item.title}</h4>
                              <p className="text-sm text-gray-600">Quantity: {item.quantity}</p>
                            </div>
                          </div>
                          <p className="font-medium text-gray-900">
                            ${(item.price * item.quantity).toFixed(2)}
                          </p>
                        </div>
                      ))}
                    </div>

                    <div className="border-t border-gray-200 mt-4 pt-4">
                      <div className="flex justify-between text-sm text-gray-600 mb-2">
                        <span>Subtotal</span>
                        <span>${(selectedOrder.total - 1).toFixed(2)}</span>
                      </div>
                      <div className="flex justify-between text-sm text-gray-600 mb-2">
                        <span>Delivery Fee</span>
                        <span>$1.00</span>
                      </div>
                      <div className="flex justify-between font-medium text-gray-900">
                        <span>Total</span>
                        <span>${selectedOrder.total.toFixed(2)}</span>
                      </div>
                    </div>
                  </div>

                  {/* Delivery Information */}
                  {selectedOrder.deliveryAddress && (
                    <div className="bg-white rounded-xl shadow-sm p-6">
                      <h3 className="font-medium text-gray-900 mb-4">Delivery Information</h3>
                      <div className="flex items-start space-x-3">
                        <MapPin className="w-5 h-5 text-gray-400 mt-1" />
                        <div>
                          <p className="font-medium text-gray-900">Delivery Address</p>
                          <p className="text-gray-600">{selectedOrder.deliveryAddress}</p>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Contact Cook (for customers) */}
                  {user?.user_metadata?.userType === 'customer' && (
                    <div className="bg-white rounded-xl shadow-sm p-6">
                      <h3 className="font-medium text-gray-900 mb-4">Need Help?</h3>
                      <div className="flex space-x-3">
                        <button className="flex items-center space-x-2 bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg font-medium transition-colors">
                          <Phone className="w-4 h-4" />
                          <span>Contact Cook</span>
                        </button>
                        <button className="flex items-center space-x-2 bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg font-medium transition-colors">
                          <span>Report Issue</span>
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <div className="bg-white rounded-xl shadow-sm p-8 text-center">
                  <Package className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-600">Select an order to view details</p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
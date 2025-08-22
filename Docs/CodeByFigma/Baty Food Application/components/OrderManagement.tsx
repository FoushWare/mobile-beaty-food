import React, { useState } from 'react';
import { ArrowLeft, Check, X, Clock, Package } from 'lucide-react';

interface Order {
  id: string;
  customerName: string;
  customerPhone: string;
  items: Array<{
    name: string;
    quantity: number;
    price: number;
  }>;
  total: number;
  address: string;
  status: 'pending' | 'accepted' | 'preparing' | 'ready' | 'delivered';
  orderTime: string;
}

interface OrderManagementProps {
  user: any;
  onBack: () => void;
}

export function OrderManagement({ user, onBack }: OrderManagementProps) {
  const [selectedTab, setSelectedTab] = useState<'all' | 'pending' | 'preparing'>('all');
  const [orders, setOrders] = useState<Order[]>([
    {
      id: '123',
      customerName: 'Ahmed Mohamed',
      customerPhone: '+20 123 456 789',
      items: [
        { name: 'Grilled Kebab', quantity: 2, price: 5 }
      ],
      total: 10,
      address: '5th District, New Cairo',
      status: 'pending',
      orderTime: '10:30 AM'
    },
    {
      id: '124',
      customerName: 'Sarah Ahmed',
      customerPhone: '+20 987 654 321',
      items: [
        { name: 'Grilled Chicken', quantity: 1, price: 6 }
      ],
      total: 6,
      address: '90th Street, New Cairo',
      status: 'pending',
      orderTime: '11:15 AM'
    },
    {
      id: '125',
      customerName: 'Omar Hassan',
      customerPhone: '+20 555 123 456',
      items: [
        { name: 'Grilled Fish', quantity: 1, price: 8 },
        { name: 'Grilled Kebab', quantity: 1, price: 5 }
      ],
      total: 13,
      address: 'Maadi, Cairo',
      status: 'preparing',
      orderTime: '9:45 AM'
    }
  ]);

  const tabs = [
    { id: 'all', label: 'All', count: orders.length },
    { id: 'pending', label: 'New', count: orders.filter(o => o.status === 'pending').length },
    { id: 'preparing', label: 'Preparing', count: orders.filter(o => o.status === 'preparing').length }
  ];

  const filteredOrders = orders.filter(order => {
    if (selectedTab === 'all') return true;
    if (selectedTab === 'pending') return order.status === 'pending';
    if (selectedTab === 'preparing') return order.status === 'preparing';
    return true;
  });

  const updateOrderStatus = (orderId: string, newStatus: Order['status']) => {
    setOrders(orders.map(order =>
      order.id === orderId ? { ...order, status: newStatus } : order
    ));
  };

  const getStatusColor = (status: Order['status']) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-700';
      case 'accepted': return 'bg-blue-100 text-blue-700';
      case 'preparing': return 'bg-orange-100 text-orange-700';
      case 'ready': return 'bg-green-100 text-green-700';
      case 'delivered': return 'bg-gray-100 text-gray-700';
      default: return 'bg-gray-100 text-gray-700';
    }
  };

  const getStatusIcon = (status: Order['status']) => {
    switch (status) {
      case 'pending': return <Clock size={16} />;
      case 'preparing': return <Package size={16} className="animate-spin" />;
      case 'ready': return <Check size={16} />;
      default: return <Clock size={16} />;
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
          <h1 className="font-semibold text-gray-800">📦 Order Management</h1>
          <div className="w-10"></div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b border-gray-200">
        <div className="flex space-x-1 p-4">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setSelectedTab(tab.id as any)}
              className={`px-4 py-2 rounded-lg transition-colors flex items-center space-x-2 ${
                selectedTab === tab.id
                  ? 'bg-orange-100 text-orange-700'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              <span>{tab.label}</span>
              {tab.count > 0 && (
                <span className={`text-xs px-2 py-1 rounded-full ${
                  selectedTab === tab.id
                    ? 'bg-orange-200'
                    : 'bg-gray-200'
                }`}>
                  {tab.count}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Orders List */}
      <div className="p-4 space-y-4">
        {filteredOrders.length === 0 ? (
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-8 text-center">
            <Package className="mx-auto mb-4 text-gray-400" size={48} />
            <h3 className="font-medium text-gray-800 mb-2">No orders found</h3>
            <p className="text-gray-600">
              {selectedTab === 'pending' ? 'No new orders at the moment.' : 'No orders in this category.'}
            </p>
          </div>
        ) : (
          filteredOrders.map(order => (
            <div key={order.id} className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
              {/* Order Header */}
              <div className="flex items-start justify-between mb-4">
                <div>
                  <div className="flex items-center space-x-3 mb-2">
                    <h3 className="font-semibold text-gray-800">Order #{order.id}</h3>
                    <span className={`px-2 py-1 rounded-full text-xs flex items-center space-x-1 ${getStatusColor(order.status)}`}>
                      {getStatusIcon(order.status)}
                      <span className="capitalize">{order.status}</span>
                    </span>
                  </div>
                  <p className="text-sm text-gray-600">Customer: {order.customerName}</p>
                  <p className="text-sm text-gray-600">Phone: {order.customerPhone}</p>
                  <p className="text-sm text-gray-600">Time: {order.orderTime}</p>
                </div>
                <div className="text-right">
                  <div className="text-xl font-bold text-green-600">${order.total}</div>
                </div>
              </div>

              {/* Order Items */}
              <div className="mb-4">
                <h4 className="font-medium text-gray-800 mb-2">Items:</h4>
                {order.items.map((item, index) => (
                  <div key={index} className="flex justify-between text-sm py-1">
                    <span>{item.name} × {item.quantity}</span>
                    <span>${item.price * item.quantity}</span>
                  </div>
                ))}
              </div>

              {/* Delivery Address */}
              <div className="mb-4 p-3 bg-gray-50 rounded-lg">
                <h4 className="font-medium text-gray-800 mb-1">Delivery Address:</h4>
                <p className="text-sm text-gray-600">📍 {order.address}</p>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-2">
                {order.status === 'pending' && (
                  <>
                    <button
                      onClick={() => updateOrderStatus(order.id, 'accepted')}
                      className="flex-1 bg-green-500 hover:bg-green-600 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center space-x-1"
                    >
                      <Check size={16} />
                      <span>Accept</span>
                    </button>
                    <button
                      onClick={() => setOrders(orders.filter(o => o.id !== order.id))}
                      className="flex-1 bg-red-500 hover:bg-red-600 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center space-x-1"
                    >
                      <X size={16} />
                      <span>Decline</span>
                    </button>
                  </>
                )}
                
                {order.status === 'accepted' && (
                  <button
                    onClick={() => updateOrderStatus(order.id, 'preparing')}
                    className="flex-1 bg-orange-500 hover:bg-orange-600 text-white py-2 px-4 rounded-lg transition-colors"
                  >
                    Start Preparing
                  </button>
                )}
                
                {order.status === 'preparing' && (
                  <button
                    onClick={() => updateOrderStatus(order.id, 'ready')}
                    className="flex-1 bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded-lg transition-colors"
                  >
                    Mark as Ready
                  </button>
                )}
                
                {order.status === 'ready' && (
                  <button
                    onClick={() => updateOrderStatus(order.id, 'delivered')}
                    className="flex-1 bg-purple-500 hover:bg-purple-600 text-white py-2 px-4 rounded-lg transition-colors"
                  >
                    Mark as Delivered
                  </button>
                )}

                <button
                  onClick={() => window.open(`tel:${order.customerPhone}`)}
                  className="bg-gray-100 hover:bg-gray-200 text-gray-700 py-2 px-4 rounded-lg transition-colors"
                >
                  📞 Call
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
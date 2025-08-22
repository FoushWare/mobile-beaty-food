import React, { useState, useEffect } from 'react';
import { User, Settings, Plus, Package, BarChart3, DollarSign, Star, Clock } from 'lucide-react';
import { CookDashboard } from './CookDashboard';
import { RecipeManagement } from './RecipeManagement';
import { OrderManagement } from './OrderManagement';

interface CookAppProps {
  user: any;
  onLogout: () => void;
  isMobile: boolean;
}

type CookView = 'dashboard' | 'recipes' | 'orders' | 'profile';

export function CookApp({ user, onLogout, isMobile }: CookAppProps) {
  const [currentView, setCurrentView] = useState<CookView>('dashboard');
  const [stats, setStats] = useState({
    newOrders: 5,
    totalSales: 25,
    rating: 4.8,
    activeRecipes: 3
  });

  const navigation = [
    { id: 'dashboard', label: 'Dashboard', icon: BarChart3 },
    { id: 'recipes', label: 'Recipes', icon: Plus },
    { id: 'orders', label: 'Orders', icon: Package },
  ];

  const renderContent = () => {
    switch (currentView) {
      case 'recipes':
        return <RecipeManagement user={user} onBack={() => setCurrentView('dashboard')} />;
      case 'orders':
        return <OrderManagement user={user} onBack={() => setCurrentView('dashboard')} />;
      default:
        return (
          <CookDashboard
            user={user}
            stats={stats}
            onNavigate={setCurrentView}
            onLogout={onLogout}
          />
        );
    }
  };

  if (!isMobile) {
    // Desktop layout with sidebar
    return (
      <div className="min-h-screen bg-gray-50 flex">
        {/* Sidebar */}
        <div className="w-64 bg-white shadow-sm border-r border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <div className="flex items-center space-x-3">
              <div className="text-2xl">👨‍🍳</div>
              <div>
                <h1 className="font-bold text-gray-800">Cook Dashboard</h1>
                <p className="text-sm text-gray-600">{user?.user_metadata?.name}</p>
              </div>
            </div>
          </div>

          <nav className="p-4">
            <ul className="space-y-2">
              {navigation.map(item => (
                <li key={item.id}>
                  <button
                    onClick={() => setCurrentView(item.id as CookView)}
                    className={`w-full flex items-center space-x-3 p-3 rounded-lg transition-colors ${
                      currentView === item.id
                        ? 'bg-orange-100 text-orange-700'
                        : 'text-gray-600 hover:bg-gray-100'
                    }`}
                  >
                    <item.icon size={20} />
                    <span>{item.label}</span>
                  </button>
                </li>
              ))}
            </ul>
          </nav>

          <div className="absolute bottom-4 left-4 right-4">
            <button
              onClick={onLogout}
              className="w-full p-3 text-red-600 hover:bg-red-50 rounded-lg transition-colors flex items-center space-x-3"
            >
              <span>Sign Out</span>
            </button>
          </div>
        </div>

        {/* Main Content */}
        <div className="flex-1">
          {renderContent()}
        </div>
      </div>
    );
  }

  // Mobile layout
  return (
    <div className="min-h-screen bg-gray-50">
      {renderContent()}
    </div>
  );
}
import React, { useState } from 'react';
import { ArrowLeft, User, Phone, MapPin, Mail, Edit2, Save, X } from 'lucide-react';

interface ProfileProps {
  user: any;
  onNavigate: (screen: string) => void;
  onLogout: () => void;
}

export const Profile: React.FC<ProfileProps> = ({
  user,
  onNavigate,
  onLogout
}) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editedProfile, setEditedProfile] = useState({
    name: user?.name || '',
    phone: user?.phone || '',
    address: user?.address || '',
  });

  const handleSaveProfile = () => {
    // Here you would typically save to backend
    console.log('Saving profile:', editedProfile);
    setIsEditing(false);
    // You could call an API to update the profile
  };

  const handleCancelEdit = () => {
    setEditedProfile({
      name: user?.name || '',
      phone: user?.phone || '',
      address: user?.address || '',
    });
    setIsEditing(false);
  };

  const menuItems = [
    { icon: User, label: 'My Orders', action: () => onNavigate('order-tracking') },
    { icon: User, label: 'Favorites', action: () => {} },
    { icon: MapPin, label: 'Saved Addresses', action: () => {} },
    { icon: Phone, label: 'Help & Support', action: () => {} },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <button
              onClick={() => onNavigate(user?.role === 'cook' ? 'cook-dashboard' : 'customer-home')}
              className="flex items-center text-gray-600 hover:text-gray-900"
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Back
            </button>
            <h1 className="text-xl font-semibold text-gray-900">Profile</h1>
            <div className="w-20"></div> {/* Spacer for centering */}
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Profile Header */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-4">
              <div className={`w-16 h-16 rounded-full flex items-center justify-center ${
                user?.role === 'cook' 
                  ? 'bg-gradient-to-br from-green-400 to-green-500' 
                  : 'bg-gradient-to-br from-orange-400 to-orange-500'
              }`}>
                <span className="text-2xl text-white">
                  {user?.role === 'cook' ? '👨‍🍳' : '🍽️'}
                </span>
              </div>
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{user?.name}</h2>
                <p className="text-gray-600">{user?.email}</p>
                <span className={`inline-flex px-2 py-1 rounded-full text-xs font-medium mt-1 ${
                  user?.role === 'cook' 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-orange-100 text-orange-800'
                }`}>
                  {user?.role === 'cook' ? 'Cook' : 'Customer'}
                </span>
              </div>
            </div>
            
            <button
              onClick={() => isEditing ? handleSaveProfile() : setIsEditing(true)}
              className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-colors ${
                isEditing 
                  ? 'bg-green-500 hover:bg-green-600 text-white'
                  : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
              }`}
            >
              {isEditing ? (
                <>
                  <Save className="w-4 h-4" />
                  <span>Save</span>
                </>
              ) : (
                <>
                  <Edit2 className="w-4 h-4" />
                  <span>Edit</span>
                </>
              )}
            </button>
          </div>

          {/* Profile Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                <User className="w-4 h-4 inline mr-2" />
                Full Name
              </label>
              {isEditing ? (
                <input
                  type="text"
                  value={editedProfile.name}
                  onChange={(e) => setEditedProfile({...editedProfile, name: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                />
              ) : (
                <p className="text-gray-900 bg-gray-50 px-3 py-2 rounded-lg">{user?.name}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                <Mail className="w-4 h-4 inline mr-2" />
                Email Address
              </label>
              <p className="text-gray-900 bg-gray-50 px-3 py-2 rounded-lg">{user?.email}</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                <Phone className="w-4 h-4 inline mr-2" />
                Phone Number
              </label>
              {isEditing ? (
                <input
                  type="tel"
                  value={editedProfile.phone}
                  onChange={(e) => setEditedProfile({...editedProfile, phone: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                  placeholder="Enter your phone number"
                />
              ) : (
                <p className="text-gray-900 bg-gray-50 px-3 py-2 rounded-lg">
                  {user?.phone || 'Not provided'}
                </p>
              )}
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                <MapPin className="w-4 h-4 inline mr-2" />
                Address
              </label>
              {isEditing ? (
                <textarea
                  rows={3}
                  value={editedProfile.address}
                  onChange={(e) => setEditedProfile({...editedProfile, address: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500 resize-none"
                  placeholder="Enter your address"
                />
              ) : (
                <p className="text-gray-900 bg-gray-50 px-3 py-2 rounded-lg">
                  {user?.address || 'Not provided'}
                </p>
              )}
            </div>
          </div>

          {isEditing && (
            <div className="flex justify-end space-x-3 mt-6 pt-6 border-t border-gray-200">
              <button
                onClick={handleCancelEdit}
                className="flex items-center space-x-2 px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
              >
                <X className="w-4 h-4" />
                <span>Cancel</span>
              </button>
              <button
                onClick={handleSaveProfile}
                className="flex items-center space-x-2 px-6 py-2 bg-green-500 hover:bg-green-600 text-white rounded-lg font-medium transition-colors"
              >
                <Save className="w-4 h-4" />
                <span>Save Changes</span>
              </button>
            </div>
          )}
        </div>

        {/* Stats (for cooks) */}
        {user?.role === 'cook' && (
          <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Your Stats</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="text-center">
                <p className="text-2xl font-bold text-green-500">{user?.rating?.toFixed(1) || '5.0'}</p>
                <p className="text-sm text-gray-600">Average Rating</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-blue-500">{user?.totalOrders || 0}</p>
                <p className="text-sm text-gray-600">Total Orders</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-purple-500">0</p>
                <p className="text-sm text-gray-600">Active Recipes</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-orange-500">0</p>
                <p className="text-sm text-gray-600">This Month</p>
              </div>
            </div>
          </div>
        )}

        {/* Menu Items */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Account</h3>
          <div className="space-y-2">
            {menuItems.map((item, index) => (
              <button
                key={index}
                onClick={item.action}
                className="w-full flex items-center space-x-3 p-3 text-left text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
              >
                <item.icon className="w-5 h-5 text-gray-400" />
                <span>{item.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Account Actions */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Account Actions</h3>
          <div className="space-y-3">
            <button className="w-full text-left p-3 text-gray-700 hover:bg-gray-50 rounded-lg transition-colors">
              Privacy Settings
            </button>
            <button className="w-full text-left p-3 text-gray-700 hover:bg-gray-50 rounded-lg transition-colors">
              Notification Preferences
            </button>
            <button className="w-full text-left p-3 text-gray-700 hover:bg-gray-50 rounded-lg transition-colors">
              Help & Support
            </button>
            <button className="w-full text-left p-3 text-gray-700 hover:bg-gray-50 rounded-lg transition-colors">
              Terms of Service
            </button>
            <button
              onClick={onLogout}
              className="w-full text-left p-3 text-red-600 hover:bg-red-50 rounded-lg transition-colors font-medium"
            >
              Sign Out
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
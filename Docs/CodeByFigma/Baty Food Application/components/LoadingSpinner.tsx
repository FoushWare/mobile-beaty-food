import React from 'react';

const LoadingSpinner: React.FC = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-green-50 flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-600 rounded-full flex items-center justify-center mx-auto mb-4 animate-pulse">
          <span className="text-white text-2xl">🍽️</span>
        </div>
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-500 mx-auto mb-4"></div>
        <p className="text-gray-600">Loading delicious recipes...</p>
      </div>
    </div>
  );
};

export default LoadingSpinner;
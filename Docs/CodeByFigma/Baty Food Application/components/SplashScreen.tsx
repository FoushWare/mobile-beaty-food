import React, { useEffect } from 'react';

export function SplashScreen() {
  // Initialize some demo data when the app loads
  useEffect(() => {
    const initializeDemoData = async () => {
      try {
        // Add a small delay to show the splash screen
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // You can add demo data initialization here if needed
        console.log('Baty Food app initializing...');
      } catch (error) {
        console.error('Demo data initialization failed:', error);
      }
    };

    initializeDemoData();
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-orange-100 flex flex-col items-center justify-center">
      <div className="text-center animate-fade-in">
        <div className="text-8xl mb-6">🍽️</div>
        <h1 className="text-4xl mb-4 text-gray-800" style={{ color: '#FF6B35' }}>
          Baty Food
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Authentic Home Food
        </p>
        <div className="w-16 h-1 bg-orange-500 mx-auto rounded-full animate-pulse"></div>
        
        <div className="mt-8 text-sm text-gray-500">
          <p>Welcome to your food delivery experience!</p>
        </div>
      </div>
    </div>
  );
}
import React from 'react';
import { Star, ChefHat } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface Cook {
  id: string;
  name: string;
  rating: number;
  avatar: string;
  specialties: string[];
}

interface CookCardProps {
  cook: Cook;
}

export function CookCard({ cook }: CookCardProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
      <div className="flex items-center space-x-4">
        <ImageWithFallback
          src={cook.avatar}
          alt={cook.name}
          className="w-16 h-16 rounded-full object-cover"
        />
        
        <div className="flex-1">
          <div className="flex items-center space-x-2 mb-1">
            <h3 className="font-semibold text-gray-800">{cook.name}</h3>
            <ChefHat size={16} className="text-orange-500" />
          </div>
          
          <div className="flex items-center space-x-1 mb-2">
            <Star className="fill-yellow-400 text-yellow-400" size={16} />
            <span className="text-sm font-medium">{cook.rating}</span>
            <span className="text-sm text-gray-500">rating</span>
          </div>
          
          <div className="flex flex-wrap gap-1">
            {cook.specialties.map((specialty, index) => (
              <span
                key={index}
                className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full"
                style={{ backgroundColor: '#2E8B57', color: 'white' }}
              >
                {specialty}
              </span>
            ))}
          </div>
        </div>
        
        <button className="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg transition-colors text-sm">
          View Profile
        </button>
      </div>
    </div>
  );
}
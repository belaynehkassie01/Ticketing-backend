// backend/src/utils/ethiopian/location.util.js
import citiesConfig from '../../config/ethiopian/cities.config.js';

export default {
  // Major Ethiopian cities with coordinates
  cities: citiesConfig.cities,
  
  // Ethiopian regions
  regions: citiesConfig.regions,
  
  // Find city by ID
  getCityById: function(id) {
    return this.cities.find(city => city.id === id);
  },
  
  // Find city by name
  getCityByName: function(name, language = 'en') {
    const field = language === 'am' ? 'nameAm' : 'name';
    return this.cities.find(city => 
      city[field]?.toLowerCase() === name.toLowerCase()
    );
  },
  
  // Get cities by region
  getCitiesByRegion: function(regionCode) {
    return this.cities.filter(city => city.region === regionCode);
  },
  
  // Get region information
  getRegion: function(regionCode) {
    return this.regions.find(region => region.code === regionCode);
  },
  
  // Calculate distance between two coordinates (in kilometers)
  calculateDistance: function(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in kilometers
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  },
  
  // Convert degrees to radians
  toRad: function(degrees) {
    return degrees * (Math.PI / 180);
  },
  
  // Find nearby cities
  findNearbyCities: function(lat, lon, radiusKm = 50) {
    return this.cities.filter(city => {
      if (!city.latitude || !city.longitude) return false;
      
      const distance = this.calculateDistance(
        lat, lon, 
        city.latitude, city.longitude
      );
      
      return distance <= radiusKm;
    }).map(city => {
      const distance = this.calculateDistance(
        lat, lon, 
        city.latitude, city.longitude
      );
      
      return {
        ...city,
        distance: Math.round(distance * 10) / 10, // Round to 1 decimal
        distanceUnit: 'km'
      };
    }).sort((a, b) => a.distance - b.distance);
  },
  
  // Validate Ethiopian coordinates
  validateCoordinates: function(lat, lon) {
    // Ethiopia bounding box
    const ethiopiaBounds = {
      minLat: 3.4,  // Southernmost point
      maxLat: 14.9, // Northernmost point
      minLon: 33.0, // Westernmost point
      maxLon: 48.0  // Easternmost point
    };
    
    const errors = [];
    
    if (lat < ethiopiaBounds.minLat || lat > ethiopiaBounds.maxLat) {
      errors.push(`Latitude must be between ${ethiopiaBounds.minLat} and ${ethiopiaBounds.maxLat}`);
    }
    
    if (lon < ethiopiaBounds.minLon || lon > ethiopiaBounds.maxLon) {
      errors.push(`Longitude must be between ${ethiopiaBounds.minLon} and ${ethiopiaBounds.maxLon}`);
    }
    
    if (isNaN(lat) || isNaN(lon)) {
      errors.push('Coordinates must be valid numbers');
    }
    
    return {
      valid: errors.length === 0,
      errors,
      withinEthiopia: errors.length === 0,
      bounds: ethiopiaBounds
    };
  },
  
  // Parse address string to components
  parseEthiopianAddress: function(address) {
    if (!address || typeof address !== 'string') {
      return { valid: false, error: 'Address is required' };
    }
    
    const addressLower = address.toLowerCase();
    
    // Common Ethiopian address patterns
    const patterns = {
      kebele: /kebele\s*(\d+)/i,
      woreda: /woreda\s*(\d+)/i,
      house: /house\s*#?\s*(\d+)/i,
      subcity: /(?:sub-?city|kifle\s*ketema)\s*(.+?)(?:\s|$)/i,
      landmark: /near\s*(.+)/i
    };
    
    const result = {
      original: address,
      components: {}
    };
    
    // Extract components
    Object.entries(patterns).forEach(([key, pattern]) => {
      const match = addressLower.match(pattern);
      if (match) {
        result.components[key] = match[1].trim();
      }
    });
    
    // Try to extract city name
    const cityMatch = this.cities.find(city => 
      addressLower.includes(city.name.toLowerCase()) ||
      (city.nameAm && addressLower.includes(city.nameAm.toLowerCase()))
    );
    
    if (cityMatch) {
      result.city = cityMatch;
      result.components.city = cityMatch.name;
    }
    
    return {
      valid: true,
      ...result,
      hasCoordinates: !!(result.city?.latitude && result.city?.longitude)
    };
  },
  
  // Format address for display
  formatAddress: function(addressComponents, language = 'en') {
    const components = addressComponents.components || addressComponents;
    
    const parts = [];
    
    if (components.house) {
      parts.push(language === 'am' ? `ቤት ${components.house}` : `House ${components.house}`);
    }
    
    if (components.kebele) {
      parts.push(language === 'am' ? `ቀበሌ ${components.kebele}` : `Kebele ${components.kebele}`);
    }
    
    if (components.woreda) {
      parts.push(language === 'am' ? `ወረዳ ${components.woreda}` : `Woreda ${components.woreda}`);
    }
    
    if (components.subcity) {
      parts.push(components.subcity);
    }
    
    if (components.landmark) {
      parts.push(language === 'am' ? `ከ${components.landmark} አጠገብ` : `Near ${components.landmark}`);
    }
    
    if (components.city) {
      parts.push(components.city);
    }
    
    return parts.join(', ');
  },
  
  // Generate Google Maps URL
  generateMapsUrl: function(lat, lon, label = '') {
    if (!lat || !lon) return null;
    
    const encodedLabel = encodeURIComponent(label);
    return `https://www.google.com/maps?q=${lat},${lon}&label=${encodedLabel}`;
  },
  
  // Generate OpenStreetMap URL
  generateOSMUrl: function(lat, lon, zoom = 15) {
    if (!lat || !lon) return null;
    
    return `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}#map=${zoom}/${lat}/${lon}`;
  },
  
  // Get timezone for coordinates in Ethiopia
  getTimezone: function(lat, lon) {
    // Ethiopia has single timezone: Africa/Addis_Ababa
    return 'Africa/Addis_Ababa';
  },
  
  // Suggest locations based on query
  suggestLocations: function(query, limit = 10) {
    if (!query || query.length < 2) {
      return [];
    }
    
    const queryLower = query.toLowerCase();
    
    const suggestions = [];
    
    // Search in city names
    this.cities.forEach(city => {
      if (city.name.toLowerCase().includes(queryLower) ||
          (city.nameAm && city.nameAm.toLowerCase().includes(queryLower))) {
        suggestions.push({
          type: 'city',
          id: city.id,
          name: city.name,
          nameAm: city.nameAm,
          region: city.region,
          coordinates: {
            lat: city.latitude,
            lon: city.longitude
          },
          score: this.calculateMatchScore(city.name, query)
        });
      }
    });
    
    // Search in region names
    this.regions.forEach(region => {
      if (region.name.toLowerCase().includes(queryLower) ||
          (region.nameAm && region.nameAm.toLowerCase().includes(queryLower))) {
        suggestions.push({
          type: 'region',
          id: region.code,
          name: region.name,
          nameAm: region.nameAm,
          score: this.calculateMatchScore(region.name, query)
        });
      }
    });
    
    // Sort by score and limit results
    return suggestions
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);
  },
  
  // Calculate match score for search
  calculateMatchScore: function(text, query) {
    const textLower = text.toLowerCase();
    const queryLower = query.toLowerCase();
    
    if (textLower === queryLower) return 100;
    if (textLower.startsWith(queryLower)) return 90;
    if (textLower.includes(queryLower)) return 80;
    
    // Partial match with word boundaries
    const words = textLower.split(/\s+/);
    const queryWords = queryLower.split(/\s+/);
    
    let score = 0;
    queryWords.forEach(qWord => {
      words.forEach(word => {
        if (word.startsWith(qWord)) score += 20;
        else if (word.includes(qWord)) score += 10;
      });
    });
    
    return Math.min(score, 70);
  },
  
  // Get city by coordinates (reverse geocoding simplified)
  getCityByCoordinates: function(lat, lon, thresholdKm = 20) {
    let closestCity = null;
    let minDistance = Infinity;
    
    this.cities.forEach(city => {
      if (!city.latitude || !city.longitude) return;
      
      const distance = this.calculateDistance(lat, lon, city.latitude, city.longitude);
      
      if (distance < minDistance) {
        minDistance = distance;
        closestCity = city;
      }
    });
    
    if (closestCity && minDistance <= thresholdKm) {
      return {
        ...closestCity,
        distance: Math.round(minDistance * 10) / 10,
        isExact: minDistance < 5 // Within 5km is considered exact
      };
    }
    
    return null;
  },
  
  // Validate Ethiopian postal code (simplified)
  validatePostalCode: function(code) {
    if (!code) return { valid: false, error: 'Postal code is required' };
    
    const codeStr = code.toString().trim();
    
    // Ethiopian postal codes are 4 digits
    if (!/^\d{4}$/.test(codeStr)) {
      return { valid: false, error: 'Postal code must be 4 digits' };
    }
    
    // First digit represents region (1-9)
    const regionDigit = parseInt(codeStr[0]);
    if (regionDigit < 1 || regionDigit > 9) {
      return { valid: false, error: 'Invalid region code in postal code' };
    }
    
    return {
      valid: true,
      code: codeStr,
      regionDigit,
      formatted: codeStr
    };
  },
  
  // Get driving distance and time (simplified estimation)
  estimateTravel: function(fromLat, fromLon, toLat, toLon) {
    const distance = this.calculateDistance(fromLat, fromLon, toLat, toLon);
    
    // Estimate travel time (average 40km/h in cities, 60km/h between cities)
    const avgSpeed = distance > 50 ? 60 : 40; // km/h
    const hours = distance / avgSpeed;
    
    const minutes = Math.round(hours * 60);
    
    return {
      distance: {
        km: Math.round(distance * 10) / 10,
        miles: Math.round(distance * 0.621371 * 10) / 10
      },
      time: {
        hours: Math.floor(hours),
        minutes: minutes % 60,
        totalMinutes: minutes,
        formatted: minutes < 60 
          ? `${minutes} minutes` 
          : `${Math.floor(hours)}h ${minutes % 60}m`
      },
      estimatedSpeed: avgSpeed
    };
  },
  
  // Generate location hash for caching
  generateLocationHash: function(lat, lon, precision = 4) {
    if (!lat || !lon) return null;
    
    // Round coordinates to specified precision
    const latRounded = Math.round(lat * Math.pow(10, precision)) / Math.pow(10, precision);
    const lonRounded = Math.round(lon * Math.pow(10, precision)) / Math.pow(10, precision);
    
    // Create hash
    return `${latRounded.toFixed(precision)},${lonRounded.toFixed(precision)}`;
  },
  
  // Parse location hash
  parseLocationHash: function(hash) {
    if (!hash || typeof hash !== 'string') return null;
    
    const parts = hash.split(',');
    if (parts.length !== 2) return null;
    
    const lat = parseFloat(parts[0]);
    const lon = parseFloat(parts[1]);
    
    if (isNaN(lat) || isNaN(lon)) return null;
    
    return { lat, lon };
  },
  
  // Get bounding box for a city
  getCityBoundingBox: function(cityId) {
    const city = this.getCityById(cityId);
    if (!city || !city.latitude || !city.longitude) return null;
    
    // Create a 10km bounding box around the city
    const radius = 0.09; // Approximately 10km in degrees
    
    return {
      minLat: city.latitude - radius,
      maxLat: city.latitude + radius,
      minLon: city.longitude - radius,
      maxLon: city.longitude + radius,
      center: {
        lat: city.latitude,
        lon: city.longitude
      },
      radiusKm: 10
    };
  },
  
  // Check if location is within venue service area
  isWithinServiceArea: function(lat, lon, venueLat, venueLon, radiusKm = 50) {
    if (!lat || !lon || !venueLat || !venueLon) return false;
    
    const distance = this.calculateDistance(lat, lon, venueLat, venueLon);
    return distance <= radiusKm;
  }
};
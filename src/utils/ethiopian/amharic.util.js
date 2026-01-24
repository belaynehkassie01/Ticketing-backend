// backend/src/utils/ethiopian/location.util.js
import citiesConfig from '../../config/ethiopian/cities.config.js';

export default {
  // Ethiopian regions with coordinates
  regions: [
    {
      id: 'AA',
      name: 'Addis Ababa',
      nameAm: 'አዲስ አበባ',
      capital: 'Addis Ababa',
      area: 527,
      population: 3500000,
      timezone: 'Africa/Addis_Ababa',
      coordinates: { lat: 9.032, lng: 38.746 },
      majorCities: ['Addis Ababa']
    },
    {
      id: 'AF',
      name: 'Afar',
      nameAm: 'አፋር',
      capital: 'Semera',
      area: 72000,
      population: 2000000,
      coordinates: { lat: 11.755, lng: 41.008 },
      majorCities: ['Semera', 'Awash', 'Logiya']
    },
    {
      id: 'AM',
      name: 'Amhara',
      nameAm: 'አማራ',
      capital: 'Bahir Dar',
      area: 154709,
      population: 22000000,
      coordinates: { lat: 11.593, lng: 37.390 },
      majorCities: ['Bahir Dar', 'Gondar', 'Dessie', 'Debre Markos']
    },
    {
      id: 'OR',
      name: 'Oromia',
      nameAm: 'ኦሮሚያ',
      capital: 'Adama',
      area: 353690,
      population: 35000000,
      coordinates: { lat: 8.541, lng: 39.269 },
      majorCities: ['Adama', 'Jimma', 'Bishoftu', 'Shashamane', 'Nekemte']
    },
    {
      id: 'TI',
      name: 'Tigray',
      nameAm: 'ትግራይ',
      capital: 'Mekelle',
      area: 53872,
      population: 7000000,
      coordinates: { lat: 13.496, lng: 39.476 },
      majorCities: ['Mekelle', 'Adigrat', 'Axum', 'Shire']
    },
    {
      id: 'SN',
      name: 'Southern Nations',
      nameAm: 'ደቡብ ብሔሮች',
      capital: 'Hawassa',
      area: 105476,
      population: 20000000,
      coordinates: { lat: 7.056, lng: 38.476 },
      majorCities: ['Hawassa', 'Arba Minch', 'Dilla', 'Sodo']
    }
  ],
  
  // Major Ethiopian cities (extended list)
  cities: [
    // Addis Ababa and surrounding
    {
      id: 1,
      name: 'Addis Ababa',
      nameAm: 'አዲስ አበባ',
      region: 'AA',
      coordinates: { lat: 9.032, lng: 38.746 },
      elevation: 2355,
      population: 3500000,
      isCapital: true,
      subCities: [
        'Arada', 'Kirkos', 'Gulele', 'Lideta', 'Bole', 'Yeka',
        'Nifas Silk-Lafto', 'Kolfe Keranio', 'Addis Ketema', 'Akaki Kaliti'
      ]
    },
    {
      id: 2,
      name: 'Bishoftu',
      nameAm: 'ቢሾፍቱ',
      region: 'OR',
      coordinates: { lat: 8.752, lng: 38.978 },
      elevation: 1920,
      population: 200000,
      distanceFromAddis: 47, // km
      notable: 'City of Lakes'
    },
    
    // Amhara Region
    {
      id: 3,
      name: 'Bahir Dar',
      nameAm: 'ባሕር ዳር',
      region: 'AM',
      coordinates: { lat: 11.593, lng: 37.390 },
      elevation: 1800,
      population: 300000,
      isRegionalCapital: true,
      notable: 'Lake Tana, Blue Nile Falls'
    },
    {
      id: 4,
      name: 'Gondar',
      nameAm: 'ጎንደር',
      region: 'AM',
      coordinates: { lat: 12.600, lng: 37.467 },
      elevation: 2133,
      population: 300000,
      notable: 'Royal Enclosure, Fasil Ghebbi'
    },
    
    // Oromia Region
    {
      id: 5,
      name: 'Adama',
      nameAm: 'አዳማ',
      region: 'OR',
      coordinates: { lat: 8.541, lng: 39.269 },
      elevation: 1712,
      population: 400000,
      isRegionalCapital: true
    },
    {
      id: 6,
      name: 'Jimma',
      nameAm: 'ጅማ',
      region: 'OR',
      coordinates: { lat: 7.673, lng: 36.834 },
      elevation: 1780,
      population: 200000,
      notable: 'Coffee growing region'
    },
    
    // Tigray Region
    {
      id: 7,
      name: 'Mekelle',
      nameAm: 'መቀሌ',
      region: 'TI',
      coordinates: { lat: 13.496, lng: 39.476 },
      elevation: 2084,
      population: 500000,
      isRegionalCapital: true
    },
    
    // Southern Nations
    {
      id: 8,
      name: 'Hawassa',
      nameAm: 'ሀዋሳ',
      region: 'SN',
      coordinates: { lat: 7.056, lng: 38.476 },
      elevation: 1708,
      population: 350000,
      isRegionalCapital: true,
      notable: 'Lake Hawassa'
    },
    
    // Other major cities
    {
      id: 9,
      name: 'Dire Dawa',
      nameAm: 'ድሬ ዳዋ',
      region: 'DD',
      coordinates: { lat: 9.600, lng: 41.850 },
      elevation: 1276,
      population: 400000
    },
    {
      id: 10,
      name: 'Harar',
      nameAm: 'ሐረር',
      region: 'HA',
      coordinates: { lat: 9.312, lng: 42.125 },
      elevation: 1885,
      population: 150000,
      notable: 'Walled city, UNESCO site'
    }
  ],
  
  // Get city by ID
  getCityById: function(id) {
    return this.cities.find(city => city.id === id);
  },
  
  // Get city by name
  getCityByName: function(name) {
    return this.cities.find(city => 
      city.name.toLowerCase() === name.toLowerCase() ||
      city.nameAm === name
    );
  },
  
  // Get cities by region
  getCitiesByRegion: function(regionId) {
    return this.cities.filter(city => city.region === regionId);
  },
  
  // Get region by ID
  getRegionById: function(regionId) {
    return this.regions.find(region => region.id === regionId);
  },
  
  // Calculate distance between two coordinates (in km)
  calculateDistance: function(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = this.deg2rad(lat2 - lat1);
    const dLon = this.deg2rad(lon2 - lon1);
    
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const distance = R * c;
    
    return distance;
  },
  
  // Convert degrees to radians
  deg2rad: function(deg) {
    return deg * (Math.PI/180);
  },
  
  // Find cities within radius
  findCitiesWithinRadius: function(lat, lng, radiusKm = 50) {
    return this.cities.filter(city => {
      const distance = this.calculateDistance(
        lat, lng, 
        city.coordinates.lat, 
        city.coordinates.lng
      );
      return distance <= radiusKm;
    }).map(city => ({
      ...city,
      distance: this.calculateDistance(lat, lng, city.coordinates.lat, city.coordinates.lng)
    })).sort((a, b) => a.distance - b.distance);
  },
  
  // Get nearest city to coordinates
  getNearestCity: function(lat, lng) {
    const citiesWithDistance = this.cities.map(city => ({
      ...city,
      distance: this.calculateDistance(lat, lng, city.coordinates.lat, city.coordinates.lng)
    }));
    
    return citiesWithDistance.sort((a, b) => a.distance - b.distance)[0];
  },
  
  // Validate Ethiopian coordinates
  validateCoordinates: function(lat, lng) {
    // Ethiopia coordinates range approximately
    const minLat = 3.0;  // Southernmost point
    const maxLat = 15.0; // Northernmost point
    const minLng = 33.0; // Westernmost point
    const maxLng = 48.0; // Easternmost point
    
    const errors = [];
    
    if (lat < minLat || lat > maxLat) {
      errors.push(`Latitude must be between ${minLat} and ${maxLat}`);
    }
    
    if (lng < minLng || lng > maxLng) {
      errors.push(`Longitude must be between ${minLng} and ${maxLng}`);
    }
    
    return {
      valid: errors.length === 0,
      errors,
      isInEthiopia: errors.length === 0,
      approximateRegion: this.getApproximateRegion(lat, lng)
    };
  },
  
  // Get approximate region based on coordinates
  getApproximateRegion: function(lat, lng) {
    // Simplified region approximation
    if (lat > 14) return 'TI'; // Tigray
    if (lat > 12 && lng > 39) return 'AF'; // Afar
    if (lat > 10 && lat < 12 && lng > 37 && lng < 39) return 'AM'; // Amhara
    if (lat > 8 && lat < 10 && lng > 38 && lng < 40) return 'OR'; // Oromia (Addis area)
    if (lat > 6 && lat < 8) return 'SN'; // Southern Nations
    if (lat < 6) return 'SO'; // Somali
    
    return 'Unknown';
  },
  
  // Format address in Ethiopian style
  formatEthiopianAddress: function(addressParts) {
    const {
      subCity = '',
      woreda = '',
      kebele = '',
      houseNumber = '',
      landmark = '',
      additionalInfo = ''
    } = addressParts;
    
    let address = '';
    
    if (houseNumber) address += `House No. ${houseNumber}, `;
    if (kebele) address += `Kebele ${kebele}, `;
    if (woreda) address += `Woreda ${woreda}, `;
    if (subCity) address += `${subCity} Sub-city, `;
    
    address = address.replace(/,\s*$/, ''); // Remove trailing comma
    
    if (landmark) {
      address += ` (Near ${landmark})`;
    }
    
    if (additionalInfo) {
      address += ` - ${additionalInfo}`;
    }
    
    return address.trim();
  },
  
  // Parse Ethiopian address string
  parseEthiopianAddress: function(addressString) {
    const patterns = [
      // Pattern: House No. X, Kebele Y, Woreda Z, Sub-city
      /House No\.?\s*(\d+[A-Z]?),\s*Kebele\s*(\d+),\s*Woreda\s*(\d+),\s*(.+?)\s*Sub-city/i,
      // Pattern: Kebele X, Woreda Y, Sub-city Z
      /Kebele\s*(\d+),\s*Woreda\s*(\d+),\s*(.+?)\s*Sub-city/i,
      // Pattern: Woreda X, Sub-city Y
      /Woreda\s*(\d+),\s*(.+?)\s*Sub-city/i
    ];
    
    for (const pattern of patterns) {
      const match = addressString.match(pattern);
      if (match) {
        return {
          houseNumber: match[1] || null,
          kebele: match[2] || null,
          woreda: match[3] || match[1] || null,
          subCity: match[4] || match[2] || match[1] || null
        };
      }
    }
    
    // Check for landmark pattern
    const landmarkMatch = addressString.match(/Near\s+(.+)/i);
    if (landmarkMatch) {
      return { landmark: landmarkMatch[1] };
    }
    
    return { raw: addressString };
  },
  
  // Get city options for dropdown (with regions)
  getCityOptions: function(includeRegions = true) {
    return this.cities.map(city => {
      const region = this.getRegionById(city.region);
      
      return {
        value: city.id,
        label: city.name,
        labelAm: city.nameAm,
        region: city.region,
        regionName: region ? region.name : 'Unknown',
        coordinates: city.coordinates,
        isCapital: city.isCapital || false
      };
    }).sort((a, b) => {
      // Sort by region, then by city name
      if (a.region !== b.region) {
        return a.region.localeCompare(b.region);
      }
      return a.label.localeCompare(b.label);
    });
  },
  
  // Get region options for dropdown
  getRegionOptions: function() {
    return this.regions.map(region => ({
      value: region.id,
      label: region.name,
      labelAm: region.nameAm,
      capital: region.capital,
      area: region.area,
      population: region.population
    })).sort((a, b) => a.label.localeCompare(b.label));
  },
  
  // Calculate travel time between cities (approximate)
  calculateTravelTime: function(fromCityId, toCityId, mode = 'car') {
    const fromCity = this.getCityById(fromCityId);
    const toCity = this.getCityById(toCityId);
    
    if (!fromCity || !toCity) {
      return null;
    }
    
    const distance = this.calculateDistance(
      fromCity.coordinates.lat, fromCity.coordinates.lng,
      toCity.coordinates.lat, toCity.coordinates.lng
    );
    
    let speed;
    switch (mode) {
      case 'car':
        speed = 60; // km/h average
        break;
      case 'bus':
        speed = 50; // km/h average
        break;
      case 'walk':
        speed = 5; // km/h average
        break;
      default:
        speed = 50;
    }
    
    const hours = distance / speed;
    const hoursInt = Math.floor(hours);
    const minutes = Math.round((hours - hoursInt) * 60);
    
    return {
      from: fromCity.name,
      to: toCity.name,
      distance: Math.round(distance),
      mode,
      estimatedTime: {
        hours: hoursInt,
        minutes: minutes,
        totalMinutes: Math.round(hours * 60),
        formatted: hoursInt > 0 
          ? `${hoursInt} hr ${minutes} min`
          : `${minutes} min`
      },
      note: 'Estimated time may vary based on road conditions'
    };
  },
  
  // Get popular venues in a city (would come from database in production)
  getPopularVenues: function(cityId) {
    const city = this.getCityById(cityId);
    if (!city) return [];
    
    // Mock data - in production, query venues table
    const venuesByCity = {
      1: [ // Addis Ababa
        { name: 'Millennium Hall', capacity: 5000, type: 'convention' },
        { name: 'Ghion Hotel', capacity: 2000, type: 'hotel' },
        { name: 'Sheraton Addis', capacity: 1500, type: 'hotel' },
        { name: 'Arada Cultural Center', capacity: 800, type: 'cultural' }
      ],
      3: [ // Bahir Dar
        { name: 'Kuriftu Resort', capacity: 1000, type: 'resort' },
        { name: 'Papyrus Hotel', capacity: 500, type: 'hotel' }
      ],
      7: [ // Mekelle
        { name: 'Mekelle University Auditorium', capacity: 2000, type: 'educational' },
        { name: 'Axum Hotel', capacity: 800, type: 'hotel' }
      ]
    };
    
    return venuesByCity[cityId] || [];
  },
  
  // Get event hotspots (cities with most events)
  getEventHotspots: function() {
    // In production, this would query events table
    // Mock data for now
    return [
      { cityId: 1, cityName: 'Addis Ababa', eventCount: 245, trend: 'up' },
      { cityId: 3, cityName: 'Bahir Dar', eventCount: 89, trend: 'stable' },
      { cityId: 5, cityName: 'Adama', eventCount: 67, trend: 'up' },
      { cityId: 8, cityName: 'Hawassa', eventCount: 54, trend: 'up' },
      { cityId: 6, cityName: 'Jimma', eventCount: 42, trend: 'stable' }
    ];
  },
  
  // Generate Google Maps URL
  generateGoogleMapsUrl: function(lat, lng, label = '') {
    const baseUrl = 'https://www.google.com/maps/search/?api=1';
    const query = label 
      ? `&query=${encodeURIComponent(label)}`
      : `&query=${lat},${lng}`;
    
    return `${baseUrl}${query}`;
  },
  
  // Generate directions URL
  generateDirectionsUrl: function(fromLat, fromLng, toLat, toLng, mode = 'driving') {
    const baseUrl = 'https://www.google.com/maps/dir/?api=1';
    const origin = `&origin=${fromLat},${fromLng}`;
    const destination = `&destination=${toLat},${toLng}`;
    const travelMode = `&travelmode=${mode}`;
    
    return `${baseUrl}${origin}${destination}${travelMode}`;
  },
  
  // Get weather information for city (placeholder for API integration)
  getWeatherInfo: async function(cityId) {
    const city = this.getCityById(cityId);
    if (!city) return null;
    
    // In production, integrate with weather API
    // This is mock data
    return {
      city: city.name,
      temperature: 22, // Celsius
      condition: 'Sunny',
      humidity: 45,
      windSpeed: 12, // km/h
      forecast: 'Partly cloudy',
      lastUpdated: new Date().toISOString()
    };
  },
  
  // Validate if event date conflicts with Ethiopian holidays in that city
  validateEventDate: function(cityId, eventDate) {
    const city = this.getCityById(cityId);
    if (!city) return { valid: false, error: 'Invalid city' };
    
    const date = new Date(eventDate);
    const day = date.getDate();
    const month = date.getMonth() + 1;
    
    // Ethiopian holidays that affect events
    const majorHolidays = [
      { month: 1, day: 7, name: 'Christmas', nameAm: 'ገና' },
      { month: 1, day: 19, name: 'Epiphany', nameAm: 'ጥምቀት' },
      { month: 4, day: 27, name: 'Easter', nameAm: 'ፋሲካ' },
      { month: 9, day: 11, name: 'New Year', nameAm: 'እንቁጣጣሽ' },
      { month: 9, day: 27, name: 'Meskel', nameAm: 'መስቀል' }
    ];
    
    const conflictingHoliday = majorHolidays.find(h => 
      h.month === month && h.day === day
    );
    
    if (conflictingHoliday) {
      return {
        valid: false,
        error: `Event conflicts with ${conflictingHoliday.name}`,
        errorAm: `ዝግጅቱ ከ${conflictingHoliday.nameAm} ጋር ይጋጫል`,
        holiday: conflictingHoliday,
        suggestion: 'Consider scheduling on a different date'
      };
    }
    
    return {
      valid: true,
      city: city.name,
      date: date.toISOString(),
      dayOfWeek: date.getDay(),
      note: 'No major holiday conflicts detected'
    };
  }
};
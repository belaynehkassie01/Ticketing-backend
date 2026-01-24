// backend/src/config/ethiopian/cities.config.js
export default {
  // Ethiopian regions/states
  regions: [
    { code: 'AA', name: 'Addis Ababa', nameAm: 'አዲስ አበባ' },
    { code: 'AF', name: 'Afar', nameAm: 'አፋር' },
    { code: 'AM', name: 'Amhara', nameAm: 'አማራ' },
    { code: 'BG', name: 'Benishangul-Gumuz', nameAm: 'ቤኒሻንጉል-ጉሙዝ' },
    { code: 'DD', name: 'Dire Dawa', nameAm: 'ድሬ ዳዋ' },
    { code: 'GA', name: 'Gambela', nameAm: 'ጋምቤላ' },
    { code: 'HA', name: 'Harari', nameAm: 'ሀረሪ' },
    { code: 'OR', name: 'Oromia', nameAm: 'ኦሮሚያ' },
    { code: 'SI', name: 'Sidama', nameAm: 'ሲዳማ' },
    { code: 'SO', name: 'Somali', nameAm: 'ሶማሌ' },
    { code: 'SW', name: 'South West Ethiopia', nameAm: 'ደቡብ ምዕራብ ኢትዮጵያ' },
    { code: 'SN', name: 'Southern Nations', nameAm: 'ደቡብ ብሔሮች' },
    { code: 'TI', name: 'Tigray', nameAm: 'ትግራይ' },
  ],
  
  // Major cities with coordinates
  cities: [
    {
      id: 1,
      name: 'Addis Ababa',
      nameAm: 'አዲስ አበባ',
      region: 'AA',
      latitude: 9.032,
      longitude: 38.746,
      isCapital: true,
      population: 3500000,
      timezone: 'Africa/Addis_Ababa',
    },
    {
      id: 2,
      name: 'Bahir Dar',
      nameAm: 'ባሕር ዳር',
      region: 'AM',
      latitude: 11.593,
      longitude: 37.390,
      isCapital: false,
      population: 300000,
    },
    {
      id: 3,
      name: 'Mekelle',
      nameAm: 'መቀሌ',
      region: 'TI',
      latitude: 13.496,
      longitude: 39.476,
      isCapital: false,
      population: 500000,
    },
    {
      id: 4,
      name: 'Adama',
      nameAm: 'አዳማ',
      region: 'OR',
      latitude: 8.541,
      longitude: 39.269,
      isCapital: false,
      population: 400000,
    },
    {
      id: 5,
      name: 'Hawassa',
      nameAm: 'ሀዋሳ',
      region: 'SN',
      latitude: 7.056,
      longitude: 38.476,
      isCapital: false,
      population: 350000,
    },
    {
      id: 6,
      name: 'Jimma',
      nameAm: 'ጅማ',
      region: 'OR',
      latitude: 7.673,
      longitude: 36.834,
      isCapital: false,
      population: 200000,
    },
    {
      id: 7,
      name: 'Gondar',
      nameAm: 'ጎንደር',
      region: 'AM',
      latitude: 12.600,
      longitude: 37.467,
      isCapital: false,
      population: 300000,
    },
    {
      id: 8,
      name: 'Dessie',
      nameAm: 'ደሴ',
      region: 'AM',
      latitude: 11.133,
      longitude: 39.633,
      isCapital: false,
      population: 250000,
    },
    {
      id: 9,
      name: 'Dire Dawa',
      nameAm: 'ድሬ ዳዋ',
      region: 'DD',
      latitude: 9.600,
      longitude: 41.850,
      isCapital: false,
      population: 400000,
    },
    {
      id: 10,
      name: 'Jijiga',
      nameAm: 'ጅጅጋ',
      region: 'SO',
      latitude: 9.350,
      longitude: 42.800,
      isCapital: false,
      population: 150000,
    },
  ],
  
  // Sub-cities for Addis Ababa
  addisSubCities: [
    'Arada',
    'Kirkos',
    'Gulele',
    'Lideta',
    'Bole',
    'Yeka',
    'Nifas Silk-Lafto',
    'Kolfe Keranio',
    'Addis Ketema',
    'Akaki Kaliti',
  ].map((name, index) => ({
    id: 100 + index,
    name,
    nameAm: name, // Add Amharic names as needed
    parentCityId: 1,
    isSubCity: true,
  })),
  
  // Utility functions
  getCityById: function(id) {
    return this.cities.find(city => city.id === id);
  },
  
  getCitiesByRegion: function(regionCode) {
    return this.cities.filter(city => city.region === regionCode);
  },
  
  getRegionByCode: function(regionCode) {
    return this.regions.find(region => region.code === regionCode);
  },
  
  // For dropdown/select options
  getCityOptions: function() {
    return this.cities.map(city => ({
      value: city.id,
      label: city.name,
      labelAm: city.nameAm,
      region: city.region,
    }));
  },
  
  getRegionOptions: function() {
    return this.regions.map(region => ({
      value: region.code,
      label: region.name,
      labelAm: region.nameAm,
    }));
  },
};
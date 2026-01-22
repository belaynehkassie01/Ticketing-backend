// File: backend/src/utils/ethiopian/calendar.util.js
// Ethiopian Calendar Conversion Functions

export function convertToEthiopianDate(gregorianDate) {
  // Ethiopian calendar starts 7-8 years behind Gregorian
  // This is a simplified version - use proper library for production
  const date = new Date(gregorianDate);
  const ethiopianYear = date.getFullYear() - 8;
  const ethiopianMonth = date.getMonth() + 1; // 1-12
  const ethiopianDay = date.getDate();
  
  return `${ethiopianYear}-${String(ethiopianMonth).padStart(2, '0')}-${String(ethiopianDay).padStart(2, '0')}`;
}

export function convertToGregorianDate(ethiopianDate) {
  // ethiopianDate format: "2016-07-08"
  const [year, month, day] = ethiopianDate.split('-').map(Number);
  const gregorianYear = year + 8;
  
  return new Date(gregorianYear, month - 1, day);
}

export function getEthiopianHolidays(year) {
  // Ethiopian public holidays
  const holidays = [
    { date: `${year}-01-07`, name: 'ገና (Christmas)', name_en: 'Christmas' },
    { date: `${year}-01-19`, name: 'ጥምቀት (Epiphany)', name_en: 'Epiphany' },
    { date: `${year}-03-02`, name: 'አድዋ (Adwa Victory)', name_en: 'Adwa Victory Day' },
    { date: `${year}-04-06`, name: 'የኢትዮጵያ ድል ቀን', name_en: 'Ethiopian Patriots Victory Day' },
    { date: `${year}-05-01`, name: 'የሰራተኞች ቀን', name_en: 'International Workers Day' },
    { date: `${year}-05-05`, name: 'የአርበኞች ቀን', name_en: 'Ethiopian Patriots Day' },
    { date: `${year}-05-28`, name: 'ደርግ የወደቀበት ቀን', name_en: 'Downfall of Derg' },
    { date: `${year}-09-11`, name: 'አዲስ አመት (New Year)', name_en: 'Ethiopian New Year' },
    { date: `${year}-09-27`, name: 'መስቀል (Finding of True Cross)', name_en: 'Meskel' },
  ];
  
  return holidays;
}

export function isEthiopianHoliday(date) {
  const ethiopianDate = convertToEthiopianDate(date);
  const [year] = ethiopianDate.split('-');
  const holidays = getEthiopianHolidays(year);
  
  return holidays.some(holiday => holiday.date === ethiopianDate);
}
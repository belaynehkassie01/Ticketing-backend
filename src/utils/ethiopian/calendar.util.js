// backend/src/utils/ethiopian/calendar.util.js
export default {
  // Ethiopian months with Amharic names
  months: [
    { number: 1, en: 'Meskerem', am: 'መስከረም', days: 30 },
    { number: 2, en: 'Tikimt', am: 'ጥቅምት', days: 30 },
    { number: 3, en: 'Hidar', am: 'ኅዳር', days: 30 },
    { number: 4, en: 'Tahsas', am: 'ታህሳስ', days: 30 },
    { number: 5, en: 'Tir', am: 'ጥር', days: 30 },
    { number: 6, en: 'Yekatit', am: 'የካቲት', days: 30 },
    { number: 7, en: 'Megabit', am: 'መጋቢት', days: 30 },
    { number: 8, en: 'Miyazya', am: 'ሚያዝያ', days: 30 },
    { number: 9, en: 'Ginbot', am: 'ግንቦት', days: 30 },
    { number: 10, en: 'Sene', am: 'ሰኔ', days: 30 },
    { number: 11, en: 'Hamle', am: 'ሐምሌ', days: 30 },
    { number: 12, en: 'Nehase', am: 'ነሐሴ', days: 30 },
    { number: 13, en: 'Pagume', am: 'ጳጉሜ', days: 5 } // 6 in leap year
  ],
  
  // Ethiopian weekdays
  weekdays: [
    { number: 1, en: 'Monday', am: 'ሰኞ', amShort: 'ሰ' },
    { number: 2, en: 'Tuesday', am: 'ማክሰኞ', amShort: 'ማ' },
    { number: 3, en: 'Wednesday', am: 'ረቡዕ', amShort: 'ረ' },
    { number: 4, en: 'Thursday', am: 'ሐሙስ', amShort: 'ሐ' },
    { number: 5, en: 'Friday', am: 'አርብ', amShort: 'አ' },
    { number: 6, en: 'Saturday', am: 'ቅዳሜ', amShort: 'ቅ' },
    { number: 7, en: 'Sunday', am: 'እሑድ', amShort: 'እ' }
  ],
  
  // Major Ethiopian holidays
  holidays: {
    // Fixed dates (month/day)
    '09-11': { en: 'Ethiopian New Year', am: 'እንቁጣጣሽ' },
    '09-17': { en: 'Finding of True Cross', am: 'መስቀል' },
    '09-27': { en: 'Meskel', am: 'መስቀል' },
    '03-23': { en: 'Victory of Adwa', am: 'የአድዋ ድል' },
    '05-05': { en: 'Ethiopian Patriots Victory Day', am: 'የአርበኞች ቀን' },
    '05-28': { en: 'Downfall of Derg', am: 'ደርግ የወደቀበት ቀን' },
    
    // Movable holidays (calculated)
    'easter': { en: 'Easter', am: 'ፋሲካ' },
    'christmas': { en: 'Christmas', am: 'ገና' },
    'eid_al_fitr': { en: 'Eid al-Fitr', am: 'ኢድ አልፈጥር' },
    'eid_al_adha': { en: 'Eid al-Adha', am: 'ኢድ አልአድሃ' }
  },
  
  // Convert Gregorian to Ethiopian date
  gregorianToEthiopian: function(gregorianDate) {
    const date = new Date(gregorianDate);
    const gregorianYear = date.getFullYear();
    const gregorianMonth = date.getMonth() + 1;
    const gregorianDay = date.getDate();
    
    // Ethiopian calendar starts 7-8 years behind Gregorian
    const ethiopianYear = gregorianYear - 8;
    
    // Calculate if it's September or later (Ethiopian New Year is Sept 11/12)
    let ethiopianMonth, ethiopianDay;
    
    if (gregorianMonth >= 9) {
      // After Ethiopian New Year
      ethiopianMonth = gregorianMonth - 8;
      ethiopianDay = gregorianDay - 10;
      
      // Adjust for New Year
      if (gregorianMonth === 9 && gregorianDay <= 11) {
        ethiopianYear = gregorianYear - 9;
        ethiopianMonth = 13;
        ethiopianDay = gregorianDay + 20;
      }
    } else {
      // Before Ethiopian New Year
      ethiopianMonth = gregorianMonth + 4;
      ethiopianDay = gregorianDay + 20;
      
      // Adjust for Pagume (13th month)
      if (ethiopianMonth > 13) {
        ethiopianMonth = 1;
        ethiopianDay = gregorianDay - 10;
      }
    }
    
    // Handle day overflow
    const monthInfo = this.months.find(m => m.number === ethiopianMonth);
    if (ethiopianDay > monthInfo.days) {
      ethiopianDay -= monthInfo.days;
      ethiopianMonth++;
      
      if (ethiopianMonth > 13) {
        ethiopianMonth = 1;
        ethiopianYear++;
      }
    }
    
    // Handle day underflow
    if (ethiopianDay < 1) {
      ethiopianMonth--;
      if (ethiopianMonth < 1) {
        ethiopianMonth = 13;
        ethiopianYear--;
      }
      const prevMonth = this.months.find(m => m.number === ethiopianMonth);
      ethiopianDay += prevMonth.days;
    }
    
    // Get weekday
    const weekday = date.getDay(); // 0 = Sunday, 6 = Saturday
    const ethiopianWeekday = weekday === 0 ? 7 : weekday; // Ethiopian: 1 = Monday, 7 = Sunday
    
    return {
      year: ethiopianYear,
      month: ethiopianMonth,
      day: ethiopianDay,
      weekday: ethiopianWeekday,
      monthEn: this.months.find(m => m.number === ethiopianMonth).en,
      monthAm: this.months.find(m => m.number === ethiopianMonth).am,
      weekdayEn: this.weekdays.find(w => w.number === ethiopianWeekday).en,
      weekdayAm: this.weekdays.find(w => w.number === ethiopianWeekday).am,
      isHoliday: this.isHoliday(ethiopianMonth, ethiopianDay, ethiopianYear),
      formatted: {
        en: `${this.months.find(m => m.number === ethiopianMonth).en} ${ethiopianDay}, ${ethiopianYear}`,
        am: `${ethiopianDay} ${this.months.find(m => m.number === ethiopianMonth).am} ${ethiopianYear}`,
        short: `${ethiopianDay}/${ethiopianMonth}/${ethiopianYear}`,
        iso: `${ethiopianYear}-${ethiopianMonth.toString().padStart(2, '0')}-${ethiopianDay.toString().padStart(2, '0')}`
      }
    };
  },
  
  // Convert Ethiopian to Gregorian date
  ethiopianToGregorian: function(ethiopianYear, ethiopianMonth, ethiopianDay) {
    // Simplified conversion (for accurate conversion, use a library)
    let gregorianYear = ethiopianYear + 8;
    let gregorianMonth, gregorianDay;
    
    if (ethiopianMonth <= 4) {
      gregorianMonth = ethiopianMonth + 8;
      gregorianDay = ethiopianDay + 10;
    } else {
      gregorianMonth = ethiopianMonth - 4;
      gregorianDay = ethiopianDay - 20;
      
      if (gregorianMonth < 1) {
        gregorianMonth += 12;
        gregorianYear--;
      }
    }
    
    // Adjust for month boundaries
    const daysInMonth = new Date(gregorianYear, gregorianMonth, 0).getDate();
    if (gregorianDay > daysInMonth) {
      gregorianDay -= daysInMonth;
      gregorianMonth++;
      
      if (gregorianMonth > 12) {
        gregorianMonth = 1;
        gregorianYear++;
      }
    }
    
    const date = new Date(gregorianYear, gregorianMonth - 1, gregorianDay);
    
    return {
      date,
      year: gregorianYear,
      month: gregorianMonth,
      day: gregorianDay,
      iso: date.toISOString(),
      formatted: date.toLocaleDateString('en-ET', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        timeZone: 'Africa/Addis_Ababa'
      })
    };
  },
  
  // Check if date is an Ethiopian holiday
  isHoliday: function(month, day, year = null) {
    const dateKey = `${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
    const fixedHoliday = this.holidays[dateKey];
    
    if (fixedHoliday) {
      return {
        isHoliday: true,
        name: fixedHoliday,
        type: 'fixed'
      };
    }
    
    // Check movable holidays if year is provided
    if (year) {
      // This would calculate Easter, Eid, etc. based on year
      // Simplified placeholder
      if (month === 4 && day >= 15 && day <= 22) {
        return {
          isHoliday: true,
          name: { en: 'Easter', am: 'ፋሲካ' },
          type: 'movable'
        };
      }
    }
    
    return { isHoliday: false };
  },
  
  // Get current Ethiopian date
  getCurrentEthiopianDate: function() {
    return this.gregorianToEthiopian(new Date());
  },
  
  // Format Ethiopian date
  formatEthiopianDate: function(ethiopianDate, format = 'medium', language = 'en') {
    const { year, month, day, weekday } = ethiopianDate;
    const monthInfo = this.months.find(m => m.number === month);
    const weekdayInfo = this.weekdays.find(w => w.number === weekday);
    
    const formats = {
      short: {
        en: `${day}/${month}/${year}`,
        am: `${day}/${month}/${year}`
      },
      medium: {
        en: `${monthInfo.en} ${day}, ${year}`,
        am: `${day} ${monthInfo.am} ${year}`
      },
      long: {
        en: `${weekdayInfo.en}, ${monthInfo.en} ${day}, ${year}`,
        am: `${weekdayInfo.am}, ${day} ${monthInfo.am} ${year}`
      },
      full: {
        en: `${weekdayInfo.en}, ${monthInfo.en} ${day}, ${year} E.C.`,
        am: `${weekdayInfo.am}, ${day} ${monthInfo.am} ${year} ዓ.ም.`
      }
    };
    
    return formats[format]?.[language] || formats.medium[language];
  },
  
  // Calculate Ethiopian date difference
  differenceInDays: function(startEthDate, endEthDate) {
    // Convert to Gregorian first for accurate calculation
    const startGreg = this.ethiopianToGregorian(startEthDate.year, startEthDate.month, startEthDate.day);
    const endGreg = this.ethiopianToGregorian(endEthDate.year, endEthDate.month, endEthDate.day);
    
    const diffTime = endGreg.date - startGreg.date;
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  },
  
  // Add days to Ethiopian date
  addDays: function(ethiopianDate, days) {
    const gregorian = this.ethiopianToGregorian(ethiopianDate.year, ethiopianDate.month, ethiopianDate.day);
    const newGregorian = new Date(gregorian.date);
    newGregorian.setDate(newGregorian.getDate() + days);
    
    return this.gregorianToEthiopian(newGregorian);
  },
  
  // Validate Ethiopian date
  validateEthiopianDate: function(year, month, day) {
    if (year < 1900 || year > 2100) {
      return { valid: false, error: 'Year must be between 1900 and 2100' };
    }
    
    if (month < 1 || month > 13) {
      return { valid: false, error: 'Month must be between 1 and 13' };
    }
    
    const monthInfo = this.months.find(m => m.number === month);
    if (!monthInfo) {
      return { valid: false, error: 'Invalid month' };
    }
    
    // Check for leap year in Pagume
    const isLeapYear = this.isLeapYear(year);
    const maxDays = month === 13 ? (isLeapYear ? 6 : 5) : monthInfo.days;
    
    if (day < 1 || day > maxDays) {
      return { valid: false, error: `Day must be between 1 and ${maxDays} for month ${month}` };
    }
    
    return {
      valid: true,
      date: { year, month, day },
      monthInfo,
      isLeapYear,
      formatted: this.formatEthiopianDate({ year, month, day }, 'medium', 'en')
    };
  },
  
  // Check if Ethiopian year is leap year
  isLeapYear: function(year) {
    // Ethiopian leap year occurs every 4 years
    return year % 4 === 3;
  },
  
  // Get Ethiopian months in a year
  getMonthsInYear: function(year) {
    const isLeapYear = this.isLeapYear(year);
    
    return this.months.map(month => ({
      ...month,
      days: month.number === 13 ? (isLeapYear ? 6 : 5) : month.days,
      year,
      isCurrent: false // Would compare with current date
    }));
  },
  
  // Generate Ethiopian date range for event scheduling
  generateDateRange: function(startDate, endDate, includeWeekends = true, excludeHolidays = false) {
    const dates = [];
    let current = startDate;
    
    while (this.differenceInDays(current, endDate) >= 0) {
      const dateInfo = {
        ...current,
        isWeekend: current.weekday >= 6, // Saturday (6) and Sunday (7) are weekend
        holiday: this.isHoliday(current.month, current.day, current.year)
      };
      
      let shouldInclude = true;
      
      if (!includeWeekends && dateInfo.isWeekend) {
        shouldInclude = false;
      }
      
      if (excludeHolidays && dateInfo.holiday.isHoliday) {
        shouldInclude = false;
      }
      
      if (shouldInclude) {
        dates.push(dateInfo);
      }
      
      current = this.addDays(current, 1);
    }
    
    return dates;
  },
  
  // Get Ethiopian season for a date
  getSeason: function(month) {
    if (month >= 1 && month <= 3) {
      return { en: 'Autumn', am: 'ከልብ ወቅት' };
    } else if (month >= 4 && month <= 6) {
      return { en: 'Winter', am: 'በጋ ወቅት' };
    } else if (month >= 7 && month <= 9) {
      return { en: 'Spring', am: 'ክረምት ወቅት' };
    } else {
      return { en: 'Summer', am: 'ጸደይ ወቅት' };
    }
  },
  
  // Calculate age in Ethiopian years
  calculateEthiopianAge: function(birthDate, currentDate = this.getCurrentEthiopianDate()) {
    let age = currentDate.year - birthDate.year;
    
    if (currentDate.month < birthDate.month || 
        (currentDate.month === birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    
    return {
      years: age,
      months: currentDate.month - birthDate.month + (currentDate.day < birthDate.day ? -1 : 0),
      days: Math.abs(currentDate.day - birthDate.day),
      full: `${age} ${age === 1 ? 'year' : 'years'}`
    };
  }
};
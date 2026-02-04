-- ============================================
-- SEEDER: 006_ethiopian_holidays.sql
-- Purpose: Seed Ethiopian holidays for event planning
-- Dependencies: ethiopian_holidays table must exist
-- Sources: Ethiopian Calendar, Religious observances
-- Period: 2024-2026 Ethiopian Calendar Years
-- ============================================

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Clear existing holidays (idempotent)
DELETE FROM `ethiopian_holidays`;

-- ============================================
-- ETHIOPIAN NATIONAL HOLIDAYS (2024-2026)
-- Based on Ethiopian Calendar (GC = Gregorian)
-- ============================================

INSERT INTO `ethiopian_holidays` (
  `name`,
  `name_amharic`,
  `description`,
  `start_date`,
  `end_date`,
  `holiday_type`,
  `is_active`,
  `year`,
  `recurring`,
  `created_at`,
  `updated_at`
) VALUES 
-- ============================================
-- 2024 ETHIOPIAN HOLIDAYS (2016 Ethiopian Year)
-- ============================================

-- Ethiopian New Year (Enkutatash)
(
  'Ethiopian New Year',
  'እንቁጣጣሽ',
  'First day of the Ethiopian New Year (Meskerem 1)',
  '2024-09-11',  -- GC: September 11
  '2024-09-11',
  'national',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Finding of the True Cross (Meskel)
(
  'Finding of the True Cross',
  'መስቀል',
  'Orthodox Christian holiday celebrating the discovery of the True Cross',
  '2024-09-27',  -- GC: September 27
  '2024-09-27',
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Christmas (Genna)
(
  'Ethiopian Christmas',
  'ገና',
  'Christmas Day in the Ethiopian Orthodox Church',
  '2025-01-07',  -- GC: January 7, 2025 (Ethiopian Christmas 2017)
  '2025-01-07',
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Epiphany (Timket)
(
  'Ethiopian Epiphany',
  'ጥምቀት',
  'Celebration of the baptism of Jesus in the Jordan River',
  '2025-01-19',  -- GC: January 19, 2025
  '2025-01-20',  -- Two-day celebration
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Victory of Adwa
(
  'Victory of Adwa',
  'የአድዋ ድል',
  'Commemoration of Ethiopian victory at the Battle of Adwa',
  '2024-03-02',  -- GC: March 2
  '2024-03-02',
  'national',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- International Women''s Day
(
  'International Women''s Day',
  'ዓለም አቀፍ የሴቶች ቀን',
  'International celebration of women''s achievements',
  '2024-03-08',  -- GC: March 8
  '2024-03-08',
  'international',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Good Friday
(
  'Ethiopian Good Friday',
  'ስቅለት',
  'Commemoration of the crucifixion of Jesus',
  '2024-05-03',  -- GC: May 3 (varies yearly)
  '2024-05-03',
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Easter (Fasika)
(
  'Ethiopian Easter',
  'ፋሲካ',
  'Resurrection of Jesus in Ethiopian Orthodox Church',
  '2024-05-05',  -- GC: May 5 (varies yearly)
  '2024-05-05',
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Labour Day
(
  'Labour Day',
  'የሠራተኞች ቀን',
  'International Workers'' Day',
  '2024-05-01',  -- GC: May 1
  '2024-05-01',
  'international',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Patriots'' Victory Day
(
  'Patriots'' Victory Day',
  'የአርበኞች ድል ቀን',
  'Celebration of Ethiopian resistance fighters',
  '2024-05-05',  -- GC: May 5
  '2024-05-05',
  'national',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Downfall of Derg
(
  'Downfall of Derg',
  'ደርግ የወደቀበት ቀን',
  'Overthrow of the Derg communist regime',
  '2024-05-28',  -- GC: May 28
  '2024-05-28',
  'national',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Eid al-Fitr (Estimated)
(
  'Eid al-Fitr',
  'ኢድ አል ፊጥር',
  'Muslim holiday marking the end of Ramadan',
  '2024-04-10',  -- GC: April 10 (estimated, based on moon sighting)
  '2024-04-10',
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Eid al-Adha (Estimated)
(
  'Eid al-Adha',
  'ኢድ አል አድሐ',
  'Muslim Festival of Sacrifice',
  '2024-06-17',  -- GC: June 17 (estimated)
  '2024-06-17',
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- ============================================
-- 2025 ETHIOPIAN HOLIDAYS (2017 Ethiopian Year)
-- ============================================

-- Ethiopian New Year 2025
(
  'Ethiopian New Year',
  'እንቁጣጣሽ',
  'First day of the Ethiopian New Year',
  '2025-09-11',
  '2025-09-11',
  'national',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- Meskel 2025
(
  'Finding of the True Cross',
  'መስቀል',
  'Meskel celebration',
  '2025-09-27',
  '2025-09-27',
  'religious',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Christmas 2025 (actually Jan 2026 GC)
(
  'Ethiopian Christmas',
  'ገና',
  'Christmas Day',
  '2026-01-07',  -- GC: January 7, 2026
  '2026-01-07',
  'religious',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- Timket 2025
(
  'Ethiopian Epiphany',
  'ጥምቀት',
  'Epiphany celebration',
  '2026-01-19',
  '2026-01-20',
  'religious',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- Adwa Victory 2025
(
  'Victory of Adwa',
  'የአድዋ ድል',
  'Battle of Adwa commemoration',
  '2025-03-02',
  '2025-03-02',
  'national',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- Good Friday 2025 (estimated)
(
  'Ethiopian Good Friday',
  'ስቅለት',
  'Good Friday',
  '2025-04-18',  -- GC: April 18 (estimated)
  '2025-04-18',
  'religious',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- Easter 2025 (estimated)
(
  'Ethiopian Easter',
  'ፋሲካ',
  'Easter celebration',
  '2025-04-20',  -- GC: April 20 (estimated)
  '2025-04-20',
  'religious',
  TRUE,
  2025,
  TRUE,
  NOW(),
  NOW()
),

-- ============================================
-- 2026 ETHIOPIAN HOLIDAYS (2018 Ethiopian Year)
-- ============================================

-- Ethiopian New Year 2026
(
  'Ethiopian New Year',
  'እንቁጣጣሽ',
  'First day of the Ethiopian New Year',
  '2026-09-11',
  '2026-09-11',
  'national',
  TRUE,
  2026,
  TRUE,
  NOW(),
  NOW()
),

-- Meskel 2026
(
  'Finding of the True Cross',
  'መስቀል',
  'Meskel celebration',
  '2026-09-27',
  '2026-09-27',
  'religious',
  TRUE,
  2026,
  TRUE,
  NOW(),
  NOW()
),

-- Adwa Victory 2026
(
  'Victory of Adwa',
  'የአድዋ ድል',
  'Battle of Adwa commemoration',
  '2026-03-02',
  '2026-03-02',
  'national',
  TRUE,
  2026,
  TRUE,
  NOW(),
  NOW()
),

-- ============================================
-- REGIONAL HOLIDAYS (Major regions)
-- ============================================

-- Oromia Region - Irreecha Festival (Thanksgiving)
(
  'Irreecha Festival',
  'ኢሬቻ',
  'Oromo thanksgiving festival celebrated at end of rainy season',
  '2024-10-01',  -- GC: Early October (varies)
  '2024-10-02',
  'regional',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Tigray Region - Ashenda Festival
(
  'Ashenda Festival',
  'አሸንዳ',
  'Tigrayan festival celebrating womanhood and virginity',
  '2024-08-21',  -- GC: August 21 (after Ethiopian Easter)
  '2024-08-23',
  'regional',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Gurage Region - Fichee-Chambalaalla
(
  'Fichee-Chambalaalla',
  'ፊቼ-ቻምባላላ',
  'Gurage New Year celebration',
  '2024-08-01',  -- GC: August (varies)
  '2024-08-03',
  'regional',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Sidama Region - Fichee Celebrations
(
  'Sidama New Year',
  'ፊቼ (ሲዳማ)',
  'Sidama people New Year celebration',
  '2024-10-01',  -- GC: October (varies)
  '2024-10-03',
  'regional',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- ============================================
-- MAJOR EVENT PERIODS (Not holidays but important for event planning)
-- ============================================

-- Ethiopian Lent (Fast of Hudade/Abiy Tsom)
(
  'Ethiopian Lent',
  'አቢይ ጾም',
  '55-day fasting period before Ethiopian Easter',
  '2024-03-11',  -- GC: March 11 (varies)
  '2024-05-04',  -- Ends day before Easter
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ramadan (Muslim fasting month)
(
  'Ramadan',
  'ረመዳን',
  'Islamic holy month of fasting',
  '2024-03-10',  -- GC: March 10 (estimated)
  '2024-04-09',  -- 30 days
  'religious',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Month of Mourning (Miazia)
(
  'Month of Mourning',
  'የማይአዝያ ወር',
  'Traditional mourning period in Ethiopian calendar',
  '2024-04-09',  -- GC: April 9 (Miazia 1)
  '2024-05-08',  -- GC: May 8 (Miazia 30)
  'cultural',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
),

-- Ethiopian Tourism Month (Hamle)
(
  'Tourism Season',
  'የቱሪዝም ወቅት',
  'Peak tourism season in Ethiopia',
  '2024-07-08',  -- GC: July 8 (Hamle 1)
  '2024-08-06',  -- GC: August 6 (Hamle 30)
  'cultural',
  TRUE,
  2024,
  TRUE,
  NOW(),
  NOW()
);

COMMIT;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- SEEDER VERIFICATION & SUMMARY
-- ============================================

SELECT 
  '✅ 006_ethiopian_holidays.sql - SEEDING COMPLETE' as message,
  'Ethiopian holidays seeded successfully' as details,
  NOW() as seeded_at
UNION ALL
SELECT 
  '📅 HOLIDAYS SUMMARY' as message,
  CONCAT(
    'Total Holidays: ', COUNT(*),
    ' | National: ', SUM(CASE WHEN holiday_type = 'national' THEN 1 ELSE 0 END),
    ' | Religious: ', SUM(CASE WHEN holiday_type = 'religious' THEN 1 ELSE 0 END),
    ' | Regional: ', SUM(CASE WHEN holiday_type = 'regional' THEN 1 ELSE 0 END),
    ' | International: ', SUM(CASE WHEN holiday_type = 'international' THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `ethiopian_holidays`
UNION ALL
SELECT 
  '📆 YEARS COVERED' as message,
  CONCAT(
    'Years: ', 
    GROUP_CONCAT(DISTINCT year ORDER BY year SEPARATOR ', '),
    ' | Recurring Holidays: ',
    SUM(CASE WHEN recurring = TRUE THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `ethiopian_holidays`
UNION ALL
SELECT 
  '🇪🇹 MAJOR ETHIOPIAN HOLIDAYS' as message,
  CONCAT(
    GROUP_CONCAT(
      DISTINCT name 
      WHERE holiday_type IN ('national', 'religious') 
      AND year = 2024 
      ORDER BY start_date
      SEPARATOR ' → '
    )
  ) as details,
  NULL as seeded_at
FROM `ethiopian_holidays`
UNION ALL
SELECT 
  '🏛️ REGIONAL FESTIVALS' as message,
  CONCAT(
    GROUP_CONCAT(
      DISTINCT name 
      WHERE holiday_type = 'regional'
      SEPARATOR ', '
    )
  ) as details,
  NULL as seeded_at
FROM `ethiopian_holidays`
UNION ALL
SELECT 
  '⛪ RELIGIOUS BREAKDOWN' as message,
  CONCAT(
    'Christian: ', 
    SUM(CASE WHEN name LIKE '%Christmas%' OR name LIKE '%Easter%' OR name LIKE '%Meskel%' OR name LIKE '%Timket%' THEN 1 ELSE 0 END),
    ' | Muslim: ',
    SUM(CASE WHEN name LIKE '%Eid%' OR name LIKE '%Ramadan%' THEN 1 ELSE 0 END),
    ' | Cultural: ',
    SUM(CASE WHEN holiday_type = 'cultural' THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `ethiopian_holidays`
UNION ALL
SELECT 
  '📝 EVENT PLANNING NOTES' as message,
  '1. Avoid scheduling events on major holidays\n2. Consider regional festivals for local marketing\n3. Note fasting periods for food events\n4. Tourism season is ideal for large events' as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
UNION ALL
SELECT 
  '⚠️ IMPORTANT NOTES' as message,
  '1. Muslim holidays based on moon sighting (estimated dates)\n2. Easter dates vary yearly\n3. Update dates annually for accuracy\n4. Regional holidays may have local variations' as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
ORDER BY 
  CASE 
    WHEN message LIKE '✅%' THEN 1
    WHEN message LIKE '📅%' THEN 2
    WHEN message LIKE '📆%' THEN 3
    WHEN message LIKE '🇪🇹%' THEN 4
    WHEN message LIKE '🏛️%' THEN 5
    WHEN message LIKE '⛪%' THEN 6
    WHEN message LIKE '📝%' THEN 7
    WHEN message LIKE '⚠️%' THEN 8
    ELSE 9
  END;
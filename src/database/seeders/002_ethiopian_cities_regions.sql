-- ============================================
-- SEEDER: 002_ethiopian_cities_regions.sql
-- Purpose: Seed Ethiopian cities and regions with Amharic names
-- Dependencies: cities table must exist (from migration 002)
-- Sources: Ethiopian CSA (2019), GeoNames, Local knowledge
-- Notes: 
--   1. Population data based on 2019 CSA projections
--   2. Coordinates from GeoNames (WGS84)
--   3. JSON fields require MySQL 5.7+
-- ============================================

-- Temporarily disable foreign key checks for safe truncation
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Clear ALL existing city data (truncate is faster than delete)
-- Note: This assumes no foreign key constraints yet
TRUNCATE TABLE `cities`;

-- ============================================
-- ETHIOPIAN REGIONAL CAPITALS (is_major_city = TRUE)
-- Sorted by population/importance
-- ============================================

INSERT INTO `cities` (
  `name`,
  `name_amharic`,
  `region`,
  `latitude`,
  `longitude`,
  `elevation`,
  `population`,
  `area_sq_km`,
  `phone_area_code`,
  `postal_code_prefix`,
  `popular_event_types`,
  `major_venues`,
  `is_major_city`,
  `is_active`,
  `sort_order`,
  `description`,
  `keywords`
) VALUES 
-- 1. Addis Ababa (Capital, Special Zone)
(
  'Addis Ababa',
  'አዲስ አበባ',
  'Addis Ababa',
  9.0300,
  38.7400,
  2355,
  5200000,
  527,
  '011',
  '1000',
  JSON_ARRAY('concert', 'conference', 'exhibition', 'sports', 'festival', 'workshop', 'business', 'cultural'),
  JSON_ARRAY('Millennium Hall', 'Addis Ababa Exhibition Center', 'Ghion Hotel', 'Ethio-China Friendship Square', 'Sheger Park'),
  TRUE,
  TRUE,
  1,
  'Capital city and political/economic hub of Ethiopia. Hosts major international conferences and events.',
  'capital, conference, business, international'
),
-- 2. Dire Dawa (City Administration)
(
  'Dire Dawa',
  'ድሬ ዳዋ',
  'Dire Dawa',
  9.6000,
  41.8667,
  1276,
  440000,
  1213,
  '025',
  '3000',
  JSON_ARRAY('cultural', 'music', 'trade_fair', 'sports'),
  JSON_ARRAY('Dire Dawa Stadium', 'Kefira Market Square'),
  TRUE,
  TRUE,
  2,
  'Important commercial and industrial city, major railway hub.',
  'commercial, railway, industrial'
),
-- 3. Mekelle (Tigray Capital)
(
  'Mekelle',
  'መቀሌ',
  'Tigray',
  13.4969,
  39.4769,
  2084,
  520000,
  180,
  '034',
  '2310',
  JSON_ARRAY('academic', 'cultural', 'music', 'conference', 'university'),
  JSON_ARRAY('Mekelle University Stadium', 'Alula Hall'),
  TRUE,
  TRUE,
  3,
  'Capital of Tigray Region, major educational and cultural center.',
  'university, education, cultural'
),
-- 4. Gondar (Amhara - Historical)
(
  'Gondar',
  'ጎንደር',
  'Amhara',
  12.6000,
  37.4667,
  2133,
  424000,
  192,
  '058',
  '3100',
  JSON_ARRAY('historical', 'cultural', 'festival', 'religious', 'music'),
  JSON_ARRAY('Fasil Ghebbi', 'Gondar University Auditorium'),
  TRUE,
  TRUE,
  4,
  'Historical city known as the "Camelot of Africa", UNESCO World Heritage site.',
  'historical, unesco, castle, festival'
),
-- 5. Bahir Dar (Amhara Capital)
(
  'Bahir Dar',
  'ባሕር ዳር',
  'Amhara',
  11.6000,
  37.3833,
  1800,
  348000,
  213,
  '058',
  '6000',
  JSON_ARRAY('cultural', 'festival', 'music', 'boating', 'conference'),
  JSON_ARRAY('Papyrus Hotel Convention Center', 'Kuriftu Resort', 'Tana Hotel'),
  TRUE,
  TRUE,
  5,
  'Capital of Amhara Region on Lake Tana shore. Known for Blue Nile Falls.',
  'lake tana, blue nile, conference, resort'
),
-- 6. Hawassa (SNNPR Capital)
(
  'Hawassa',
  'ሀዋሳ',
  'SNNPR',
  7.0500,
  38.4667,
  1708,
  398000,
  157,
  '046',
  '1400',
  JSON_ARRAY('music', 'sports', 'academic', 'lake_festival', 'youth'),
  JSON_ARRAY('Hawassa University', 'Lake Hawassa Resort', 'Haile Resort'),
  TRUE,
  TRUE,
  6,
  'Capital of SNNPR Region on Lake Hawassa. Popular weekend destination.',
  'lake, resort, university, weekend'
),
-- 7. Adama (Oromia Capital)
(
  'Adama',
  'አዳማ',
  'Oromia',
  8.5400,
  39.2700,
  1712,
  480000,
  200,
  '022',
  '1880',
  JSON_ARRAY('sports', 'conference', 'music', 'exhibition'),
  JSON_ARRAY('Adama Stadium', 'Adama Science and Technology University'),
  TRUE,
  TRUE,
  7,
  'Capital of Oromia Region. Major transportation and industrial hub.',
  'transportation, industrial, sports, university'
),
-- 8. Jijiga (Somali Capital)
(
  'Jijiga',
  'ጅጅጋ',
  'Somali',
  9.3500,
  42.8000,
  1609,
  225000,
  50,
  '025',
  '1800',
  JSON_ARRAY('cultural', 'traditional', 'trade_fair', 'religious'),
  JSON_ARRAY('Jijiga Stadium', 'Somali Region Cultural Center'),
  TRUE,
  TRUE,
  8,
  'Capital of Somali Region. Important trade center near Somalia border.',
  'trade, cultural, border, somali'
),
-- 9. Semera (Afar Capital)
(
  'Semera',
  'ሰመራ',
  'Afar',
  11.7914,
  41.0056,
  419,
  50000,
  15,
  '033',
  '2410',
  JSON_ARRAY('cultural', 'development', 'government'),
  JSON_ARRAY('Afar Region Administration Hall'),
  TRUE,
  TRUE,
  9,
  'Capital of Afar Region. Strategic location for industrial development.',
  'industrial, strategic, government'
),
-- 10. Assosa (Benishangul-Gumuz Capital)
(
  'Assosa',
  'አሶሳ',
  'Benishangul-Gumuz',
  10.0667,
  34.5333,
  1570,
  40000,
  12,
  '057',
  '0800',
  JSON_ARRAY('cultural', 'mining_expo', 'agricultural'),
  JSON_ARRAY('Assosa University', 'Benishangul Cultural Center'),
  TRUE,
  TRUE,
  10,
  'Capital of Benishangul-Gumuz Region. Known for gold mining.',
  'mining, gold, cultural, border'
),
-- 11. Gambela (Gambela Capital)
(
  'Gambela',
  'ጋምቤላ',
  'Gambela',
  8.2500,
  34.5833,
  526,
  50000,
  10,
  '047',
  '1900',
  JSON_ARRAY('cultural', 'wildlife', 'river_festival'),
  JSON_ARRAY('Gambela Stadium', 'Baro River Cultural Center'),
  TRUE,
  TRUE,
  11,
  'Capital of Gambela Region on Baro River. Rich cultural diversity.',
  'river, cultural, wildlife, diverse'
),
-- 12. Harar (Harari Capital)
(
  'Harar',
  'ሐረር',
  'Harari',
  9.3167,
  42.1167,
  1885,
  151000,
  19,
  '025',
  '2500',
  JSON_ARRAY('historical', 'cultural', 'religious', 'unesco', 'coffee'),
  JSON_ARRAY('Harar Jugol Wall', 'Rimbaud House', 'Harar Cultural Museum'),
  TRUE,
  TRUE,
  12,
  'Capital of Harari Region. UNESCO World Heritage city, known for hyenas.',
  'unesco, historical, hyena, cultural'
),
-- 13. Wolaita Sodo (Sidama Important)
(
  'Wolaita Sodo',
  'ወላይታ ሶዶ',
  'Sidama',
  6.8600,
  37.7600,
  2100,
  110000,
  25,
  '046',
  '3100',
  JSON_ARRAY('agricultural', 'cultural', 'music', 'youth'),
  JSON_ARRAY('Wolaita Sodo University', 'Sodo Stadium'),
  TRUE,
  TRUE,
  13,
  'Major city in Sidama Region. Agricultural and educational center.',
  'agricultural, university, sidama, youth'
);

-- ============================================
-- OTHER IMPORTANT CITIES (is_major_city = FALSE)
-- ============================================

INSERT INTO `cities` (
  `name`,
  `name_amharic`,
  `region`,
  `latitude`,
  `longitude`,
  `elevation`,
  `population`,
  `is_major_city`,
  `is_active`,
  `sort_order`
) VALUES 
-- Oromia Region
('Shashamane', 'ሻሸመኔ', 'Oromia', 7.2000, 38.6000, 1923, 208000, FALSE, TRUE, 14),
('Bishoftu', 'ቢሾፍቱ', 'Oromia', 8.7500, 38.9833, 1920, 204000, FALSE, TRUE, 15),
('Ambo', 'አምቦ', 'Oromia', 8.9833, 37.8500, 2101, 100000, FALSE, TRUE, 16),
('Nekemte', 'ነቀምተ', 'Oromia', 9.0833, 36.5500, 2088, 148000, FALSE, TRUE, 17),

-- Amhara Region
('Dessie', 'ደሴ', 'Amhara', 11.1333, 39.6333, 2470, 193000, FALSE, TRUE, 18),
('Debre Birhan', 'ደብረ ብርሃን', 'Amhara', 9.6833, 39.5333, 2840, 114000, FALSE, TRUE, 19),
('Debre Markos', 'ደብረ ማርቆስ', 'Amhara', 10.3333, 37.7333, 2446, 104000, FALSE, TRUE, 20),
('Kombolcha', 'ኮምቦልቻ', 'Amhara', 11.0833, 39.7333, 1842, 110000, FALSE, TRUE, 21),

-- Tigray Region
('Axum', 'አክሱም', 'Tigray', 14.1211, 38.7233, 2131, 80000, FALSE, TRUE, 22),
('Adigrat', 'አዲግራት', 'Tigray', 14.2775, 39.4622, 2457, 120000, FALSE, TRUE, 23),
('Shire', 'ሸረ', 'Tigray', 14.1061, 38.2844, 1953, 90000, FALSE, TRUE, 24),

-- SNNPR Region
('Arba Minch', 'አርባ ምንጭ', 'SNNPR', 6.0333, 37.5500, 1285, 151000, FALSE, TRUE, 25),
('Dilla', 'ዲላ', 'SNNPR', 6.4167, 38.3167, 1570, 119000, FALSE, TRUE, 26),
('Hosaena', 'ሆሳዕና', 'SNNPR', 7.5500, 37.8500, 2177, 133000, FALSE, TRUE, 27),

-- Somali Region
('Gode', 'ጎዴ', 'Somali', 5.9500, 43.4500, 320, 150000, FALSE, TRUE, 28),
('Kebri Dehar', 'ከብሪ ዳሃር', 'Somali', 6.7333, 44.2667, 550, 100000, FALSE, TRUE, 29),

-- Afar Region
('Awash', 'አዋሽ', 'Afar', 8.9833, 40.1667, 960, 30000, FALSE, TRUE, 30),
('Logiya', 'ሎጊያ', 'Afar', 11.9667, 41.1000, 450, 25000, FALSE, TRUE, 31),

-- Sidama Region
('Yirgalem', 'ይርጋለም', 'Sidama', 6.7500, 38.4167, 1775, 85000, FALSE, TRUE, 32);

COMMIT;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- BATCH UPDATE: Add popular_event_types for all cities
-- Using CASE expression for performance
-- ============================================

UPDATE `cities` 
SET `popular_event_types` = CASE
  WHEN `name` = 'Addis Ababa' THEN JSON_ARRAY('concert', 'conference', 'exhibition', 'sports', 'festival', 'workshop', 'business', 'cultural')
  WHEN `name` = 'Dire Dawa' THEN JSON_ARRAY('cultural', 'music', 'trade_fair', 'sports')
  WHEN `name` = 'Mekelle' THEN JSON_ARRAY('academic', 'cultural', 'music', 'conference', 'university')
  WHEN `name` = 'Gondar' THEN JSON_ARRAY('historical', 'cultural', 'festival', 'religious', 'music')
  WHEN `name` = 'Bahir Dar' THEN JSON_ARRAY('cultural', 'festival', 'music', 'boating', 'conference')
  WHEN `name` = 'Hawassa' THEN JSON_ARRAY('music', 'sports', 'academic', 'lake_festival', 'youth')
  WHEN `name` = 'Adama' THEN JSON_ARRAY('sports', 'conference', 'music', 'exhibition')
  WHEN `name` = 'Jijiga' THEN JSON_ARRAY('cultural', 'traditional', 'trade_fair', 'religious')
  WHEN `name` = 'Semera' THEN JSON_ARRAY('cultural', 'development', 'government')
  WHEN `name` = 'Assosa' THEN JSON_ARRAY('cultural', 'mining_expo', 'agricultural')
  WHEN `name` = 'Gambela' THEN JSON_ARRAY('cultural', 'wildlife', 'river_festival')
  WHEN `name` = 'Harar' THEN JSON_ARRAY('historical', 'cultural', 'religious', 'unesco', 'coffee')
  WHEN `name` = 'Wolaita Sodo' THEN JSON_ARRAY('agricultural', 'cultural', 'music', 'youth')
  WHEN `region` = 'Oromia' THEN JSON_ARRAY('cultural', 'music', 'agricultural', 'sports')
  WHEN `region` = 'Amhara' THEN JSON_ARRAY('religious', 'cultural', 'historical', 'music')
  WHEN `region` = 'Tigray' THEN JSON_ARRAY('academic', 'cultural', 'religious')
  WHEN `region` = 'SNNPR' THEN JSON_ARRAY('cultural', 'music', 'agricultural')
  WHEN `region` = 'Somali' THEN JSON_ARRAY('cultural', 'traditional', 'trade')
  WHEN `region` = 'Afar' THEN JSON_ARRAY('cultural', 'development')
  WHEN `region` = 'Benishangul-Gumuz' THEN JSON_ARRAY('cultural', 'mining', 'agricultural')
  WHEN `region` = 'Gambela' THEN JSON_ARRAY('cultural', 'wildlife', 'river')
  WHEN `region` = 'Harari' THEN JSON_ARRAY('historical', 'cultural', 'coffee')
  WHEN `region` = 'Sidama' THEN JSON_ARRAY('agricultural', 'cultural', 'coffee')
  ELSE JSON_ARRAY('cultural', 'community', 'local')
END;

-- ============================================
-- SEEDER VERIFICATION & DETAILED SUMMARY
-- ============================================

SELECT 
  '✅ 002_ethiopian_cities_regions.sql - SEEDING COMPLETE' as message,
  'Ethiopian cities and regions seeded successfully' as details,
  NOW() as seeded_at
UNION ALL
SELECT 
  '📊 SUMMARY STATISTICS' as message,
  CONCAT(
    'Total Cities: ', COUNT(*),
    ' | Major Cities: ', SUM(CASE WHEN `is_major_city` = TRUE THEN 1 ELSE 0 END),
    ' | Other Cities: ', SUM(CASE WHEN `is_major_city` = FALSE THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `cities`
UNION ALL
SELECT 
  '📍 REGIONS COVERED' as message,
  GROUP_CONCAT(DISTINCT `region` ORDER BY 
    CASE `region`
      WHEN 'Addis Ababa' THEN 1
      WHEN 'Dire Dawa' THEN 2
      WHEN 'Oromia' THEN 3
      WHEN 'Amhara' THEN 4
      WHEN 'Tigray' THEN 5
      WHEN 'SNNPR' THEN 6
      WHEN 'Somali' THEN 7
      WHEN 'Sidama' THEN 8
      WHEN 'Afar' THEN 9
      WHEN 'Benishangul-Gumuz' THEN 10
      WHEN 'Gambela' THEN 11
      WHEN 'Harari' THEN 12
      ELSE 13
    END
  ) as details,
  NULL as seeded_at
FROM `cities`
UNION ALL
SELECT 
  '🏙️ TOP 5 CITIES BY POPULATION' as message,
  CONCAT(
    GROUP_CONCAT(`name` ORDER BY `population` DESC LIMIT 5 SEPARATOR ', ')
  ) as details,
  NULL as seeded_at
FROM `cities`
ORDER BY 
  CASE 
    WHEN message LIKE '✅%' THEN 1
    WHEN message LIKE '📊%' THEN 2
    WHEN message LIKE '📍%' THEN 3
    WHEN message LIKE '🏙️%' THEN 4
    ELSE 5
  END;
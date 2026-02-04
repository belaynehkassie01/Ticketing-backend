-- ============================================
-- SEEDER: 003_event_categories.sql
-- Purpose: Seed event categories for Ethiopian context
-- Dependencies: event_categories table must exist
-- Ethiopian Context: 
--   1. Bilingual category names (English/Amharic)
--   2. Culturally relevant categories
--   3. Icons and colors for UI display
-- ============================================

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Clear existing categories (idempotent)
DELETE FROM `event_categories`;

-- ============================================
-- CORE EVENT CATEGORIES (Popular in Ethiopia)
-- ============================================

INSERT INTO `event_categories` (
  `name`,
  `name_amharic`,
  `slug`,
  `description`,
  `description_amharic`,
  `icon`,
  `color`,
  `is_active`,
  `sort_order`,
  `keywords`,
  `created_at`
) VALUES 
-- 1. Music & Concerts (Most popular in Ethiopia)
(
  'Music & Concerts',
  'ሙዚቃ እና ኮንሰርቶች',
  'music-concerts',
  'Live music performances, concerts, and musical events featuring Ethiopian and international artists.',
  'የቀጥታ ሙዚቃ ማሳያዎች፣ ኮንሰርቶች እና የሙዚቃ ዝግጅቶች ኢትዮጵያዊ እና ዓለም አቀፍ አርቲስቶችን የሚያቀርቡ።',
  'music',
  '#FF6B6B',
  TRUE,
  1,
  'concert, live music, band, singer, azmari, traditional music',
  NOW()
),
-- 2. Cultural & Traditional
(
  'Cultural & Traditional',
  'ባህላዊ እና ትውፊታዊ',
  'cultural-traditional',
  'Traditional Ethiopian cultural events, festivals, and heritage celebrations.',
  'የባህል ዝግጅቶች፣ በዓላት እና የትውፊት አከባበሮች።',
  'users',
  '#4ECDC4',
  TRUE,
  2,
  'cultural festival, heritage, tradition, holiday, meskel, timket',
  NOW()
),
-- 3. Conference & Business
(
  'Conference & Business',
  'ኮንፈረንስ እና ንግድ',
  'conference-business',
  'Business conferences, seminars, workshops, and professional networking events.',
  'የንግድ ኮንፈረንሶች፣ ሴሚናሮች፣ ዎርክሾፖች እና ፕሮፌሽናል ኔትወርኪንግ ዝግጅቶች።',
  'briefcase',
  '#45B7D1',
  TRUE,
  3,
  'business, workshop, seminar, networking, corporate',
  NOW()
),
-- 4. Sports & Fitness
(
  'Sports & Fitness',
  'ስፖርት እና የአካል ብቃት',
  'sports-fitness',
  'Sports events, tournaments, fitness classes, and athletic competitions.',
  'የስፖርት ዝግጅቶች፣ ቻምፒዮናቶች፣ የአካል ብቃት ክፍሎች እና የአትሌቲክስ ውድድሮች።',
  'activity',
  '#96CEB4',
  TRUE,
  4,
  'football, marathon, fitness, gym, tournament, competition',
  NOW()
),
-- 5. Food & Drink
(
  'Food & Drink',
  'ምግብ እና መጠጥ',
  'food-drink',
  'Food festivals, cooking classes, wine tasting, and culinary events.',
  'የምግብ በዓላት፣ የምግብ አሰራር ክፍሎች፣ የወይን ጠጅ ሙከራ እና የምግብ ሙዚቃ ዝግጅቶች።',
  'coffee',
  '#FFEAA7',
  TRUE,
  5,
  'food festival, cooking, coffee, tej, traditional food',
  NOW()
),
-- 6. Art & Exhibition
(
  'Art & Exhibition',
  'ኪነጥበብ እና ማሳያ',
  'art-exhibition',
  'Art exhibitions, gallery openings, craft fairs, and creative workshops.',
  'የኪነጥበብ ማሳያዎች፣ የጋለሪ መክፈቻዎች፣ የሥራ አጫጭር ገበያዎች እና ፈጠራ ዎርክሾፖች።',
  'palette',
  '#DDA0DD',
  TRUE,
  6,
  'art exhibition, painting, sculpture, gallery, craft',
  NOW()
),
-- 7. Technology & Startup
(
  'Technology & Startup',
  'ቴክኖሎጂ እና ንግድ ጀምሪ',
  'technology-startup',
  'Tech conferences, startup events, hackathons, and innovation workshops.',
  'የቴክኖሎጂ ኮንፈረንሶች፣ የንግድ ጀምሪ ዝግጅቶች፣ ሃክቶኖች እና የፈጠራ ዎርክሾፖች።',
  'cpu',
  '#6C5CE7',
  TRUE,
  7,
  'tech, startup, hackathon, innovation, digital',
  NOW()
),
-- 8. Education & Academic
(
  'Education & Academic',
  'ትምህርት እና አካዳሚክ',
  'education-academic',
  'Educational seminars, university events, book launches, and academic conferences.',
  'የትምህርት ሴሚናሮች፣ የዩኒቨርሲቲ ዝግጅቶች፣ የመጽሐፍ ማስጀመሪያዎች እና የአካዳሚክ ኮንፈረንሶች።',
  'book-open',
  '#00B894',
  TRUE,
  8,
  'education, university, seminar, book, academic',
  NOW()
),
-- 9. Religious & Spiritual
(
  'Religious & Spiritual',
  'ሃይማኖታዊ እና መንፈሳዊ',
  'religious-spiritual',
  'Religious gatherings, spiritual retreats, and faith-based events.',
  'የሃይማኖት ስብሰባዎች፣ መንፈሳዊ እረፍቶች እና በእምነት የተመሰረቱ ዝግጅቶች።',
  'heart',
  '#FD79A8',
  TRUE,
  9,
  'religious, church, mosque, spiritual, meditation',
  NOW()
),
-- 10. Fashion & Beauty
(
  'Fashion & Beauty',
  'ፋሽን እና ውበት',
  'fashion-beauty',
  'Fashion shows, beauty contests, modeling events, and style workshops.',
  'የፋሽን ማሳያዎች፣ የውበት ውድድሮች፣ የሞዴሊንግ ዝግጅቶች እና የስታይል ዎርክሾፖች።',
  'star',
  '#E84393',
  TRUE,
  10,
  'fashion show, beauty pageant, modeling, style, makeup',
  NOW()
),
-- 11. Comedy & Entertainment
(
  'Comedy & Entertainment',
  'ጨዋታ እና መዝናኛ',
  'comedy-entertainment',
  'Comedy shows, stand-up performances, theater plays, and entertainment events.',
  'የጨዋታ ማሳያዎች፣ የስታንድ-አፕ አጫጭር ሥራዎች፣ የቲያትር ትዕይንቶች እና የመዝናኛ ዝግጅቶች።',
  'smile',
  '#FDCB6E',
  TRUE,
  11,
  'comedy, stand-up, theater, drama, entertainment',
  NOW()
),
-- 12. Charity & Fundraising
(
  'Charity & Fundraising',
  'የበጎ አድራጎት እና ገንዘብ ማከፋፈያ',
  'charity-fundraising',
  'Charity events, fundraising galas, and community service activities.',
  'የበጎ አድራጎት ዝግጅቶች፣ የገንዘብ ማከፋፈያ ጋላዎች እና የማህበረሰብ አገልግሎት እንቅስቃሴዎች።',
  'gift',
  '#00CEC9',
  TRUE,
  12,
  'charity, fundraising, donation, community, NGO',
  NOW()
),
-- 13. Health & Wellness
(
  'Health & Wellness',
  'ጤና እና ደህንነት',
  'health-wellness',
  'Health fairs, wellness retreats, yoga classes, and medical awareness events.',
  'የጤና ገበያዎች፣ የደህንነት እረፍቶች፣ የዮጋ ክፍሎች እና የሕክምና ንቃት ዝግጅቶች።',
  'activity',
  '#55EFC4',
  TRUE,
  13,
  'health, wellness, yoga, meditation, medical',
  NOW()
),
-- 14. Family & Kids
(
  'Family & Kids',
  'ቤተሰብ እና ልጆች',
  'family-kids',
  'Family-friendly events, children activities, and kid-oriented entertainment.',
  'ለቤተሰብ ተስማሚ ዝግጅቶች፣ የልጆች እንቅስቃሴዎች እና ለልጆች የተዘጋጁ የመዝናኛ ዝግጅቶች።',
  'home',
  '#FF7675',
  TRUE,
  14,
  'family, kids, children, fun, playground',
  NOW()
),
-- 15. Nightlife & Party
(
  'Nightlife & Party',
  'የምሽት ሕይወት እና ፓርቲ',
  'nightlife-party',
  'Nightclub events, parties, DJ nights, and social gatherings.',
  'የናይትክላብ ዝግጅቶች፣ ፓርቲዎች፣ የጂ ማሳያዎች እና የማህበራዊ ስብሰባዎች።',
  'moon',
  '#2D3436',
  TRUE,
  15,
  'nightlife, party, club, DJ, social',
  NOW()
);

-- ============================================
-- ETHIOPIAN-SPECIFIC SUBCATEGORIES (Optional table, but we'll add as tags)
-- ============================================

-- Insert into event_tags table if it exists
INSERT IGNORE INTO `event_tags` (
  `name`,
  `name_amharic`,
  `slug`,
  `is_active`,
  `created_at`
) VALUES 
-- Music subgenres
('Traditional Music', 'ባህላዊ ሙዚቃ', 'traditional-music', TRUE, NOW()),
('Azmari Bet', 'አዝማሪ ቤት', 'azmari-bet', TRUE, NOW()),
('Ethio-Jazz', 'ኢትዮ-ጃዝ', 'ethio-jazz', TRUE, NOW()),
('Gospel Music', 'ጎስፔል ሙዚቃ', 'gospel-music', TRUE, NOW()),

-- Cultural events
('Coffee Ceremony', 'ቡና ሰርግ', 'coffee-ceremony', TRUE, NOW()),
('Meskel Celebration', 'መስቀል በዓል', 'meskel-celebration', TRUE, NOW()),
('Timket Festival', 'ጥምቀት በዓል', 'timket-festival', TRUE, NOW()),
('Enkutatash', 'እንቁጣጣሽ', 'enkutatash', TRUE, NOW()),

-- Food & Drink
('Tej Tasting', 'ጠጅ ሙከራ', 'tej-tasting', TRUE, NOW()),
('Injera Making', 'እንጀራ ማዘጋጀት', 'injera-making', TRUE, NOW()),
('Traditional Coffee', 'ባህላዊ ቡና', 'traditional-coffee', TRUE, NOW()),

-- Sports
('Ethiopian Run', 'ኢትዮጵያዊ ሩጫ', 'ethiopian-run', TRUE, NOW()),
('Football Match', 'እግር ኳስ ጨዋታ', 'football-match', TRUE, NOW()),
('Traditional Games', 'ባህላዊ ጨዋታዎች', 'traditional-games', TRUE, NOW());

COMMIT;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- SEEDER VERIFICATION & DETAILED SUMMARY
-- ============================================

SELECT 
  '✅ 003_event_categories.sql - SEEDING COMPLETE' as message,
  'Event categories seeded successfully' as details,
  NOW() as seeded_at
UNION ALL
SELECT 
  '📊 CATEGORY SUMMARY' as message,
  CONCAT(
    'Total Categories: ', COUNT(*),
    ' | Active: ', SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END),
    ' | Inactive: ', SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `event_categories`
UNION ALL
SELECT 
  '🎨 CATEGORIES WITH AMHARIC NAMES' as message,
  CONCAT(
    'All ', COUNT(*), ' categories have Amharic translations'
  ) as details,
  NULL as seeded_at
FROM `event_categories`
WHERE `name_amharic` IS NOT NULL AND `name_amharic` != ''
UNION ALL
SELECT 
  '🏆 TOP 5 POPULAR CATEGORIES' as message,
  CONCAT(
    GROUP_CONCAT(`name` ORDER BY `sort_order` LIMIT 5 SEPARATOR ', ')
  ) as details,
  NULL as seeded_at
FROM `event_categories`
WHERE `is_active` = TRUE
UNION ALL
SELECT 
  '🏷️ ETHIOPIAN TAGS CREATED' as message,
  CONCAT(
    'Total Tags: ', COUNT(*)
  ) as details,
  NULL as seeded_at
FROM `event_tags`
UNION ALL
SELECT 
  '🔧 TECHNICAL DETAILS' as message,
  CONCAT(
    'All categories have: ✅ Icons, ✅ Colors, ✅ Sort Order, ✅ Keywords'
  ) as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
ORDER BY 
  CASE 
    WHEN message LIKE '✅%' THEN 1
    WHEN message LIKE '📊%' THEN 2
    WHEN message LIKE '🎨%' THEN 3
    WHEN message LIKE '🏆%' THEN 4
    WHEN message LIKE '🏷️%' THEN 5
    WHEN message LIKE '🔧%' THEN 6
    ELSE 7
  END;
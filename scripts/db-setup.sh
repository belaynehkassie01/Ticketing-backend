#!/bin/bash

# Ethiopian Ticketing Platform - Database Setup Script
# This script sets up the complete database with migrations and seeds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
check_node() {
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 14+"
        exit 1
    fi
    log_info "Node.js version: $(node --version)"
}

# Check if npm is installed
check_npm() {
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed. Please install npm"
        exit 1
    fi
    log_info "npm version: $(npm --version)"
}

# Check if MySQL is installed
check_mysql() {
    if ! command -v mysql &> /dev/null; then
        log_error "MySQL client is not installed. Please install MySQL client"
        exit 1
    fi
    log_info "MySQL client version: $(mysql --version | head -n1)"
}

# Load environment variables
load_env() {
    if [ -f "../.env" ]; then
        log_info "Loading environment variables from .env"
        export $(cat ../.env | grep -v '^#' | xargs)
    elif [ -f "../.env.example" ]; then
        log_warning ".env file not found, using .env.example"
        export $(cat ../.env.example | grep -v '^#' | xargs)
    else
        log_error "No environment file found"
        exit 1
    fi
}

# Create database if it doesn't exist
create_database() {
    log_info "Creating database if it doesn't exist..."
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME 
        CHARACTER SET utf8mb4 
        COLLATE utf8mb4_unicode_ci;
        
        USE $DB_NAME;
        
        -- Create backup user with limited permissions
        CREATE USER IF NOT EXISTS '${DB_NAME}_backup'@'%' IDENTIFIED BY '${DB_PASSWORD}_backup_123';
        GRANT SELECT, SHOW VIEW, LOCK TABLES, RELOAD ON $DB_NAME.* TO '${DB_NAME}_backup'@'%';
        FLUSH PRIVILEGES;
    "
    
    if [ $? -eq 0 ]; then
        log_success "Database setup completed"
    else
        log_error "Failed to create database"
        exit 1
    fi
}

# Install dependencies if needed
install_dependencies() {
    log_info "Checking dependencies..."
    
    if [ ! -d "../node_modules" ]; then
        log_info "Installing dependencies..."
        cd ..
        npm install
        cd scripts
    else
        log_info "Dependencies already installed"
    fi
}

# Run migrations
run_migrations() {
    log_info "Running database migrations..."
    
    cd ..
    
    # Check if migrations directory exists
    if [ ! -d "src/database/migrations" ]; then
        log_warning "Migrations directory not found, creating..."
        mkdir -p src/database/migrations
    fi
    
    # Run migrations
    node src/database/migrate.js migrate
    
    if [ $? -eq 0 ]; then
        log_success "Migrations completed successfully"
    else
        log_error "Migrations failed"
        exit 1
    fi
    
    cd scripts
}

# Run seeds
run_seeds() {
    log_info "Running database seeds..."
    
    cd ..
    
    # Check if seeds directory exists
    if [ ! -d "src/database/seeds" ]; then
        log_warning "Seeds directory not found, creating..."
        mkdir -p src/database/seeds
    fi
    
    # Run seeds
    node src/database/seed.js run
    
    if [ $? -eq 0 ]; then
        log_success "Seeds completed successfully"
    else
        log_error "Seeds failed"
        exit 1
    fi
    
    cd scripts
}

# Check database connection
check_db_connection() {
    log_info "Checking database connection..."
    
    cd ..
    
    # Create a simple test script
    cat > test-db.js << 'EOF'
const mysql = require('mysql2/promise');
require('dotenv').config();

async function testConnection() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'ethiopian_ticketing'
        });
        
        console.log('✅ Database connection successful');
        await connection.end();
        process.exit(0);
    } catch (error) {
        console.error('❌ Database connection failed:', error.message);
        process.exit(1);
    }
}

testConnection();
EOF
    
    node test-db.js
    
    if [ $? -eq 0 ]; then
        log_success "Database connection verified"
    else
        log_error "Database connection failed"
        rm test-db.js
        exit 1
    fi
    
    rm test-db.js
    cd scripts
}

# Create initial seed files
create_initial_seeds() {
    log_info "Creating initial seed files..."
    
    cd ..
    
    SEEDS_DIR="src/database/seeds"
    
    # Create seeds directory if it doesn't exist
    mkdir -p "$SEEDS_DIR"
    
    # 1. System Admin User
    cat > "$SEEDS_DIR/001_system_admin.sql" << 'EOF'
-- System Administrator
-- Password: Admin@123 (should be changed on first login)

INSERT INTO users (
    phone, email, password_hash, full_name, role,
    phone_verified, is_active, created_at
) VALUES (
    '+251911111111',
    'admin@ethiotickets.et',
    -- Password: Admin@123 (bcrypt hash)
    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'System Administrator',
    'admin',
    TRUE,
    TRUE,
    NOW()
);

-- Create system roles
INSERT INTO roles (name, description, permissions, is_system, is_active) VALUES
('super_admin', 'Full system access', '["*"]', TRUE, TRUE),
('admin', 'Administrator access', '["users.read", "users.write", "events.manage", "payments.verify", "payouts.process"]', TRUE, TRUE),
('moderator', 'Content moderator', '["events.moderate", "users.manage"]', TRUE, TRUE),
('customer_support', 'Customer support agent', '["tickets.view", "users.view", "disputes.manage"]', TRUE, TRUE);

-- Assign super_admin role to admin user
SET @admin_id = (SELECT id FROM users WHERE phone = '+251911111111');
SET @super_admin_role_id = (SELECT id FROM roles WHERE name = 'super_admin');

INSERT INTO user_roles (user_id, role_id, assigned_at) 
VALUES (@admin_id, @super_admin_role_id, NOW());
EOF
    
    # 2. Ethiopian Cities and Regions
    cat > "$SEEDS_DIR/002_ethiopian_cities_regions.sql" << 'EOF'
-- Ethiopian Cities and Regions
-- Source: Ethiopian administrative divisions

INSERT INTO cities (name_en, name_am, region, is_active) VALUES
-- Addis Ababa
('Addis Ababa', 'አዲስ አበባ', 'Addis Ababa', TRUE),
-- Afar Region
('Semera', 'ሰመራ', 'Afar', TRUE),
('Asaita', 'አሳይታ', 'Afar', TRUE),
('Dubti', 'ዱብቲ', 'Afar', TRUE),
-- Amhara Region
('Bahir Dar', 'ባሕር ዳር', 'Amhara', TRUE),
('Gondar', 'ጎንደር', 'Amhara', TRUE),
('Dessie', 'ደሴ', 'Amhara', TRUE),
('Debre Markos', 'ደብረ ማርቆስ', 'Amhara', TRUE),
('Debre Birhan', 'ደብረ ብርሃን', 'Amhara', TRUE),
-- Oromia Region
('Adama', 'አዳማ', 'Oromia', TRUE),
('Jimma', 'ጅማ', 'Oromia', TRUE),
('Shashamane', 'ሻሸመኔ', 'Oromia', TRUE),
('Bishoftu', 'ቢሾፍቱ', 'Oromia', TRUE),
('Ambo', 'አምቦ', 'Oromia', TRUE),
-- Southern Nations, Nationalities, and Peoples Region
('Hawassa', 'ሀዋሳ', 'Southern Nations, Nationalities, and Peoples', TRUE),
('Arba Minch', 'አርባ ምንጭ', 'Southern Nations, Nationalities, and Peoples', TRUE),
('Sodo', 'ሶዶ', 'Southern Nations, Nationalities, and Peoples', TRUE),
('Dila', 'ዲላ', 'Southern Nations, Nationalities, and Peoples', TRUE),
-- Tigray Region
('Mekelle', 'መቐለ', 'Tigray', TRUE),
('Adigrat', 'አዲግራት', 'Tigray', TRUE),
('Aksum', 'አክሱም', 'Tigray', TRUE),
('Shire', 'ሽሬ', 'Tigray', TRUE),
-- Other Regions
('Dire Dawa', 'ድሬ ዳዋ', 'Dire Dawa', TRUE),
('Harar', 'ሐረር', 'Harari', TRUE),
('Gambela', 'ጋምቤላ', 'Gambela', TRUE),
('Jijiga', 'ጅጅጋ', 'Somali', TRUE);

-- Create indexes after insertion
CREATE INDEX IF NOT EXISTS idx_cities_region ON cities(region);
CREATE INDEX IF NOT EXISTS idx_cities_name_en ON cities(name_en);
CREATE INDEX IF NOT EXISTS idx_cities_name_am ON cities(name_am);
EOF
    
    # 3. Event Categories
    cat > "$SEEDS_DIR/003_event_categories.sql" << 'EOF'
-- Event Categories with Ethiopian context

INSERT INTO event_categories (name, name_amharic, description, icon, color, is_active, sort_order) VALUES
('Music & Concerts', 'ሙዚቃ እና ኮንሰርት', 'Live music performances, concerts, and musical events', 'music', '#FF6B6B', TRUE, 1),
('Theater & Drama', 'ቲያትር እና ድራማ', 'Plays, theater performances, and drama shows', 'theater', '#4ECDC4', TRUE, 2),
('Sports', 'ስፖርት', 'Sports events, matches, and competitions', 'sports', '#45B7D1', TRUE, 3),
('Conference & Business', 'ኮንፈረንስ እና ንግድ', 'Business conferences, seminars, and workshops', 'conference', '#96CEB4', TRUE, 4),
('Festivals & Cultural', 'ፌስቲቫል እና ባህላዊ', 'Cultural festivals, traditional events, and celebrations', 'festival', '#FFEAA7', TRUE, 5),
('Art & Exhibition', 'አርት እና ማሳያ', 'Art exhibitions, galleries, and creative displays', 'art', '#DDA0DD', TRUE, 6),
('Religious', 'ሃይማኖታዊ', 'Religious events, ceremonies, and gatherings', 'religion', '#98D8C8', TRUE, 7),
('Education & Workshop', 'ትምህርት እና አደረጃጀት', 'Educational workshops, training, and learning events', 'education', '#F7DC6F', TRUE, 8),
('Charity & Fundraising', 'በጎ አድራጎት እና ገንዘብ ማሰባሰብ', 'Charity events and fundraising activities', 'charity', '#FFA07A', TRUE, 9),
('Food & Drink', 'ምግብ እና መጠጥ', 'Food festivals, tasting events, and culinary experiences', 'food', '#20B2AA', TRUE, 10),
('Nightlife & Party', 'የምሽት ሕይወት እና ፓርቲ', 'Nightlife events, parties, and social gatherings', 'nightlife', '#9370DB', TRUE, 11),
('Family & Kids', 'ቤተሰብ እና ልጆች', 'Family-friendly events and activities for children', 'family', '#FFB347', TRUE, 12),
('Other', 'ሌላ', 'Other types of events', 'other', '#B0B0B0', TRUE, 13);
EOF
    
    # 4. Payment Methods
    cat > "$SEEDS_DIR/004_payment_methods.sql" << 'EOF'
-- Ethiopian Payment Methods
-- Supports Telebirr, CBE, and other local payment methods

INSERT INTO payment_methods (
    name, name_amharic, code, type, is_active, is_default,
    sort_order, min_amount, max_amount, qr_supported,
    has_fee, fee_type, fee_percentage, fee_fixed,
    instructions, instructions_amharic, icon
) VALUES
-- Telebirr
(
    'Telebirr',
    'ቴሌብር',
    'telebirr',
    'mobile_money',
    TRUE,
    TRUE,
    1,
    1.00,
    50000.00,
    TRUE,
    FALSE,
    'percentage',
    0.00,
    0.00,
    '1. Open Telebirr App\n2. Tap "Scan QR Code"\n3. Scan the QR code above\n4. Enter your PIN to confirm payment',
    '1. ቴሌብር አፕ ይክፈቱ\n2. "QR ኮድ አንበል" ይንኩ\n3. ከላይ ያለውን QR ኮድ ይንበሩ\n4. ክፍያውን ለማረጋገጥ PIN ያስገቡ',
    'telebirr.png'
),
-- CBE Birr
(
    'CBE Birr',
    'ሲቢኢ ብር',
    'cbe_birr',
    'mobile_money',
    TRUE,
    FALSE,
    2,
    1.00,
    100000.00,
    TRUE,
    FALSE,
    'percentage',
    0.00,
    0.00,
    '1. Open CBE Birr App\n2. Select "Send Money"\n3. Scan QR code or enter details\n4. Confirm payment',
    '1. ሲቢኢ ብር አፕ ይክፈቱ\n2. "ገንዘብ ላክ" ይምረጡ\n3. QR ኮድ ይንበሩ ወይም ዝርዝሮችን ያስገቡ\n4. ክፍያውን ያረጋግጡ',
    'cbe_birr.png'
),
-- CBE Bank Transfer
(
    'CBE Bank Transfer',
    'ሲቢኢ ባንክ ማስተላለፍ',
    'cbe_transfer',
    'bank_transfer',
    TRUE,
    FALSE,
    3,
    10.00,
    500000.00,
    FALSE,
    FALSE,
    'fixed',
    0.00,
    0.00,
    '1. Visit any CBE branch or use CBE mobile/online banking\n2. Transfer to: Account: 1000123456789\n   Name: Ethiopian Tickets PLC\n3. Use reference number from your booking\n4. Upload receipt after payment',
    '1. ማንኛውም ሲቢኢ ቅርንጫፍ ይጎብኙ ወይም ሲቢኢ ሞባይል/ኦንላይን ባንክ ይጠቀሙ\n2. ወደ የሚከተለው ያስተላልፉ: አካውንት: 1000123456789\n   ስም: የኢትዮጵያ ትኬቶች PLC\n3. ከቦታ የሚገኘውን ማጣቀሻ ቁጥር ይጠቀሙ\n4. ክፍያ ካደረጉ በኋላ ክፍያ ሰርተፍኬት ይስቀሉ',
    'cbe_bank.png'
),
-- Cash Payment
(
    'Cash Payment',
    'ኬሽ ክፍያ',
    'cash',
    'cash',
    TRUE,
    FALSE,
    4,
    1.00,
    10000.00,
    FALSE,
    FALSE,
    'fixed',
    0.00,
    0.00,
    'Pay cash at the event venue. Present your booking confirmation.',
    'በዝግጅቱ ቦታ በኬሽ ይክፈሉ። የቦታ ማረጋገጫዎን ያሳዩ።',
    'cash.png'
);
EOF
    
    # 5. System Settings
    cat > "$SEEDS_DIR/005_system_settings.sql" << 'EOF'
-- System Configuration Settings
-- Platform-wide settings that control behavior

INSERT INTO system_settings (category, setting_key, setting_value, setting_type, label, description, is_public, is_editable) VALUES
-- Platform Settings
('platform', 'platform_name', 'Ethiopian Ticketing Platform', 'string', 'Platform Name', 'The name of the platform displayed to users', TRUE, TRUE),
('platform', 'platform_name_amharic', 'የኢትዮጵያ ትኬት ፕላትፎርም', 'string', 'የፕላትፎርም ስም', 'ለተጠቃሚዎች የሚታይ የፕላትፎርም ስም', TRUE, TRUE),
('platform', 'support_phone', '+251911222333', 'string', 'Support Phone', 'Customer support phone number', TRUE, TRUE),
('platform', 'support_email', 'support@ethiotickets.et', 'string', 'Support Email', 'Customer support email address', TRUE, TRUE),
('platform', 'default_language', 'am', 'string', 'Default Language', 'Default language for the platform (am for Amharic, en for English)', TRUE, TRUE),

-- Commission Settings
('commission', 'default_commission_rate', '10.0', 'number', 'Default Commission Rate', 'Default platform commission percentage on ticket sales', FALSE, TRUE),
('commission', 'min_commission_rate', '5.0', 'number', 'Minimum Commission Rate', 'Minimum allowed commission rate', FALSE, TRUE),
('commission', 'max_commission_rate', '20.0', 'number', 'Maximum Commission Rate', 'Maximum allowed commission rate', FALSE, TRUE),
('commission', 'vat_rate', '15.0', 'number', 'VAT Rate', 'Value Added Tax rate for Ethiopia', TRUE, FALSE),

-- Payment Settings
('payment', 'reservation_timeout_minutes', '15', 'number', 'Reservation Timeout', 'Minutes before a ticket reservation expires', TRUE, TRUE),
('payment', 'telebirr_timeout_minutes', '10', 'number', 'Telebirr Payment Timeout', 'Minutes for Telebirr QR code to expire', TRUE, TRUE),
('payment', 'cbe_payment_valid_hours', '24', 'number', 'CBE Payment Validity', 'Hours CBE payment details remain valid', TRUE, TRUE),
('payment', 'min_payout_amount', '500.00', 'number', 'Minimum Payout Amount', 'Minimum amount organizers can request for payout', FALSE, TRUE),

-- Ticket Settings
('ticket', 'max_tickets_per_user', '10', 'number', 'Max Tickets per User', 'Maximum tickets a user can buy for one event', TRUE, TRUE),
('ticket', 'refund_deadline_hours', '48', 'number', 'Refund Deadline', 'Hours before event when refunds are no longer allowed', TRUE, TRUE),
('ticket', 'checkin_buffer_minutes', '30', 'number', 'Check-in Buffer', 'Minutes after event start when check-in is still allowed', TRUE, TRUE),

-- SMS & Notification Settings
('notification', 'sms_enabled', 'true', 'boolean', 'SMS Enabled', 'Enable SMS notifications to users', FALSE, TRUE),
('notification', 'email_enabled', 'true', 'boolean', 'Email Enabled', 'Enable email notifications to users', FALSE, TRUE),
('notification', 'otp_valid_minutes', '5', 'number', 'OTP Validity Minutes', 'Minutes OTP codes remain valid', FALSE, TRUE),
('notification', 'event_reminder_hours', '24', 'number', 'Event Reminder Hours', 'Hours before event to send reminder', FALSE, TRUE),

-- Feature Flags
('features', 'organizer_applications_enabled', 'true', 'boolean', 'Organizer Applications', 'Allow users to apply as organizers', TRUE, TRUE),
('features', 'offline_checkin_enabled', 'true', 'boolean', 'Offline Check-in', 'Enable offline ticket check-in', TRUE, TRUE),
('features', 'ticket_transfer_enabled', 'true', 'boolean', 'Ticket Transfer', 'Allow users to transfer tickets to others', TRUE, TRUE),
('features', 'waiting_list_enabled', 'false', 'boolean', 'Waiting List', 'Enable waiting list for sold-out events', TRUE, TRUE);
EOF
    
    # 6. Ethiopian Holidays
    cat > "$SEEDS_DIR/006_ethiopian_holidays.sql" << 'EOF'
-- Ethiopian Holidays 2024-2025
-- Important dates that might affect events

INSERT INTO ethiopian_holidays (name, name_amharic, description, start_date, end_date, holiday_type, is_active, year, recurring) VALUES
-- National Holidays
('New Year''s Day', 'አዲስ ዓመት', 'Ethiopian New Year (Enkutatash)', '2024-09-11', '2024-09-11', 'national', TRUE, 2024, TRUE),
('Meskel', 'መስቀል', 'Finding of the True Cross', '2024-09-27', '2024-09-27', 'religious', TRUE, 2024, TRUE),
('Christmas', 'ገና', 'Ethiopian Christmas (Genna)', '2025-01-07', '2025-01-07', 'religious', TRUE, 2025, TRUE),
('Epiphany', 'ጥምቀት', 'Baptism of Jesus (Timket)', '2025-01-19', '2025-01-19', 'religious', TRUE, 2025, TRUE),
('Adwa Victory Day', 'አድዋ ድል ቀን', 'Victory of Adwa', '2025-03-02', '2025-03-02', 'national', TRUE, 2025, TRUE),
('Labour Day', 'የሰራተኞች ቀን', 'International Workers'' Day', '2025-05-01', '2025-05-01', 'international', TRUE, 2025, TRUE),
('Easter', 'ፋሲካ', 'Ethiopian Easter (Fasika)', '2025-04-20', '2025-04-20', 'religious', TRUE, 2025, TRUE),
('Patriots Victory Day', 'የወታደሮች ቀን', 'Ethiopian Patriots Victory Day', '2025-05-05', '2025-05-05', 'national', TRUE, 2025, TRUE),
('Downfall of Derg', 'ደርግ መውደቅ', 'Downfall of the Derg regime', '2025-05-28', '2025-05-28', 'national', TRUE, 2025, TRUE),

-- Muslim Holidays (estimated dates)
('Eid al-Fitr', 'ኢድ አል ፊትር', 'End of Ramadan', '2025-03-31', '2025-03-31', 'religious', TRUE, 2025, TRUE),
('Eid al-Adha', 'ኢድ አል አድሃ', 'Feast of Sacrifice', '2025-06-07', '2025-06-07', 'religious', TRUE, 2025, TRUE),
('Mawlid', 'መውሊድ', 'Birth of Prophet Muhammad', '2025-09-15', '2025-09-15', 'religious', TRUE, 2025, TRUE);

-- Create holiday indexes
CREATE INDEX IF NOT EXISTS idx_holidays_dates ON ethiopian_holidays(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_holidays_year ON ethiopian_holidays(year);
CREATE INDEX IF NOT EXISTS idx_holidays_type ON ethiopian_holidays(holiday_type);
EOF
    
    log_success "Created 6 initial seed files"
    
    cd scripts
}

# Show usage
show_usage() {
    echo -e "${BLUE}Ethiopian Ticketing Platform - Database Setup${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo "Usage: ./db-setup.sh [command]"
    echo ""
    echo "Commands:"
    echo "  full              Complete setup (check dependencies, create DB, run migrations & seeds)"
    echo "  check             Check dependencies and environment only"
    echo "  create-db         Create database only"
    echo "  migrate           Run migrations only"
    echo "  seed              Run seeds only"
    echo "  create-seeds      Create initial seed files"
    echo "  status            Show database and migration status"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./db-setup.sh full          # Complete setup"
    echo "  ./db-setup.sh check         # Check environment"
    echo "  ./db-setup.sh migrate       # Run migrations"
    echo ""
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        full)
            log_info "Starting complete database setup..."
            check_node
            check_npm
            check_mysql
            load_env
            install_dependencies
            create_database
            check_db_connection
            run_migrations
            run_seeds
            log_success "🎉 Complete database setup finished!"
            ;;
        check)
            log_info "Checking environment..."
            check_node
            check_npm
            check_mysql
            load_env
            check_db_connection
            log_success "✅ Environment check completed"
            ;;
        create-db)
            log_info "Creating database..."
            load_env
            create_database
            ;;
        migrate)
            log_info "Running migrations..."
            load_env
            run_migrations
            ;;
        seed)
            log_info "Running seeds..."
            load_env
            run_seeds
            ;;
        create-seeds)
            log_info "Creating initial seed files..."
            create_initial_seeds
            ;;
        status)
            log_info "Checking database status..."
            load_env
            cd ..
            echo ""
            echo "🔍 Database Status:"
            echo "=================="
            node src/database/migrate.js status
            echo ""
            echo "🌱 Seed Status:"
            echo "=============="
            node src/database/seed.js status
            cd scripts
            ;;
        help|*)
            show_usage
            ;;
    esac
}

# Make script executable and run
chmod +x "$0"
main "$@"
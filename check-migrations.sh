#!/bin/bash
echo "í´ Checking migration files..."
echo "=============================="

MIGRATIONS_DIR="src/database/migrations"

if [ -d "$MIGRATIONS_DIR" ]; then
    COUNT=$(ls -1 "$MIGRATIONS_DIR"/*.sql 2>/dev/null | wc -l)
    echo "âœ… Found $COUNT SQL files in migrations directory"
    
    if [ $COUNT -gt 0 ]; then
        echo "\ní³‹ Migration files:"
        ls -1 "$MIGRATIONS_DIR"/*.sql | head -10
        if [ $COUNT -gt 10 ]; then
            echo "... and $(($COUNT - 10)) more"
        fi
    fi
else
    echo "âŒ Migrations directory not found: $MIGRATIONS_DIR"
fi

echo "\ní³ Current directory: $(pwd)"
echo "í³ Listing SQL files in current directory:"
ls -1 *.sql 2>/dev/null | wc -l

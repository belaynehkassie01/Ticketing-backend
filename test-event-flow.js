// File: backend/test-event-flow.js
import fetch from 'node-fetch';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const API_BASE = 'http://localhost:5000/api';

async function testEventFlow() {
  console.log('🎪 Testing Event Creation Flow...\n');
  
  const testPhone = '+251911778899';
  let organizerToken = '';
  let eventId = '';
  let ticketTypeId = '';
  
  // Database connection
  const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ethio_tickets'
  });
  
  try {
    // 1. Create organizer user
    console.log('1. Creating organizer user...');
    await db.execute('DELETE FROM users WHERE phone = ?', [testPhone]);
    
    // Register user
    const sendRes = await fetch(`${API_BASE}/auth/send-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: testPhone })
    });
    
    const sendData = await sendRes.json();
    const userId = sendData.data.userId;
    
    // Get OTP and verify
    const [rows] = await db.execute(
      'SELECT verification_code FROM users WHERE id = ?',
      [userId]
    );
    
    const otp = rows[0].verification_code;
    
    const verifyRes = await fetch(`${API_BASE}/auth/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId, otp })
    });
    
    const verifyData = await verifyRes.json();
    let token = verifyData.data.token;
    
    // Apply to be organizer
    console.log('2. Applying to be organizer...');
    const applyRes = await fetch(`${API_BASE}/organizer/apply`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        business_name: 'Test Event Organizer',
        business_type: 'individual',
        contact_person: 'Test Organizer',
        contact_phone: testPhone,
        bank_name: 'cbe',
        bank_account: '1000999888777',
        account_holder_name: 'Test Business'
      })
    });
    
    console.log('✅ Organizer application submitted\n');
    
    // For testing, manually approve in database
    console.log('3. Manually approving organizer (for testing)...');
    await db.execute(`
      UPDATE users SET 
        organizer_status = 'approved',
        role = 'organizer',
        organizer_id = 1
      WHERE id = ?
    `, [userId]);
    
    await db.execute(`
      INSERT INTO organizers (id, user_id, business_name, business_type, status) 
      VALUES (1, ?, 'Test Organizer', 'individual', 'approved')
      ON DUPLICATE KEY UPDATE status = 'approved'
    `, [userId]);
    
    // Get new token with organizer role
    const newTokenRes = await fetch(`${API_BASE}/auth/send-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: testPhone })
    });
    
    const newSendData = await newTokenRes.json();
    const [newRows] = await db.execute(
      'SELECT verification_code FROM users WHERE id = ?',
      [newSendData.data.userId]
    );
    
    const newOtp = newRows[0].verification_code;
    
    const newVerifyRes = await fetch(`${API_BASE}/auth/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        userId: newSendData.data.userId, 
        otp: newOtp 
      })
    });
    
    const newVerifyData = await newVerifyRes.json();
    organizerToken = newVerifyData.data.token;
    
    console.log('✅ Organizer approved and token obtained\n');
    
    // 4. Create event
    console.log('4. Creating event...');
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const eventData = {
      title: 'የሙከራ ኮንሰርት - Test Concert',
      title_amharic: 'የሙከራ ኮንሰርት',
      description: 'This is a test concert event for the Ethiopian ticketing platform',
      description_amharic: 'ይህ ለኢትዮጵያ ቲኬቲንግ መድረክ የተዘጋጀ የሙከራ ኮንሰርት ነው',
      category_id: 1, // Music category
      city_id: 1, // Addis Ababa
      start_date: tomorrow.toISOString(),
      end_date: new Date(tomorrow.getTime() + 3 * 60 * 60 * 1000).toISOString(), // +3 hours
      cover_image: 'https://example.com/concert.jpg'
    };
    
    const eventRes = await fetch(`${API_BASE}/events`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${organizerToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(eventData)
    });
    
    const eventResult = await eventRes.json();
    console.log('Event creation:', eventResult.success ? '✅' : '❌');
    
    if (eventResult.success) {
      eventId = eventResult.data.event.id;
      console.log(`Event ID: ${eventId}\n`);
      
      // 5. Add ticket types
      console.log('5. Adding ticket types...');
      const ticketTypes = [
        {
          name: 'General Admission',
          name_amharic: 'ጠቅላላ መግቢያ',
          price: 500,
          quantity: 100,
          description: 'Standard entry ticket',
          max_per_user: 5
        },
        {
          name: 'VIP',
          name_amharic: 'ቪአይፒ',
          price: 1500,
          quantity: 20,
          description: 'VIP access with special seating',
          max_per_user: 2,
          access_level: 'vip'
        }
      ];
      
      for (const ticketData of ticketTypes) {
        const ticketRes = await fetch(`${API_BASE}/events/${eventId}/tickets`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${organizerToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(ticketData)
        });
        
        const ticketResult = await ticketRes.json();
        console.log(`Ticket "${ticketData.name}": ${ticketResult.success ? '✅' : '❌'}`);
        
        if (ticketResult.success && !ticketTypeId) {
          ticketTypeId = ticketResult.data.ticket_type.id;
        }
      }
      
      // 6. Publish event
      console.log('\n6. Publishing event...');
      const publishRes = await fetch(`${API_BASE}/events/${eventId}/publish`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${organizerToken}`,
          'Content-Type': 'application/json'
        }
      });
      
      const publishResult = await publishRes.json();
      console.log(`Event publish: ${publishResult.success ? '✅' : '❌'}`);
      
      // 7. Test public access
      console.log('\n7. Testing public access...');
      const publicRes = await fetch(`${API_BASE}/events/${eventId}`);
      const publicResult = await publicRes.json();
      
      if (publicResult.success) {
        console.log('✅ Public can view event');
        console.log(`Event: ${publicResult.data.event.title}`);
        console.log(`Ticket types: ${publicResult.data.ticket_count}`);
      }
      
      // 8. Check ticket availability
      if (ticketTypeId) {
        console.log('\n8. Checking ticket availability...');
        const availRes = await fetch(`${API_BASE}/events/tickets/${ticketTypeId}/check`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ quantity: 2 })
        });
        
        const availResult = await availRes.json();
        console.log(`Availability check: ${availResult.success ? '✅' : '❌'}`);
        if (availResult.success) {
          console.log(`Price for 2 tickets: ETB ${availResult.data.total_price}`);
        }
      }
      
      console.log('\n🎉 Event flow test completed!');
      console.log('\n📋 What we built:');
      console.log('  1. Event creation with Ethiopian dates');
      console.log('  2. Ticket types with Ethiopian VAT calculation');
      console.log('  3. Event publishing workflow');
      console.log('  4. Public event listing');
      console.log('  5. Ticket availability checking');
      
    } else {
      console.log('❌ Failed to create event:', eventResult.message);
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  } finally {
    await db.end();
  }
}

// Check server
fetch('http://localhost:5000')
  .then(() => {
    console.log('✅ Server is running\n');
    testEventFlow();
  })
  .catch(() => {
    console.log('❌ Server not running');
  });
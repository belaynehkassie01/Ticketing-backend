// File: backend/test-auth-flow-fixed.js
import fetch from 'node-fetch';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const API_BASE = 'http://localhost:5000/api';

async function testAuthFlow() {
  console.log('🧪 Testing Authentication Flow (Fixed)...\n');
  
  const testPhone = '+251911223344';
  
  // Database connection
  const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ethio_tickets'
  });
  
  try {
    // 1. Clean up existing test user
    console.log('1. Cleaning up existing test user...');
    await db.execute('DELETE FROM users WHERE phone = ?', [testPhone]);
    
    // 2. Send OTP
    console.log('2. Testing /api/auth/send-otp...');
    const sendOTPResponse = await fetch(`${API_BASE}/auth/send-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: testPhone })
    });
    
    const sendOTPResult = await sendOTPResponse.json();
    console.log('Response:', sendOTPResult);
    
    if (!sendOTPResult.success) {
      console.log('❌ Failed to send OTP');
      return;
    }
    
    const userId = sendOTPResult.data.userId;
    console.log(`✅ OTP sent to ${testPhone}, User ID: ${userId}\n`);
    
    // Wait a moment for the OTP to be saved
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // 3. Get actual OTP from database
    console.log('3. Getting actual OTP from database...');
    const [rows] = await db.execute(
      'SELECT verification_code FROM users WHERE id = ?',
      [userId]
    );
    
    if (!rows[0] || !rows[0].verification_code) {
      console.log('❌ No OTP found in database');
      return;
    }
    
    const actualOTP = rows[0].verification_code;
    console.log(`✅ Actual OTP from database: ${actualOTP}\n`);
    
    // 4. Verify OTP with actual code
    console.log(`4. Testing /api/auth/verify-otp with actual OTP...`);
    const verifyResponse = await fetch(`${API_BASE}/auth/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId, otp: actualOTP })
    });
    
    const verifyResult = await verifyResponse.json();
    console.log('Response:', verifyResult);
    
    if (verifyResult.success) {
      const token = verifyResult.data.token;
      console.log(`✅ Login successful! Token: ${token.substring(0, 30)}...\n`);
      
      // 5. Test protected route
      console.log('5. Testing protected route /api/auth/profile...');
      const profileResponse = await fetch(`${API_BASE}/auth/profile`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      
      const profileResult = await profileResponse.json();
      if (profileResult.success) {
        console.log('✅ Profile fetched successfully!');
        console.log(`User: ${profileResult.data.user.phone} (${profileResult.data.user.role})`);
      } else {
        console.log('❌ Failed to fetch profile:', profileResult.message);
      }
      
      // 6. Test updating profile
      console.log('\n6. Testing profile update...');
      const updateResponse = await fetch(`${API_BASE}/auth/profile`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          full_name: 'የሙከራ ተጠቃሚ',
          preferred_language: 'am'
        })
      });
      
      const updateResult = await updateResponse.json();
      if (updateResult.success) {
        console.log('✅ Profile updated successfully!');
      } else {
        console.log('❌ Failed to update profile:', updateResult.message);
      }
      
    } else {
      console.log('❌ OTP verification failed:', verifyResult.message);
    }
    
    console.log('\n🎉 Auth flow test completed!');
    
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
    testAuthFlow();
  })
  .catch(() => {
    console.log('❌ Server not running. Start with: nodemon server.js');
  });
// File: backend/test-otp-final.js
import fetch from 'node-fetch';

async function testOTP() {
  console.log('🎯 Final OTP Test\n');
  
  // Use a NEW phone number to avoid old OTP issues
  const testPhone = '+251911334455';
  
  try {
    console.log('1. Sending OTP to', testPhone);
    const sendRes = await fetch('http://localhost:5000/api/auth/send-otp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: testPhone })
    });
    
    const sendData = await sendRes.json();
    console.log('Response:', sendData);
    
    if (!sendData.success) {
      console.log('❌ Failed to send OTP');
      return;
    }
    
    const userId = sendData.data.userId;
    
    console.log('\n2. ✅ OTP sent! User ID:', userId);
    console.log('\n3. Look at your SERVER LOGS for the OTP');
    console.log('   (In the terminal where nodemon is running)');
    console.log('   You should see: "Sending OTP to +251911334455: XXXXXX"');
    console.log('\n4. Enter the OTP from logs:');
    
    // For manual entry - you can't automate this because OTP is random
    console.log('\n📝 Manual verification required:');
    console.log('   curl -X POST http://localhost:5000/api/auth/verify-otp \\');
    console.log('     -H "Content-Type: application/json" \\');
    console.log(`     -d '{"userId": ${userId}, "otp": "PASTE_OTP_HERE"}'`);
    
    // Check if server is working
    console.log('\n🔗 Server status:');
    const healthRes = await fetch('http://localhost:5000/');
    const healthData = await healthRes.json();
    console.log('   Server:', healthData.message);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.log('\n🔧 Check:');
    console.log('   1. Server running: nodemon server.js');
    console.log('   2. Database running (XAMPP/WAMP)');
  }
}

testOTP();
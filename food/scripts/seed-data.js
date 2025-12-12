const admin = require('firebase-admin');

// Initialize Firebase Admin
// Download service account key from Firebase Console:
// Project Settings > Service Accounts > Generate New Private Key
// Save as service-account-key.json in this directory

try {
  const serviceAccount = require('./service-account-key.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (error) {
  console.error('Error: service-account-key.json not found!');
  console.error('Download it from Firebase Console > Project Settings > Service Accounts');
  process.exit(1);
}

const db = admin.firestore();

// Sample menu data
const menuItems = [
  {
    name: 'Idli Sambar (3 pcs)',
    price: 50,
    meal: 'breakfast',
    enabled: true,
    description: 'Soft steamed idlis with sambar and coconut chutney',
    imageUrl: ''
  },
  {
    name: 'Masala Dosa',
    price: 70,
    meal: 'breakfast',
    enabled: true,
    description: 'Crispy rice crepe with spiced potato filling',
    imageUrl: ''
  },
  {
    name: 'Poha',
    price: 40,
    meal: 'breakfast',
    enabled: true,
    description: 'Flattened rice with peanuts and spices',
    imageUrl: ''
  },
  {
    name: 'Veg Thali',
    price: 120,
    meal: 'lunch',
    enabled: true,
    description: 'Rice, 2 vegetables, dal, chapati, curd, pickle',
    imageUrl: ''
  },
  {
    name: 'Paneer Butter Masala',
    price: 150,
    meal: 'lunch',
    enabled: true,
    description: 'Cottage cheese in rich tomato gravy',
    imageUrl: ''
  },
  {
    name: 'Chole Bhature',
    price: 100,
    meal: 'lunch',
    enabled: true,
    description: 'Spiced chickpeas with fluffy fried bread',
    imageUrl: ''
  },
  {
    name: 'Vada Pav',
    price: 30,
    meal: 'snack',
    enabled: true,
    description: 'Spicy potato fritter in a bun',
    imageUrl: ''
  },
  {
    name: 'Samosa (2 pcs)',
    price: 40,
    meal: 'snack',
    enabled: true,
    description: 'Crispy pastry with spiced potato filling',
    imageUrl: ''
  },
  {
    name: 'Masala Chai',
    price: 20,
    meal: 'snack',
    enabled: true,
    description: 'Indian spiced tea with milk',
    imageUrl: ''
  },
  {
    name: 'Pakora Plate',
    price: 60,
    meal: 'snack',
    enabled: true,
    description: 'Mixed vegetable fritters',
    imageUrl: ''
  },
  {
    name: 'Dal Tadka',
    price: 100,
    meal: 'dinner',
    enabled: true,
    description: 'Yellow lentils tempered with spices',
    imageUrl: ''
  },
  {
    name: 'Chicken Biryani',
    price: 180,
    meal: 'dinner',
    enabled: true,
    description: 'Aromatic rice with tender chicken pieces',
    imageUrl: ''
  },
  {
    name: 'Palak Paneer',
    price: 140,
    meal: 'dinner',
    enabled: true,
    description: 'Cottage cheese in spinach gravy',
    imageUrl: ''
  },
  {
    name: 'Roti (5 pcs)',
    price: 30,
    meal: 'dinner',
    enabled: true,
    description: 'Whole wheat flatbread',
    imageUrl: ''
  }
];

async function seedMenu() {
  console.log('🌱 Seeding menu data...');
  
  try {
    const batch = db.batch();
    
    menuItems.forEach(item => {
      const ref = db.collection('menu').doc();
      batch.set(ref, item);
      console.log(`   ✓ Added: ${item.name} (${item.meal})`);
    });
    
    await batch.commit();
    console.log('\n✅ Successfully seeded menu data!');
    console.log(`📊 Total items: ${menuItems.length}`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
}

// Run the seed function
seedMenu();

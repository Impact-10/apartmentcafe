import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { onAuthStateChanged } from 'firebase/auth';
import { useEffect, useState } from 'react';
import { CartProvider } from './hooks/useCart.jsx';
import Header from './components/Header';
import Footer from './components/Footer';
import MenuSection from './components/MenuSection';
import CartFloating from './components/CartFloating';
import CartModal from './components/CartModal';
import OrderTracker from './components/OrderTracker';
import AdminLogin from './components/AdminLogin';
import AdminOrders from './components/AdminOrders';
import { useMenuRTDB } from './hooks/useMenuRTDB';
import { auth } from './lib/firebase';
import './styles.css';

function HomePage() {
  const { menu, loading, error } = useMenuRTDB();
  const [activeMeal, setActiveMeal] = useState('breakfast');

  // Auto-select first available meal if current is empty
  useEffect(() => {
    if (!loading && menu) {
      if (menu[activeMeal]?.length === 0) {
        const available = ['breakfast', 'lunch', 'snack', 'dinner'].find(
          meal => menu[meal]?.length > 0
        );
        if (available) setActiveMeal(available);
      }
    }
  }, [menu, loading, activeMeal]);

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner">
          <i className="bi bi-hourglass-split"></i>
          <p>Loading menu...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="error-container">
        <i className="bi bi-exclamation-triangle"></i>
        <p>Error loading menu: {error}</p>
      </div>
    );
  }

  const hasItems = Object.values(menu).some(items => items.length > 0);

  if (!hasItems) {
    return (
      <div className="empty-container">
        <i className="bi bi-inbox"></i>
        <p>No menu items available at the moment</p>
        <p className="empty-subtitle">Check back later!</p>
      </div>
    );
  }

  // Map meal IDs to display data
  const mealData = {
    breakfast: { title: 'Breakfast', icon: 'bi-sunrise' },
    lunch: { title: 'Lunch', icon: 'bi-sun' },
    snack: { title: 'Evening Snack', icon: 'bi-cup-hot' },
    dinner: { title: 'Dinner', icon: 'bi-moon-stars' }
  };

  const currentMeal = mealData[activeMeal];

  return (
    <>
      <Header activeMeal={activeMeal} onMealChange={setActiveMeal} />
      
      <main className="main-content-new">
        <div className="container-new">
          <MenuSection
            title={currentMeal.title}
            items={menu[activeMeal] || []}
            icon={currentMeal.icon}
          />
        </div>
      </main>

      <Footer />
      <CartFloating />
      <CartModal />
      <OrderTracker />
    </>
  );
}

function AdminPage() {
  const [user, setUser] = useState(null);
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (next) => {
      setUser(next);
      setChecking(false);
    });
    return () => unsub();
  }, []);

  if (checking) {
    return (
      <div className="loading-container">
        <div className="loading-spinner">
          <i className="bi bi-hourglass-split"></i>
          <p>Checking admin session...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <AdminLogin />;
  }

  return <AdminOrders user={user} />;
}

function App() {
  return (
    <Router>
      <CartProvider>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/admin" element={<AdminPage />} />
        </Routes>
      </CartProvider>
    </Router>
  );
}

export default App;

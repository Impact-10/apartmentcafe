import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { onAuthStateChanged } from 'firebase/auth';
import { useEffect, useState } from 'react';
import { CartProvider } from './hooks/useCart.jsx';
import Header from './components/Header';
import Footer from './components/Footer';
import MenuSection from './components/MenuSection';
import CartFloating from './components/CartFloating';
import CartModal from './components/CartModal';
import AdminLogin from './components/AdminLogin';
import AdminOrders from './components/AdminOrders';
import { useMenuRTDB } from './hooks/useMenuRTDB';
import { auth } from './lib/firebase';
import './styles.css';

function HomePage() {
  const { menu, loading, error } = useMenuRTDB();

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

  return (
    <>
      <Header />
      
      <main className="main-content">
        <div className="container">
          {menu.breakfast.length > 0 && (
            <MenuSection
              title="Breakfast"
              items={menu.breakfast}
              icon="bi-sunrise"
            />
          )}
          
          {menu.lunch.length > 0 && (
            <MenuSection
              title="Lunch"
              items={menu.lunch}
              icon="bi-sun"
            />
          )}
          
          {menu.snack.length > 0 && (
            <MenuSection
              title="Evening Snack"
              items={menu.snack}
              icon="bi-cup-hot"
            />
          )}
          
          {menu.dinner.length > 0 && (
            <MenuSection
              title="Dinner"
              items={menu.dinner}
              icon="bi-moon-stars"
            />
          )}
        </div>
      </main>

      <Footer />
      <CartFloating />
      <CartModal />
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

import { createContext, useContext, useState, useCallback, useEffect } from 'react';

const CartContext = createContext();

/**
 * Cart Provider Component
 * Manages cart state and provides cart operations
 */
export function CartProvider({ children }) {
  const [cart, setCart] = useState([]);
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [lastOrderTime, setLastOrderTime] = useState(null);

  // Load cart from localStorage on mount
  useEffect(() => {
    const savedCart = localStorage.getItem('cafe-cart');
    if (savedCart) {
      try {
        setCart(JSON.parse(savedCart));
      } catch (e) {
        console.error('Failed to parse saved cart:', e);
      }
    }
    
    const savedOrderTime = localStorage.getItem('cafe-last-order');
    if (savedOrderTime) {
      setLastOrderTime(parseInt(savedOrderTime, 10));
    }
  }, []);

  // Save cart to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('cafe-cart', JSON.stringify(cart));
  }, [cart]);

  // Add item to cart or update quantity
  const addToCart = useCallback((item, quantity = 1) => {
    setCart((prevCart) => {
      const existingItemIndex = prevCart.findIndex((i) => i.id === item.id);
      
      if (existingItemIndex > -1) {
        // Update existing item quantity
        const newCart = [...prevCart];
        newCart[existingItemIndex] = {
          ...newCart[existingItemIndex],
          qty: newCart[existingItemIndex].qty + quantity
        };
        return newCart;
      } else {
        // Add new item
        return [...prevCart, { ...item, qty: quantity }];
      }
    });
  }, []);

  // Update item quantity
  const updateQuantity = useCallback((itemId, quantity) => {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }
    
    setCart((prevCart) =>
      prevCart.map((item) =>
        item.id === itemId ? { ...item, qty: quantity } : item
      )
    );
  }, []);

  // Remove item from cart
  const removeFromCart = useCallback((itemId) => {
    setCart((prevCart) => prevCart.filter((item) => item.id !== itemId));
  }, []);

  // Clear entire cart
  const clearCart = useCallback(() => {
    setCart([]);
    localStorage.removeItem('cafe-cart');
  }, []);

  // Calculate total
  const total = cart.reduce((sum, item) => sum + item.price * item.qty, 0);

  // Calculate item count
  const itemCount = cart.reduce((sum, item) => sum + item.qty, 0);

  // Toggle cart modal
  const toggleCart = useCallback(() => {
    setIsCartOpen((prev) => !prev);
  }, []);

  const openCart = useCallback(() => setIsCartOpen(true), []);
  const closeCart = useCallback(() => setIsCartOpen(false), []);

  // Check if user can place order (rate limiting)
  const canPlaceOrder = useCallback(() => {
    if (!lastOrderTime) return true;
    const now = Date.now();
    const timeSinceLastOrder = now - lastOrderTime;
    return timeSinceLastOrder > 30000; // 30 seconds
  }, [lastOrderTime]);

  // Record order placement time
  const recordOrderPlacement = useCallback(() => {
    const now = Date.now();
    setLastOrderTime(now);
    localStorage.setItem('cafe-last-order', now.toString());
  }, []);

  const value = {
    cart,
    addToCart,
    updateQuantity,
    removeFromCart,
    clearCart,
    total,
    itemCount,
    isCartOpen,
    toggleCart,
    openCart,
    closeCart,
    canPlaceOrder,
    recordOrderPlacement
  };

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

/**
 * Hook to use cart context
 */
export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}

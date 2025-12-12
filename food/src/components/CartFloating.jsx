import { useCart } from '../hooks/useCart';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * CartFloating component
 * Floating oval cart button at the bottom of the page
 */
export default function CartFloating() {
  const { itemCount, toggleCart } = useCart();

  if (itemCount === 0) {
    return null;
  }

  return (
    <motion.button
      className="cart-floating"
      onClick={toggleCart}
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      exit={{ y: 100, opacity: 0 }}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      <i className="bi bi-cart3"></i>
      <span className="cart-text">View Cart</span>
      <AnimatePresence mode="wait">
        <motion.span
          key={itemCount}
          className="cart-badge"
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          exit={{ scale: 0 }}
        >
          {itemCount}
        </motion.span>
      </AnimatePresence>
    </motion.button>
  );
}

import { useState } from 'react';
import { useCart } from '../hooks/useCart';
import { motion } from 'framer-motion';

/**
 * ItemCard component
 * Displays a menu item with image, name, price, description and quantity controls
 */
export default function ItemCard({ item }) {
  const { addToCart } = useCart();
  const [quantity, setQuantity] = useState(1);
  const [isAdding, setIsAdding] = useState(false);

  const handleIncrement = () => {
    setQuantity((prev) => Math.min(prev + 1, 10));
  };

  const handleDecrement = () => {
    setQuantity((prev) => Math.max(prev - 1, 1));
  };

  const handleAddToCart = () => {
    setIsAdding(true);
    addToCart(item, quantity);
    
    setTimeout(() => {
      setIsAdding(false);
      setQuantity(1);
    }, 500);
  };

  return (
    <motion.div
      className="item-card scroll-stack-item"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
    >
      {item.imageUrl && (
        <div className="item-image">
          <img src={item.imageUrl} alt={item.name} loading="lazy" />
        </div>
      )}
      
      <div className="item-content">
        <div className="item-header">
          <h3 className="item-name">{item.name}</h3>
          <span className="item-price">₹{item.price}</span>
        </div>
        
        {item.description && (
          <p className="item-description">{item.description}</p>
        )}
        
        <div className="item-actions">
          <div className="quantity-control">
            <button
              className="qty-btn"
              onClick={handleDecrement}
              disabled={quantity <= 1}
              aria-label="Decrease quantity"
            >
              <i className="bi bi-dash"></i>
            </button>
            <span className="qty-value">{quantity}</span>
            <button
              className="qty-btn"
              onClick={handleIncrement}
              disabled={quantity >= 10}
              aria-label="Increase quantity"
            >
              <i className="bi bi-plus"></i>
            </button>
          </div>
          
          <motion.button
            className={`add-btn ${isAdding ? 'adding' : ''}`}
            onClick={handleAddToCart}
            disabled={isAdding}
            whileTap={{ scale: 0.95 }}
          >
            {isAdding ? (
              <>
                <i className="bi bi-check-lg"></i> Added!
              </>
            ) : (
              <>
                <i className="bi bi-cart-plus"></i> Add
              </>
            )}
          </motion.button>
        </div>
      </div>
    </motion.div>
  );
}

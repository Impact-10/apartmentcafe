import { useState } from 'react';
import { useCart } from '../hooks/useCart';
import { motion } from 'framer-motion';
import { ScrollStackItem } from './ScrollStack';

export default function ItemCard({ item, index = 0 }) {
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
    <ScrollStackItem>
      <motion.div
        className="item-card-stack"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.4 }}
      >
        <div className="stack-card-content">
          {/* Image Section - Fixed Grid */}
          <div className="stack-image-grid">
            {item.imageUrl ? (
              <img 
                src={item.imageUrl} 
                alt={item.name} 
                loading="lazy"
                className="stack-image"
              />
            ) : (
              <div className="stack-image-placeholder">
                <i className="bi bi-image"></i>
              </div>
            )}
          </div>

          {/* Content Section */}
          <div className="stack-card-info">
            <div className="stack-header">
              <h3 className="stack-name">{item.name}</h3>
              <span className="stack-price">₹{item.price}</span>
            </div>

            {item.description && (
              <p className="stack-description">{item.description}</p>
            )}

            <div className="stack-actions">
              <div className="stack-qty-control">
                <button
                  className="qty-stack-btn"
                  onClick={handleDecrement}
                  disabled={quantity <= 1}
                  aria-label="Decrease"
                >
                  <i className="bi bi-minus"></i>
                </button>
                <span className="qty-stack-value">{quantity}</span>
                <button
                  className="qty-stack-btn"
                  onClick={handleIncrement}
                  disabled={quantity >= 10}
                  aria-label="Increase"
                >
                  <i className="bi bi-plus"></i>
                </button>
              </div>

              <motion.button
                className={`add-to-cart-btn ${isAdding ? 'added' : ''}`}
                onClick={handleAddToCart}
                disabled={isAdding}
                whileTap={{ scale: 0.95 }}
                whileHover={{ scale: 1.02 }}
              >
                <i className={`bi ${isAdding ? 'bi-check-circle-fill' : 'bi-bag-plus'}`}></i>
                <span>{isAdding ? 'Added!' : 'Add to Cart'}</span>
              </motion.button>
            </div>
          </div>
        </div>
      </motion.div>
    </ScrollStackItem>
  );
}

import { useState } from 'react';
import { useCart } from '../hooks/useCart';
import { motion } from 'framer-motion';

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
    <motion.div
      className="item-card"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, delay: index * 0.05 }}
    >
        <div className="card-content">
          {/* Image Section */}
          <div className="card-image-wrapper">
            {item.imageUrl ? (
              <img 
                src={item.imageUrl} 
                alt={item.name} 
                loading="lazy"
                className="card-image"
              />
            ) : (
              <div className="card-image-placeholder">
                <i className="bi bi-image"></i>
              </div>
            )}
          </div>

          {/* Content Section */}
          <div className="card-info">
            <div className="card-header">
              <h3 className="card-name">{item.name}</h3>
              <span className="card-price">₹{item.price}</span>
            </div>

            {item.description && (
              <p className="card-description">{item.description}</p>
            )}

            <div className="card-actions">
              <div className="qty-control">
                <button
                  className="qty-btn"
                  onClick={handleDecrement}
                  disabled={quantity <= 1}
                  aria-label="Decrease"
                >
                  <i className="bi bi-minus"></i>
                </button>
                <span className="qty-value">{quantity}</span>
                <button
                  className="qty-btn"
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
  );
}

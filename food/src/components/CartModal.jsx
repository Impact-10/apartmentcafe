import { useState } from 'react';
import { useCart } from '../hooks/useCart';
import { motion, AnimatePresence } from 'framer-motion';
import CheckoutModal from './CheckoutModal';

/**
 * CartModal component
 * Modal that displays cart items and allows quantity adjustments
 */
export default function CartModal() {
  const {
    cart,
    total,
    isCartOpen,
    closeCart,
    updateQuantity,
    removeFromCart
  } = useCart();

  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);

  const handleCheckout = () => {
    setIsCheckoutOpen(true);
  };

  const handleCloseCheckout = () => {
    setIsCheckoutOpen(false);
  };

  if (!isCartOpen) {
    return null;
  }

  return (
    <>
      <AnimatePresence>
        {isCartOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              className="modal-backdrop"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={closeCart}
            />

            {/* Modal */}
            <motion.div
              className="modal cart-modal"
              initial={{ y: '100%' }}
              animate={{ y: 0 }}
              exit={{ y: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
            >
              <div className="modal-header">
                <h2>
                  <i className="bi bi-cart3"></i> Your Cart
                </h2>
                <button className="close-btn" onClick={closeCart} aria-label="Close cart">
                  <i className="bi bi-x-lg"></i>
                </button>
              </div>

              <div className="modal-body">
                {cart.length === 0 ? (
                  <div className="empty-cart">
                    <i className="bi bi-cart-x"></i>
                    <p>Your cart is empty</p>
                  </div>
                ) : (
                  <>
                    <div className="cart-items">
                      {cart.map((item) => (
                        <motion.div
                          key={item.id}
                          className="cart-item"
                          layout
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          exit={{ opacity: 0, x: 20 }}
                        >
                          <div className="cart-item-info">
                            <h3>{item.name}</h3>
                            <p className="cart-item-price">₹{item.price} each</p>
                          </div>

                          <div className="cart-item-actions">
                            <div className="quantity-control">
                              <button
                                className="qty-btn"
                                onClick={() => updateQuantity(item.id, item.qty - 1)}
                                aria-label="Decrease quantity"
                              >
                                <i className="bi bi-dash"></i>
                              </button>
                              <span className="qty-value">{item.qty}</span>
                              <button
                                className="qty-btn"
                                onClick={() => updateQuantity(item.id, item.qty + 1)}
                                aria-label="Increase quantity"
                              >
                                <i className="bi bi-plus"></i>
                              </button>
                            </div>

                            <div className="cart-item-total">
                              <span>₹{item.price * item.qty}</span>
                            </div>

                            <button
                              className="remove-btn"
                              onClick={() => removeFromCart(item.id)}
                              aria-label="Remove item"
                            >
                              <i className="bi bi-trash"></i>
                            </button>
                          </div>
                        </motion.div>
                      ))}
                    </div>

                    <div className="cart-summary">
                      <div className="cart-total">
                        <span>Total</span>
                        <strong>₹{total}</strong>
                      </div>
                      <button className="checkout-btn" onClick={handleCheckout}>
                        <i className="bi bi-check-circle"></i> Proceed to Checkout
                      </button>
                    </div>
                  </>
                )}
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Checkout Modal */}
      {isCheckoutOpen && (
        <CheckoutModal
          isOpen={isCheckoutOpen}
          onClose={handleCloseCheckout}
          onSuccess={() => {
            handleCloseCheckout();
            closeCart();
          }}
        />
      )}
    </>
  );
}

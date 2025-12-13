import { useState } from 'react';
import { useCart } from '../hooks/useCart';
import { motion, AnimatePresence } from 'framer-motion';
import { placeOrder } from '../lib/ordersRTDB';

/**
 * CheckoutModal component
 * Collects customer information and places order
 */
export default function CheckoutModal({ isOpen, onClose, onSuccess }) {
  const { cart, total, clearCart, canPlaceOrder, recordOrderPlacement } = useCart();
  
  const [formData, setFormData] = useState({
    name: '',
    blockDoor: '',
    mobile: ''
  });
  
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    
    // Clear error for this field
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.blockDoor.trim()) {
      newErrors.blockDoor = 'Block and door number is required';
    }

    if (!formData.mobile.trim()) {
      newErrors.mobile = 'Mobile number is required';
    } else if (!/^\d{10}$/.test(formData.mobile.trim())) {
      newErrors.mobile = 'Please enter a valid 10-digit mobile number';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    if (!canPlaceOrder()) {
      setErrors({ general: 'Please wait 30 seconds before placing another order' });
      return;
    }

    setIsSubmitting(true);
    setErrors({});

    try {
      const itemsObject = cart.reduce((acc, item) => {
        acc[item.id] = {
          name: item.name,
          qty: item.qty,
          price: item.price
        };
        return acc;
      }, {});

      const orderId = await placeOrder({
        name: formData.name.trim(),
        blockDoor: formData.blockDoor.trim(),
        mobile: formData.mobile.trim(),
        items: itemsObject,
        total
      });

      // Store orderId in localStorage for session-based tracking
      localStorage.setItem('lastOrderId', orderId);

      recordOrderPlacement();
      setSuccessMessage(`Order placed successfully! Track your order at the bottom.`);
      clearCart();
      setFormData({ name: '', blockDoor: '', mobile: '' });

      setTimeout(() => {
        onSuccess();
      }, 2000);
    } catch (error) {
      console.error('Error placing order:', error);
      setErrors({ general: 'Failed to place order. Please try again.' });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) {
    return null;
  }

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="modal-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            style={{ zIndex: 1001 }}
          />

          {/* Modal */}
          <motion.div
            className="modal checkout-modal"
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.9, opacity: 0 }}
            style={{ zIndex: 1002 }}
          >
            <div className="modal-header">
              <h2>
                <i className="bi bi-box-seam"></i> Checkout
              </h2>
              <button className="close-btn" onClick={onClose} aria-label="Close checkout">
                <i className="bi bi-x-lg"></i>
              </button>
            </div>

            <div className="modal-body">
              {successMessage ? (
                <div className="success-message">
                  <i className="bi bi-check-circle-fill"></i>
                  <p>{successMessage}</p>
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="checkout-form">
                  <div className="form-group">
                    <label htmlFor="name">
                      <i className="bi bi-person"></i> Full Name
                    </label>
                    <input
                      type="text"
                      id="name"
                      name="name"
                      value={formData.name}
                      onChange={handleChange}
                      placeholder="Enter your name"
                      disabled={isSubmitting}
                      autoComplete="name"
                    />
                    {errors.name && <span className="error-text">{errors.name}</span>}
                  </div>

                  <div className="form-group">
                    <label htmlFor="blockDoor">
                      <i className="bi bi-building"></i> Block & Door No.
                    </label>
                    <input
                      type="text"
                      id="blockDoor"
                      name="blockDoor"
                      value={formData.blockDoor}
                      onChange={handleChange}
                      placeholder="e.g., B-4, 102"
                      disabled={isSubmitting}
                    />
                    {errors.blockDoor && <span className="error-text">{errors.blockDoor}</span>}
                  </div>

                  <div className="form-group">
                    <label htmlFor="mobile">
                      <i className="bi bi-phone"></i> Mobile Number
                    </label>
                    <input
                      type="tel"
                      id="mobile"
                      name="mobile"
                      value={formData.mobile}
                      onChange={handleChange}
                      placeholder="10-digit mobile number"
                      disabled={isSubmitting}
                      autoComplete="tel"
                    />
                    {errors.mobile && <span className="error-text">{errors.mobile}</span>}
                  </div>

                  {errors.general && (
                    <div className="error-message">
                      <i className="bi bi-exclamation-circle"></i>
                      <span>{errors.general}</span>
                    </div>
                  )}

                  <div className="order-summary">
                    <h3>Order Summary</h3>
                    <div className="summary-items">
                      {cart.map((item) => (
                        <div key={item.id} className="summary-item">
                          <span>{item.name} × {item.qty}</span>
                          <span>₹{item.price * item.qty}</span>
                        </div>
                      ))}
                    </div>
                    <div className="summary-total">
                      <strong>Total</strong>
                      <strong>₹{total}</strong>
                    </div>
                  </div>

                  <button
                    type="submit"
                    className="place-order-btn"
                    disabled={isSubmitting}
                  >
                    {isSubmitting ? (
                      <>
                        <i className="bi bi-hourglass-split"></i> Placing Order...
                      </>
                    ) : (
                      <>
                        <i className="bi bi-check-circle"></i> Place Order
                      </>
                    )}
                  </button>

                  <p className="checkout-note">
                    <i className="bi bi-info-circle"></i> Payment will be collected on delivery
                  </p>
                </form>
              )}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

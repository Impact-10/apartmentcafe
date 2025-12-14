import { useState, useEffect } from 'react';
import { ref, onValue, off } from 'firebase/database';
import { db } from '../lib/firebase';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * OrderTracker Component
 * Session-based order tracking using localStorage
 * Shows live order status updates at bottom of page
 */
export default function OrderTracker() {
  const [orderStatus, setOrderStatus] = useState(null);
  const [isVisible, setIsVisible] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);

  useEffect(() => {
    // Check if there's an active order in localStorage
    const lastOrderId = localStorage.getItem('lastOrderId');
    
    if (!lastOrderId) {
      return;
    }

    // Subscribe to order updates (real-time)
    const orderRef = ref(db, `orders/${lastOrderId}`);
    
    const unsubscribe = onValue(orderRef, (snapshot) => {
      const data = snapshot.val();
      
      if (!data) {
        // Order not found (likely moved to history)
        localStorage.removeItem('lastOrderId');
        setOrderStatus(null);
        setIsVisible(false);
        document.body.classList.remove('has-tracker');
        return;
      }

      setOrderStatus({
        id: lastOrderId,
        status: data.status,
        name: data.name
      });
      setIsVisible(true);
      document.body.classList.add('has-tracker');

      // If delivered, clean up after showing for 5 seconds
      if (data.status === 'delivered') {
        setTimeout(() => {
          localStorage.removeItem('lastOrderId');
          setIsVisible(false);
          setOrderStatus(null);
          document.body.classList.remove('has-tracker');
        }, 5000);
      }
    });

    // Cleanup listener on unmount
    return () => {
      off(orderRef);
      unsubscribe();
      document.body.classList.remove('has-tracker');
    };
  }, []);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    const lastOrderId = localStorage.getItem('lastOrderId');
    
    if (!lastOrderId) {
      setIsRefreshing(false);
      return;
    }

    // Force re-fetch from Firebase
    const orderRef = ref(db, `orders/${lastOrderId}`);
    const snapshot = await new Promise((resolve) => {
      onValue(orderRef, resolve, { onlyOnce: true });
    });
    
    const data = snapshot.val();
    
    if (!data) {
      localStorage.removeItem('lastOrderId');
      setOrderStatus(null);
      setIsVisible(false);
      document.body.classList.remove('has-tracker');
    } else {
      setOrderStatus({
        id: lastOrderId,
        status: data.status,
        name: data.name
      });
    }
    
    setTimeout(() => setIsRefreshing(false), 500);
  };

  if (!isVisible || !orderStatus) {
    return null;
  }

  const getStatusInfo = (status) => {
    switch (status) {
      case 'pending':
        return {
          icon: 'bi-clock-history',
          text: 'Order Placed',
          color: '#FF6B35',
          progress: 33
        };
      case 'accepted':
        return {
          icon: 'bi-check-circle',
          text: 'Accepted - Preparing',
          color: '#FFA726',
          progress: 66
        };
      case 'delivered':
        return {
          icon: 'bi-check-circle-fill',
          text: 'Delivered!',
          color: '#4CAF50',
          progress: 100
        };
      default:
        return {
          icon: 'bi-clock',
          text: 'Processing',
          color: '#999',
          progress: 0
        };
    }
  };

  const statusInfo = getStatusInfo(orderStatus.status);

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          className="order-tracker"
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30 }}
        >
          <div className="tracker-content">
            <div className="tracker-icon">
              <i className={`bi ${statusInfo.icon}`} style={{ color: statusInfo.color }}></i>
            </div>
            
            <div className="tracker-info">
              <div className="tracker-title">Order #{orderStatus.id.slice(-6)}</div>
              <div className="tracker-status">{statusInfo.text}</div>
            </div>

            <div className="tracker-progress">
              <div className="progress-bar">
                <motion.div
                  className="progress-fill"
                  style={{ backgroundColor: statusInfo.color }}
                  initial={{ width: 0 }}
                  animate={{ width: `${statusInfo.progress}%` }}
                  transition={{ duration: 0.5 }}
                />
              </div>
            </div>

            <button 
              className="tracker-refresh-btn"
              onClick={handleRefresh}
              disabled={isRefreshing}
              title="Refresh order status"
            >
              <i className={`bi bi-arrow-clockwise ${isRefreshing ? 'spinning' : ''}`}></i>
            </button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

import { useEffect, useMemo, useState } from 'react';
import { signOut } from 'firebase/auth';
import { ref, update, get } from 'firebase/database';
import { auth, db } from '../lib/firebase';
import {
  adminUpdateStatus,
  archiveOrder,
  listenOrdersPending,
  listenOrdersAccepted,
  listenOrdersDelivered
} from '../lib/ordersRTDB';
import { useMenuRTDB } from '../hooks/useMenuRTDB';
import { motion } from 'framer-motion';

export default function AdminOrders({ user }) {
  const [pending, setPending] = useState([]);
  const [accepted, setAccepted] = useState([]);
  const [delivered, setDelivered] = useState([]);
  const [processing, setProcessing] = useState(new Set());
  const { allMenu, loading: menuLoading } = useMenuRTDB();

  useEffect(() => {
    const stopPending = listenOrdersPending(setPending);
    const stopAccepted = listenOrdersAccepted(setAccepted);
    const stopDelivered = listenOrdersDelivered(setDelivered);
    
    return () => {
      stopPending();
      stopAccepted();
      stopDelivered();
    };
  }, []);

  const menuById = useMemo(() => {
    const map = new Map();
    allMenu.forEach((item) => map.set(item.id, item));
    return map;
  }, [allMenu]);

  const handleStatusChange = async (orderId, newStatus) => {
    setProcessing((prev) => new Set(prev).add(orderId));
    try {
      await adminUpdateStatus(orderId, newStatus);
      
      // If status changed to delivered, archive after brief delay
      if (newStatus === 'delivered') {
        setTimeout(async () => {
          try {
            // Fetch the order data before archiving
            const orderRef = ref(db, `orders/${orderId}`);
            const snapshot = await get(orderRef);
            if (snapshot.exists()) {
              await archiveOrder(orderId, snapshot.val());
            }
          } catch (err) {
            console.error('Failed to archive order:', err);
          }
        }, 3000); // 3 second delay before archiving
      }
    } catch (err) {
      alert(err.message || 'Failed to update order');
    } finally {
      setProcessing((prev) => {
        const next = new Set(prev);
        next.delete(orderId);
        return next;
      });
    }
  };

  const handleToggleMenu = async (itemId, enabled) => {
    setProcessing((prev) => new Set(prev).add(itemId));
    try {
      await update(ref(db, `menu/${itemId}`), { enabled });
    } catch (err) {
      alert(err.message || 'Failed to update menu');
    } finally {
      setProcessing((prev) => {
        const next = new Set(prev);
        next.delete(itemId);
        return next;
      });
    }
  };

  const formatTime = (value) => {
    if (!value) return '—';
    const date = new Date(value);
    return date.toLocaleString('en-IN', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="admin-panel">
      <div className="admin-header">
        <div>
          <h1><i className="bi bi-shield-check"></i> Admin</h1>
          <p className="admin-sub">Signed in as {user.email}</p>
        </div>
        <button className="secondary-btn" onClick={() => signOut(auth)}>
          <i className="bi bi-box-arrow-right"></i> Sign out
        </button>
      </div>

      <div className="admin-content">
        {/* Pending Orders Section */}
        <section className="orders-section">
          <h2><i className="bi bi-clock-history"></i> Pending ({pending.length})</h2>
          {pending.length === 0 ? (
            <div className="empty-state">
              <i className="bi bi-inbox"></i>
              <p>No pending orders</p>
            </div>
          ) : (
            <div className="orders-list">
              {pending.map((order) => (
                <motion.div
                  key={order.id}
                  className="order-card"
                  layout
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                >
                  <div className="order-header">
                    <div>
                      <h3>{order.name}</h3>
                      <p className="order-meta">
                        <i className="bi bi-building"></i> {order.blockDoor}
                        <span className="divider">•</span>
                        <i className="bi bi-phone"></i> {order.mobile}
                      </p>
                    </div>
                    <span className="status-badge status-pending">pending</span>
                  </div>

                  <div className="order-items">
                    {order.items && Object.entries(order.items).map(([id, item]) => (
                      <div key={id} className="order-item">
                        <span>{item.name} × {item.qty}</span>
                        <span>₹{item.price * item.qty}</span>
                      </div>
                    ))}
                  </div>

                  <div className="order-footer">
                    <div className="order-total">
                      <strong>Total: ₹{order.total}</strong>
                      <span className="order-time">{formatTime(order.createdAt)}</span>
                    </div>
                    <button
                      className="action-btn accept-btn"
                      onClick={() => handleStatusChange(order.id, 'accepted')}
                      disabled={processing.has(order.id)}
                    >
                      {processing.has(order.id) ? 'Updating...' : 'Accept'}
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>

        {/* Accepted Orders Section */}
        <section className="orders-section">
          <h2><i className="bi bi-check-circle"></i> Accepted ({accepted.length})</h2>
          {accepted.length === 0 ? (
            <div className="empty-state">
              <i className="bi bi-inbox"></i>
              <p>No accepted orders</p>
            </div>
          ) : (
            <div className="orders-list">
              {accepted.map((order) => (
                <motion.div
                  key={order.id}
                  className="order-card"
                  layout
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                >
                  <div className="order-header">
                    <div>
                      <h3>{order.name}</h3>
                      <p className="order-meta">
                        <i className="bi bi-building"></i> {order.blockDoor}
                        <span className="divider">•</span>
                        <i className="bi bi-phone"></i> {order.mobile}
                      </p>
                    </div>
                    <span className="status-badge status-accepted">accepted</span>
                  </div>

                  <div className="order-items">
                    {order.items && Object.entries(order.items).map(([id, item]) => (
                      <div key={id} className="order-item">
                        <span>{item.name} × {item.qty}</span>
                        <span>₹{item.price * item.qty}</span>
                      </div>
                    ))}
                  </div>

                  <div className="order-footer">
                    <div className="order-total">
                      <strong>Total: ₹{order.total}</strong>
                      <span className="order-time">{formatTime(order.acceptedAt || order.createdAt)}</span>
                    </div>
                    <button
                      className="action-btn deliver-btn"
                      onClick={() => handleStatusChange(order.id, 'delivered')}
                      disabled={processing.has(order.id)}
                    >
                      {processing.has(order.id) ? 'Updating...' : 'Mark Delivered'}
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>

        {/* Delivered Orders Section */}
        <section className="orders-section">
          <h2><i className="bi bi-check-circle-fill"></i> Delivered ({delivered.length})</h2>
          {delivered.length === 0 ? (
            <div className="empty-state">
              <i className="bi bi-inbox"></i>
              <p>No delivered orders yet</p>
            </div>
          ) : (
            <div className="orders-list compact">
              {delivered.map((order) => (
                <motion.div
                  key={order.id}
                  className="order-row delivered"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                >
                  <div>
                    <strong>{order.name}</strong>
                    <span className="small-meta"> {order.blockDoor} • {order.mobile}</span>
                  </div>
                  <div className="order-row-meta">
                    <span className="status-pill status-delivered">delivered</span>
                    <span>₹{order.total}</span>
                    <span className="small-meta">{formatTime(order.deliveredAt || order.createdAt)}</span>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>

        <section className="menu-section-admin">
          <h2><i className="bi bi-card-list"></i> Menu Toggle</h2>
          {menuLoading ? (
            <div className="loading-state">Loading menu...</div>
          ) : allMenu.length === 0 ? (
            <div className="empty-state">Add menu items in RTDB /menu</div>
          ) : (
            <div className="menu-list">
              {allMenu.map((item) => (
                <div key={item.id} className={`menu-item-admin ${item.enabled ? 'enabled' : 'disabled'}`}>
                  <div>
                    <h3>{item.name}</h3>
                    <p className="menu-meta">{item.meal} • ₹{item.price}</p>
                  </div>
                  <button
                    className={`toggle-btn ${item.enabled ? 'enabled' : 'disabled'}`}
                    onClick={() => handleToggleMenu(item.id, !item.enabled)}
                    disabled={processing.has(item.id)}
                  >
                    {processing.has(item.id) ? '...' : item.enabled ? 'Disable' : 'Enable'}
                  </button>
                </div>
              ))}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

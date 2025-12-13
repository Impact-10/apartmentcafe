import {
  equalTo,
  onValue,
  orderByChild,
  push,
  query,
  ref,
  remove,
  set,
  update
} from 'firebase/database';
import { db, serverTimestamp } from './firebase';

// Place new order (always pending state)
export async function placeOrder({ name, blockDoor, mobile, items, total }) {
  const orderRef = ref(db, 'orders');
  const payload = {
    name,
    blockDoor,
    mobile,
    items,
    total,
    status: 'pending',
    createdAt: serverTimestamp()
  };

  const newRef = await push(orderRef, payload);
  return newRef.key;
}

// Admin update order status with validation
// Valid transitions: pending → accepted → delivered
export async function adminUpdateStatus(orderId, newStatus) {
  const orderRef = ref(db, `orders/${orderId}`);
  
  // Validate status values
  const validStatuses = ['pending', 'accepted', 'delivered'];
  if (!validStatuses.includes(newStatus)) {
    throw new Error(`Invalid status: ${newStatus}`);
  }

  const updates = { status: newStatus };
  
  if (newStatus === 'accepted') {
    updates.acceptedAt = serverTimestamp();
  } else if (newStatus === 'delivered') {
    updates.deliveredAt = serverTimestamp();
  }

  await update(orderRef, updates);
}

// Archive delivered order to history and remove from orders
export async function archiveOrder(orderId, orderData) {
  const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
  const historyRef = ref(db, `ordersHistory/${date}/${orderId}`);
  const orderRef = ref(db, `orders/${orderId}`);

  // Write to history
  await set(historyRef, orderData);
  
  // Remove from active orders
  await remove(orderRef);
}

// Listen to orders by status
export function listenOrdersByStatus(status, callback) {
  const statusQuery = query(ref(db, 'orders'), orderByChild('status'), equalTo(status));

  const unsubscribe = onValue(statusQuery, (snapshot) => {
    const data = snapshot.val() || {};
    const orders = Object.entries(data).map(([id, value]) => ({ id, ...value }));

    orders.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
    callback(orders);
  });

  return () => unsubscribe();
}

// Convenience wrappers for each status
export function listenOrdersPending(callback) {
  return listenOrdersByStatus('pending', callback);
}

export function listenOrdersAccepted(callback) {
  return listenOrdersByStatus('accepted', callback);
}

export function listenOrdersDelivered(callback) {
  return listenOrdersByStatus('delivered', callback);
}

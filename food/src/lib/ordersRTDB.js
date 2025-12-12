import {
  equalTo,
  limitToLast,
  onValue,
  orderByChild,
  push,
  query,
  ref,
  update
} from 'firebase/database';
import { db, serverTimestamp } from './firebase';

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

export async function adminAccept(orderId) {
  const orderRef = ref(db, `orders/${orderId}`);
  await update(orderRef, {
    status: 'completed',
    completedAt: serverTimestamp()
  });
}

export function listenOrdersPending(callback) {
  const pendingQuery = query(ref(db, 'orders'), orderByChild('status'), equalTo('pending'));

  const unsubscribe = onValue(pendingQuery, (snapshot) => {
    const data = snapshot.val() || {};
    const orders = Object.entries(data).map(([id, value]) => ({ id, ...value }));

    orders.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
    callback(orders);
  });

  return () => unsubscribe();
}

export function listenOrdersHistory(callback, limit = 20) {
  const historyQuery = query(ref(db, 'orders'), orderByChild('createdAt'), limitToLast(limit));

  const unsubscribe = onValue(historyQuery, (snapshot) => {
    const data = snapshot.val() || {};
    const orders = Object.entries(data).map(([id, value]) => ({ id, ...value }));

    orders.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
    callback(orders);
  });

  return () => unsubscribe();
}

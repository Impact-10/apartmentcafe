import { useEffect, useState } from 'react';
import { onValue, ref } from 'firebase/database';
import { db } from '../lib/firebase';

const mealOrder = { breakfast: 0, lunch: 1, snack: 2, dinner: 3 };

export function useMenuRTDB() {
  const [menu, setMenu] = useState({ breakfast: [], lunch: [], snack: [], dinner: [] });
  const [allMenu, setAllMenu] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const menuRef = ref(db, '/');
    setLoading(true);

    const unsubscribe = onValue(
      menuRef,
      (snapshot) => {
        const data = snapshot.val() || {};
        const grouped = { breakfast: [], lunch: [], snack: [], dinner: [] };
        const flat = [];

        Object.entries(data).forEach(([id, value]) => {
          // Only process items with a price property (valid menu items)
          if (typeof value === 'object' && value !== null && 'price' in value) {
            const item = { id, ...value };
            flat.push(item);
            if (item.enabled) {
              const mealKey = item.meal || 'snack';
              if (grouped[mealKey]) {
                grouped[mealKey].push(item);
              }
            }
          }
        });

        flat.sort((a, b) => {
          const byMeal = (mealOrder[a.meal] ?? 99) - (mealOrder[b.meal] ?? 99);
          if (byMeal !== 0) return byMeal;
          return (a.name || '').localeCompare(b.name || '');
        });

        Object.keys(grouped).forEach((key) => {
          grouped[key].sort((a, b) => (a.name || '').localeCompare(b.name || ''));
        });

        setAllMenu(flat);
        setMenu(grouped);
        setLoading(false);
        setError(null);
      },
      (err) => {
        console.error('Error loading menu from RTDB', err);
        setError(err.message);
        setLoading(false);
      }
    );

    return () => unsubscribe();
  }, []);

  return { menu, allMenu, loading, error };
}

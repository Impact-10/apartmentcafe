import { motion } from 'framer-motion';

export default function Header({ activeMeal, onMealChange }) {
  const meals = [
    { id: 'breakfast', label: 'Breakfast', icon: 'bi-sunrise' },
    { id: 'lunch', label: 'Lunch', icon: 'bi-sun' },
    { id: 'snack', label: 'Evening Snack', icon: 'bi-cup-hot' },
    { id: 'dinner', label: 'Dinner', icon: 'bi-moon-stars' }
  ];

  return (
    <header className="header-clean">
      <div className="container">
        <div className="header-content-clean">
          <div className="header-brand-clean">
            <i className="bi bi-cup-hot-fill"></i>
            <div className="brand-text">
              <h1>Apartment Café</h1>
              <p>Culinary Excellence</p>
            </div>
          </div>
        </div>
        
        <nav className="meal-tabs-clean">
          {meals.map((meal) => (
            <motion.button
              key={meal.id}
              className={`meal-tab-clean ${activeMeal === meal.id ? 'active' : ''}`}
              onClick={() => onMealChange(meal.id)}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.98 }}
            >
              <i className={`bi ${meal.icon}`}></i>
              <span>{meal.label}</span>
            </motion.button>
          ))}
        </nav>
      </div>
    </header>
  );
}

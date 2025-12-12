import ItemCard from './ItemCard';
import { motion } from 'framer-motion';

export default function MenuSection({ title, items, icon }) {
  if (!items || items.length === 0) {
    return (
      <div className="empty-menu">
        <i className={`bi ${icon}`}></i>
        <p>No {title.toLowerCase()} items available</p>
      </div>
    );
  }

  return (
    <motion.div
      className="menu-section"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      <div className="section-header">
        <h2>{title}</h2>
        <span className="item-count">{items.length} dishes</span>
      </div>

      <div className="menu-items-container">
        {items.map((item, index) => (
          <ItemCard key={item.id} item={item} index={index} />
        ))}
      </div>
    </motion.div>
  );
}

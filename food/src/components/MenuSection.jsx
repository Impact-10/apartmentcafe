import ScrollStack from './ScrollStack';
import ItemCard from './ItemCard';
import { motion } from 'framer-motion';

export default function MenuSection({ title, items, icon }) {
  if (!items || items.length === 0) {
    return (
      <div className="empty-menu-stack">
        <i className={`bi ${icon}`}></i>
        <p>No {title.toLowerCase()} items available</p>
      </div>
    );
  }

  return (
    <motion.div
      className="menu-section-stack"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      <div className="section-header-stack">
        <h2>{title}</h2>
        <span className="item-count-stack">{items.length} dishes</span>
      </div>

      <ScrollStack
        className="scroll-stack-menu"
        itemDistance={60}
        itemStackDistance={25}
        itemScale={0.04}
        baseScale={0.88}
        stackPosition="15%"
        scaleEndPosition="8%"
        useWindowScroll={true}
      >
        {items.map((item, index) => (
          <ItemCard key={item.id} item={item} index={index} />
        ))}
      </ScrollStack>
    </motion.div>
  );
}

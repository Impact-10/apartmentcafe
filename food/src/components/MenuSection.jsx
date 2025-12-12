import ScrollStackWrapper from './ScrollStackWrapper';
import ItemCard from './ItemCard';

/**
 * MenuSection component
 * Displays a section of menu items for a specific meal type
 */
export default function MenuSection({ title, items, icon }) {
  if (!items || items.length === 0) {
    return null;
  }

  return (
    <section className="menu-section" id={title.toLowerCase().replace(/\s+/g, '-')}>
      <div className="section-header">
        <i className={`bi ${icon}`}></i>
        <h2 className="section-title">{title}</h2>
        <span className="item-count">{items.length} items</span>
      </div>
      
      <ScrollStackWrapper className="menu-grid">
        {items.map((item) => (
          <ItemCard key={item.id} item={item} />
        ))}
      </ScrollStackWrapper>
    </section>
  );
}

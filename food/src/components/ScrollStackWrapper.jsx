import { useEffect, useRef } from 'react';

/**
 * ScrollStack Wrapper Component
 * Uses reactbits.dev ScrollStack pattern for scroll-based animations
 * You can integrate the actual ScrollStack from reactbits.dev later
 */
export default function ScrollStackWrapper({ children, className = '' }) {
  const containerRef = useRef(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('scroll-stack-visible');
          }
        });
      },
      {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
      }
    );

    const items = container.querySelectorAll('.scroll-stack-item');
    items.forEach((item) => observer.observe(item));

    return () => observer.disconnect();
  }, [children]);

  return (
    <div ref={containerRef} className={`scroll-stack-container ${className}`}>
      {children}
    </div>
  );
}

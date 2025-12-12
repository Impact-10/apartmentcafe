# UI Responsiveness Guide - Apartment Café

## Breakpoints Summary

### 📱 Mobile Devices (< 480px)
**Layout**: Vertical Stack Cards
- **Card Layout**: Single column (100% width)
- **Image**: Full width, 200px height (above content)
- **Header**: 1.5rem font
- **Buttons**: 100% width, 48px+ height (touch-friendly)
- **Tabs**: Horizontal scroll with 0.6rem gap

**Use Cases**: iPhone SE, older Android phones

### 📱 Medium Mobile (480px - 768px)
**Layout**: Horizontal Cards
- **Card Layout**: 260px image | flexible content
- **Image**: 260×200px (fixed, left side)
- **Header**: 1.8rem font
- **Buttons**: Responsive sizing
- **Tabs**: Scrollable on demand

**Use Cases**: iPhone 8-14, standard Android phones

### 📱 Tablet (768px - 1024px)
**Layout**: Horizontal Cards (Optimized)
- **Card Layout**: 280px image | flexible content
- **Image**: 280×220px (fixed, left side)
- **Header**: 2rem font
- **Buttons**: Full width on mobile, inline on larger
- **Tabs**: All visible in one line

**Use Cases**: iPad Mini, standard tablets

### 🖥️ Desktop (1024px - 1440px)
**Layout**: Horizontal Cards (Full)
- **Card Layout**: 300px image | flexible content
- **Image**: 300×240px (fixed, left side)
- **Header**: 2rem font
- **Buttons**: Proper spacing with ripple effect
- **Container**: Optimal readability

**Use Cases**: Standard laptops, desktop monitors

### 🖥️ Large Desktop (1441px+)
**Layout**: Horizontal Cards (Premium)
- **Container**: Max-width 1400px, centered
- **Image**: 300×240px
- **Spacing**: Maximum comfortable margins
- **Typography**: Full readability with proper line-height

**Use Cases**: Large monitors, cinema displays

## Responsive Features

### Card Scaling
| Size | Image | Padding | Gap | Font (Title) |
|------|-------|---------|-----|--------------|
| XS (480px) | 100% h:200 | 1.5rem | 1.5rem | 1.2rem |
| SM (768px) | 260×200 | 1.8rem | 2rem | 1.4rem |
| MD (1024px) | 280×220 | 2rem | 2.5rem | 1.6rem |
| LG (1440px) | 300×240 | 3rem | 3rem | 1.8rem |

### Typography Scaling
```
Mobile (480px):      1.2rem title
Tablet (768px):      1.4rem title
Tablet (1024px):     1.6rem title
Desktop (1440px+):   1.8rem title
```

### Button Responsiveness
- **Mobile (< 768px)**: 100% width, full padding
- **Tablet+**: Inline with flex layout, responsive padding

### Touch Optimization
- **Button height**: Minimum 48px for touch targets
- **Tab spacing**: 0.6rem on mobile, 1.5rem on desktop
- **Modal**: 95vh max-height on mobile, proper overflow

## Performance Notes

### GPU-Accelerated Animations
- ScrollStack cards use `transform: translateZ(0)` for 60fps scrolling
- Button hover effects use `transform` (GPU-accelerated)
- No blur filters on scroll (performance optimization)

### Will-Change Optimization
- Selective `will-change` declarations (only on interactive elements)
- No `will-change: transform, opacity` (causes paint thrashing)
- Focus on `will-change: background, box-shadow, transform` for buttons

### Reduced Motion Support
- Respects `prefers-reduced-motion: reduce`
- 60fps animations enabled for users with no motion preference
- Smooth scrolling via Lenis library

## Mobile-First CSS Strategy
1. **Base styles**: Mobile optimized (480px)
2. **@media (max-width: 768px)**: Medium mobile adjustments
3. **@media (max-width: 1024px)**: Tablet refinements
4. **@media (min-width: 1441px)**: Desktop enhancements
5. **@media (hover: none) and (pointer: coarse)**: Touch devices
6. **@media (max-height: 600px)**: Landscape mode optimization
7. **@media (prefers-reduced-motion)**: Accessibility considerations

## Testing Checklist

- [ ] **Mobile XS (320-480px)**: Vertical layout, full-width elements
- [ ] **Mobile S (480-768px)**: Horizontal cards, responsive sizing
- [ ] **Tablet (768-1024px)**: Optimized card sizing, all tabs visible
- [ ] **Desktop (1024-1440px)**: Full horizontal layout with proper spacing
- [ ] **Large Desktop (1440px+)**: Maximum readability and comfort
- [ ] **Landscape Mobile**: Proper header and modal sizing
- [ ] **Touch Devices**: 48px+ button targets, tap feedback
- [ ] **Slow Networks**: No render blocking, progressive enhancement
- [ ] **Scroll Performance**: 60fps smooth scrolling without jank
- [ ] **Button Hover**: Ripple effect visible without blur artifacts

## Browser Support
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers with CSS Grid, Flexbox, and CSS Variables support

---
**Last Updated**: Performance optimization completed - removed 270+ lines of conflicting old responsive CSS

# 🤝 Contributing to Apartment Café

Thank you for your interest in contributing! This guide will help you get started.

## 🎯 How You Can Contribute

- 🐛 Report bugs
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit code fixes
- 🎨 Enhance UI/UX
- ✅ Write tests
- 🌍 Add translations

## 🚀 Getting Started

### 1. Fork & Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/apartment-cafe.git
cd apartment-cafe
```

### 2. Set Up Development Environment

```bash
# Install dependencies
npm install
cd functions && npm install && cd ..

# Copy environment variables
cp .env.example .env
# Edit .env with your Firebase config

# Start development server
npm run dev
```

### 3. Create a Branch

```bash
# For features
git checkout -b feature/your-feature-name

# For bug fixes
git checkout -b fix/bug-description

# For documentation
git checkout -b docs/improvement-description
```

## 📋 Development Guidelines

### Code Style

We use ESLint and Prettier for code formatting:

```bash
# Format code
npm run format

# Lint code
npm run lint

# Fix lint issues
npm run lint:fix
```

### Component Structure

```jsx
import { useState } from 'react';
import PropTypes from 'prop-types';

/**
 * Component description
 * @param {Object} props - Component props
 */
function MyComponent({ prop1, prop2 }) {
  const [state, setState] = useState(initialValue);

  // Helper functions
  const handleAction = () => {
    // Implementation
  };

  return (
    <div className="my-component">
      {/* JSX */}
    </div>
  );
}

MyComponent.propTypes = {
  prop1: PropTypes.string.isRequired,
  prop2: PropTypes.number
};

export default MyComponent;
```

### File Naming

- Components: `PascalCase.jsx`
- Hooks: `useCamelCase.js`
- Utils: `camelCase.js`
- Styles: `kebab-case.css`

### CSS Guidelines

```css
/* Use CSS variables for colors */
.my-component {
  color: var(--text-primary);
  background: var(--bg-primary);
}

/* Mobile-first approach */
.my-component {
  /* Base styles for mobile */
}

@media (min-width: 768px) {
  .my-component {
    /* Tablet styles */
  }
}

@media (min-width: 1024px) {
  .my-component {
    /* Desktop styles */
  }
}
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Feature
git commit -m "feat: add order history for customers"

# Bug fix
git commit -m "fix: resolve cart not updating issue"

# Documentation
git commit -m "docs: update setup instructions"

# Style
git commit -m "style: format code with prettier"

# Refactor
git commit -m "refactor: simplify checkout logic"

# Test
git commit -m "test: add cart functionality tests"

# Chore
git commit -m "chore: update dependencies"
```

## 🧪 Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] Customer flow (browse, cart, checkout)
- [ ] Admin flow (orders, menu management)
- [ ] Mobile responsive design
- [ ] Real-time updates work
- [ ] Form validations
- [ ] Error states
- [ ] Loading states

### Testing Cloud Functions Locally

```bash
# Install Firebase emulator
npm install -g firebase-tools

# Start emulator
firebase emulators:start

# Test in your app by updating .env:
VITE_FUNCTIONS_BASE_URL=http://localhost:5001/your-project-id/us-central1
```

## 📝 Pull Request Process

### 1. Update Your Branch

```bash
# Sync with main branch
git checkout main
git pull origin main
git checkout your-branch
git rebase main
```

### 2. Push Your Changes

```bash
git push origin your-branch
```

### 3. Create Pull Request

On GitHub:
1. Go to your fork
2. Click "Pull Request"
3. Fill in the PR template

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
Describe how you tested your changes

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tested on mobile
```

## 🐛 Reporting Bugs

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Screenshots
If applicable

## Environment
- OS: [e.g., Windows 11]
- Browser: [e.g., Chrome 120]
- Device: [e.g., Desktop]
- App Version: [e.g., 1.0.0]

## Additional Context
Any other relevant information
```

## 💡 Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the feature

## Problem It Solves
What problem does this solve?

## Proposed Solution
How would you implement it?

## Alternatives Considered
Other solutions you've thought about

## Additional Context
Mockups, examples, etc.
```

## 🎨 UI/UX Contributions

### Design Guidelines

- Follow existing color scheme (CSS variables)
- Use Bootstrap Icons for consistency
- Maintain mobile-first approach
- Ensure accessibility (ARIA labels, keyboard navigation)
- Test on multiple screen sizes

### Adding New Components

1. Create component in `src/components/`
2. Add JSDoc comments
3. Export from component file
4. Add CSS to `src/styles.css` or component-specific file
5. Update documentation

## 📚 Documentation

### Documentation Standards

- Use clear, concise language
- Include code examples
- Add screenshots for visual features
- Keep README.md up to date
- Document all environment variables
- Explain complex logic with comments

### Adding Documentation

- Main docs: Edit `README.md`
- Quick setup: Edit `QUICKSTART.md`
- Contributing: Edit this file
- Component docs: Add JSDoc to components

## 🔐 Security

### Security Guidelines

- Never commit `.env` files
- Never commit Firebase service keys
- Use environment variables for secrets
- Follow Firebase security best practices
- Validate all user inputs
- Sanitize data before Firestore writes

### Reporting Security Issues

For security issues, **DO NOT** create a public GitHub issue.

Email: [your-security-email@domain.com]

Include:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## 🌍 Internationalization

### Adding Translations

1. Create translation file: `src/i18n/[locale].json`
2. Use translation hook in components
3. Test with different locales
4. Update documentation

Example structure:
```json
{
  "header": {
    "title": "Apartment Café",
    "tagline": "Fresh daily meals"
  },
  "menu": {
    "breakfast": "Breakfast",
    "lunch": "Lunch"
  }
}
```

## 📦 Dependencies

### Adding Dependencies

```bash
# For production
npm install package-name

# For development
npm install -D package-name

# Explain why in PR description
```

### Updating Dependencies

```bash
# Check for updates
npm outdated

# Update dependencies
npm update

# Test thoroughly after updates
npm test
```

## 🚀 Release Process

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

### Creating a Release

1. Update version in `package.json`
2. Update CHANGELOG.md
3. Create git tag: `git tag v1.2.3`
4. Push tag: `git push origin v1.2.3`
5. Deploy to production

## 💬 Communication

### Where to Ask Questions

- GitHub Issues: Feature requests, bugs
- GitHub Discussions: General questions
- Pull Request Comments: Code-specific questions

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn
- Focus on the code, not the person
- Assume good intentions

## 🎓 Learning Resources

### Recommended Reading

- [React Documentation](https://react.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Framer Motion Docs](https://www.framer.com/motion/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

### Project Architecture

```
Customer Flow:
1. Browse menu (real-time Firestore listener)
2. Add to cart (React Context)
3. Checkout (form validation)
4. Place order (Firestore write)

Admin Flow:
1. View orders (real-time listener)
2. Manage orders (Cloud Function call)
3. Toggle menu (Cloud Function call)

Security:
- Firestore rules prevent client writes
- Cloud Functions validate admin secret
- All admin actions server-side
```

## ✅ Checklist for Contributors

Before submitting:

- [ ] Code follows project style
- [ ] Tested locally
- [ ] Tested on mobile
- [ ] No console errors
- [ ] Documentation updated
- [ ] Comments added
- [ ] Commit messages follow convention
- [ ] Branch is up to date
- [ ] PR description is clear

## 🙏 Thank You!

Every contribution makes this project better. Whether it's code, documentation, bug reports, or feature ideas - we appreciate your time and effort!

---

**Happy coding!** 🚀

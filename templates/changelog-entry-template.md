# Changelog Entry Template

Use this template for consistent changelog entries across all projects.

## Format

```markdown
### YYYY-MM-DD - [SEVERITY] Brief Description

**Severity Levels**:
- **[MAJOR]** - Breaking changes, major refactors, complete rewrites
- **[MINOR]** - New features, enhancements, non-breaking improvements
- **[PATCH]** - Bug fixes, documentation updates, minor tweaks

**Changes**:
- Specific change with file references (e.g., Updated `src/main.js:45-67`)
- Another change with context
- Third change with impact noted

**Impact**:
- How this affects users/developers
- Performance implications
- Compatibility notes

**Files Modified**:
- `path/to/file1.ext` - Brief description of changes
- `path/to/file2.ext` - Brief description of changes
- `path/to/file3.ext` - Brief description of changes

**Testing**:
- Tests added/updated
- Manual testing performed
- Edge cases considered

**Dependencies**:
- New dependencies added
- Dependencies updated
- Dependencies removed

**Migration Notes** (if applicable):
- Steps users need to take
- Backwards compatibility information
- Deprecation warnings

**Related Issues**: #123, #456
**Related PRs**: #789
```

## Examples

### Example 1: Major Feature Addition

```markdown
### 2025-11-14 - [MINOR] Add AI-powered code review system

**Changes**:
- Implemented OpenAI GPT-4 integration for automated code reviews in `src/ai/reviewer.js`
- Added configuration options for AI preferences in `config/ai.json`
- Created new UI components for review feedback display in `components/ReviewPanel.jsx`

**Impact**:
- Reduces code review time by 40%
- Provides consistent code quality checks
- Requires OpenAI API key configuration

**Files Modified**:
- `src/ai/reviewer.js` - Core AI review logic
- `config/ai.json` - Configuration schema
- `components/ReviewPanel.jsx` - UI components
- `tests/ai/reviewer.test.js` - Comprehensive test suite

**Testing**:
- Added 25 unit tests for AI reviewer
- Tested with 100+ real code samples
- Verified rate limiting and error handling

**Dependencies**:
- Added: openai@4.20.0
- Added: react-markdown@9.0.0

**Migration Notes**:
- Add `OPENAI_API_KEY` to environment variables
- Run `npm install` to install new dependencies
- Optional: Configure AI preferences in Settings > AI Review
```

### Example 2: Critical Bug Fix

```markdown
### 2025-11-14 - [PATCH] Fix memory leak in background worker

**Changes**:
- Fixed event listener cleanup in `workers/background.js:156-178`
- Added proper garbage collection triggers
- Implemented memory monitoring alerts

**Impact**:
- Prevents application crash after 24+ hours of use
- Reduces memory footprint by 60%
- Improves overall application stability

**Files Modified**:
- `workers/background.js` - Fixed listener cleanup
- `utils/memory.js` - Added monitoring utilities
- `tests/workers/background.test.js` - Added memory leak tests

**Testing**:
- Added specific memory leak detection tests
- Ran 48-hour stress test successfully
- Verified fix with memory profiler

**Related Issues**: #523, #551, #559
```

### Example 3: Breaking Change

```markdown
### 2025-11-14 - [MAJOR] Migrate to ESM modules

**Changes**:
- Converted entire codebase from CommonJS to ESM
- Updated all import/export statements
- Modified build configuration for ESM support

**Impact**:
- **BREAKING**: Requires Node.js 16+ (previously 14+)
- **BREAKING**: Changes import syntax for consumers
- Improves tree-shaking and bundle size (20% reduction)

**Files Modified**:
- All `.js` files - Converted to ESM syntax
- `package.json` - Added "type": "module"
- `webpack.config.js` - Updated for ESM
- `tsconfig.json` - Modified module resolution

**Migration Notes**:
- Update Node.js to version 16 or higher
- Change require() to import statements:
  ```javascript
  // Before
  const module = require('module')
  // After
  import module from 'module'
  ```
- Update any dynamic imports to use ESM syntax
- Run `npm run migrate:esm` for automated conversion help

**Related PRs**: #234
```

## Best Practices

1. **Be Specific**: Include file paths and line numbers when relevant
2. **Focus on Impact**: Explain WHY, not just WHAT changed
3. **Include Context**: Reference issues, PRs, and discussions
4. **Testing Details**: Document what was tested and how
5. **Migration Path**: Always provide clear upgrade instructions for breaking changes
6. **Semantic Versioning**: Choose the correct severity level
7. **Chronological Order**: Latest entries at the top
8. **Group Related Changes**: If multiple changes are part of one feature, group them
9. **Credit Contributors**: Mention who contributed (for team projects)
10. **Keep It Scannable**: Use consistent formatting and clear headers
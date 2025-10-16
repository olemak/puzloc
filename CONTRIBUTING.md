# Contributing to Puzloc

Thank you for your interest in contributing to Puzloc! This document provides guidelines and instructions for contributing to this project.

## Getting Started

1. **Read the Documentation**
   - [README.md](./README.md) - Project overview
   - [GETTING_STARTED.md](./docs/GETTING_STARTED.md) - Setup instructions
   - [ARCHITECTURE.md](./docs/ARCHITECTURE.md) - System architecture
   - [GAME_RULES.md](./docs/GAME_RULES.md) - Game mechanics

2. **Set Up Your Environment**
   - Follow the [Getting Started Guide](./docs/GETTING_STARTED.md)
   - Ensure all tests pass before making changes
   - Familiarize yourself with the codebase structure

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or modifications
- `chore/` - Maintenance tasks

### 2. Make Your Changes

- Write clear, readable code
- Follow existing code style
- Add tests for new functionality
- Update documentation as needed
- Keep commits focused and atomic

### 3. Write Good Commit Messages

Format:
```
type(scope): brief description

Longer explanation if needed

Fixes #123
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance

Examples:
```
feat(numlock): add difficulty selection for challenges

fix(auth): resolve token refresh race condition

docs(api): update authentication endpoint documentation

test(phraselock): add tests for letter reveal logic
```

### 4. Run Tests

```bash
# Run all tests
npm test

# Run specific tests
cd apps/backend && dotnet test
cd apps/frontend-svelte && npm test
cd packages/game-engine && npm test

# Run linting
npm run lint
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Reference to related issues
- Screenshots/GIFs for UI changes
- Test results

## Code Style

### TypeScript/JavaScript

- Use TypeScript for all new code
- Follow ESLint configuration
- Use Prettier for formatting
- Prefer functional programming patterns
- Use meaningful variable names

```typescript
// Good
const calculateNumLockScore = (attempts: number, timeMs: number): number => {
  const baseScore = 1000;
  const attemptPenalty = (attempts - 1) * 100;
  return baseScore - attemptPenalty;
};

// Bad
const calc = (a, t) => {
  return 1000 - (a - 1) * 100;
};
```

### C# (.NET)

- Follow Microsoft C# conventions
- Use PascalCase for classes and methods
- Use camelCase for parameters and local variables
- Use async/await for asynchronous operations
- Add XML documentation comments for public APIs

```csharp
// Good
public class GameService
{
    /// <summary>
    /// Validates a NumLock guess against the solution
    /// </summary>
    public async Task<GuessResult> ValidateGuessAsync(string guess, string solution)
    {
        // Implementation
    }
}

// Bad
public class gameservice
{
    public GuessResult validate_guess(string g, string s)
    {
        // Implementation
    }
}
```

### Svelte Components

- One component per file
- Use TypeScript in script blocks
- Keep components focused and reusable
- Use props for configuration
- Emit events for parent communication

```svelte
<!-- Good -->
<script lang="ts">
  export let value: string;
  export let disabled: boolean = false;
  
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();
  
  function handleChange() {
    dispatch('change', { value });
  }
</script>

<button {disabled} on:click={handleChange}>
  {value}
</button>
```

## Testing Guidelines

### Backend Tests

```csharp
[Fact]
public async Task ValidateGuess_CorrectGuess_ReturnsAllCorrect()
{
    // Arrange
    var service = new NumLockService();
    var guess = "1234";
    var solution = "1234";
    
    // Act
    var result = await service.ValidateGuessAsync(guess, solution);
    
    // Assert
    Assert.All(result.Feedback, f => Assert.Equal(FeedbackStatus.Correct, f.Status));
}
```

### Frontend Tests

```typescript
import { render, fireEvent } from '@testing-library/svelte';
import NumPad from './NumPad.svelte';

test('clicking digit appends to input', async () => {
  const { getByText, getByTestId } = render(NumPad);
  
  await fireEvent.click(getByText('1'));
  await fireEvent.click(getByText('2'));
  
  const input = getByTestId('guess-input');
  expect(input).toHaveValue('12');
});
```

### Shared Package Tests

```typescript
import { NumLockEngine } from '../src/numlock-engine';

describe('NumLockEngine', () => {
  describe('checkGuess', () => {
    it('handles repeated digits correctly', () => {
      const result = NumLockEngine.checkGuess('1111', '1123');
      expect(result.filter(r => r.status === 'correct').length).toBe(2);
    });
  });
});
```

## Documentation

### Code Comments

- Comment the "why", not the "what"
- Use JSDoc/XML comments for public APIs
- Keep comments up-to-date with code changes

```typescript
/**
 * Calculates the score for a NumLock game session.
 * 
 * Score decreases with more attempts and longer time.
 * Difficulty multiplier increases base score.
 * 
 * @param attempts - Number of attempts used (1-6)
 * @param timeMs - Time taken in milliseconds
 * @param difficulty - Game difficulty level
 * @returns Calculated score (0 or higher)
 */
function calculateScore(
  attempts: number, 
  timeMs: number, 
  difficulty: Difficulty
): number {
  // Implementation
}
```

### README Updates

When adding a new feature or application:
- Update relevant README files
- Add to main README if it's a major feature
- Include usage examples
- Update architecture docs if needed

## Database Changes

### Migrations

Always use Entity Framework migrations:

```bash
cd apps/backend

# Create migration
dotnet ef migrations add DescriptiveMigrationName

# Review generated migration
# Edit if needed

# Apply migration
dotnet ef database update

# Test migration rollback
dotnet ef database update PreviousMigrationName
```

### Schema Changes

- Never modify `init.sql` after first deployment
- Use migrations for all schema changes
- Test migrations on clean database
- Document breaking changes

## API Changes

### Backward Compatibility

- Don't break existing endpoints
- Use versioning for major changes: `/api/v2/`
- Deprecate old endpoints gracefully
- Document all changes

### Adding New Endpoints

```csharp
/// <summary>
/// Gets the daily challenge for PhraseLock
/// </summary>
/// <returns>The daily PhraseLock challenge</returns>
[HttpGet("phraselock/challenge/daily")]
[Authorize]
public async Task<ActionResult<Challenge>> GetDailyPhraseLockChallenge()
{
    // Implementation
}
```

Update API documentation:
- Add endpoint to docs/api/
- Update Swagger annotations
- Add examples to README

## Pull Request Guidelines

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Commits are clean and well-organized
- [ ] Branch is up-to-date with main

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Fixes #123

## Testing
Describe testing performed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No new warnings
```

### Review Process

1. Automated checks must pass (CI/CD)
2. Code review by at least one maintainer
3. Address review feedback
4. Maintainer approves and merges

## Issue Guidelines

### Reporting Bugs

Use the bug report template:

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What should happen

**Screenshots**
If applicable

**Environment**
- OS: [e.g., macOS 14]
- Browser: [e.g., Chrome 120]
- Version: [e.g., 1.0.0]

**Additional context**
Any other relevant information
```

### Feature Requests

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of desired behavior

**Describe alternatives considered**
Other solutions you've thought about

**Additional context**
Any other relevant information
```

## Release Process

### Version Numbering

We use Semantic Versioning (SemVer):
- `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes

### Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version bumped in package.json
- [ ] Tag created: `git tag v1.0.0`
- [ ] Release notes written

## Getting Help

- 💬 Join our Discord/Slack
- 📧 Email: dev@puzloc.com
- 📖 Check existing documentation
- 🐛 Search existing issues

## Code of Conduct

### Our Pledge

We pledge to make participation in this project a harassment-free experience for everyone.

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory comments
- Trolling or inflammatory comments
- Personal or political attacks
- Publishing others' private information

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project website (when launched)

Thank you for contributing to Puzloc! 🎮✨


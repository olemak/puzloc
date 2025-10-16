# Puzloc Shared Packages

This directory contains shared libraries and utilities used across multiple applications in the Puzloc monorepo.

## Packages

### 📦 shared-types/
**Shared TypeScript Type Definitions**

Common types and interfaces used across frontend and backend (when using TypeScript).

**Contents:**
- API request/response types
- Game state types
- User and authentication types
- Database entity types (TypeScript equivalents)
- Validation schemas (Zod/Yup)

**Example:**
```typescript
// User types
export interface User {
  id: string;
  username: string;
  email: string;
  displayName?: string;
  avatarUrl?: string;
  createdAt: Date;
}

// NumLock game types
export type FeedbackStatus = 'correct' | 'wrong-position' | 'not-in-answer';

export interface NumLockGuess {
  digit: string;
  status: FeedbackStatus;
}

export interface NumLockAttempt {
  guess: string;
  feedback: NumLockGuess[];
  attemptNumber: number;
}

// API Response types
export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}
```

**Usage:**
```typescript
import { User, NumLockAttempt } from '@puzloc/shared-types';
```

---

### 🎮 game-engine/
**Core Game Logic**

Shared game logic that can be used on both client and server.

**Features:**
- NumLock validation and feedback calculation
- PhraseLock letter reveal logic
- Score calculation algorithms
- Game state management
- Input validation

**Example:**
```typescript
// NumLock engine
export class NumLockEngine {
  static checkGuess(guess: string, solution: string): NumLockGuess[] {
    // Returns feedback for each digit
  }
  
  static calculateScore(attempts: number, timeMs: number): number {
    // Calculate final score based on performance
  }
  
  static isValidGuess(guess: string): boolean {
    // Validate 4-digit input
  }
}

// PhraseLock engine
export class PhraseLockEngine {
  static revealLetters(phrase: string, guessed: Set<string>): string {
    // Returns phrase with guessed letters revealed
  }
  
  static isLetterInPhrase(letter: string, phrase: string): boolean {
    // Check if letter exists
  }
}
```

**Usage:**
```typescript
import { NumLockEngine } from '@puzloc/game-engine';

const feedback = NumLockEngine.checkGuess('1234', '4321');
```

---

### 🌐 api-client/
**Typed API Client**

Type-safe API client for consuming the backend API from frontends.

**Features:**
- Type-safe API methods
- Automatic JWT token handling
- Request/response interceptors
- Error handling
- Retry logic

**Example:**
```typescript
export class PuzlocApiClient {
  constructor(baseUrl: string, tokenProvider?: () => string) {}
  
  // Authentication
  auth = {
    login: (credentials: LoginRequest): Promise<AuthResponse> => {},
    register: (data: RegisterRequest): Promise<AuthResponse> => {},
    refresh: (token: string): Promise<RefreshResponse> => {},
  };
  
  // Games
  games = {
    numlock: {
      getDailyChallenge: (): Promise<Challenge> => {},
      submitGuess: (guess: string): Promise<AttemptResult> => {},
      getSession: (challengeId: string): Promise<GameSession> => {},
    },
    phraselock: {
      getDailyChallenge: (): Promise<Challenge> => {},
      guessLetter: (letter: string): Promise<LetterResult> => {},
      guessPhrase: (phrase: string): Promise<PhraseResult> => {},
    },
  };
  
  // Leaderboard
  leaderboard = {
    getGlobal: (gameType: string, period: string): Promise<LeaderboardEntry[]> => {},
    getUserRank: (userId: string): Promise<UserRank> => {},
  };
  
  // Users
  users = {
    getProfile: (userId: string): Promise<User> => {},
    updateProfile: (data: UpdateProfileRequest): Promise<User> => {},
    getStats: (userId: string, gameType?: string): Promise<UserStats> => {},
  };
}
```

**Usage:**
```typescript
import { PuzlocApiClient } from '@puzloc/api-client';

const client = new PuzlocApiClient('https://api.puzloc.com');
const challenge = await client.games.numlock.getDailyChallenge();
```

---

### 🛠️ utils/
**Common Utilities**

Shared utility functions used across applications.

**Contents:**
- Date formatting utilities
- String manipulation helpers
- Validation helpers
- Constants and enums
- Error handling utilities
- Local storage wrappers

**Example:**
```typescript
// Date utilities
export const formatGameDate = (date: Date): string => {
  return date.toISOString().split('T')[0];
};

export const isToday = (date: Date): boolean => {
  const today = new Date();
  return formatGameDate(date) === formatGameDate(today);
};

// Game utilities
export const GAME_TYPES = {
  NUM_LOCK: 'numlock',
  PHRASE_LOCK: 'phraselock',
} as const;

export const MAX_ATTEMPTS = {
  [GAME_TYPES.NUM_LOCK]: 6,
  [GAME_TYPES.PHRASE_LOCK]: 10,
} as const;

// Validation
export const isValidNumLockGuess = (guess: string): boolean => {
  return /^\d{4}$/.test(guess);
};

export const isValidLetter = (input: string): boolean => {
  return /^[a-zA-Z]$/.test(input);
};
```

---

## Creating New Packages

### Structure:
```bash
packages/
└── my-package/
    ├── src/
    │   ├── index.ts
    │   └── ...
    ├── package.json
    ├── tsconfig.json
    ├── README.md
    └── tests/
```

### package.json:
```json
{
  "name": "@puzloc/my-package",
  "version": "1.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest"
  },
  "devDependencies": {
    "typescript": "^5.0.0"
  }
}
```

### tsconfig.json:
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

## Package Dependencies

Packages can depend on each other:

```json
{
  "dependencies": {
    "@puzloc/shared-types": "*",
    "@puzloc/utils": "*"
  }
}
```

## Using Packages in Apps

### In frontend-svelte:
```json
{
  "dependencies": {
    "@puzloc/shared-types": "*",
    "@puzloc/api-client": "*",
    "@puzloc/game-engine": "*"
  }
}
```

### In backend (.NET):
For .NET projects, create equivalent C# types or use TypeScript types through build tools.

## Development Workflow

### Building packages:
```bash
# Build all packages
nx run-many --target=build --projects=tag:type:lib

# Build specific package
cd packages/shared-types
npm run build
```

### Testing packages:
```bash
# Test all packages
nx run-many --target=test --projects=tag:type:lib

# Test specific package
cd packages/game-engine
npm test
```

### Publishing (future):
```bash
# Publish to private npm registry
npm publish --access restricted
```

## Best Practices

1. **Keep packages focused**: Each package should have a single, clear purpose
2. **No circular dependencies**: Avoid packages depending on each other circularly
3. **Version carefully**: Use semantic versioning
4. **Document exports**: Clear JSDoc comments for all public APIs
5. **Test thoroughly**: High test coverage for shared code
6. **Type everything**: Full TypeScript coverage
7. **Build before use**: Always build packages before using in apps

## Testing Shared Code

Since shared code is used everywhere, comprehensive testing is critical:

```typescript
// game-engine.test.ts
import { NumLockEngine } from '../src/numlock-engine';

describe('NumLockEngine', () => {
  describe('checkGuess', () => {
    it('should return all correct when guess matches solution', () => {
      const result = NumLockEngine.checkGuess('1234', '1234');
      expect(result.every(r => r.status === 'correct')).toBe(true);
    });
    
    it('should return wrong-position for digits in wrong places', () => {
      const result = NumLockEngine.checkGuess('4321', '1234');
      expect(result.every(r => r.status === 'wrong-position')).toBe(true);
    });
    
    it('should return not-in-answer for wrong digits', () => {
      const result = NumLockEngine.checkGuess('5678', '1234');
      expect(result.every(r => r.status === 'not-in-answer')).toBe(true);
    });
  });
});
```

## Inter-Package Communication

```
┌─────────────────┐
│   utils         │
└────────┬────────┘
         │
    ┌────▼────────────┐
    │  shared-types   │
    └────┬────────────┘
         │
    ┌────▼──────────┐     ┌──────────────┐
    │ game-engine   │────►│  api-client  │
    └───────────────┘     └──────────────┘
```

All packages can use `utils` and `shared-types`, but avoid deep dependency chains.


# Puzloc Game Rules

This document defines the exact rules and mechanics for each game in the Puzloc platform.

## 🔢 NumLock

A Wordle-inspired number guessing game where players must crack a 4-digit code.

### Objective
Guess the correct 4-digit code in the minimum number of attempts.

### Game Setup
- A random 4-digit code is generated (0000-9999)
- Players have 6 attempts to guess the code
- Each digit can appear multiple times
- The code is kept secret until the game ends

### How to Play

1. **Make a Guess**: Enter any 4-digit number
2. **Receive Feedback**: Each digit is marked with a color:
   - 🟢 **Green (Correct)**: The digit is correct AND in the right position
   - 🟡 **Yellow (Wrong Position)**: The digit exists in the code but is in the wrong position
   - ⚫ **Gray (Not in Answer)**: The digit does not exist in the code
3. **Use Logic**: Use the feedback to narrow down possibilities
4. **Win or Lose**: 
   - Win: Guess the correct code within 6 attempts
   - Lose: Run out of attempts

### Examples

#### Example 1: Simple Case
```
Secret Code: 1234

Guess 1: 1567
Result:  🟢 ⚫ ⚫ ⚫
Analysis: 1 is correct and in position 1. 5, 6, 7 are not in the code.

Guess 2: 1892
Result:  🟢 ⚫ ⚫ 🟡
Analysis: 1 is still correct. 2 is in the code but not in position 4.

Guess 3: 1234
Result:  🟢 🟢 🟢 🟢
WIN! ✅
```

#### Example 2: Repeated Digits
```
Secret Code: 1123

Guess 1: 1111
Result:  🟢 🟢 ⚫ ⚫
Analysis: Two 1's are correct (positions 1 and 2), but there aren't four 1's.

Guess 2: 1124
Result:  🟢 🟢 🟢 ⚫
Analysis: First three digits correct. 4 is not in the code.

Guess 3: 1123
Result:  🟢 🟢 🟢 🟢
WIN! ✅
```

#### Example 3: All Wrong Positions
```
Secret Code: 1234

Guess 1: 4321
Result:  🟡 🟡 🟡 🟡
Analysis: All digits exist but all are in wrong positions!

Guess 2: 2143
Result:  🟡 🟢 🟡 🟡
Analysis: 1 is correct in position 2. Others are in wrong positions.

Guess 3: 3142
Result:  🟡 🟢 🟡 🟢
Analysis: Getting closer! 1 and 2 are in correct positions.

Guess 4: 1234
Result:  🟢 🟢 🟢 🟢
WIN! ✅
```

### Scoring

Score is calculated based on:
1. **Number of attempts**: Fewer is better
2. **Time taken**: Faster is better
3. **Difficulty**: Harder codes give more points

```typescript
function calculateScore(attempts: number, timeMs: number, difficulty: 'easy' | 'medium' | 'hard'): number {
  const baseScore = 1000;
  const difficultyMultiplier = { easy: 1, medium: 1.5, hard: 2 };
  const attemptPenalty = (attempts - 1) * 100;
  const timePenalty = Math.floor(timeMs / 1000) * 5;
  
  const score = Math.max(0, 
    baseScore * difficultyMultiplier[difficulty] 
    - attemptPenalty 
    - timePenalty
  );
  
  return Math.round(score);
}
```

**Examples:**
- Solve in 1 attempt, 20 seconds (medium): 1500 - 0 - 100 = **1400 points**
- Solve in 3 attempts, 60 seconds (medium): 1500 - 200 - 300 = **1000 points**
- Solve in 6 attempts, 180 seconds (hard): 2000 - 500 - 900 = **600 points**

### Edge Cases

**Duplicate Digits:**
If the secret is `1123` and you guess `1111`:
- First two 1's: 🟢 (correct position)
- Last two 1's: ⚫ (only two 1's exist in the secret)

**All Same Digit:**
Secret: `7777`, Guess: `7777` → All 🟢

**No Matches:**
Secret: `1234`, Guess: `5678` → All ⚫

---

## 📝 PhraseLock

A Hangman/Countdown-inspired word puzzle where players reveal a hidden phrase.

### Objective
Reveal the complete phrase by guessing letters or the entire phrase.

### Game Setup
- A phrase is selected from a curated list
- The phrase is masked: `*** **** ***** ***`
- Players start with 10 attempts (lives)
- Punctuation and spaces are revealed from the start

### How to Play

1. **Guess a Letter**: Type any letter (A-Z)
   - ✅ **Correct**: Letter is revealed in all positions where it appears
   - ❌ **Incorrect**: Lose one life
   
2. **Guess the Phrase**: Type the complete phrase
   - ✅ **Correct**: Instant win!
   - ❌ **Incorrect**: Lose 2 lives (heavier penalty)

3. **Win Conditions**:
   - Reveal all letters
   - Guess the complete phrase correctly
   
4. **Lose Condition**:
   - Run out of lives (attempts)

### Examples

#### Example 1: Letter by Letter
```
Secret Phrase: "THE QUICK BROWN FOX"

Initial:  *** ***** ***** ***
Lives: 10

Guess: E
Result: ✅ (2 found)
Display: **E ***** ***E* ***
Lives: 10

Guess: T
Result: ✅ (1 found)
Display: T*E ***** ***E* ***
Lives: 10

Guess: A
Result: ❌ (not found)
Display: T*E ***** ***E* ***
Lives: 9

Guess: H
Result: ✅ (1 found)
Display: THE ***** ***E* ***
Lives: 9

Guess: Q
Result: ✅ (1 found)
Display: THE Q**** ***E* ***
Lives: 9

... continue guessing ...

Final: THE QUICK BROWN FOX
WIN! ✅
```

#### Example 2: Early Phrase Guess
```
Secret Phrase: "BREAK A LEG"

Initial: ***** * ***
Lives: 10

Guess: E
Result: ✅ (2 found)
Display: **E** * *E*
Lives: 10

Guess: A
Result: ✅ (2 found)
Display: **EA* A *E*
Lives: 10

Guess: BREAK A LEG
Result: ✅
WIN! ✅ (with 10 lives remaining)
Bonus: +200 points for early guess!
```

#### Example 3: Running Out of Lives
```
Secret Phrase: "ACTIONS SPEAK LOUDER"

Initial: ******* ***** ******
Lives: 10

Guess: Z ❌ → 9 lives
Guess: X ❌ → 8 lives
Guess: Q ❌ → 7 lives
Guess: J ❌ → 6 lives
Guess: F ❌ → 5 lives
Guess: WORDS SPEAK LOUDER ❌ → 3 lives (wrong phrase -2)
Guess: B ❌ → 2 lives
Guess: M ❌ → 1 life
Guess: ACTIONS SPEAK LOADER ❌ → -1 lives

GAME OVER ❌
The phrase was: "ACTIONS SPEAK LOUDER"
```

### Scoring

Score is based on:
1. **Lives remaining**: More is better
2. **Time taken**: Faster is better
3. **Phrase length**: Longer phrases worth more points
4. **Category difficulty**: Harder categories worth more

```typescript
function calculateScore(
  livesRemaining: number, 
  timeMs: number, 
  phraseLength: number,
  difficulty: 'easy' | 'medium' | 'hard'
): number {
  const baseScore = 1000;
  const difficultyMultiplier = { easy: 1, medium: 1.5, hard: 2 };
  const livesBonus = livesRemaining * 50;
  const lengthBonus = phraseLength * 10;
  const timePenalty = Math.floor(timeMs / 1000) * 3;
  
  const score = Math.max(0,
    baseScore * difficultyMultiplier[difficulty]
    + livesBonus
    + lengthBonus
    - timePenalty
  );
  
  return Math.round(score);
}
```

**Examples:**
- 20 char phrase, 8 lives left, 45 seconds, medium: 1500 + 400 + 200 - 135 = **1965 points**
- 15 char phrase, 3 lives left, 120 seconds, hard: 2000 + 150 + 150 - 360 = **1940 points**

### Categories

Phrases are grouped into categories:

- **Movies**: Famous movie titles and quotes
- **Proverbs**: Common sayings and idioms
- **Geography**: Countries, cities, landmarks
- **Science**: Scientific terms and concepts
- **Pop Culture**: Music, TV, internet culture
- **History**: Historical events and figures
- **Literature**: Books, authors, famous quotes

Each category has difficulty ratings (easy/medium/hard).

### Special Features (Optional)

**Hint System:**
- Use a life to reveal a random letter
- Use 2 lives to reveal the category
- Use 3 lives to reveal phrase length

**Letter Bank:**
Show which letters have been guessed:
```
Guessed: A E I O U T N R S L
Available: B C D F G H J K M P Q V W X Y Z
```

---

## 🏆 Leaderboards

### Types

1. **Daily**: Today's top performers
2. **Weekly**: This week's top performers
3. **Monthly**: This month's top performers
4. **All-Time**: Overall top performers

### Ranking Criteria

Players are ranked by:
1. **Total Score**: Primary metric
2. **Win Rate**: Percentage of games won
3. **Average Attempts**: Lower is better
4. **Current Streak**: Consecutive daily wins

### Tiebreakers

If two players have the same score:
1. Better win rate
2. Lower average attempts
3. Longer current streak
4. Earlier registration date

---

## 🎖️ Achievements

### NumLock Achievements

- **First Steps**: Complete your first game
- **Perfect Code**: Solve in 1 attempt
- **Speedster**: Solve in under 30 seconds
- **Persistent**: Play 10 games
- **Century**: Play 100 games
- **Hot Streak**: Win 5 days in a row
- **Unstoppable**: Win 10 days in a row
- **Master**: Win 50 games

### PhraseLock Achievements

- **Letter Detective**: Reveal 100 letters
- **Phrase Master**: Guess 10 phrases correctly
- **Perfect Reveal**: Win with 10 lives remaining
- **Speed Reader**: Win in under 60 seconds
- **Category Expert**: Win 10 puzzles in each category
- **No Hints Needed**: Win without using any hints
- **Lucky Guess**: Win by guessing the phrase with 0 revealed letters

### Universal Achievements

- **Multi-Talented**: Win at both game types
- **Daily Dedication**: Play every day for 30 days
- **Completionist**: Unlock all other achievements
- **Top 10**: Reach top 10 on any leaderboard
- **Champion**: Reach #1 on any leaderboard

---

## 🎮 Daily Challenges

### How It Works

- New challenges released at 00:00 UTC daily
- Everyone gets the same challenge
- One attempt per day per game type
- Results compare against all players
- Streak tracking for consecutive days

### Challenge Difficulty

**NumLock:**
- **Easy**: No repeated digits (e.g., 1234)
- **Medium**: Some repeated digits (e.g., 1123)
- **Hard**: Multiple repeated digits (e.g., 1112)

**PhraseLock:**
- **Easy**: Short, common phrases (10-15 chars)
- **Medium**: Medium phrases with some uncommon words (15-25 chars)
- **Hard**: Long phrases with difficult words (25+ chars)

### Streaks

- Solve daily challenge to maintain streak
- Miss a day = streak resets to 0
- Streak bonus applies to score
- Streak shield: Skip one day per month without losing streak (optional feature)

---

## 🎯 Game Balance

### Anti-Cheat Measures

1. **Server Validation**: All guesses validated server-side
2. **Time Tracking**: Suspiciously fast times flagged
3. **Pattern Detection**: Random guessing patterns detected
4. **Rate Limiting**: Prevent automated solvers
5. **Session Management**: One game per challenge per user

### Difficulty Balancing

NumLock difficulty based on:
- Number of repeated digits
- Digit distribution
- Common patterns (avoid 1234, 0000, etc.)

PhraseLock difficulty based on:
- Phrase length
- Common letter frequency
- Category familiarity
- Word complexity

---

## 📊 Statistics Tracked

### Per User
- Games played
- Games won
- Win rate
- Average attempts
- Best time
- Current streak
- Max streak
- Total score
- Leaderboard rank

### Per Game
- Total plays
- Win percentage
- Average attempts
- Average time
- Most common guesses
- Distribution of attempts to win

---

## 🔮 Future Game Modes

### NumLock Variants
- **TimeAttack**: Solve as many as possible in 5 minutes
- **Multiplayer**: Race against another player
- **Mastermind**: 6-digit codes with harder rules
- **Blind**: No feedback until all 6 attempts used

### PhraseLock Variants
- **Countdown**: Phrase from Countdown TV show format
- **Category Sprint**: 5 phrases, same category
- **Reverse**: You create the phrase, AI guesses
- **Team Mode**: Collaborative phrase solving

This document serves as the single source of truth for game rules and will be referenced during implementation.


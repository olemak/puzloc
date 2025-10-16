-- Puzloc Database Initialization Script
-- This script sets up the initial database schema for the multi-game puzzle platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index on email and username for faster lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Game types enum (for reference, we'll use VARCHAR in tables)
-- Valid values: 'numlock', 'phraselock'

-- Daily challenges table
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_type VARCHAR(20) NOT NULL CHECK (game_type IN ('numlock', 'phraselock')),
    challenge_date DATE NOT NULL,
    solution TEXT NOT NULL, -- The actual answer (will be encrypted/hashed in app)
    solution_hash VARCHAR(255) NOT NULL, -- Hash for verification
    difficulty VARCHAR(20) CHECK (difficulty IN ('easy', 'medium', 'hard')),
    metadata JSONB, -- Additional data like hints, category for phraselock, etc.
    max_attempts INT DEFAULT 6,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(game_type, challenge_date)
);

-- Index for querying challenges by date and type
CREATE INDEX idx_challenges_date_type ON challenges(challenge_date, game_type);

-- Game attempts table
CREATE TABLE attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    guess TEXT NOT NULL,
    result JSONB NOT NULL, -- Feedback data (e.g., [{digit: '1', status: 'correct'}, ...])
    attempt_number INT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    time_taken_ms INT, -- Time taken for this attempt in milliseconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for faster queries
CREATE INDEX idx_attempts_user_id ON attempts(user_id);
CREATE INDEX idx_attempts_challenge_id ON attempts(challenge_id);
CREATE INDEX idx_attempts_user_challenge ON attempts(user_id, challenge_id);

-- Game sessions table (tracks a user's complete game session)
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    total_attempts INT DEFAULT 0,
    is_won BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, challenge_id)
);

-- Index for querying user sessions
CREATE INDEX idx_game_sessions_user_id ON game_sessions(user_id);
CREATE INDEX idx_game_sessions_challenge_id ON game_sessions(challenge_id);

-- User statistics table
CREATE TABLE user_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_type VARCHAR(20) NOT NULL CHECK (game_type IN ('numlock', 'phraselock')),
    games_played INT DEFAULT 0,
    games_won INT DEFAULT 0,
    games_lost INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    max_streak INT DEFAULT 0,
    total_attempts INT DEFAULT 0,
    average_attempts DECIMAL(4,2),
    best_time_ms INT, -- Best time to solve (in milliseconds)
    total_score INT DEFAULT 0, -- Overall score/points
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, game_type)
);

-- Index for user stats
CREATE INDEX idx_user_stats_user_game ON user_stats(user_id, game_type);

-- Leaderboard entries table
CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_type VARCHAR(20) NOT NULL CHECK (game_type IN ('numlock', 'phraselock')),
    period VARCHAR(20) NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'all_time')),
    score INT NOT NULL,
    rank INT,
    wins INT DEFAULT 0,
    average_attempts DECIMAL(4,2),
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    period_start DATE,
    period_end DATE
);

-- Indexes for leaderboard queries
CREATE INDEX idx_leaderboard_game_period ON leaderboard_entries(game_type, period, rank);
CREATE INDEX idx_leaderboard_calculated_at ON leaderboard_entries(calculated_at);

-- Achievements table (for future gamification)
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    game_type VARCHAR(20), -- NULL means applies to all games
    criteria JSONB NOT NULL, -- Requirements to unlock
    points INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User achievements (many-to-many relationship)
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Index for user achievements
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);

-- Refresh tokens table (for JWT authentication)
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE,
    is_revoked BOOLEAN DEFAULT FALSE
);

-- Index for token lookups
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on users
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger to auto-update updated_at on user_stats
CREATE TRIGGER update_user_stats_updated_at
    BEFORE UPDATE ON user_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- View for current daily challenges
CREATE VIEW v_daily_challenges AS
SELECT 
    c.*,
    COUNT(DISTINCT gs.user_id) as total_players,
    COUNT(DISTINCT CASE WHEN gs.is_won THEN gs.user_id END) as total_winners
FROM challenges c
LEFT JOIN game_sessions gs ON c.id = gs.challenge_id
WHERE c.challenge_date = CURRENT_DATE
GROUP BY c.id;

-- View for user leaderboard rankings
CREATE VIEW v_user_rankings AS
SELECT 
    u.id as user_id,
    u.username,
    u.display_name,
    u.avatar_url,
    us.game_type,
    us.games_played,
    us.games_won,
    us.current_streak,
    us.max_streak,
    us.average_attempts,
    us.total_score,
    RANK() OVER (PARTITION BY us.game_type ORDER BY us.total_score DESC) as rank
FROM users u
JOIN user_stats us ON u.id = us.user_id
WHERE u.is_active = TRUE
ORDER BY us.game_type, rank;

-- Insert some sample achievements
INSERT INTO achievements (code, name, description, icon, game_type, criteria, points) VALUES
    ('first_win', 'First Victory', 'Win your first game', 'trophy', NULL, '{"wins": 1}', 10),
    ('perfect_numlock', 'Perfect Code', 'Solve a NumLock puzzle in one attempt', 'star', 'numlock', '{"attempts": 1, "won": true}', 50),
    ('speed_demon', 'Speed Demon', 'Solve a puzzle in under 30 seconds', 'lightning', NULL, '{"time_ms": 30000}', 25),
    ('streak_5', '5-Day Streak', 'Win 5 days in a row', 'fire', NULL, '{"streak": 5}', 30),
    ('century_club', 'Century Club', 'Play 100 games', 'medal', NULL, '{"games_played": 100}', 100);

-- Create a sample user (password is 'password123' hashed with bcrypt)
-- Note: In production, passwords should be hashed by the application
INSERT INTO users (username, email, password_hash, display_name) VALUES
    ('demo_user', 'demo@puzloc.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5NU8vxO9KKEJW', 'Demo Player');

-- Grant permissions (if needed for specific users)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO puzloc_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO puzloc_user;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Puzloc database initialized successfully!';
END $$;


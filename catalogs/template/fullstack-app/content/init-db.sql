-- Database initialization script for ${{ values.name }}
-- This script runs when PostgreSQL container starts for the first time

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create initial tables (these will also be created by SQLAlchemy, but this ensures they exist)
CREATE TABLE IF NOT EXISTS health_logs (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) DEFAULT 'healthy',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    endpoint VARCHAR(100),
    response_time INTEGER
);

CREATE TABLE IF NOT EXISTS app_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    component VARCHAR(100)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_health_logs_timestamp ON health_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_health_logs_status ON health_logs(status);
CREATE INDEX IF NOT EXISTS idx_app_logs_timestamp ON app_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_app_logs_level ON app_logs(level);

-- Insert initial data
INSERT INTO health_logs (status, endpoint, response_time) 
VALUES ('healthy', '/health', 0)
ON CONFLICT DO NOTHING;

INSERT INTO app_logs (level, message, component) 
VALUES ('INFO', 'Database initialized for ${{ values.name }}', 'database')
ON CONFLICT DO NOTHING;

-- Create a sample function for health checking
CREATE OR REPLACE FUNCTION check_database_health()
RETURNS TABLE(
    table_name TEXT,
    row_count BIGINT,
    last_update TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'health_logs'::TEXT,
        COUNT(*)::BIGINT,
        MAX(timestamp)
    FROM health_logs
    UNION ALL
    SELECT 
        'app_logs'::TEXT,
        COUNT(*)::BIGINT,
        MAX(timestamp)
    FROM app_logs;
END;
$$ LANGUAGE plpgsql;

-- Grant necessary permissions to the app user
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO appuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO appuser;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO appuser;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO appuser;

-- Log the completion
INSERT INTO app_logs (level, message, component) 
VALUES ('INFO', 'Database initialization completed successfully', 'database');

COMMIT;
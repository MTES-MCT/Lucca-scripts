-- =====================================================
-- 03_load_logs.sql
-- Load user connection logs into the simplified database
-- =====================================================

USE lucca_simplified;

-- Clear existing data before loading
TRUNCATE logs;

-- Insert connection logs
INSERT INTO logs (
    utilisateur_id,
    connexion_date
)
SELECT
    u.id AS utilisateur_id,   -- direct user ID from Lucca
    l.createdAt AS connexion_date
FROM lucca.lucca_log l
         LEFT JOIN lucca.lucca_user u ON l.user_id = u.id WHERE l.status = 'status.connection';

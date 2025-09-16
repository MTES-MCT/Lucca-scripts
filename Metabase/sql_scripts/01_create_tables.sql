-- =====================================================
-- 01_create_tables.sql
-- Create simplified tables for Lucca ETL
-- =====================================================

-- Switch to simplified database (make sure it exists)
CREATE DATABASE IF NOT EXISTS lucca_simplified
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE lucca_simplified;

-- =====================================================
-- USERS TABLE
-- Stores user-level information (adherent + user link)
-- =====================================================
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    -- Stable anonymized identifier for adherent (SHA2 hash)
                       adherent_id CHAR(64) NOT NULL,

    -- Department code (e.g., "34")
                       departement VARCHAR(10) NOT NULL,

    -- Type of affiliation: Commune / Intercommunalité / Service / Inconnu
                       appartenance VARCHAR(50) NOT NULL,

    -- Name of the affiliation (e.g., "Montpellier")
                       nom_appartenance VARCHAR(255) NOT NULL,

    -- Concatenated list of groups the user belongs to
                       niveau_acces TEXT,

    -- Stable anonymized identifier for the user (SHA2 hash)
                       utilisateur_id CHAR(64) NOT NULL,

    -- Primary key on (adherent_id, utilisateur_id) to avoid duplicates
                       PRIMARY KEY (adherent_id, utilisateur_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- LOGS TABLE
-- Stores connection history of users
-- =====================================================
DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
                      utilisateur_id INT NOT NULL,        -- direct user ID
                      connexion_date DATETIME NOT NULL,   -- connection timestamp

                      INDEX idx_user_date (utilisateur_id, connexion_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================
-- HISTORY TABLE
-- Stores historical actions of adherents on dossiers
-- =====================================================
DROP TABLE IF EXISTS history;

CREATE TABLE history (
                         dossier_id INT NOT NULL,        -- identifier of the dossier
                         adherent_id INT NOT NULL,       -- unique adherent identifier
                         action_date DATETIME NOT NULL,  -- date of the action
                         action_type VARCHAR(100) NOT NULL, -- type of action (Ouverture dossier, Création contrôle, etc.)
                         ville VARCHAR(255) NOT NULL,
                         interco VARCHAR(255),
                         departement VARCHAR(10) NOT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



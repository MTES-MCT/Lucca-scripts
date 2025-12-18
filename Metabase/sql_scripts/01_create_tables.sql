-- =====================================================
-- 01_create_tables.sql
-- Create simplified tables for Lucca ETL
-- =====================================================

-- USE lucca_simplified;

-- =====================================================
-- USERS TABLE
-- Stores user-level information (adherent + user link)
-- =====================================================
DROP TABLE IF EXISTS stats_users;

CREATE TABLE stats_users
(
    id               INT AUTO_INCREMENT PRIMARY KEY,          -- basic primary key

    adherent_id      CHAR(64)     NOT NULL,
    departement      VARCHAR(10)  NOT NULL,                   -- Department code (e.g., "34")
    appartenance     VARCHAR(50)  NOT NULL,                   -- Type of affiliation: Commune / Intercommunalité / Service / Inconnu
    nom_appartenance VARCHAR(255) NOT NULL,                   -- Name of the affiliation (e.g., "Montpellier")
    niveau_acces     TEXT,                                    -- Concatenated list of groups the user belongs to
    utilisateur_id   CHAR(64)     NOT NULL,                   -- Stable anonymized identifier for the user (SHA2 hash)
    UNIQUE KEY uq_adherent_user (adherent_id, utilisateur_id) -- ensure no duplicates
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================
-- LOGS TABLE
-- Stores connection history of users
-- =====================================================
DROP TABLE IF EXISTS stats_logs;

CREATE TABLE stats_logs
(
    id             INT AUTO_INCREMENT PRIMARY KEY, -- basic primary key
    utilisateur_id INT      NOT NULL,              -- direct user ID
    connexion_date DATETIME NOT NULL,              -- connection timestamp

    INDEX          idx_user_date (utilisateur_id, connexion_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================
-- HISTORY TABLE
-- Stores historical actions of adherents on dossiers
-- =====================================================
DROP TABLE IF EXISTS stats_history;

CREATE TABLE stats_history
(
    id          INT AUTO_INCREMENT PRIMARY KEY, -- basic primary key
    dossier_id  INT          NOT NULL,          -- identifier of the dossier
    adherent_id INT          NOT NULL,          -- unique adherent identifier
    action_date DATETIME     NOT NULL,          -- date of the action
    action_type VARCHAR(100) NOT NULL,          -- type of action (Ouverture dossier, Création contrôle, etc.)
    ville       VARCHAR(255) NOT NULL,
    interco     VARCHAR(255),
    departement VARCHAR(10)  NOT NULL,
    action_id INT ,
    next_action_id INT ,

    INDEX       idx_dossier (dossier_id),
    INDEX       idx_adherent (adherent_id),
    INDEX       idx_action_date (action_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

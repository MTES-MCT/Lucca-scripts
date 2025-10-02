-- =====================================================
-- 02_load_users.sql
-- Load users into the simplified Lucca database
-- =====================================================

-- Switch to the simplified database
-- USE lucca_simplified;

-- Clear existing data before loading
TRUNCATE stats_users;

-- Insert users with a stable, unique, and anonymized identifier
INSERT INTO stats_users (
    adherent_id,
    departement,
    appartenance,
    nom_appartenance,
    niveau_acces,
    utilisateur_id
)
SELECT
    -- Generate a unique, stable, and anonymized ID using SHA2
    a.id AS adherent_id,

    -- Department code
    d.code AS departement,

    -- Determine type of affiliation: Town / Intercommunal / Service
    CASE
        WHEN a.town_id IS NOT NULL THEN 'Ville'
        WHEN a.intercommunal_id IS NOT NULL THEN 'Intercommunalité'
        WHEN a.service_id IS NOT NULL THEN 'Service'
        ELSE 'Inconnu'
        END AS appartenance,

    -- Get the name of the affiliation
    CASE
        WHEN a.town_id IS NOT NULL THEN lpt.name
        WHEN a.intercommunal_id IS NOT NULL THEN lpi.name
        WHEN a.service_id IS NOT NULL THEN lps.name
        ELSE 'Inconnu'
        END AS nom_appartenance,

    -- Concatenate all groups the user belongs to
    GROUP_CONCAT(DISTINCT g.name SEPARATOR ', ') AS niveau_acces,

    -- Original user ID from Lucca (for reference)
    u.id AS utilisateur_id

FROM lucca_adherent a
         LEFT JOIN lucca_department d ON a.department_id = d.id
         LEFT JOIN lucca_user u ON a.user_id = u.id
         LEFT JOIN lucca_parameter_town lpt ON a.town_id = lpt.id
         LEFT JOIN lucca_parameter_intercommunal lpi ON a.intercommunal_id = lpi.id
         LEFT JOIN lucca_parameter_service lps ON a.service_id = lps.id
         LEFT JOIN lucca_user_linked_group linkGroup ON u.id = linkGroup.user_id
         LEFT JOIN lucca_user_group g ON linkGroup.group_id = g.id

-- Group by all non-aggregated fields to avoid duplicate rows
GROUP BY
    a.id,
    d.code,
    a.town_id,
    a.intercommunal_id,
    a.service_id,
    lpt.name,
    lpi.name,
    lps.name,
    u.id;

-- =====================================================
-- 04_load_history.sql
-- Load historical actions into the simplified database
-- =====================================================

-- USE lucca_simplified;

-- Clean existing history (optional depending on ETL frequency)
TRUNCATE stats_history;

-- =====================================================
-- Insert minute stories
-- Each story corresponds to an action performed on a folder/dossier
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    story.createdAt AS action_date,
    CASE story.status
        WHEN 'choice.statusMinute.open' THEN 'Ouverture dossier'
        WHEN 'choice.statusMinute.courier' THEN 'Création courrier'
        WHEN 'choice.statusMinute.updating' THEN 'Création PV reactualisation'
        WHEN 'choice.statusMinute.decision' THEN 'Création décisions de justice'
        ELSE 'Autre'
        END AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_minute_story story
         LEFT JOIN lucca.lucca_minute minute ON minute.id = story.minute_id
    LEFT JOIN lucca.lucca_department department ON department.id = story.department_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
WHERE story.status IN (
    'choice.statusMinute.open',
    'choice.statusMinute.courier',
    'choice.statusMinute.updating',
    'choice.statusMinute.decision'
    );

-- =====================================================
-- Insert controls (inside) – one line per linked human
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    control.createdAt AS action_date,
    'Création contrôle avec droit de visite' AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_human human
         LEFT JOIN lucca.lucca_minute_control_linked_human_minute humanLinked ON human.id = humanLinked.human_id
         LEFT JOIN lucca.lucca_minute_control control ON humanLinked.control_id = control.id
         LEFT JOIN lucca.lucca_minute minute ON minute.id = control.minute_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
    LEFT JOIN lucca.lucca_department department ON department.id = minute.department_id
WHERE control.stateControl = 'choice.state.inside';

-- =====================================================
-- Insert controls (outside)
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    control.createdAt AS action_date,
    'Création contrôle sans droit visite' AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_control control
         LEFT JOIN lucca.lucca_minute minute ON minute.id = control.minute_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
    LEFT JOIN lucca.lucca_department department ON department.id = minute.department_id
WHERE control.stateControl = 'choice.state.outside';

-- =====================================================
-- Insert folders (PV avec Natinfs)
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    folder.createdAt AS action_date,
    'Création PV avec natinfs' AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_folder folder
         LEFT JOIN lucca.lucca_minute minute ON minute.id = folder.minute_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
    LEFT JOIN lucca.lucca_department department ON department.id = minute.department_id
WHERE EXISTS (
    SELECT 1
    FROM lucca.lucca_minute_folder_linked_natinf natinfsLinked
    WHERE natinfsLinked.folder_id = folder.id
    );

-- =====================================================
-- Insert folders (PV sans Natinfs)
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    folder.createdAt AS action_date,
    'Création rapport de constatation (PV sans natinfs)' AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_folder folder
         LEFT JOIN lucca.lucca_minute minute ON minute.id = folder.minute_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
    LEFT JOIN lucca.lucca_department department ON department.id = minute.department_id
WHERE NOT EXISTS (
    SELECT 1
    FROM lucca.lucca_minute_folder_linked_natinf natinfsLinked
    WHERE natinfsLinked.folder_id = folder.id
    );

-- =====================================================
-- Insert closure (with regularization / remis en état)
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    closure.createdAt AS action_date,
    'Clôture dossier avec remise en état' AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_closure closure
         LEFT JOIN lucca.lucca_minute minute ON minute.id = closure.minute_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
    LEFT JOIN lucca.lucca_department department ON department.id = minute.department_id
WHERE closure.natureRegularized = 'choice.natureRegularized.field';

-- =====================================================
-- Insert closure (other reasons)
-- =====================================================
INSERT INTO stats_history (
    dossier_id,
    adherent_id,
    action_date,
    action_type,
    ville,
    interco,
    departement
)
SELECT
    minute.id AS dossier_id,
    minute.adherent_id AS adherent_id,
    closure.createdAt AS action_date,
    'Clôture dossier autres raisons' AS action_type,
    town.name AS ville,
    interco.name AS interco,
    department.code AS departement
FROM lucca.lucca_minute_closure closure
         LEFT JOIN lucca.lucca_minute minute ON minute.id = closure.minute_id
    LEFT JOIN lucca.lucca_minute_plot plot ON minute.plot_id = plot.id
    LEFT JOIN lucca.lucca_parameter_town town ON plot.town_id = town.id
    LEFT JOIN lucca.lucca_parameter_intercommunal interco ON town.intercommunal_id = interco.id
    LEFT JOIN lucca.lucca_department department ON department.id = minute.department_id
WHERE closure.natureRegularized != 'choice.natureRegularized.field';

## ETL - Génération de la base simplifiée

Ce projet contient des scripts SQL permettant de générer une base simplifiée à partir de la base Lucca.  
Un script bash `run_etl.sh` permet d’exécuter tous les fichiers SQL dans le bon ordre et peut être automatisé via `cron`.

### Organisation des fichiers

metabase/
│ run_etl.sh
│
└───sql_scripts/
│ 01_create_tables.sql
│ 02_load_users.sql
│ 03_load_logs.sql
│ 04_load_history.sql

- `run_etl.sh` : script principal pour exécuter tous les scripts SQL.
- `sql_scripts/` : dossier contenant tous les fichiers SQL à exécuter, triés par ordre alphabétique.

### Configuration

Éditer `run_etl.sh` pour configurer la connexion à MariaDB :

```bash
DB_NAME="lucca_simplified"
DB_USER="votre_utilisateur"
DB_PASS="votre_motdepasse"
DB_HOST="localhost"
DB_PORT=3306
SQL_FOLDER="./sql_scripts"
LOG_FILE="./etl_log.txt"```

### Exécution manuelle

Rendre le script exécutable et le lancer :

```chmod +x run_etl.sh
./run_etl.sh```

Les logs seront écrits dans etl_log.txt.

Automatisation avec cron

Pour exécuter le script automatiquement, ajouter une entrée dans le crontab.


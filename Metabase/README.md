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

Créer un fichier .env au même niveau que `run_etl.sh` pour configurer la connexion à MariaDB :

```bash
# Database connection
DB_NAME=lucca_simplified
DB_USER=user
DB_PASS=password
DB_HOST=host
DB_PORT=3306

# Folder to store logs (default: ./logs)
LOG_ROOT=./logs
```

### Exécution manuelle

Rendre le script exécutable et le lancer :

```bash
chmod +x run_etl.sh
./run_etl.sh
```

Les logs seront écrits dans etl_log.txt.

###  Automatisation avec cron

Pour exécuter le script automatiquement, ajouter une entrée dans le crontab pour exécuter run_etl.sh à la fréquence souhaité.

###  Problèmes courants

Si une erreur similaire à l'erreur suivante est présente : 
```
=== Starting ETL job at Tue Sep 16 10:51:08 CEST 2025 ===
Executing ./sql_scripts/01_create_tables.sql ...
'). Legal suffix characters are: K, M, G, T, P, E
' to 'port'r while setting value '33066
❌ Error executing ./sql_scripts/01_create_tables.sql
```

Exécuter : `dos2unix .env`

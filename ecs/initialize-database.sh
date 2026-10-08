#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

RDS_ENDPOINT="${RDS_ENDPOINT:-}"
DB_USER="${DB_USER:-admin}"
DB_PASSWORD="${DB_PASSWORD:-}"

if [[ -z "$RDS_ENDPOINT" ]]; then
  echo "ERROR: RDS_ENDPOINT is not set."
  echo
  echo "Run:"
  echo '  export RDS_ENDPOINT="$(cd terraform/01-infrastructure && terraform output -raw db_endpoint)"'
  echo '  export DB_PASSWORD="YOUR_RDS_PASSWORD"'
  echo '  ./initialize-database.sh'
  exit 1
fi

if [[ -z "$DB_PASSWORD" ]]; then
  echo "ERROR: DB_PASSWORD is not set."
  exit 1
fi

if ! command -v mysql >/dev/null 2>&1; then
  echo "ERROR: mysql client is not installed."
  exit 1
fi

echo "Waiting for MySQL at ${RDS_ENDPOINT}:3306..."
for i in {1..60}; do
  if mysqladmin ping -h "$RDS_ENDPOINT" -P 3306 -u "$DB_USER" -p"$DB_PASSWORD" --silent >/dev/null 2>&1; then
    echo "MySQL is ready."
    break
  fi

  if [[ "$i" -eq 60 ]]; then
    echo "ERROR: RDS did not become available."
    exit 1
  fi

  sleep 10
done

mysql -h "$RDS_ENDPOINT" -P 3306 -u "$DB_USER" -p"$DB_PASSWORD" < createdatabase.sql

echo "Database initialisation complete."

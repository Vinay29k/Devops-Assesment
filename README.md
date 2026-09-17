# DevOps Assessment — Terraform + Database Reliability

## Structure

```
infra/               Terraform (see infra/README.md)
db/init/             SQL that runs automatically on first container start
  001_create_tables.sql   schema migration
  002_seed.sql             seed data
scripts/
  backup.sh          timestamped pg_dump backup
  restore.sh         restores a backup into a fresh database
docker-compose.yml   local Postgres for Parts 4-6
```

## Part 4 & 5 — Local database, schema, seed data, indexing

Start the database:

```bash
docker compose up -d
```

On first startup (empty volume), Postgres runs everything in `db/init/` in
filename order: `001_create_tables.sql` creates `hotel_bookings` and
`booking_events` (plus indexes), then `002_seed.sql` inserts ~150 bookings
across 4 organizations, 5 cities, and 4 statuses, with lifecycle events for
most of them.

Check it worked:

```bash
docker compose exec db psql -U appadmin -d appdb -c "SELECT COUNT(*) FROM hotel_bookings;"
docker compose exec db psql -U appadmin -d appdb -c "SELECT city, COUNT(*) FROM hotel_bookings GROUP BY city;"
```

### Query optimization

Target query:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

Index added (in `001_create_tables.sql`):

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);
```

**Why this shape:** `city` is an equality filter and, across a multi-city
dataset, the most selective one, so it leads the index. `created_at` is a
range filter and comes second, letting Postgres do one contiguous index
range scan instead of a full table scan. `org_id`, `status`, and `amount`
are never filtered on here — only read — so they ride along as `INCLUDE`
columns rather than key columns. That lets an index-only scan answer the
whole query straight from the index, skipping heap lookups entirely once
the visibility map is up to date.

Confirm the plan is using it:

```bash
docker compose exec db psql -U appadmin -d appdb -c "
EXPLAIN ANALYZE
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;"
```

Look for `Index Only Scan using idx_hotel_bookings_city_created_at` in the
output (rather than `Seq Scan`).

## Part 6 — Backup and restore

Take a backup:

```bash
./scripts/backup.sh
```

This runs `pg_dump` in custom format (`-F c`) inside the running container
and writes a timestamped file to `backups/backup_<timestamp>.dump` on the
host.

Restore it:

```bash
./scripts/restore.sh
```

This restores the most recent backup (or a specific file passed as an
argument) into a **new** database, `appdb_restore_test`, inside the same
Postgres instance — the original `appdb` is never touched.

### Verifying the restore worked

Compare row counts between the original and the restored copy:

```bash
docker compose exec db psql -U appadmin -d appdb -c "SELECT COUNT(*) FROM hotel_bookings;"
docker compose exec db psql -U appadmin -d appdb_restore_test -c "SELECT COUNT(*) FROM hotel_bookings;"
```

Both should return the same number. As a spot check, compare one row by id:

```bash
docker compose exec db psql -U appadmin -d appdb -c "SELECT * FROM hotel_bookings ORDER BY created_at LIMIT 1;"
docker compose exec db psql -U appadmin -d appdb_restore_test -c "SELECT * FROM hotel_bookings ORDER BY created_at LIMIT 1;"
```

If both queries return matching data, the restore is verified.

## Terraform

See [`infra/README.md`](infra/README.md) for the AWS infrastructure design,
environment structure, and how to validate it locally (`fmt`, `init`,
`validate`, `plan`) without deploying anything.

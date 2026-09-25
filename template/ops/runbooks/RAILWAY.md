# Railway Runbook

## Services

| Service | Root directory | Config file | Start command | Health path | Public URL |
|---|---|---|---|---|---|
| <api> | `<backend/>` | `<backend/railway.json>` | `<uvicorn main:app --host 0.0.0.0 --port $PORT>` | `/health` | <url> |

Rule: exactly **one** config-as-code file per service. Delete duplicates (`railway.json` + `railway.toml` + `Procfile` for the same service cause ambiguity).

## Environment variables

Names only; values live in Railway. Keep in sync with `.env.example`.

| Variable | Service | Purpose |
|---|---|---|
| `<DATABASE_URL>` | <api> | <Postgres connection, reference variable> |

## Data and volumes

| Store | Type | Mounted at / reference | Backed up? |
|---|---|---|---|
| <db> | <Railway Postgres / Supabase> | `<DATABASE_URL>` | <yes/no> |

## Deploy

1. Merge PR to `main`; Railway auto-deploys.
2. Watch: `railway logs` until the health check passes.
3. Verify: `curl -s <url>/health` and read the body; load the UI; check logs for boot errors.

## Rollback

Railway dashboard → service → Deployments → last good deploy → Redeploy. Record the incident in the crash log.

## Known issues

| Symptom | Cause | Fix |
|---|---|---|
| Healthcheck timeout on deploy | Server starts after slow boot work | Bind `$PORT` first, run boot tasks after |
| Data gone after redeploy | Written to container disk | Use Postgres/Supabase or a mounted volume |
| HTTP 451 from an external API | Provider geo-blocks Railway US egress | Use an allowed endpoint / REST alternative / different region |
| Wrong build or start command | Conflicting configs or wrong root directory | One config per service; check the service's root directory setting |

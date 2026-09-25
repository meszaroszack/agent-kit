# Architecture

_Last reviewed: <YYYY-MM-DD>. Update in the same PR as any structural change._

## Overview

<2–4 sentences: what the system does and its main moving parts.>

```
<ASCII or Mermaid diagram: user → frontend → API → services → database / external APIs>
```

## Components

| Component | Tech | Responsibility | Railway service |
|---|---|---|---|
| <frontend> | <React/Vite> | <UI> | <service name> |
| <api> | <FastAPI> | <business logic> | <service name> |
| <database> | <Postgres> | <persistence> | <plugin / Supabase> |

## Data flow

1. <Step-by-step for the most important user or system flow.>

## State and persistence

Where every piece of state lives and whether it survives a restart or redeploy.

| State | Location | Survives redeploy? |
|---|---|---|
| <e.g. positions> | <Postgres table `positions`> | Yes |

## External services

| Service | Used for | Auth | Failure behavior |
|---|---|---|---|
| <e.g. Kalshi API> | <orders, market data> | <RSA-PSS signed headers> | <retry/backoff; halt on …> |

## Key decisions

See `ai/summaries/DECISION-LOG.md`. The most important ones:

- DEC-<NNN>: <title>

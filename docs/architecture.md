# Architecture

CreatorPilot turns external market signals and a creator's own performance data into concrete
content decisions and a publish-ready kit.

This document is the agreed structure for the shared foundation. **Nothing described here is
implemented yet** — the branch exists so four people can build in parallel without overlapping.

## 1. Product pipeline

```
1. Input            2. Analyse           3. Generate         4. Deliver          5. Iterate
niche, channel,  →  signals, audience, → ideas, titles,   →  ready-to-publish → feedback and
video or script     performance data     analysis, kit       plan                 past performance
```

## 2. Layers

| # | Layer | Responsibility | Path | Owner |
|---|-------|----------------|------|-------|
| 1 | Signal sources | YouTube Data API, Google Trends, RSS and news feeds, comments, niche data | external | — |
| 2 | Integrations | Adapters, credentials, retries, normalisation, API-quota accounting | `backend/app/integrations/` | Member 3 |
| 3 | Feature extraction | Audio, visual, transcript and pacing signals from media | `backend/app/features/` | Member 1 |
| 4 | ML prediction | Custom models: retention, drop-off, performance, analytics | `backend/app/ml/` | Member 2 |
| 5 | Domain intelligence | Niche scoring: demand, competition, format fit, quality rubrics | `backend/app/intelligence/` | Member 2 |
| 6 | Recommendations | Ranking and action selection over scores | `backend/app/recommendations/` | Member 2 |
| 7 | LLM access | Provider-agnostic access, prompt assets, structured output, guardrails | `backend/app/llm/` | Member 4 |
| 8 | Orchestration and API | Use-cases, HTTP surface, persistence, infrastructure | `backend/app/services/`, `api/`, `db/`, `core/` | Member 3 |
| 9 | Product surface | Dashboards, testing flows, analysis views | `frontend/` | Member 4 |

`contracts/` holds the interface definitions that every arrow between layers must use.

## 3. Dependency direction

Imports flow one way and never backwards:

```
api  ──►  services  ──►  features
                  ├──►  ml
                  ├──►  intelligence
                  ├──►  recommendations
                  ├──►  llm
                  ├─┬──►  integrations
                  │ └──►  db
                  └─────►  core
```

Rules that keep the split honest:

- A layer never imports `api/`.
- `features/` does not call `ml/`, `intelligence/`, `recommendations/` or `llm/`; it returns
  signals and lets orchestration decide what consumes them.
- `ml/` and `intelligence/` consume feature contracts; they do not reach into `integrations/`.
- `llm/` is the only place that talks to a model provider. No other package imports a provider
  SDK, and the frontend never calls an LLM directly.
- `integrations/` is the only place that talks to an external data source, and the only place
  that owns API-quota accounting.
- `db/` owns the schema. Other layers persist through `services/`.

## 4. Layer boundaries in practice

| Boundary | Producer → consumer | Shape |
|----------|--------------------|-------|
| Feature set | `features/` → `ml/`, `intelligence/` | Normalised signals with provenance (source, timestamps, confidence) |
| Prediction | `ml/` → `intelligence/`, `recommendations/` | Scores with model identity and version |
| Score | `intelligence/` → `recommendations/` | Niche and content scores with the reasoning attached |
| Recommendation | `recommendations/` → `services/` | Ranked options the creator can act on |
| LLM call | `services/` → `llm/` | Provider-neutral request; structured response |
| API | `api/` → `frontend/` | Versioned JSON over HTTPS |

Detailed naming, versioning and change rules: [api_contracts.md](api_contracts.md).

## 5. Storage

| Store | Purpose | Status |
|-------|---------|--------|
| PostgreSQL | Creators, channels, analyses, generated content, history | Container defined in `docker-compose.yml`, schema not written |
| Redis | Caching and API-quota accounting | Container defined, no keys or policies yet |
| Object/artefact storage | Uploaded media, rendered assets | Deliberately not chosen yet — decision belongs to the owning branch |

Nothing is migrated or seeded here. `db/` is empty by design.

## 6. Technology decisions

| Area | Decision | Note |
|------|----------|------|
| Backend | Python 3.11+, FastAPI | `pyproject.toml`; no runtime dependencies pinned yet |
| Frontend | React + TypeScript | Scaffolded by Member 4 inside `frontend/`; no root Node workspace |
| Local infrastructure | Docker Compose: Postgres 16 + Redis 7 | Development only |
| Contracts | JSON Schema / OpenAPI under `contracts/` | Written when the first consumer needs them |

Python is configured at the repository root rather than per-package so there is exactly one
source of truth for lint, type and test configuration. A **root `package.json` is intentionally
absent**: the frontend owns its own manifest inside `frontend/`, and adding a root Node workspace
now would create a second tooling source of truth before there is a second Node package.

## 7. Explicit non-goals for this branch

- No application logic, routes, models, migrations or UI.
- No downloaded or trained models, no datasets, no fixtures.
- No provider integration (YouTube, Trends, news, LLM).
- No per-member branches — each member creates their own branch from `main`.

## 8. Changing this structure

A new top-level directory or a new cross-layer dependency is an architecture change: record it
here first, then implement it. Anything under `contracts/` needs all four reviewers.

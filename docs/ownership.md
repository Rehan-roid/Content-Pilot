# Ownership

Four people, four independent workstreams, one `main`. This document is the working agreement;
`CODEOWNERS` is its enforcement. Keep the two in sync.

## Team

| Member | Scope | Owned paths | GitHub handle |
|--------|-------|-------------|---------------|
| **Member 1** | AI feature extraction — audio, visual, transcript, pacing | `backend/app/features/` | _TBD_ |
| **Member 2** | Custom ML models, predictions, retention, analytics | `backend/app/ml/`, `backend/app/intelligence/`, `backend/app/recommendations/` | _TBD_ |
| **Member 3** | Backend, database, APIs, infrastructure, integration | `backend/app/api/`, `core/`, `db/`, `integrations/`, `services/`, `backend/tests/`, `docker-compose.yml`, `pyproject.toml`, `Makefile` | _TBD_ |
| **Member 4** | Frontend, dashboard, product experience, LLM integration | `frontend/`, `backend/app/llm/` | _TBD_ |
| **All four** | Contracts, architecture, root conventions | `contracts/`, `docs/`, root files | — |

Replace `_TBD_` and the `@member-*` placeholders in `CODEOWNERS` with the real GitHub usernames
before relying on required reviews.

## What each member delivers

**Member 1 — feature extraction.** Turns media into signals: audio characteristics, visual and
frame analysis, transcript with timing, and pacing (speech rate, cut rhythm, hook position).
Returns normalised, provenance-carrying features. Does **not** score, rank, predict or call an
LLM.

**Member 2 — models and domain intelligence.** Owns the custom models and the scoring logic:
retention and drop-off prediction, performance analytics, niche demand and competition scoring,
content-quality rubrics, and the ranking that turns scores into ordered options. Does **not**
fetch external data, expose HTTP routes, or render anything.

**Member 3 — backend and integration.** Owns the HTTP surface, persistence, settings, logging,
use-case orchestration and every external data adapter including quota accounting. This is the
only layer that writes to the database or exposes an endpoint.

**Member 4 — product and LLM access.** Owns the React/TypeScript application and the
provider-agnostic LLM layer: prompt assets, structured output, guardrails, cost and rate limits.
The browser never holds a provider key; all model access goes through the backend.

## Boundary rules

1. **One source of truth per concern.** Scores are computed in `intelligence/`, not in the
   frontend, not in `api/`, not in prompts. Contracts live in `contracts/`, not duplicated in a
   module.
2. **No cross-layer shortcuts.** `api/` calls `services/`; `services/` orchestrates. A layer
   never imports `api/`, and nothing except `llm/` imports a model provider SDK.
3. **No parallel external clients.** Only `integrations/` speaks to YouTube, Trends or news
   feeds; only `llm/` speaks to model providers.
4. **Contracts before code.** A new cross-module payload is proposed in `contracts/schemas/` and
   recorded in `docs/api_contracts.md`, then implemented.
5. **No shared mutable state across modules.** Pass values through function signatures or
   contracts, not module-level globals.

## Working agreement

- `main` is the only long-lived branch and stays deployable and readable at all times.
- Each member works on their own branch created from `main` (for example `feat/feature-extraction`)
  and opens a pull request into `main`. Branches are personal; nobody pushes to another member's
  branch.
- Pull requests change only owned paths. Touching someone else's directory needs their review.
- Squash-merge or rebase to keep `main` linear; no merge commits from feature branches.
- Keep `main` green: the checks in `Makefile` (`lint`, `typecheck`, `test`) are expected to pass
  before a merge.
- Secrets never travel through git, chat or logs. Local values live in `.env`.

## Shared decisions

Anything under `contracts/`, `docs/`, or the root configuration files requires **all four**
approvals. That is deliberate: those files are the only place where the four workstreams can
silently diverge.

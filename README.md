# CreatorPilot — Creator Intelligence OS

A co-pilot for content creators: it reads the signals in a creator's niche, audience and market,
then helps them decide **what to create**, **optimise the content**, **analyse performance** and
**turn it into revenue**.

**Repository:** [Rehan-roid/Content-Pilot](https://github.com/Rehan-roid/Content-Pilot)
**Default branch:** `main`

> **Status — foundation only.**
> This branch is the shared project skeleton: directory structure, module boundaries, contracts
> and conventions. It deliberately contains **no application logic, no endpoints, no models, no
> datasets and no UI**. Each feature is built by its owner on a separate branch and merged into
> `main` through a reviewed pull request.

## Core features

| # | Feature | Outcome |
|---|---------|---------|
| 1 | **Title & Thumbnail Testing** | Generate and score title/thumbnail variants before publishing |
| 2 | **Topic & Idea Selection** | Rank niche ideas against real demand signals, with the reasoning shown |
| 3 | **Creator Assistant** | Daily / weekly / monthly niche dashboards and a one-click content kit |
| 4 | **Video Analysis** | Transcript, audio and visual analysis with concrete improvement actions |
| 5 | **Video Repurposing** | One long video → short-form clips with titles, captions and hashtags |

Product pipeline: **Input → Analyse → Generate → Deliver → Iterate**.

## Module map

Every arrow between layers is a contract, not a direct import. `contracts/` is the single source
of truth for interfaces; the reasoning is in [docs/architecture.md](docs/architecture.md).

```
signals ──► integrations ──► features ──► ml ──► intelligence ──► recommendations
             (M3)            (M1)        (M2)     (M2)                (M2)
                                                                    │
frontend ◄── api ◄── services ◄──────────────────────────────────────┘      llm (M4)
  (M4)       (M3)     (M3)                    ↕ contracts/
```

| Path | Responsibility | Owner |
|------|----------------|-------|
| `backend/app/features/` | Audio, visual, transcript and pacing extraction | Member 1 |
| `backend/app/ml/` | Custom models, prediction, retention, analytics | Member 2 |
| `backend/app/intelligence/` | Domain intelligence and scoring | Member 2 |
| `backend/app/recommendations/` | Ranking and action selection | Member 2 |
| `backend/app/api/` `core/` `db/` `integrations/` `services/` | Backend, database, APIs, infrastructure, integration | Member 3 |
| `backend/app/llm/` | LLM access layer | Member 4 |
| `frontend/` | Dashboard and product experience | Member 4 |
| `contracts/` | Shared interface definitions | All four |

Boundaries, review rules and the working agreement: [docs/ownership.md](docs/ownership.md).

## Repository layout

```
.
├── backend/
│   ├── app/
│   │   ├── api/                 # HTTP layer                          (M3)
│   │   ├── core/                # settings, logging, errors           (M3)
│   │   ├── db/                  # persistence and migrations          (M3)
│   │   ├── features/            # audio / visual / transcript / pacing (M1)
│   │   ├── integrations/        # YouTube, Trends, RSS, news          (M3)
│   │   ├── intelligence/        # niche scoring                       (M2)
│   │   ├── llm/                 # provider-agnostic LLM access        (M4)
│   │   ├── ml/                  # models, predictions, analytics      (M2)
│   │   ├── recommendations/     # ranking and actions                 (M2)
│   │   └── services/            # use-case orchestration              (M3)
│   └── tests/                   # test suite root
├── contracts/                   # shared interfaces (all four)
│   ├── openapi/                 # API specifications
│   └── schemas/                 # shared payload schemas
├── docs/                        # architecture, ownership, contracts
├── frontend/                    # React + TypeScript app               (M4)
├── CODEOWNERS
├── Makefile
├── docker-compose.yml           # local Postgres + Redis only
├── pyproject.toml
├── .env.example
├── .dockerignore
├── .gitignore
└── README.md
```

## Quick start

Requires Python 3.11+ and Docker (for local infrastructure only). `make` is optional — on Windows
without it, run the command shown after each target.

```bash
cp .env.example .env          # placeholders only; .env is git-ignored
make venv install             # python -m venv .venv && pip install -e ".[dev]"
make up                       # docker compose up -d  → Postgres + Redis
```

| Command | Purpose |
|---------|---------|
| `make lint` / `make format` | Ruff checks and formatting |
| `make typecheck` | Mypy over `backend/app` |
| `make test` | Pytest over `backend/tests` |
| `make dev` | Runs the API — enabled once Member 3 lands `backend/app/main.py` |
| `make up` / `make down` / `make logs` | Local Postgres + Redis |

## Conventions

- **Contracts first.** A cross-module payload is defined in `contracts/schemas/` before it is used.
  See [docs/api_contracts.md](docs/api_contracts.md).
- **One owner per directory.** `CODEOWNERS` enforces the split; shared files need all four.
- **No secrets, no data, no weights in git.** `.gitignore` is strict on purpose.
- **No new top-level directories** without a decision recorded in `docs/architecture.md`.

## What is intentionally absent

Application logic, FastAPI routes, database models, model training, provider integrations,
prompt assets, React components and every generated artefact. Those belong to the individual
branches; this branch must stay mergeable by all four members at once.

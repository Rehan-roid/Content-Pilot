# Backend

Python 3.11+ / FastAPI service. **No application code exists yet** — this directory defines the
package layout and the boundaries each owner builds inside.

## Layout

```
backend/
├── app/
│   ├── api/             # HTTP layer: routers, dependencies, request/response mapping  (M3)
│   ├── core/            # settings, logging, errors, security helpers                 (M3)
│   ├── db/              # engine/session setup, ORM models, migrations                (M3)
│   ├── features/        # audio, visual, transcript and pacing extraction             (M1)
│   ├── integrations/    # YouTube Data API, Google Trends, RSS/news, quota accounting (M3)
│   ├── intelligence/    # niche and content scoring rubrics                           (M2)
│   ├── llm/             # provider-agnostic LLM access, prompts, guardrails           (M4)
│   ├── ml/              # custom models, prediction, retention, analytics             (M2)
│   ├── recommendations/ # ranking and action selection                                (M2)
│   └── services/        # use-case orchestration across the layers above              (M3)
└── tests/               # test suite root (mirrors the app layout)
```

## Import rules

```
api → services → { features, ml, intelligence, recommendations, llm, integrations, db, core }
```

- `api/` is a leaf: no other package imports it.
- `features/` returns signals; it never calls `ml/`, `intelligence/`, `recommendations/` or `llm/`.
- Only `integrations/` talks to external data sources; only `llm/` talks to model providers.
- Only `db/` owns the schema. Everything else persists through `services/`.

If you need an import that points backwards, the boundary is wrong — raise it in the pull request
rather than adding the import.

## Adding a package

A new package inside an owned layer is fine. A **new top-level layer** is an architecture change:
record it in `docs/architecture.md` before creating it.

Every package needs an `__init__.py` with a one-paragraph docstring stating its purpose, its
owner and what it must not import.

## Running

```bash
pip install -e ".[dev]"      # from the repository root
pytest                       # testpaths = backend/tests
ruff check backend
mypy
```

The ASGI entrypoint (`app.main:app`) is Member 3's first deliverable. `make dev` checks for it
and explains itself if it is missing.

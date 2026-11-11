# Shared contracts

This directory is the single source of truth for everything that crosses a module boundary.

```
contracts/
├── openapi/    # HTTP interface descriptions (versioned, generated or hand-written)
└── schemas/    # Shared payload schemas: feature sets, predictions, scores,
                # recommendations, content kits, LLM requests/responses
```

Both directories are intentionally empty. Nothing here is implemented in the foundation branch:
the first schema is written when the first consumer needs it, by its producer, with all four
owners reviewing.

## Rules

1. **Define once.** A payload used across modules is defined here and imported from here. Do not
   copy a schema into `backend/` or the frontend.
2. **Version it.** Additive changes stay in the current version; breaking changes get a new one.
   `docs/api_contracts.md` records the conventions.
3. **Provenance is part of the contract.** Anything derived from an external source declares that
   source and its retrieval time.
4. **No examples with fabricated data.** A schema may declare required fields and constraints;
   it must not ship invented sample payloads or fixtures.
5. **No secrets, no real payload captures.** Contracts describe shape, never live values.

## Changing a contract

Open a pull request that touches this directory and `docs/api_contracts.md` together. It needs
all four approvals — this is the only place where the four workstreams can quietly diverge.

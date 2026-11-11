# Frontend

React + TypeScript application. **Not scaffolded yet** — the directory exists to reserve the
boundary so the four workstreams do not collide.

- **Owner:** Member 4 (frontend, dashboard, product experience).
- **Scaffold on your branch**, inside this directory, with the tooling you want (for example a
  Vite React-TS setup). Nothing needs to be agreed at the root first.
- **No root `package.json`.** The frontend manifest lives here. Adding a Node workspace at the
  repository root would create a second tooling source of truth before a second Node package
  exists.
- **Keep build output out of git:** `dist/`, `build/`, `node_modules/` and `.vite/` are already
  ignored.

## What belongs here

Dashboards and product surfaces for the five features: title and thumbnail testing, topic and
idea selection, the daily/weekly/monthly assistant, video analysis, and repurposing. Presentation,
interaction and client-side state only.

## What does not

- Scoring, ranking or prediction logic — that is the backend's job, and it is the one place the
  numbers are produced.
- Provider keys or direct LLM calls. Every model call goes through the backend `llm/` layer.
- Duplicated copies of payload shapes. Types come from `contracts/` (generated or hand-mirrored
  once, never re-invented).

The API is treated as remote and fallible: loading, empty and error states are part of the UI,
and placeholder success data is never shipped as if it were real.

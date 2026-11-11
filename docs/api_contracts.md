# API contracts

The contract layer exists so the four workstreams can build in parallel without guessing what
the other side will send.

**Status:** rules and boundaries only. No endpoint, schema or payload is implemented in this
branch — the first contracts are written when the first consumer needs them.

## 1. Where contracts live

| Artefact | Location | Owner |
|----------|----------|-------|
| HTTP interface description | `contracts/openapi/` | Member 3 |
| Shared payload schemas (features, predictions, scores, recommendations, LLM I/O) | `contracts/schemas/` | Producer of the payload, reviewed by all four |
| Human-readable rules | this document | All four |

`contracts/` is the single source of truth. A schema copied into a module — or redefined in the
frontend — is a bug, not a convenience.

## 2. Conventions

- **Versioning:** the HTTP surface is versioned by URL prefix (`/api/v1`). Breaking changes ship
  as `/api/v2`; additive changes stay in `v1`.
- **Encoding:** JSON over HTTPS, UTF-8. Field names are `snake_case` on the wire; the frontend
  maps to its own naming at its boundary.
- **Timestamps:** ISO-8601, UTC, explicit offset.
- **Identifiers:** opaque strings. Clients never parse them.
- **Errors:** RFC 9457 `application/problem+json` with `type`, `title`, `status`, `detail` and a
  stable machine-readable `code`. No stack traces, provider messages or secrets in a response.
- **Pagination:** cursor-based (`limit`, `cursor`, `next_cursor`) for any list that can grow.
- **Numbers:** scores are floats in `[0, 1]` unless a schema explicitly documents another range.
  Every score carries the model or rubric identifier that produced it.
- **Provenance:** any payload derived from an external source records that source and its
  retrieval time. A number without provenance is not a decision input.
- **Secrets:** never in a request or response body. Provider credentials stay server-side.

## 3. Domain surfaces

Proposed grouping, derived from the five product features. **Nothing here is implemented**; the
grouping exists so each owner knows which path their work will land under.

| Feature | Proposed resource group | Producer |
|---------|------------------------|----------|
| Title & Thumbnail Testing | `/api/v1/titles`, `/api/v1/thumbnails` | M2 scoring, M3 API, M4 UI |
| Topic & Idea Selection | `/api/v1/topics`, `/api/v1/ideas` | M2, M3, M4 |
| Creator Assistant | `/api/v1/assistant` (dashboards, content kits) | M2, M3, M4 |
| Video Analysis | `/api/v1/analysis` | M1 features, M2, M3, M4 |
| Video Repurposing | `/api/v1/repurposing` | M1, M3, M4 |

Anything not in this table needs a decision recorded here before it is built.

## 4. Cross-module payloads

These are the only places where the workstreams touch. Each payload is defined once, in
`contracts/schemas/`, and its schema version is part of the contract.

| Payload | Producer | Consumers | Must express |
|---------|----------|-----------|--------------|
| **Feature set** | Member 1 | Member 2, Member 3 | Signal values, units, provenance, extraction method, confidence |
| **Prediction** | Member 2 | Member 2 (scoring), Member 3 | Predicted outcome, score, model identifier and version |
| **Score / assessment** | Member 2 | Member 2, Member 3, Member 4 | Score plus the reasoning the product must display |
| **Recommendation** | Member 2 | Member 3, Member 4 | Ranked options with evidence and expected effect |
| **Content kit** | Member 3 (orchestration) | Member 4 | Titles, description, hashtags, hooks, posting plan — assembled from the layers above |
| **LLM request / response** | Member 4 | Member 3 | Provider-neutral input, structured output, usage and cost metadata |

Rules for these payloads:

- A consumer never assumes a field the schema does not declare.
- Unknown fields are ignored, not rejected, so additive changes stay non-breaking.
- Every payload that can be shown to a creator carries the human-readable reasoning that
  justifies it. The product promises *why*, not just *what*.

## 5. Changing a contract

1. Propose the change here and in `contracts/`, with the affected producers and consumers.
2. Get all four owners to review (enforced by `CODEOWNERS`).
3. Land the schema first, then the producer, then the consumer.
4. Remove the old shape only after every consumer has moved.

## 6. Client expectations

- The frontend treats the API as remote and fallible: it handles loading, empty and error states
  without inventing placeholder success payloads.
- The frontend never generates scores, rankings or copy that the backend is responsible for.
- No API key, provider token or internal identifier is ever exposed to the browser.

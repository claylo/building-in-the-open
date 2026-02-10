---
skill: writing-design-docs
persona: technical-writer
expected_type: design-doc
expected_path_pattern: "docs/designs/*.md"
description: Feature design for a caching layer.
---

# Scenario: Feature design document

## Design context

You are designing a caching layer for the task management API. The API currently hits the database on every request. Response times are 50-200ms for list endpoints. The goal is to reduce p95 latency to under 20ms for read-heavy endpoints.

**Proposed approach:** In-process LRU cache with TTL-based invalidation.

**Key decisions:**
- Use `moka` crate (concurrent, TTL-aware, bounded size) over `lru` (no TTL) or Redis (operational complexity for a single-instance API)
- Cache at the service layer, not the HTTP layer — cache domain objects, not serialized responses
- TTL of 30 seconds for list endpoints, 5 minutes for individual task lookups
- Write-through invalidation: mutations invalidate the relevant cache entries immediately
- Cache size bounded at 10,000 entries (estimated 50MB with average task size of 5KB)

**Open questions:**
- Should cache warming happen on startup or lazily?
- How to handle cache stampedes when a popular key expires?

## Expected behavior

The writing-design-docs skill should produce a design document that:
- Has all required design-doc template sections
- Scores at or below grade 12 readability
- Uses Technical Writer voice
- Includes the approach, alternatives considered, and consequences

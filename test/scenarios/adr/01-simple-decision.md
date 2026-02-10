---
skill: writing-adrs
persona: technical-writer
expected_type: adr
expected_path_pattern: "docs/decisions/*.md"
description: Straightforward technology choice with clear alternatives.
---

# Scenario: Simple architectural decision

## Decision context

You are building a REST API for a task management application. The team needs to choose a serialization format for the API responses.

**Decision:** Use JSON as the primary serialization format for all API responses.

**Alternatives considered:**
- **Protocol Buffers:** Better performance and smaller payloads, but requires schema compilation step, generated code, and clients need protobuf libraries. Overkill for a CRUD API with mostly human-readable data.
- **MessagePack:** Binary JSON — smaller payloads without schema overhead. But debugging is harder (can't curl and read the response), tooling ecosystem is thinner, and the size savings are marginal for our payload sizes (typically < 10KB).
- **JSON:** Universal browser/client support, human-readable, extensive tooling, no schema compilation. Slightly larger payloads but compression (gzip/brotli) closes the gap for wire size.

**Consequences:**
- API responses are immediately debuggable with curl, Postman, browser dev tools
- No build step for client SDKs — any HTTP client works
- Payload sizes are acceptable with compression (measured: 2-3x larger than protobuf uncompressed, < 10% difference with gzip)
- If we later need a high-throughput internal service-to-service channel, we can add a protobuf endpoint alongside JSON without breaking existing clients

## Expected behavior

The writing-adrs skill should produce an ADR in MADR 4.0.0 format that:
- Has all required sections (title, status, context, decision, consequences)
- Scores at or below grade 12 readability
- Uses Technical Writer voice (rigorous, opinionated, explicit trade-offs)
- Properly numbers as the next ADR in sequence

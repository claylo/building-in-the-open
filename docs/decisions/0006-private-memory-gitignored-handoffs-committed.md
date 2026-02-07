---
status: accepted
date: 2026-02-07
decision-makers: Clay Loveless
consulted: []
informed: []
---

# 0006: Private memory is gitignored; handoffs are committed

## Context and Problem Statement

Context curation produces two types of output: unfiltered private context (motivations, frustrations, hunches) and professional public handoffs (state, decisions, next steps). Both are valuable, but they serve different audiences with different trust boundaries. How should we handle their visibility in the repository?

## Decision Drivers

- Private memory must capture full candor — including content that would fail the conference-talk test
- Public handoffs must be available to anyone with repo access (contributors, future team, agents)
- "Building in the open" means handoffs are part of the public record of how the project evolved
- Gitignoring private memory is the simplest mechanism to prevent accidental exposure
- Developers working with AI agents often share context that is personally useful but professionally inappropriate for a repo

## Considered Options

- Private memory gitignored, handoffs committed
- Both committed with access controls (e.g., branch protection, separate private branch)
- Both gitignored, committed manually when ready

## Decision Outcome

Chosen option: "Private memory gitignored, handoffs committed," because it creates a clean, structural separation between the private and public channels. The gitignore is enforced by the filesystem, not by author discipline. There's no way to accidentally `git add PRIVATE_MEMORY.md` if it's in `.gitignore`.

### Consequences

- Good, because the private channel is genuinely private — structural enforcement, not policy enforcement
- Good, because handoffs become part of the project's public history, supporting "building in the open"
- Good, because the separation is trivially simple to understand and implement
- Good, because agents don't need to make judgment calls about which parts of their context to commit
- Bad, because private memory doesn't survive if the local filesystem is lost (it's not backed up via git)
- Bad, because private memory from one machine isn't available on another (no sync mechanism)

### Confirmation

Validated by checking that `.gitignore` includes `PRIVATE_MEMORY.md` and that `git status` never shows it as an untracked file. The `curating-context` skill writes both files; if the public handoff appears in `git status` and the private memory doesn't, the separation works.

## Pros and Cons of the Options

### Private memory gitignored, handoffs committed

`PRIVATE_MEMORY.md` is in `.gitignore`. `.handoffs/` is committed and goes through the tone firewall.

- Good, because structural separation — can't accidentally commit private context
- Good, because simple mental model: gitignored = private, committed = public
- Good, because handoffs build a public history of project evolution
- Bad, because private memory has no backup or sync mechanism
- Bad, because switching machines means losing private context

### Both committed with access controls

Both files are committed, but private memory lives in a protected branch or encrypted directory.

- Good, because private memory is backed up and synced via git
- Bad, because access controls add complexity (branch permissions, encryption keys)
- Bad, because a misconfigured access control could expose private content
- Bad, because "building in the open" means the repo is likely public — access controls on individual files within a public repo are awkward at best

### Both gitignored, committed manually

Neither is committed automatically. The author reviews and manually commits handoffs when they're ready.

- Good, because maximum control over what reaches the repo
- Bad, because manual commitment means handoffs often don't get committed (out of sight, out of mind)
- Bad, because the whole point of this system is reducing context loss — adding a manual step reintroduces the failure mode

## More Information

- Design doc: `docs/designs/2026-02-07-building-in-the-open-plugin-design.md` (Architecture section)
- Related: ADR-0002 (tone firewall applies to committed artifacts, which includes handoffs)
- Related: ADR-0005 (public handoffs have a token budget, enforced by tooling)

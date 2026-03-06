# Handoff: bito-lint CD Pipeline Fixes & Release Infrastructure

## Current State

### Done (committed & pushed)

- **Code review fixes (bito-lint, merged to main):** 5 commits on `fix/code-review-tweaks` branch, merged via PR. Test env mutex, input size limits, grammar checker static sets, doctor word list simplification, deny.toml cleanup.
- **cliff.toml fix (bito-lint, on main):** `remote.contributors` → `github.contributors` (PR #4 had incorrectly migrated it).
- **v0.1.3 released:** All 8 platform binaries built successfully. GPG signatures present. linux-arm64-gnu finally works (`.cargo/config.toml` lld section was already removed). crates.io published (both bito-lint and bito-lint-core, via Cargo 1.90+ workspace publishing).
- **homebrew-brew tap (pushed):** Pre-built binary formula for bito-lint with real v0.1.3 SHA256s. Template + justfile recipe for scaffolding new formulas (`just new-formula <name> <desc> [license]`).

### Done (local, NOT committed/pushed)

These changes are in `~/source/claylo/bito-lint` on the `main` branch, uncommitted:

1. **cd.yml — GPG cleanup:** Moved `rm -f private.key` inline into the signing step (was a separate `if: always()` step that hit Windows where the file doesn't exist).

2. **cd.yml — Homebrew job rewritten:** Replaced `mislav/bump-homebrew-formula-action` with custom step that generates a multi-platform pre-built binary formula from `.sha256` release files and pushes via GitHub API. The bump action can't handle `on_macos`/`on_linux` blocks with multiple `url`/`sha256` pairs.

3. **cd.yml — npm job rewritten for OIDC trusted publishing:**
   - Added job-level `permissions: { contents: read, id-token: write }`
   - Added `npm install -g npm@latest` step (Node 20 ships npm 10.x, OIDC needs >= 11.5.1)
   - Removed all `NODE_AUTH_TOKEN` / `NPM_TOKEN` references
   - Added `--provenance` to publish commands
   - Fixed tar extraction: `--strip-components=2 "*/bin/..."` → `--strip-components=1 "bin/..."` (tarballs have no top-level directory)
   - Fixed error handling: platform publish failures now count and abort before main package publishes

4. **docs/releases.md rewritten:** Homebrew section (pre-built binaries), npm section (trusted publishing bootstrap), GPG instructions (base64 encoding), tarball structure (no top-level dir), troubleshooting additions. All examples de-bito-lint-ified to `your-tool` for template portability.

5. **Deb/RPM signing steps** still lack `rm -f private.key` cleanup (low priority, neither is enabled).

### Done (local, in claylo-rs repo)

- **`~/source/claylo/claylo-rs/claylo-rs/ref/first-release.md`:** Design doc for first-release bootstrap workflow. Covers the full sequence (GitHub secrets → first release → Homebrew verification → npm bootstrap → trusted publishing config → verify pipeline). Includes automation opportunities and a suggested `just first-release` wizard UX.

## Next Steps

1. **Commit and push bito-lint changes.** The cd.yml, docs/releases.md changes are ready. Suggest a single commit: `fix: rewrite CD for pre-built homebrew, npm trusted publishing, and tar extraction`.

2. **npm bootstrap for bito-lint.** When ready:
   - Create granular access token on npmjs.com (scoped to `@claylo`, Publish)
   - Manual first publish of all 7 packages (6 platform + 1 main)
   - Configure trusted publishing on each package at npmjs.com
   - `gh variable set NPM_ENABLED --body "true"`
   - Delete the granular token

3. **Test the Homebrew CD step.** The custom formula generation hasn't been tested in CI yet. Next release (v0.1.4) will be the first real test. Key risk: the `sed -i 's/^          //' formula.rb` heredoc indentation stripping — verify it produces clean Ruby.

4. **Propagate to claylo-rs template.** The releases.md, cd.yml changes, and the first-release workflow design need to flow back into the claylo-rs project template. The `ref/first-release.md` captures the design; actual template updates are TBD.

5. **Deb/RPM signing cleanup.** Add `rm -f private.key` inline to signing steps in `publish-deb` and `publish-rpm` jobs (same pattern as the binary signing fix).

## Key Files

| File | Repo | Status |
|------|------|--------|
| `.github/workflows/cd.yml` | bito-lint | Modified locally, not committed |
| `docs/releases.md` | bito-lint | Modified locally, not committed |
| `Formula/bito-lint.rb` | homebrew-brew | Pushed |
| `template.rb` | homebrew-brew | Pushed |
| `justfile` | homebrew-brew | Pushed |
| `ref/first-release.md` | claylo-rs | Created locally, not committed |

## Gotchas

- **Cargo 1.90+ workspace publishing:** `cargo publish --locked` at workspace root publishes `default-members` in dependency order. bito-lint's `default-members = ["crates/*"]` publishes both bito-lint-core and bito-lint. This is intentional but wasn't understood initially.
- **GPG secrets:** Must be `gpg --armor ... | base64 | gh secret set ...`. Raw armored keys break because GitHub secrets strip newlines.
- **npm trusted publishing:** Packages must exist before you can configure OIDC. Manual first publish required. Classic npm tokens deprecated Dec 2025 — use granular access tokens.
- **Homebrew bump action limitation:** `mislav/bump-homebrew-formula-action` regex-replaces only the FIRST `url`/`sha256` in a formula. Multi-platform formulas with `on_macos`/`on_linux` blocks need a custom approach.
- **Release tarball structure:** No top-level directory. Paths start at `bin/`, `share/`, etc. Tar extraction needs `--strip-components=1`, not `--strip-components=2`.
- **cliff.toml namespacing:** Commit-level data uses `commit.remote.*`. Release-level contributor data uses `github.contributors` (NOT `remote.contributors`). PR #4 incorrectly changed the latter.

## What Worked / Didn't Work

| Approach | Outcome |
|----------|---------|
| Using bump-homebrew-formula-action for pre-built binaries | **Failed** — can't handle multiple url/sha256 fields |
| Custom formula generation via GitHub API push | **Works** — generates from .sha256 files, pushes via `gh api` |
| OIDC trusted publishing for npm | **Not yet tested in CI** — workflow is written, needs first manual publish bootstrap |
| `<<-RUBY` heredoc with tab stripping in justfile | **Failed** — justfile requires consistent indentation, can't mix tabs/spaces |
| Template file + sed substitution for formula scaffolding | **Works** — clean, simple, no indentation issues |
| `sed -E 's/(^|-)([a-z])/\U\2/g'` for PascalCase | **Failed** — macOS sed doesn't support `\U` |
| `perl -pe 's/(^|-)(.)/uc($2)/ge'` for PascalCase | **Works** on macOS |

## Commands

```bash
# Check uncommitted bito-lint changes
cd ~/source/claylo/bito-lint && git diff --stat

# Check v0.1.3 CD run status
gh run list --repo claylo/bito-lint --limit 5

# Verify the homebrew formula is installable
brew tap claylo/brew && brew install bito-lint

# Check what npm packages exist under @claylo
npm search @claylo 2>/dev/null || echo "none published yet"
```

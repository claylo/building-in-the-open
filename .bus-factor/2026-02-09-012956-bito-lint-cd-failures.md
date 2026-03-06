# Handoff: bito-lint CD — linux-arm64-gnu + Homebrew tap

## Current State

bito-lint v0.1.2 released. 7 of 8 binary targets succeed. `linux-arm64-gnu` still fails at link time. Homebrew publishing skipped (and broken even if it ran). crates.io publish succeeded.

### v0.1.2 CD results

| Target | Result |
|--------|--------|
| linux-x64-gnu | pass |
| linux-x64-musl | pass |
| linux-arm64-gnu | **FAIL** |
| linux-arm64-musl | pass (was failing in v0.1.0, fixed in v0.1.2) |
| darwin-x64 | pass |
| darwin-arm64 | pass |
| windows-x64-msvc | pass |
| windows-arm64-msvc | pass |
| crates.io | pass |
| Homebrew | skipped (needs publish-binaries to fully pass) |

### What's broken: linux-arm64-gnu

**Symptom:** `collect2: fatal error: cannot find 'ld'` during linking.

**Root cause:** `.cargo/config.toml` in the repo sets two config keys for `aarch64-unknown-linux-gnu`:

```toml
[target.aarch64-unknown-linux-gnu]
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld"]
```

The CD workflow overrides the `linker` key via `CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc` — this works. But the `rustflags` containing `-fuse-ld=lld` are NOT overridden, so GCC is invoked as the linker driver but told to delegate to `lld`, which can't find `ld` for the aarch64 sysroot on the GitHub Actions runner.

**What was tried and failed (v0.1.2):**
Setting `CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS=""` to clear the rustflags via env var. Did not work — the `-fuse-ld=lld` flag still appeared in the link command. Empty string either doesn't override array config values, or cargo doesn't support target-specific rustflags via env var for arrays.

**Why linux-arm64-musl works:** There is no `[target.aarch64-unknown-linux-musl]` section in `.cargo/config.toml`, so it has no lld flags to conflict with the cross-linker.

### Approaches to try next

1. **Remove the aarch64-gnu section from `.cargo/config.toml` entirely.** It's a dev-time optimization (lld is faster than default ld). Developers on aarch64 Linux can add it locally. This is the simplest fix.

2. **Override `.cargo/config.toml` in CI** by writing a stripped version before build:
   ```bash
   # In the aarch64-gnu build step:
   sed -i '/\[target.aarch64-unknown-linux-gnu\]/,/^$/d' .cargo/config.toml
   ```

3. **Use `CARGO_BUILD_RUSTFLAGS`** (global, not target-specific) to override all rustflags. Nuclear option — may strip useful flags from other targets. Not recommended.

4. **Use `cross-rs`** for cross-compilation targets. Handles sysroot and linker setup automatically in Docker containers. More infrastructure but eliminates these issues permanently.

### What's broken: Homebrew tap

The `publish-homebrew` job uses `mislav/bump-homebrew-formula-action` but doesn't specify the tap:

```yaml
- name: Bump formula
  uses: mislav/bump-homebrew-formula-action@56a283fa15557e9abaa4bdb63b8212abc68e655c # v3.6
  with:
    formula-name: ${{ env.PROJECT_NAME }}
    # MISSING: homebrew-tap: claylo/homebrew-brew
```

Without `homebrew-tap`, the action defaults to `Homebrew/homebrew-core`. Fix is one line.

The job also has a structural problem: it `needs: publish-binaries`, which requires ALL matrix jobs to pass. Since `linux-arm64-gnu` keeps failing, Homebrew is perpetually skipped. Options:
- Fix the arm64-gnu build (preferred)
- Change `publish-homebrew` to not depend on `publish-binaries` (Homebrew only needs darwin binaries anyway)
- Use `if: always() && needs.publish-binaries.result != 'cancelled'` to run even on partial failure

## building-in-the-open repo (unchanged from previous handoff)

Still has uncommitted changes from Phase 3/4 work:
- Modified: `.gitignore`, `.justfile`, `README.md`
- New: `CHANGELOG.md`, `docs/installation.md`, `docs/quickstart.md`, `.github/`, `test/`
- Stale `Cargo.lock` to remove
- GitHub repo not yet created

## Key Files

| File | Why |
|------|-----|
| `~/source/claylo/bito-lint/.cargo/config.toml` | The source of the lld rustflags — lines 27-29 |
| `~/source/claylo/bito-lint/.github/workflows/cd.yml` | Build step lines 95-108 — current (broken) override attempt |
| `~/source/claylo/bito-lint/.github/workflows/cd.yml` | Homebrew job lines 226-237 — missing `homebrew-tap` |

## Commit History (bito-lint)

```
750f2ed chore(release): prepare v0.1.2
8cd30aa fix(build): help linux-arm64-gnu find the right ld (#3)
8441001 chore(release): prepare v0.1.1
2519a9c fix(build): make sure build targets are installed (#2)
8218999 chore(release): prepare v0.1.0
```

## What Worked

- `CARGO_TARGET_*_LINKER` env var correctly overrides the `linker` config key
- Musl arm64 cross-compilation now works with just the gcc linker override (no lld conflict)
- 7 of 8 binary targets + crates.io all working

## What Didn't Work

- `CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS=""` does NOT clear target-specific rustflags from `.cargo/config.toml`. The `-fuse-ld=lld` flag persists in the link command. This was the v0.1.2 fix attempt.
- Cannot override array-type config values via empty-string env vars in cargo (or the mapping doesn't work as documented for target-specific rustflags).

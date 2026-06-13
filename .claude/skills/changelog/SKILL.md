---
name: changelog
description: Analyse commits since the last vX.X.X tag, recommend the next semantic version, and write a common-changelog entry to CHANGELOG.md.
---
# changelog Skill

## Purpose
Read the commit history since the last `vX.X.X` git tag, classify each commit, recommend
the next semantic version, let the user confirm or override it, then write a release entry
to `CHANGELOG.md` following the [common-changelog](https://github.com/vweevers/common-changelog) format.

## Common-changelog format reference
(Embedded here so the skill works without network access.)

- `CHANGELOG.md` starts with a `# Changelog` first-level heading.
- Each release entry: `## <version> - <YYYY-MM-DD>` (semver without `v`; ISO 8601 date).
- Entries are sorted **latest-first**; no "Unreleased" section.
- Change groups in fixed order: **Changed**, **Added**, **Removed**, **Fixed** (`### <category>` headings). Omit empty groups.
- Each group is an unordered list. Items are **imperative mood, self-describing** one-liners (e.g. "Add dark mode toggle", not "Dark mode support added").
- **Breaking changes** are prefixed `**Breaking:** ` and listed first within their group.

## Steps

### Step 1 — Find the last version tag

Run:
```
git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname
```

Take the **first** result (highest semver tag). Strip the leading `v` to get the base
version (e.g. `v1.2.3` → `1.2.3`). The commit range is `<tag>..HEAD`.

**No-tag case:** If the command returns nothing, do **not** guess. Tell the user no
`vX.X.X` tag was found, then use `AskUserQuestion` to ask:
1. What version should this first release be? (e.g. `0.1.0`)

Treat the user-supplied version as the release version (skip the version recommendation
step, since there is no prior version to bump from) and use the initial commit ref as the
start of the commit range.

### Step 2 — Gather commits in range

Run:
```
git log <range> --pretty=format:"%H%x09%s%x09%b" --no-merges
```

Where `<range>` is either `<tag>..HEAD` (tag found) or `<firstCommit>..HEAD` (no-tag
case, where `<firstCommit>` is the base ref chosen in Step 1). Include the first commit
itself when there is no prior tag by using `<firstCommit>^..HEAD` if it has a parent, or
simply `git log HEAD --pretty=...` when the first commit has no parent.

If the range yields **no commits**, tell the user there is nothing new to release and
stop.

Collect: full hash, subject line, and body (for footer detection).

### Step 3 — Classify each commit

Map each commit to one of the four common-changelog categories using the following rules:

| Conventional Commits type / signal | Category |
|------------------------------------|----------|
| `feat`, `feature` | **Added** |
| `fix`, `bugfix` | **Fixed** |
| `refactor`, `perf`, `style`, behaviour-changing `chore` | **Changed** |
| Commits that remove something (type `remove` or message contains "remove"/"delete") | **Removed** |

**Breaking change detection** (prefix entry with `**Breaking:** ` and list it first):
- Subject contains `!` before the colon (e.g. `feat!:`, `feat(scope)!:`)
- Body/footer contains a line beginning with `BREAKING CHANGE:`
- Subject or body explicitly contains the phrase "breaking change"

**Skip** (do not include in changelog — noise with no user-facing impact):
- `chore`, `ci`, `build`, `docs`, `test`, `style` commits *unless* they are user-facing
  (e.g. a `docs:` commit that ships a new man page or README that end-users read is
  **Added**; a `style:` lint fix is skipped).
- Merge commits (already excluded by `--no-merges`).
- Version-bump commits (subject matches `chore: release`, `chore: bump version`, etc.).

When a commit's type is ambiguous, use the subject wording to infer the best category.

### Step 4 — Recommend the next semantic version

*(Skip this step in the no-tag case — the user already supplied the version.)*

Determine the bump level from the **highest-impact** change classified:

| Highest impact | Bump |
|----------------|------|
| Any breaking change | **major** |
| Any Added entry | **minor** |
| Only Fixed / Changed / Removed entries | **patch** |

Compute the new version by incrementing the appropriate component of the base version and
resetting lower components to zero (e.g. `1.2.3` + minor → `1.3.0`).

Tell the user the recommendation and the reason clearly, for example:
> Recommendation: **minor** bump → `1.3.0`
> Reason: 3 new features added, no breaking changes.

### Step 5 — Let the user choose the version

Use `AskUserQuestion` with:
- **First option:** the recommended version, labelled e.g. `1.3.0 (minor bump — Recommended)`.
- The tool's built-in **Other** option lets the user type any version.

After the user responds, validate the chosen version matches `X.Y.Z` (digits only, no `v`
prefix). If it doesn't, ask again.

### Step 6 — Write the changelog entry

Compose the new release block:

```md
## <version> - <YYYY-MM-DD>

### Changed
- <imperative entry>
- **Breaking:** <imperative entry>

### Added
- <imperative entry>

### Removed
- <imperative entry>

### Fixed
- <imperative entry>
```

Rules:
- Use today's date in `YYYY-MM-DD` format.
- Omit any group (`### Changed`, etc.) that has no entries.
- Within each group, list `**Breaking:** ` entries first, then the rest.
- Each list item: imperative mood, self-describing, one line. No commit hashes, no
  author names, no parenthetical references.
- Do **not** include an "Unreleased" section.

### Step 7 — Update CHANGELOG.md

**File does not exist:** Create it with:
```md
# Changelog

## <version> - <date>
...entries...
```

**File exists:** Insert the new release entry immediately after the `# Changelog`
heading line (and any blank line that follows it), before any existing `## ` entry. This
keeps releases sorted latest-first.

Use the `Edit` tool (or `Write` if creating from scratch) to make this change.

Once done, tell the user:
- The file has been updated.
- The chosen version is `<version>`.
- **Remind them** to create the git tag themselves when they are ready:
  ```
  git tag v<version>
  git push --tags
  ```
  and to commit the updated `CHANGELOG.md`.

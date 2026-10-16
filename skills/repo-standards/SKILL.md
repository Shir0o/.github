---
name: repo-standards
description: Audit, standardize, or onboard repositories with organizational DevOps, AGENTS.md, CI workflows, Dependabot, and GitHub branch rulesets using ~/.github-repo.
---

# Repository Standards & DevOps Skill

Audits, synchronizes, and configures organization repositories using the central repository management tooling located at `~/.github-repo` (the local clone of `Shir0o/.github`).

## Capabilities & Workflows

1. **Audit & Preview (Dry Run)**: Check whether local repositories drift from organizational standards without modifying files or opening PRs.
2. **Apply Standards (Single Repo or All Repos)**: Regenerate `AGENTS.md` (combining global base with local `PROJECT.md`), install CI workflows, Dependabot configs, CodeQL, security policies, branch protection rulesets, and create PRs.
3. **Onboard a New Repo**: Inspect framework/tier, register in `apply-standards.sh`, create initial `PROJECT.md`, and deploy baseline standards and branch protection.
4. **Update Global Standards**: Update global instructions in `templates/base-agents.md` or CI/ruleset templates, then broadcast across repositories.
5. **Cross-Repo Command Execution**: Run arbitrary shell commands or git checks across repository tiers using `workspace-each.sh`.

---

## Central Tooling Reference

All commands run against `~/.github-repo`:
* **Script**: `~/.github-repo/apply-standards.sh`
* **Multi-repo Runner**: `~/.github-repo/scripts/workspace-each.sh`
* **Templates Directory**: `~/.github-repo/templates/`
  * `base-agents.md` (Core guidelines for `AGENTS.md`)
  * `CODEOWNERS` (`* @Shir0o`)
  * `SECURITY.md` (Vulnerability reporting policy)
  * `ci-flutter.yml`, `ci-node.yml` (CI PR gates)
  * `codeql.yml` (CodeQL security analysis)
  * `dependabot-flutter.yml`, `dependabot-node.yml`, `dependabot-python.yml`, `dependabot-actions-only.yml`
  * `ruleset-tier1.json` (PR required + CI pass + 1 review + linear history)
  * `ruleset-tier2.json` (PR required + branch protection)

---

## Workflows

### 1. Preview / Dry-Run Drift
To see pending drift or unapplied standards across repos:
```bash
cd ~/.github-repo
./apply-standards.sh
```
To check a specific repo:
```bash
cd ~/.github-repo
./apply-standards.sh --repo <repo_name>
```

### 2. Apply Standards to a Single Repo
When a single repository needs its `AGENTS.md` regenerated or its DevOps files updated:
```bash
cd ~/.github-repo
./apply-standards.sh --apply --repo <repo_name>
```
*Note*: This checks out a branch `chore/standardize-agent-devops`, commits changes, pushes, and creates a PR if diffs exist.

### 3. Onboard a New Repository
When adding a new repository to the organization:
1. **Detect Framework & Tier**:
   - Framework: `flutter`, `node`, `godot`, `python`, or `eleventy`.
   - Tier 1: Active production apps requiring CI + CodeQL + 1 review + linear history.
   - Tier 2: Lightweight experiments, notes, or utilities requiring baseline `AGENTS.md` + Dependabot + PR protection.
2. **Register in `~/.github-repo/apply-standards.sh`**:
   Add entry to `REPOS` array:
   ```bash
   "<local_dir_name>|<tier>|<framework>|<has_functions:yes|no>|Shir0o/<repo_name>"
   ```
3. **Scaffold `PROJECT.md` in Target Repo**:
   Ensure `~/target-repo/PROJECT.md` contains repository-specific context, tech stack notes, and run commands.
4. **Run Apply**:
   ```bash
   cd ~/.github-repo
   ./apply-standards.sh --apply --repo <local_dir_name>
   ```

### 4. Updating Global Agent Instructions or DevOps Templates
To update rules across all repositories:
1. Edit the relevant file in `~/.github-repo/templates/`:
   - Global agent rules: `templates/base-agents.md`
   - CI workflow: `templates/ci-flutter.yml` or `templates/ci-node.yml`
   - Dependabot: `templates/dependabot-*.yml`
   - Rulesets: `templates/ruleset-tier1.json` or `templates/ruleset-tier2.json`
2. Preview changes across fleet:
   ```bash
   cd ~/.github-repo
   ./apply-standards.sh
   ```
3. Apply changes and create PRs across all repos:
   ```bash
   cd ~/.github-repo
   ./apply-standards.sh --apply
   ```
4. Commit and push the template changes in `Shir0o/.github`:
   ```bash
   cd ~/.github-repo
   git commit -am "feat: update global agent instructions"
   git push origin main
   ```

### 5. Running Commands Across Repositories
Use `workspace-each.sh` to query or operate across all or a subset of repos:
```bash
# Check git status across Tier 1 repos
~/.github-repo/scripts/workspace-each.sh --tier 1 -- git status -s

# Check status across all repos
~/.github-repo/scripts/workspace-each.sh --all -- git status -s

# Filter by framework (e.g. Flutter repos)
~/.github-repo/scripts/workspace-each.sh --framework flutter -- flutter pub get
```

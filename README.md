# Shir0o Organization Standards & DevOps

Central repository for global GitHub defaults, agent instructions (`AGENTS.md`), and automated DevOps templates across all `@Shir0o` repositories.

---

## Quick Reference Commands

All commands are run from `~/.github-repo`:

```bash
cd ~/.github-repo
```

### 1. Daily & Workflow Commands

| Action | Command | Description |
| :--- | :--- | :--- |
| **Dry Run (Preview)** | `./apply-standards.sh` | Safely preview what would change across all 19 repos without touching files or opening PRs. |
| **Apply to Single Repo** | `./apply-standards.sh --apply --repo <name>` | Regenerate `AGENTS.md` and sync DevOps files for one specific repository (e.g. `--repo attd`). |
| **Apply to All Repos** | `./apply-standards.sh --apply` | Apply standards across all repos, create branch `chore/standardize-agent-devops`, commit, and open PRs. |

---

### 2. Updating Standards (Step-by-Step Playbooks)

#### A. Updating a Global Agent Rule (All Repos)
When you want to update global behavioral guidelines, TDD rules, or token/cost rules:

```bash
cd ~/.github-repo

# 1. Edit the shared base template
nano templates/base-agents.md

# 2. Preview the diff across all repos
./apply-standards.sh

# 3. Apply changes and open PRs across all repos
./apply-standards.sh --apply

# 4. Commit and push the template update to Shir0o/.github
git commit -am "feat: update global agent TDD rules"
git push origin main
```

#### B. Updating a Project-Specific Rule (1 Repo)
When adding instructions specific to one app (e.g. skeleton loaders for `attd`, Godot recording in `idle`):

```bash
# 1. Edit PROJECT.md directly in that repo
nano ~/attd/PROJECT.md

# 2. Re-sync AGENTS.md for that repo
cd ~/.github-repo
./apply-standards.sh --apply --repo attd
```

#### C. Updating DevOps Configuration (e.g., Dependabot or CI)
When adjusting Dependabot intervals, adding CI test steps, or modifying branch protection:

```bash
cd ~/.github-repo

# 1. Edit the relevant template in templates/
#    - templates/dependabot-flutter.yml
#    - templates/dependabot-node.yml
#    - templates/ci-flutter.yml
#    - templates/ci-node.yml
#    - templates/ruleset-tier1.json
#    - templates/ruleset-tier2.json
nano templates/ci-flutter.yml

# 2. Apply to target repos
./apply-standards.sh --apply

# 3. Save template changes
git commit -am "chore(ci): update flutter action version"
git push origin main
```

---

## Directory Structure

```text
~/.github-repo/
├── .github/
│   ├── CODEOWNERS              ← Global GitHub fallback (used automatically if repo lacks one)
│   └── SECURITY.md             ← Global GitHub fallback security policy
├── templates/
│   ├── base-agents.md          ← Shared core rules for AGENTS.md
│   ├── CODEOWNERS              ← Standard template (* @Shir0o)
│   ├── SECURITY.md             ← Standard private vulnerability reporting template
│   ├── dependabot-flutter.yml  ← Dependabot for pub + github-actions
│   ├── dependabot-node.yml     ← Dependabot for npm + github-actions
│   ├── dependabot-python.yml   ← Dependabot for pip + github-actions
│   ├── dependabot-actions-only.yml ← Dependabot for actions only (Godot)
│   ├── ci-flutter.yml          ← Standard Flutter PR gate
│   ├── ci-node.yml             ← Standard Node PR gate
│   ├── codeql.yml              ← CodeQL security analysis (JS/TS)
│   ├── ruleset-tier1.json      ← Full branch protection (PR + CI + 1 review + linear history)
│   └── ruleset-tier2.json      ← Lightweight branch protection (PR required)
├── apply-standards.sh          ← Rollout engine
└── README.md                   ← Documentation
```

---

## Repository Registry & Tiers

The script manages repos in two tiers:

- **Tier 1 (Full Standard)**: Active projects with CI, releases, and full branch rulesets.
  `attd`, `bible-read`, `cisa-campus-work-tracker`, `bnpb`, `auto-vol`, `cleaning-tracker`, `diary`, `wave`, `road-song`, `idle-flame`
- **Tier 2 (Lightweight)**: Experiments/scripts with baseline `AGENTS.md`, Dependabot, and lightweight branch rulesets.
  `sleep-journal`, `idle`, `csa`, `package-maker`, `notes`, `inventory`, `circle`, `shared-calendar`, `helpful-scripts`

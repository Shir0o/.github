# GitHub Security, Code Scanning & Repository Standards

This document establishes the security standards, code analysis baselines, and configuration playbooks for all repositories under `@Shir0o`.

---

## 1. Feature Availability: Free vs. Paid

GitHub provides an extensive set of security features at zero cost for public repositories, while certain advanced features require a GitHub Advanced Security (GHAS) license for private repositories.

| Feature | Public Repositories | Private Repositories |
| :--- | :--- | :--- |
| **CodeQL Code Scanning** | **100% Free** (Default & Extended suites) | Paid (Requires GHAS license) |
| **Copilot Autofix** | **100% Free** (Bundled with CodeQL) | Paid (Requires GHAS + Copilot) |
| **AI Scan for Pull Requests** | **Free Preview** (Enabled via Code Scanning API) | Paid (Requires GHAS) |
| **Dependabot Vulnerability Alerts** | **100% Free** | **100% Free** |
| **Dependabot Security Update PRs** | **100% Free** | **100% Free** |
| **Secret Scanning** | **100% Free** (Built-in) | Paid / Enterprise policy |
| **Secret Push Protection** | **100% Free** (Blocks secret commits) | Paid / Enterprise policy |

> [!IMPORTANT]
> **Strict Cost Guardrail:** Never enable GHAS-dependent features (such as CodeQL or Secret Scanning) on private repositories unless explicitly licensed. Keep private repositories strictly on the 100% free tier (Dependabot alerts and automated security PRs).

---

## 2. Onboarding Playbook for Future Repositories

Whenever creating or importing a new repository under `@Shir0o`, execute the appropriate onboarding commands below.

### A. New Public / Open-Source Repository

Run these commands with the `gh` CLI:

```bash
REPO="Shir0o/<repo-name>"

# 1. Enable CodeQL default setup with extended query suite (enables Copilot Autofix)
gh api -X PATCH "repos/$REPO/code-scanning/default-setup" \
  -f state=configured \
  -f query_suite=extended

# 2. Enable AI Scan for Pull Requests
gh api -X PATCH "repos/$REPO/code-scanning/ai-scan" \
  -f pr_scan=enabled

# 3. Enable Dependabot vulnerability alerts
gh api -X PUT "repos/$REPO/vulnerability-alerts"

# 4. Enable Dependabot automated security fix PRs
gh api -X PUT "repos/$REPO/automated-security-fixes"

# 5. Enable Secret Scanning and Push Protection
gh api -X PATCH "repos/$REPO" --input - <<'JSON'
{
  "security_and_analysis": {
    "secret_scanning": {"status": "enabled"},
    "secret_scanning_push_protection": {"status": "enabled"}
  }
}
JSON
```

### B. New Private Repository (Strictly Free Tools)

For private repositories, enable only the free Dependabot features:

```bash
REPO="Shir0o/<repo-name>"

# 1. Enable Dependabot vulnerability alerts
gh api -X PUT "repos/$REPO/vulnerability-alerts"

# 2. Enable Dependabot automated security fix PRs
gh api -X PUT "repos/$REPO/automated-security-fixes"
```

---

## 3. Pre-Flight Checklist: Converting Private Repos to Public

Before changing any private repository's visibility to public, execute the following audit:

1. **Secrets & Credentials Audit:**
   - Scan working tree for uncommitted sensitive files (`.env`, `.pem`, `.key`, `serviceAccountKey.json`, `credentials.json`, `export_credentials.cfg`).
   - Audit git commit history for inadvertently committed secrets:
     ```bash
     git log --all --full-history --oneline -- '**.env*'
     ```
   - Ensure all `.env*` patterns (except `.env.example`) are present in `.gitignore`.
2. **Open-Source License:**
   - Ensure a root `LICENSE` file exists (standard choices: MIT, Apache-2.0).
3. **Documentation:**
   - Ensure a clear `README.md` exists describing the project, setup steps, and prerequisites.
4. **DevOps & Standards:**
   - Run `apply-standards.sh --repo <name>` from `~/.github-repo` to install `CODEOWNERS`, `SECURITY.md`, and unified agent instructions.
5. **Convert Visibility:**
   ```bash
   gh repo edit Shir0o/<name> --visibility public
   ```
6. **Activate Public Security Suite:**
   - Run the commands from Section 2.A to activate CodeQL, Copilot Autofix, and AI PR scanning.

---

## 4. Repository Inventory & Tracking

### Public Repositories (Full Suite Active)

| Repository | Local Path | CodeQL & Copilot Autofix | AI Scan (PR) | Dependabot Alerts & PRs | Secret Push Protection |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Shir0o/circle` | `~/circle` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/auto-vol` | `~/auto-vol` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/attd` | `~/attd` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/bnpb` | `~/bnpb` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/road-song` | `~/road-song` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/package-builder` | `~/package-maker` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/afk-issue-loop-skill` | `~/afk-issue-loop-skill` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/.github` | `~/.github-repo` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/cleaning-tracker` | `~/cleaning-tracker` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/bible-read` | `~/bible-read` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/diary` | `~/diary` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/wave` | `~/wave` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/cisa-campus-work-tracker` | `~/cisa-campus-work-tracker` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/sleep-journal` | `~/sleep-journal` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/inventory` | `~/inventory` | Extended | Enabled | Enabled | Enabled |
| `Shir0o/shared-calendar` | `~/shared-calendar` | Extended | Enabled | Enabled | Enabled |

### Private Repositories (Free Tools Only)

| Repository | Local Path | Dependabot Alerts | Dependabot PRs | GHAS / CodeQL |
| :--- | :--- | :--- | :--- | :--- |
| `Shir0o/csa` | `~/csa` | Enabled | Enabled | Kept Free (Disabled) |
| `Shir0o/idle` | `~/idle` | Enabled | Enabled | Kept Free (Disabled) |
| `Shir0o/idle-flame` | `~/idle-flame` | Enabled | Enabled | Kept Free (Disabled) |
| `Shir0o/notes` | `~/notes` | Enabled | Enabled | Kept Free (Disabled) |
| `Shir0o/helpful-scripts` | `~/helpful-scripts` | Enabled | Enabled | Kept Free (Disabled) |


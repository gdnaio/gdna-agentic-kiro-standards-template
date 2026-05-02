---
inclusion: auto
---

# GitHub Workflow Rules

> Supplements git-standards.md and mcp-best-practices.md.
> In case of conflict, git-standards.md governs commit format, branching, and PR requirements.

## Default Organization
- Default org is `gdnaio`. Assume `gdnaio` unless the user specifies otherwise.
- Never create repos under personal accounts unless explicitly asked.

## Repository Creation
- Use MCP `create_repository` with `organization: "gdnaio"` — always include the org parameter.
- Default to `private: true` unless the user explicitly asks for public.

## Template Repos
- `gdnaio/gdna-aidlc-kiro-standards-template` — general AIDLC projects
- `gdnaio/gdna-hubspot-kiro-standards-template` — HubSpot CMS projects
- `gdnaio/gdna-agentic-kiro-standards-template` — pure agentic/agentcore projects

## Initial Push (Bootstrap Exception)
- Per git-standards.md, `main` is protected and requires PRs for normal work.
- **Exception**: When bootstrapping a brand-new repo, push the initial commit directly to `main`.
- After the initial push, all subsequent work follows git-standards.md.

## MCP GitHub Server
- Official `github/github-mcp-server` via Homebrew.
- Token vended via AWS Secrets Manager (`gdnaio/kiro-github-mcp-token`).
- Dev setup: `brew install github-mcp-server jq && .kiro/scripts/bootstrap-github-mcp.sh`

## DESTRUCTIVE OPERATIONS — BLOCKED
- Repository deletion, force push, branch protection changes, org settings changes — all blocked.
- If needed, user must do it manually on GitHub.

## Allowed Operations
- Create repos (with `organization: "gdnaio"`), read/write files, branches, PRs, issues, comments, reviews.

## PRs: conventional commit titles, squash merge to main.
## Branches: `{type}/{ticket}-{short-description}`

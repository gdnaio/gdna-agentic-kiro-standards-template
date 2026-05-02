---
inclusion: auto
---

# GitHub Workflow Rules

> This file supplements the g/d/n/a git-standards.md and mcp-best-practices.md from the AIDLC template.
> Where those standards define general git and MCP behavior, this file handles GitHub-specific operational rules.
> In case of conflict, git-standards.md governs commit format, branching, and PR requirements.

## Default Organization
- Default org is `gdnaio`. When the user says "create a repo" or references repos without specifying an owner, assume `gdnaio`.
- Never create repos under `gdnawill` (personal account) unless explicitly asked.

## Repository Creation
- The MCP `create_repository` tool does NOT support an organization parameter — **never use it**.
- Use the `gh` CLI instead:
  ```bash
  gh repo create gdnaio/<repo-name> --private --description "<description>"
  ```
- Default to `--private` unless the user explicitly asks for a public repo.

## Template Repos
- The org has these Kiro standards templates:
  - `gdnaio/gdna-aidlc-kiro-standards-template` — general AIDLC projects
  - `gdnaio/gdna-hubspot-kiro-standards-template` — HubSpot CMS projects
  - `gdnaio/gdna-agentic-kiro-standards-template` — pure agentic/agentcore projects
- To create a repo from a template, use `gh`:
  ```bash
  gh repo create gdnaio/<new-repo> --template gdnaio/<template-repo> --private --clone
  ```

## Initial Push (Bootstrap Exception)
- Per git-standards.md, `main` is protected and requires PRs for normal work.
- **Exception**: When bootstrapping a brand-new repo, push the initial commit directly to `main`:
  ```bash
  git init
  git remote add origin https://github.com/gdnaio/<repo-name>.git
  git add .
  git commit -m "chore: initial project scaffold"
  git branch -M main
  git push -u origin main
  ```
- After the initial push, all subsequent work follows git-standards.md: feature branches, PRs, squash merge.
- Do NOT use MCP `push_files` or `create_or_update_file` for initial repo setup — they are unreliable on fresh repos.

## MCP GitHub Tool Rules
- **Known limitation**: MCP `get_file_contents` requires the `branch` parameter for `gdnaio` repos. Always pass `branch: "main"` (or the target branch).
- If any MCP GitHub tool fails on a `gdnaio` repo, immediately fall back to `gh` CLI — don't retry MCP.
- MCP search/list tools (search_repositories, list_issues, list_pull_requests, list_commits) work reliably. Use them normally with `gdnaio` as owner.

## PRs and Merges
- Use `gh` CLI for PR creation to stay consistent:
  ```bash
  gh pr create --title "<type>(scope): description" --body "<description>" --base main
  ```
- PR titles follow conventional commit format per git-standards.md.
- Squash merge to `main` per git-standards.md.

## Branch Naming
- Per git-standards.md: `{type}/{ticket}-{short-description}`
- Examples: `feat/TICKET-123-add-dashboard`, `fix/TICKET-456-login-redirect`

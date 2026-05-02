# Kiro IDE Setup for g/d/n/a Developers

This project uses [Kiro IDE](https://kiro.dev) with g/d/n/a standards.

## Quick Setup

```bash
brew install github-mcp-server jq
.kiro/scripts/bootstrap-github-mcp.sh
```

Test: open Kiro, new chat, ask "List repos in gdnaio"

## What It Does

Pulls the shared GitHub PAT from AWS Secrets Manager (`gdnaio/kiro-github-mcp-token`) and configures `~/.kiro/settings/mcp.json`.

## Shared PAT Permissions

| Permission | Access | Why |
|---|---|---|
| Contents | Read and write | Files, commits, branches |
| Metadata | Read-only | Required for all API calls |
| Pull requests | Read and write | PRs and reviews |
| Issues | Read and write | Issues and comments |
| Administration | Read and write | Repo creation (also enables deletion — blocked by safety hook) |
| Members (org) | Read-only | Team lookups |

Create at: [github.com/settings/tokens?type=beta](https://github.com/settings/tokens?type=beta) with `gdnaio` as resource owner.

## Safety Architecture

1. **Token**: Minimum permissions. Admin granted only for repo creation.
2. **Hook** (`.kiro/hooks/github-safety-gate.kiro.hook`): Blocks delete/fork MCP calls.
3. **Steering** (`.kiro/steering/github-workflow.md`): Rules for allowed/blocked operations.

Kiro can create/read/write repos and PRs but **cannot** delete repos, fork, or change branch protections.

## Token Rotation

Admin: `.kiro/scripts/admin-setup-github-secret.sh` → Devs: re-run `.kiro/scripts/bootstrap-github-mcp.sh`

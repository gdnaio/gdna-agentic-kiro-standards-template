# Kiro IDE Setup for g/d/n/a Developers

This project uses [Kiro IDE](https://kiro.dev) with the g/d/n/a AIDLC standards.

## Quick Setup

```bash
brew install github-mcp-server jq
.kiro/scripts/bootstrap-github-mcp.sh
# Or with AWS profile: .kiro/scripts/bootstrap-github-mcp.sh --profile your-profile
```

Test: open Kiro, new chat, ask "List repos in gdnaio"

## What It Does

1. Pulls the shared GitHub PAT from AWS Secrets Manager (`gdnaio/kiro-github-mcp-token`)
2. Configures `~/.kiro/settings/mcp.json` with the official GitHub MCP server
3. Applies to all Kiro workspaces

## Manual Setup (No AWS Access)

Ask admin for a PAT, then edit `~/.kiro/settings/mcp.json`:

```json
{"mcpServers":{"github":{"command":"/opt/homebrew/bin/github-mcp-server","args":["stdio"],"env":{"GITHUB_PERSONAL_ACCESS_TOKEN":"github_pat_YOUR_TOKEN"},"disabled":false,"autoApprove":["search_code","get_file_contents","search_repositories","list_commits","list_pull_requests","create_or_update_file","push_files","create_repository"]}}}
```

## Token Rotation

Admin: `.kiro/scripts/admin-setup-github-secret.sh`
Devs: re-run `.kiro/scripts/bootstrap-github-mcp.sh`

## Safety: Kiro can create/read/write repos and PRs but cannot delete repos, fork, or change branch protections.

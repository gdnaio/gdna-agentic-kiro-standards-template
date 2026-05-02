# Kiro IDE Setup for g/d/n/a Developers

This project uses [Kiro IDE](https://kiro.dev) with the g/d/n/a AIDLC standards. Follow these steps to get your local environment working with the GitHub MCP integration.

## Prerequisites

- [Kiro IDE](https://kiro.dev) installed
- [Homebrew](https://brew.sh) installed (macOS)
- A GitHub account with access to the `gdnaio` organization

## Step 1: Install the Official GitHub MCP Server

```bash
brew install github-mcp-server
```

Verify it installed:

```bash
which github-mcp-server
# Should output: /opt/homebrew/bin/github-mcp-server
```

## Step 2: Create a GitHub Fine-Grained PAT

1. Go to [github.com/settings/tokens?type=beta](https://github.com/settings/tokens?type=beta)
2. Click **Generate new token**
3. Configure:
   - **Token name**: `kiro-mcp-gdnaio`
   - **Expiration**: 90 days (set a calendar reminder to rotate)
   - **Resource owner**: Select **`gdnaio`** (not your personal account)
   - **Repository access**: **All repositories**
4. Under **Repository permissions**, grant:
   - Contents: **Read and write**
   - Metadata: **Read-only** (auto-selected)
   - Pull requests: **Read and write**
   - Issues: **Read and write**
5. Under **Repository permissions**, set to **No access**:
   - Administration (prevents repo deletion)
6. Click **Generate token** and copy it (starts with `github_pat_...`)

> **Security note**: Do NOT grant Administration write access. The safety gate hook blocks destructive operations, but limiting the token is the primary defense.

## Step 3: Configure the MCP Server in Kiro

Edit your **user-level** MCP config at `~/.kiro/settings/mcp.json`.

Add (or replace) the `github` entry inside `mcpServers`:

```json
{
  "mcpServers": {
    "github": {
      "command": "/opt/homebrew/bin/github-mcp-server",
      "args": ["stdio"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "github_pat_YOUR_TOKEN_HERE"
      },
      "disabled": false,
      "autoApprove": [
        "search_code",
        "get_file_contents",
        "search_repositories",
        "list_commits",
        "list_pull_requests",
        "create_or_update_file",
        "push_files",
        "create_repository"
      ]
    }
  }
}
```

Replace `github_pat_YOUR_TOKEN_HERE` with your actual token.

## Step 4: Install the Universal Steering File (Optional)

Copy the GitHub workflow steering to your user-level steering directory so it applies to all workspaces:

```bash
mkdir -p ~/.kiro/steering
cp .kiro/steering/github-workflow.md ~/.kiro/steering/github-workflow.md
```

## Step 5: Verify

Open Kiro, start a new chat, and ask:

> "List repos in gdnaio"

If it returns org repos, you're good. Try:

> "Read the README from gdnaio/gdna-aidlc-kiro-standards-template"

If that works, your MCP integration is fully set up.

## What's Included in This Project

### Safety Protections

- **`.kiro/hooks/github-safety-gate.kiro.hook`** — Blocks destructive GitHub operations (delete, fork) via MCP. These must be done manually on GitHub.
- **`.kiro/steering/github-workflow.md`** — Rules for GitHub operations: default org, allowed/blocked operations, branching conventions.

### What Kiro Can Do (Allowed)
- Create repos under `gdnaio`
- Read/write files in org repos
- Create branches, PRs, issues
- Search code and repos
- Push commits

### What Kiro Cannot Do (Blocked)
- Delete repos, files in protected paths, or branches
- Fork repos
- Change branch protections
- Modify org settings, webhooks, or team permissions
- Force push

## Token Rotation

When your token expires (every 90 days):

1. Generate a new token following Step 2
2. Update `~/.kiro/settings/mcp.json` with the new token
3. The MCP server reconnects automatically

## Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP tools fail silently | Check token hasn't expired. Regenerate if needed. |
| Repo created under personal account | Ensure `organization: "gdnaio"` is passed. Check steering file is loaded. |
| Permission denied on org repo | Token resource owner must be `gdnaio`, not your personal account. |
| `github-mcp-server` not found | Run `brew install github-mcp-server` |

---

*Part of the g/d/n/a AIDLC development standards.*

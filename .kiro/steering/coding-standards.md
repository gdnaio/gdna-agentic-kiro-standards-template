---
title: g/d/n/a Coding Standards
inclusion: always
---

# g/d/n/a Coding Standards

## Core Philosophy
- **Explicit over implicit.** No magic. Name things clearly.
- **Small functions, single responsibility.** If it needs a comment explaining what it does, it's too complex or poorly named.
- **Fail fast, fail loud.** Validate inputs at boundaries. Don't silently swallow errors.
- **No premature abstraction.** Build concrete first. Abstract when you see the pattern repeated, not when you imagine it might be.

## Error Handling
- Custom exception hierarchy per domain (not generic `Exception` catches)
- Structured error responses: `{ "error": { "code": "...", "message": "...", "context": {} } }`
- All errors logged with correlation ID
- Never expose internal stack traces to API callers

## What Agents Must NOT Generate
- Boilerplate comments (e.g., `# This function does X`)
- TODO comments — create issues instead
- Unused imports or dead code
- `.env` files with real values (use `.env.example` only)
- Duplicate files with suffixes like `_fixed`, `_clean`, `_backup`

## Code Quality Rules
- No hardcoded values — all config via environment variables or AWS Secrets Manager
- No code duplication (DRY)
- Pin all dependency versions in `requirements.txt` and use lockfiles
- Async/await for I/O where supported; event-driven design throughout
- Fault-tolerance with safe fallback states
- CI/CD ready from the start

## Package Management
- Python: `pip` with pinned `requirements.txt` (or `pyproject.toml` with `uv`)
- Never introduce `npm`, `yarn`, or `pnpm` — this is a Python-only project type
- Infrastructure: `aws-cdk-lib` via pip, not npm CDK CLI for local commands

## Language-Specific Standards
See `python-standards.md` for Python style, patterns, and type hints.
See `aws-cli-standards.md` for AWS CLI and CDK deployment commands.
See `agentic-ai-standards.md` for agent and MCP tool patterns.

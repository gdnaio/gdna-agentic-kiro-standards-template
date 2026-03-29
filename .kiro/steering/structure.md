---
title: Project Structure
inclusion: always
---

# Project Structure (Agentic)

> **CUSTOMIZE THIS FILE** for each engagement. The base layout below is the g/d/n/a agentic project standard.

This is a Python-first, serverless agentic project. No frontend. No monorepo. See `python-standards.md` for code style, `aws-cli-standards.md` for deployment, and `agentic-ai-standards.md` for agent and MCP tool patterns.

## Standard Layout

```
project-root/
├── src/
│   ├── agents/           # Agent definitions and conversation flows
│   ├── tools/            # MCP tool implementations
│   ├── handlers/         # Lambda handler entry points
│   ├── services/         # Business logic, AWS service clients
│   └── models/           # Pydantic schemas and data models
├── tests/
│   ├── conftest.py       # Shared fixtures (moto, AWS mocks)
│   ├── unit/             # Fast, mocked unit tests
│   └── integration/      # Real AWS calls (run separately in CI)
├── infra/                # AWS CDK stack definitions
│   └── stacks/
├── .kiro/
│   ├── hooks/            # Kiro automation hooks
│   ├── scripts/          # Shell scripts called by hooks
│   ├── specs/            # Project specs (requirements, design, tasks)
│   ├── state/            # Session state (read by Cowork via GitHub)
│   └── steering/         # These files — always loaded into Kiro context
├── pyproject.toml
├── requirements.txt
├── requirements-dev.txt
└── cdk.json
```

## Module Boundaries

| Module | Purpose | Key Dependencies |
|--------|---------|------------------|
| `src/agents/` | Agent logic, Bedrock calls, conversation flows | boto3, strands-agents |
| `src/tools/` | MCP tool definitions and implementations | mcp, pydantic |
| `src/handlers/` | Lambda entry points — thin, validate, delegate | src/agents, src/services |
| `src/services/` | AWS integrations, business logic | boto3 |
| `src/models/` | Pydantic schemas, enums, shared types | pydantic |
| `infra/` | CDK stacks — Lambda, DynamoDB, S3, IAM | aws-cdk-lib |

## [Project-Specific Modules]

[Document your project's specific module boundaries, services, and agent roles here. Replace this section at project kickoff.]

## Naming Conventions
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions and variables: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE`
- Lambda handlers: `handler(event, context)` in `src/handlers/<resource>.py`
- CDK stacks: `PascalCaseStack` in `infra/stacks/<name>_stack.py`

## What Does NOT Belong Here
- No frontend code (`packages/web`, React, Vite, Next.js)
- No monorepo tooling (`pnpm`, `turborepo`, `nx`)
- No TypeScript or JavaScript
- No test files mixed into `src/` — tests live in `tests/` only

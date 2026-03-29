---
title: Git Standards
inclusion: always
---

# g/d/n/a Git Standards

## Commit Messages — Conventional Commits
```
<type>(<scope>): <description>
```

### Types
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation only
- `refactor` — Code change that neither fixes nor adds
- `test` — Adding or fixing tests
- `chore` — Build process, dependencies, tooling
- `ci` — CI configuration changes
- `security` — Security fix or improvement

### Examples
```
feat(agent): add bedrock guardrail for PII redaction
fix(tools): handle timeout on Lambda action group invocation
security(iam): scope bedrock permissions to specific agent ARN
chore(deps): update aws-cdk-lib to 2.150.0
```

## Branch Strategy
```
main                    # Production-ready, protected
├── feat/TICKET-123-description
├── fix/TICKET-456-description
└── release/v1.2.0
```

- No direct commits to `main` — PR required
- Branch names: `{type}/{ticket}-{short-description}`
- Delete branches after merge

## PR Requirements
- All CI checks pass
- At least 1 approval
- Squash merge to `main`

## .gitignore Essentials
```
.venv/
__pycache__/
*.pyc
cdk.out/
.env
.env.local
!.env.example
.DS_Store
coverage/
*.tsbuildinfo
node_modules/
```

## Secrets
- **NEVER commit secrets, tokens, API keys, or credentials**
- If accidentally committed: rotate immediately

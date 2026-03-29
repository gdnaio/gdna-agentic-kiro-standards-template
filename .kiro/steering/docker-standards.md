---
title: Docker Best Practices
inclusion: fileMatch
fileMatchPattern: "*Dockerfile*,*docker-compose*,.dockerignore"
---

# g/d/n/a Docker Standards

## Base Image Selection
- Use official, minimal base images: `python:3.12-slim` or `public.ecr.aws/lambda/python:3.12`
- Pin exact versions — never use `latest` in production
- Multi-stage builds for all production images

## Multi-Stage Build Pattern (Python Lambda)

```dockerfile
# Stage 1: Build dependencies
FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --target /build/deps -r requirements.txt

# Stage 2: Production image
FROM public.ecr.aws/lambda/python:3.12 AS runner

# Copy installed packages
COPY --from=builder /build/deps ${LAMBDA_TASK_ROOT}

# Copy application code
COPY src/ ${LAMBDA_TASK_ROOT}/src/

CMD ["src.handlers.main.handler"]
```

## Security Rules (Non-Negotiable)
- **Never run as root** — Lambda base images handle this; for non-Lambda containers, create a non-root user
- **No secrets in images** — use environment variables injected at runtime or Secrets Manager
- **No secrets in build args** — they persist in image layers
- **Minimize attack surface** — install only required packages, remove caches after install
- **Scan images** — use `docker scout` or `trivy` in CI pipeline
- **.dockerignore** — exclude `.git`, `.env`, `tests/`, `__pycache__`, `.venv`

## .dockerignore Template

```
.git
.gitignore
.env*
!.env.example
*.md
tests/
coverage/
.venv/
__pycache__/
*.pyc
*.pyo
.pytest_cache/
cdk.out/
```

## Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1
```

## Layer Optimization
- Order instructions from least to most frequently changed
- COPY `requirements.txt` before source code (cache the dependencies layer)
- Combine `RUN` commands to reduce layers
- Clean pip caches in the same layer as install (`pip install --no-cache-dir`)

## Container Sizing
- Lambda container images: target under 250MB uncompressed
- Use `python:3.12-slim` over `python:3.12` (saves ~700MB)
- Use `public.ecr.aws/lambda/python:3.12` for Lambda-specific images

## AWS ECR Integration
- Tag images with git commit SHA + environment: `{account}.dkr.ecr.{region}.amazonaws.com/{repo}:{sha}-{env}`
- Enable image scanning on push in CDK
- Lifecycle policies to remove untagged images older than 30 days
- Cross-region replication for disaster recovery where required

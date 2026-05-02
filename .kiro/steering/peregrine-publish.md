---
title: Peregrine Publish Pipeline
inclusion: always
---

# Peregrine Publish Pipeline

This project includes a CI/CD pipeline that packages build artifacts and ships them to Peregrine for hosting and deployment.

## peregrine.json — Fill It In

**When you know the product name and slug, fill in peregrine.json immediately.** Do not leave CHANGE_ME.

### Project type → domain + artifact conventions

| projectType | Default artifactPath | Zip produced | Default domain | Deploys to |
|-------------|---------------------|-------------|----------------|----------|
| `landing-page` | `landing/` | `landing-dist.zip` | `landing.gdna.io` | `{slug}.landing.gdna.io` |
| `demo` | `demo/` | `demo-bundle.zip` | `demos.gdna.io` | `{slug}.demos.gdna.io` |
| `onboarding` | `onboarding/` | `onboarding-dist.zip` | `onboarding.gdna.ai` | `{slug}.onboarding.gdna.ai` |
| `saas-app` | `dist/` | `frontend-dist.zip` | custom | Customer account |

### Shared hosting lanes

| Lane | Bucket | Domain | Cert |
|------|--------|--------|------|
| Landing pages | `peregrine-landing-pages-{env}` | `*.landing.gdna.io` | `*.landing.gdna.io` |
| Demos | `peregrine-demos-{env}` | `*.demos.gdna.io` | `*.demos.gdna.io` |
| Onboarding | `peregrine-onboarding-{env}` | `*.onboarding.gdna.ai` | `*.onboarding.gdna.ai` |

## Pipeline: tag → zip → S3 → Peregrine

1. Build in the `artifactPath` directory
2. `git tag v0.1.0 && git push --tags`
3. GH Actions packages and deploys automatically

Manual: `.kiro/scripts/package-release.sh 0.1.0`

## Rules
- Write peregrine.json early
- Use lowercase hyphenated values for productId and slug
- Use the correct domain for the project type
- Don't invent new projectTypes: `landing-page`, `demo`, `onboarding`, `saas-app`

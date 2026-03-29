---
title: Agentic AI Standards (AWS Bedrock)
inclusion: fileMatch
fileMatchPattern: "*agent*,*guardrail*,*bedrock*,*knowledge-base*"
---

# g/d/n/a Agentic AI Standards — AWS Bedrock & AgentCore

## Overview
Standards for designing, building, deploying, and governing AI agents on AWS Bedrock. These apply to all g/d/n/a projects involving autonomous or semi-autonomous AI systems, from simple RAG pipelines to multi-agent orchestration.

## Architecture Decision Tree

### When to Use What
1. **Simple Q&A / RAG** → Bedrock Knowledge Bases + Foundation Model. No agent needed.
2. **Single-task automation** → Bedrock Agent with action groups. One agent, scoped tools.
3. **Multi-step workflow with human approval** → Bedrock Agent with return-of-control. Agent proposes, human confirms.
4. **Multi-agent orchestration** → AgentCore with supervisor pattern. Multiple specialized agents coordinated by an orchestrator.
5. **Long-running autonomous tasks** → AgentCore with persistent sessions, checkpointing, and guardrails.

**Default: Start with the simplest pattern that solves the problem. Escalate complexity only when requirements demand it.**

## Agent Design Principles

### 1. Single Responsibility per Agent
Each agent has ONE clear domain and purpose. Never build a "do everything" agent.

### 2. Explicit Tool Boundaries
Agents interact with the world through TOOLS (action groups). Each tool must:
- Have a clear, descriptive name and description
- Accept well-defined input schemas
- Return structured output with success/failure indication
- Have explicit permissions — least privilege IAM
- Be idempotent where possible

### 3. Human-in-the-Loop by Default
- **Return-of-control** for any action that modifies data, spends money, or contacts external systems
- **Confirmation prompts** before irreversible actions
- **Audit trail** of every agent decision and action taken
- **Override capability** — humans can always intervene

### 4. Guardrails Are Non-Negotiable
Every agent deployment MUST include Bedrock Guardrails:
- Content filters (toxicity, PII, prompt injection defense)
- Topic restrictions (keep agent within its domain)
- PII redaction for data flowing through the agent
- Grounding checks to reduce hallucination

## AgentCore Standards (Multi-Agent)

### Supervisor Pattern
```
Supervisor Agent
├── Routes requests to specialized agents
├── Aggregates results
├── Handles failures and retries
└── Maintains conversation state

Specialized Agents
├── Agent A: Domain-specific task
├── Agent B: Domain-specific task
└── Agent C: Domain-specific task
```

### Agent Communication
- Agents communicate through structured messages, never free-form text between agents
- Input/output schemas defined and validated at boundaries
- Correlation IDs propagated across agent calls for tracing
- Timeout and retry policies per agent interaction

## Model Selection Standards

| Use Case | Default Model | Rationale |
|----------|---------------|-----------|
| Complex reasoning, analysis | Claude Sonnet 4 | Best reasoning-to-cost ratio |
| Simple classification, routing | Claude Haiku | Fast, cheap, good enough |
| High-stakes decisions | Claude Opus | Maximum capability when accuracy is critical |
| Embeddings | Titan Embed Text v2 | AWS-native, cost-effective |

- **Never hardcode model IDs** — use configuration
- **Always set max tokens** — prevent runaway costs
- **Temperature: 0 for factual tasks**, 0.3-0.7 for creative tasks

## Testing Agentic Systems

- Test each action group Lambda independently
- Mock Bedrock API calls in unit tests
- Validate guardrails block prohibited content
- Test human-in-the-loop flows
- Red team: prompt injection, adversarial inputs, cross-domain requests

## Observability
- CloudWatch metrics for all agent invocations
- X-Ray tracing for multi-agent flows
- Structured logging with correlation IDs
- Alerts on: error rate > 5%, latency P95 > 10s, guardrail trigger rate spike

## Deployment Standards
- Agents deployed via CDK
- Agent configurations in source control
- Environment promotion: dev → staging → prod with evaluation gates
- Blue/green deployment for agent version updates
- Rollback capability for all agent components

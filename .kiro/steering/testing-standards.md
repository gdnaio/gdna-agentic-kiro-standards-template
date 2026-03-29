---
title: Testing Standards
inclusion: always
---

# g/d/n/a Testing Standards (Agentic)

## Test Stack

| Layer | Tool | Scope |
|-------|------|-------|
| Unit | pytest | Functions, handlers, utilities |
| Integration | pytest + moto | AWS service integration, data flow |
| Infrastructure | pytest (CDK assertions) | Stack security properties, resource config |
| Contract | pydantic + custom | MCP tool schema validation |

## pytest Configuration

```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-q --tb=short -x"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "**/__init__.py"]

[tool.coverage.report]
fail_under = 80
```

## What to Test

### ALWAYS Test
- Lambda handler functions — input validation, error handling, return shapes
- Business logic in `src/services/` — calculations, transformations, decisions
- MCP tool handlers — correct tool schemas, error responses, edge cases
- Agent conversation flows — state transitions, tool call sequences
- AWS service interactions (mocked with `moto`)
- CDK constructs — security properties, resource configuration, IAM policies

### Test Selectively
- Integration points with external APIs — real calls in integration suite only, never unit tests
- Bedrock model responses — mock at the client level, test prompt construction and parsing

### DO NOT Unit Test
- AWS SDK internals
- Bedrock model outputs (non-deterministic)
- Third-party library internals

## Fixture Patterns

```python
# tests/conftest.py
import pytest
import boto3
from moto import mock_aws
import os

@pytest.fixture(autouse=True)
def aws_credentials(monkeypatch):
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "us-east-1")

@pytest.fixture
def dynamodb_table(aws_credentials):
    with mock_aws():
        client = boto3.resource("dynamodb", region_name="us-east-1")
        table = client.create_table(
            TableName="test-table",
            KeySchema=[{"AttributeName": "pk", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "pk", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        os.environ["TABLE_NAME"] = "test-table"
        yield table

@pytest.fixture
def s3_bucket(aws_credentials):
    with mock_aws():
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket="test-bucket")
        os.environ["BUCKET_NAME"] = "test-bucket"
        yield s3
```

## Lambda Handler Test Pattern

```python
# tests/unit/test_handler.py
import pytest
from moto import mock_aws
from src.handlers.create_item import handler

@mock_aws
def test_handler_success(dynamodb_table):
    event = {
        "body": {"name": "test-item", "category": "docs"},
        "requestContext": {"authorizer": {"userId": "user-123"}},
    }
    result = handler(event, {})
    assert result["statusCode"] == 200

@mock_aws
def test_handler_rejects_invalid_input(dynamodb_table):
    event = {"body": {"name": ""}}  # invalid: empty name
    result = handler(event, {})
    assert result["statusCode"] == 400
```

## MCP Tool Test Pattern

```python
# tests/unit/test_tools.py
from src.tools.search import search_tool

def test_search_tool_returns_results():
    result = search_tool.invoke({"query": "test query", "limit": 5})
    assert isinstance(result, list)
    assert len(result) <= 5

def test_search_tool_rejects_empty_query():
    with pytest.raises(ValueError):
        search_tool.invoke({"query": "", "limit": 5})
```

## CDK Assertion Pattern

```python
# tests/infra/test_stack.py
import aws_cdk as cdk
from aws_cdk.assertions import Template
from infra.stacks.main_stack import MainStack

def test_lambda_has_least_privilege_role():
    app = cdk.App()
    stack = MainStack(app, "TestStack")
    template = Template.from_stack(stack)

    # Lambda should NOT have wildcard resource access
    template.has_resource_properties("AWS::IAM::Policy", {
        "PolicyDocument": {
            "Statement": cdk.assertions.Match.not_(
                cdk.assertions.Match.array_with([
                    cdk.assertions.Match.object_like({"Resource": "*", "Action": "*"})
                ])
            )
        }
    })

def test_dynamodb_table_has_ttl():
    app = cdk.App()
    stack = MainStack(app, "TestStack")
    template = Template.from_stack(stack)
    template.has_resource_properties("AWS::DynamoDB::Table", {
        "TimeToLiveSpecification": {"Enabled": True}
    })
```

## Run Commands

```bash
# Fast unit tests only
pytest tests/unit/ -q --tb=short -x

# With coverage
pytest tests/unit/ -q --tb=short -x --cov=src --cov-report=term-missing

# All tests including infra assertions
pytest -q --tb=short -x

# Integration tests (run separately — requires real AWS creds)
pytest tests/integration/ -q --tb=short
```

## Directory Structure

```
tests/
├── conftest.py          # Shared fixtures (aws_credentials, mocks)
├── unit/
│   ├── test_handlers.py
│   ├── test_services.py
│   └── test_tools.py
├── integration/         # Real AWS calls — run separately
│   └── test_e2e.py
└── infra/
    └── test_stacks.py
```

## Coverage Requirements

| Layer | Minimum | Target |
|-------|---------|--------|
| Business logic (`src/services/`) | 80% | 90% |
| Lambda handlers | 80% | 90% |
| MCP tools | 70% | 85% |
| CDK constructs | 90% | 95% |

## GRC Testing Requirements
- Security-critical paths require dedicated test suites
- Auth flows: test unauthorized access, token expiry, invalid signatures
- Data access: test role-based visibility and data isolation
- Audit logging: verify audit events are emitted for data-modifying operations
- Input validation: validate all Lambda event shapes at entry — test with malformed inputs

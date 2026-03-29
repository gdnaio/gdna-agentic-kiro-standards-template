---
title: Python Standards
inclusion: always
---

# Python Standards

## Project Structure

```
project/
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── agents/
│   ├── tools/
│   ├── models/
│   ├── services/
│   └── utils/
├── tests/
│   ├── __init__.py
│   ├── unit/
│   ├── integration/
│   └── conftest.py
├── requirements.txt
├── requirements-dev.txt
├── pyproject.toml
└── .python-version
```

## Virtual Environments

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

## FastAPI Patterns

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Optional

app = FastAPI(title="Agent API", version="1.0.0")

class AgentRequest(BaseModel):
    session_id: str
    input: str = Field(..., min_length=1)
    context: Optional[dict] = None

@app.post("/invoke", response_model=AgentResponse)
async def invoke_agent(request: AgentRequest):
    result = await agent.invoke(request.input, request.session_id)
    if not result:
        raise HTTPException(status_code=500, detail="Agent invocation failed")
    return result
```

## Type Hints — Always

```python
from typing import List, Dict, Optional, Union

def process_tool_result(result: Dict[str, Any], tool_name: str) -> Optional[str]:
    if result.get("status") != "success":
        return None
    return result.get("output")
```

## AWS Lambda Handlers

```python
import json
from typing import Dict, Any
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()
tracer = Tracer()

@logger.inject_lambda_context
@tracer.capture_lambda_handler
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    try:
        body = json.loads(event.get('body', '{}'))
        result = process_request(body)
        return {'statusCode': 200, 'body': json.dumps(result)}
    except Exception as e:
        logger.exception("Error processing request")
        return {'statusCode': 500, 'body': json.dumps({'error': 'Internal server error'})}
```

## Testing with pytest

```bash
pytest -q --tb=short -x --cov=src --cov-report=term-missing
```

- `moto` for AWS service mocking (Bedrock, Lambda, DynamoDB, S3)
- Fixtures in `conftest.py`
- Separate `unit/` and `integration/` directories

## Error Handling — Result Pattern

```python
from dataclasses import dataclass
from typing import Union

@dataclass
class Success:
    data: dict

@dataclass
class Error:
    message: str
    code: str

Result = Union[Success, Error]

def invoke_agent(input: str) -> Result:
    try:
        response = bedrock_agent.invoke(input)
        return Success(data=response)
    except Exception as e:
        return Error(message=str(e), code="AGENT_ERROR")
```

## Anti-Patterns

❌ No mutable default arguments
❌ No bare `except:` clauses
❌ No `import *`
❌ No global variables
❌ No `eval()` or `exec()`
❌ No synchronous I/O in async functions

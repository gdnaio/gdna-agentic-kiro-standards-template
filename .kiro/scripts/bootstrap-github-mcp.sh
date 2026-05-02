#!/usr/bin/env bash
set -euo pipefail
SECRET_NAME="gdnaio/kiro-github-mcp-token"
DEFAULT_REGION="us-east-2"
MCP_CONFIG="$HOME/.kiro/settings/mcp.json"
MCP_SERVER_PATH="/opt/homebrew/bin/github-mcp-server"
AWS_PROFILE_ARG=""
AWS_REGION="${DEFAULT_REGION}"
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) AWS_PROFILE_ARG="--profile $2"; shift 2 ;;
    --region)  AWS_REGION="$2"; shift 2 ;;
    --help)    echo "Usage: $0 [--profile AWS_PROFILE] [--region AWS_REGION]"; exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done
echo "Checking prerequisites..."
for cmd in aws jq github-mcp-server; do
  command -v $cmd &>/dev/null || { echo "$cmd not found. brew install $cmd"; exit 1; }
done
echo "Verifying AWS credentials..."
aws sts get-caller-identity $AWS_PROFILE_ARG --region "$AWS_REGION" &>/dev/null || { echo "AWS creds not configured"; exit 1; }
echo "Fetching GitHub token from Secrets Manager..."
TOKEN=$(aws secretsmanager get-secret-value $AWS_PROFILE_ARG --region "$AWS_REGION" --secret-id "$SECRET_NAME" --query 'SecretString' --output text 2>&1)
[[ $? -ne 0 || -z "$TOKEN" || "$TOKEN" == *"ResourceNotFoundException"* ]] && { echo "Secret not found. Ask admin."; exit 1; }
echo "$TOKEN" | jq -e '.token' &>/dev/null 2>&1 && TOKEN=$(echo "$TOKEN" | jq -r '.token')
mkdir -p "$(dirname "$MCP_CONFIG")"
if [[ -f "$MCP_CONFIG" ]]; then
  UPDATED=$(jq --arg token "$TOKEN" --arg path "$MCP_SERVER_PATH" '.mcpServers.github = {"command": $path, "args": ["stdio"], "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": $token}, "disabled": false, "autoApprove": ["search_code","get_file_contents","search_repositories","list_commits","list_pull_requests","create_or_update_file","push_files","create_repository"]}' "$MCP_CONFIG")
  echo "$UPDATED" > "$MCP_CONFIG"
else
  jq -n --arg token "$TOKEN" --arg path "$MCP_SERVER_PATH" '{"mcpServers":{"github":{"command":$path,"args":["stdio"],"env":{"GITHUB_PERSONAL_ACCESS_TOKEN":$token},"disabled":false,"autoApprove":["search_code","get_file_contents","search_repositories","list_commits","list_pull_requests","create_or_update_file","push_files","create_repository"]}}}' > "$MCP_CONFIG"
fi
echo "Done! Restart Kiro or open a new chat."

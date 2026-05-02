#!/usr/bin/env bash
set -euo pipefail
SECRET_NAME="gdnaio/kiro-github-mcp-token"
DEFAULT_REGION="us-east-2"
AWS_PROFILE_ARG=""
AWS_REGION="${DEFAULT_REGION}"
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) AWS_PROFILE_ARG="--profile $2"; shift 2 ;;
    --region)  AWS_REGION="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done
read -sp "Paste the GitHub fine-grained PAT: " TOKEN; echo
[[ -z "$TOKEN" ]] && echo "No token provided." && exit 1
if aws secretsmanager describe-secret $AWS_PROFILE_ARG --region "$AWS_REGION" --secret-id "$SECRET_NAME" &>/dev/null 2>&1; then
  aws secretsmanager put-secret-value $AWS_PROFILE_ARG --region "$AWS_REGION" --secret-id "$SECRET_NAME" --secret-string "$TOKEN"
  echo "Secret updated."
else
  aws secretsmanager create-secret $AWS_PROFILE_ARG --region "$AWS_REGION" --name "$SECRET_NAME" --description "GitHub PAT for Kiro MCP (gdnaio org)" --secret-string "$TOKEN"
  echo "Secret created."
fi
echo "Tell devs to run: .kiro/scripts/bootstrap-github-mcp.sh"

#!/bin/bash

# Prompt for which GCP project ID to use
DEFAULT_GCP_PROJECT=$(gcloud config get-value project)
read -p "Enter the GCP_PROJECT (default: $DEFAULT_GCP_PROJECT): " GCP_PROJECT
if [[ -z "$GCP_PROJECT" ]]; then
  GCP_PROJECT="$DEFAULT_GCP_PROJECT"
fi

# Prompt for what the Cloud Run job should be called
DEFAULT_JOB_NAME="avanza-ynab-sync"
read -p "Enter the JOB_NAME (default: $DEFAULT_JOB_NAME): " JOB_NAME
if [[ -z "$JOB_NAME" ]]; then
  JOB_NAME="$DEFAULT_JOB_NAME"
fi

# Prompt for the Avanza username
DEFAULT_AZA_USERNAME=$(grep '^AZA_USERNAME=' .env | cut -d '=' -f2-)
read -p "Enter the AZA_USERNAME (default from .env: $DEFAULT_AZA_USERNAME): " AZA_USERNAME
if [[ -z "$AZA_USERNAME" ]]; then
  AZA_USERNAME="$DEFAULT_AZA_USERNAME"
fi

# Prompt for the Avanza password
DEFAULT_AZA_PASSWORD=$(grep '^AZA_PASSWORD=' .env | cut -d '=' -f2-)
read -p "Enter the AZA_PASSWORD (default from .env: $DEFAULT_AZA_PASSWORD): " AZA_PASSWORD
if [[ -z "$AZA_PASSWORD" ]]; then
  AZA_PASSWORD="$DEFAULT_AZA_PASSWORD"
fi

# Prompt for the Avanza TOTP secret
DEFAULT_AZA_TOTP_SECRET=$(grep '^AZA_TOTP_SECRET=' .env | cut -d '=' -f2-)
read -p "Enter the AZA_TOTP_SECRET (default from .env: $DEFAULT_AZA_TOTP_SECRET): " AZA_TOTP_SECRET
if [[ -z "$AZA_TOTP_SECRET" ]]; then
  AZA_TOTP_SECRET="$DEFAULT_AZA_TOTP_SECRET"
fi

# Prompt for the YNAB token
DEFAULT_YNAB_TOKEN=$(grep '^YNAB_TOKEN=' .env | cut -d '=' -f2-)
read -p "Enter the YNAB_TOKEN (default from .env: $DEFAULT_YNAB_TOKEN): " YNAB_TOKEN
if [[ -z "$YNAB_TOKEN" ]]; then
  YNAB_TOKEN="$DEFAULT_YNAB_TOKEN"
fi

# Prompt for the YNAB budget
DEFAULT_YNAB_BUDGET=$(grep '^YNAB_BUDGET=' .env | cut -d '=' -f2-)
read -p "Enter the YNAB_BUDGET (default from .env: $DEFAULT_YNAB_BUDGET): " YNAB_BUDGET
if [[ -z "$YNAB_BUDGET" ]]; then
  YNAB_BUDGET="$DEFAULT_YNAB_BUDGET"
fi

# Prompt for the YNAB account
DEFAULT_YNAB_ACCOUNT=$(grep '^YNAB_ACCOUNT=' .env | cut -d '=' -f2-)
read -p "Enter the YNAB_ACCOUNT (default from .env: $DEFAULT_YNAB_ACCOUNT): " YNAB_ACCOUNT
if [[ -z "$YNAB_ACCOUNT" ]]; then
  YNAB_ACCOUNT="$DEFAULT_YNAB_ACCOUNT"
fi

# Construct environment variables stringh for Cloud Run
ENV_VARS_STRING="AZA_USERNAME=${AZA_USERNAME}"
ENV_VARS_STRING="${ENV_VARS_STRING},AZA_PASSWORD=${AZA_PASSWORD}"
ENV_VARS_STRING="${ENV_VARS_STRING},AZA_TOTP_SECRET=${AZA_TOTP_SECRET}"
ENV_VARS_STRING="${ENV_VARS_STRING},YNAB_TOKEN=${YNAB_TOKEN}"
ENV_VARS_STRING="${ENV_VARS_STRING},YNAB_BUDGET=${YNAB_BUDGET}"
ENV_VARS_STRING="${ENV_VARS_STRING},YNAB_ACCOUNT=${YNAB_ACCOUNT}"

# Deploy the Cloud Run job
echo "Deploying Cloud Run job: $JOB_NAME"
gcloud run jobs deploy "$JOB_NAME" --source=. --project="$GCP_PROJECT" --set-env-vars="$ENV_VARS_STRING"

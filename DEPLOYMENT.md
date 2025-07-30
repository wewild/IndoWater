# IndoWater Deployment Guide

This document provides instructions for deploying the IndoWater system to different environments.

## Prerequisites

- Docker and Docker Compose
- Git
- SSH access to the deployment servers
- Access to the Docker Hub repository
- SSL certificates for the domains

## Environment Setup

### Development Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/wewild/IndoWater.git
   cd IndoWater
   ```

2. Create the environment file:
   ```bash
   cp .env.dev.example .env.dev
   ```

3. Edit the `.env.dev` file with your development environment settings.

4. Start the development environment:
   ```bash
   docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
   ```

5. Initialize the database:
   ```bash
   docker-compose -f docker-compose.dev.yml exec api php artisan migrate --seed
   ```

### Staging Environment

1. SSH into the staging server:
   ```bash
   ssh user@staging-server
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/wewild/IndoWater.git
   cd IndoWater
   ```

3. Create the environment file:
   ```bash
   cp .env.dev.example .env.dev
   ```

4. Edit the `.env.dev` file with your staging environment settings.

5. Start the staging environment:
   ```bash
   docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d
   ```

6. Initialize the database:
   ```bash
   docker-compose -f docker-compose.dev.yml exec api php artisan migrate --seed
   ```

### Production Environment

1. SSH into the production server:
   ```bash
   ssh user@production-server
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/wewild/IndoWater.git
   cd IndoWater
   ```

3. Create the environment file:
   ```bash
   cp .env.prod.example .env.prod
   ```

4. Edit the `.env.prod` file with your production environment settings.

5. Create the SSL certificate directory:
   ```bash
   mkdir -p nginx/ssl
   ```

6. Copy your SSL certificates to the `nginx/ssl` directory:
   ```bash
   cp /path/to/your/certificate.crt nginx/ssl/indowater.com.crt
   cp /path/to/your/private.key nginx/ssl/indowater.com.key
   ```

7. Start the production environment:
   ```bash
   docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
   ```

8. Initialize the database:
   ```bash
   docker-compose -f docker-compose.prod.yml exec api php artisan migrate --seed
   ```

## CI/CD Pipeline

The IndoWater system uses GitHub Actions for CI/CD. The pipeline is configured to:

1. Run tests on every pull request to the `main` and `develop` branches.
2. Build and push Docker images to Docker Hub on every push to the `main` and `develop` branches.
3. Deploy to the development environment on every push to the `develop` branch.
4. Deploy to the production environment on every push to the `main` branch.

### Pipeline Configuration

The CI/CD pipeline is configured in the following files:

- `.github/workflows/api-ci-cd.yml`: CI/CD pipeline for the API.
- `.github/workflows/frontend-ci-cd.yml`: CI/CD pipeline for the frontend.
- `.github/workflows/mobile-ci-cd.yml`: CI/CD pipeline for the mobile app.

### Required Secrets

The following secrets need to be configured in the GitHub repository:

- `DOCKERHUB_USERNAME`: Docker Hub username.
- `DOCKERHUB_TOKEN`: Docker Hub access token.
- `DEV_SSH_HOST`: Hostname of the development server.
- `DEV_SSH_USERNAME`: SSH username for the development server.
- `DEV_SSH_KEY`: SSH private key for the development server.
- `PROD_SSH_HOST`: Hostname of the production server.
- `PROD_SSH_USERNAME`: SSH username for the production server.
- `PROD_SSH_KEY`: SSH private key for the production server.
- `KEYSTORE_PASSWORD`: Password for the Android keystore.
- `KEY_PASSWORD`: Password for the Android key.
- `KEY_ALIAS`: Alias for the Android key.
- `KEYSTORE_BASE64`: Base64-encoded Android keystore.
- `PROVISIONING_PROFILE_BASE64`: Base64-encoded iOS provisioning profile.
- `CERTIFICATE_P12_BASE64`: Base64-encoded iOS certificate.
- `CERTIFICATE_PASSWORD`: Password for the iOS certificate.
- `APPLE_ID`: Apple ID for App Store Connect.
- `APPLE_PASSWORD`: Password for App Store Connect.
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password for App Store Connect.
- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Google Play service account JSON.

## Manual Deployment

### API

1. Build the API Docker image:
   ```bash
   cd api
   docker build -t indowater/api:latest .
   ```

2. Push the API Docker image to Docker Hub:
   ```bash
   docker push indowater/api:latest
   ```

3. SSH into the server and pull the latest image:
   ```bash
   ssh user@server
   cd /opt/indowater
   docker-compose pull api
   docker-compose up -d api
   ```

### Frontend

1. Build the frontend Docker image:
   ```bash
   cd frontend
   docker build -t indowater/frontend:latest .
   ```

2. Push the frontend Docker image to Docker Hub:
   ```bash
   docker push indowater/frontend:latest
   ```

3. SSH into the server and pull the latest image:
   ```bash
   ssh user@server
   cd /opt/indowater
   docker-compose pull frontend
   docker-compose up -d frontend
   ```

### Mobile

1. Build the Android APK:
   ```bash
   cd mobile
   flutter build apk --release --flavor production --dart-define=API_URL=https://api.indowater.com/api
   ```

2. Build the iOS IPA:
   ```bash
   cd mobile
   flutter build ios --release --flavor production --dart-define=API_URL=https://api.indowater.com/api
   ```

3. Upload the APK to Google Play:
   ```bash
   cd mobile
   fastlane android deploy
   ```

4. Upload the IPA to App Store:
   ```bash
   cd mobile
   fastlane ios deploy
   ```

## Rollback Procedure

### API and Frontend

1. SSH into the server:
   ```bash
   ssh user@server
   cd /opt/indowater
   ```

2. List the available Docker images:
   ```bash
   docker images
   ```

3. Update the Docker Compose file to use the previous image:
   ```bash
   sed -i 's/indowater\/api:latest/indowater\/api:previous-tag/' docker-compose.prod.yml
   sed -i 's/indowater\/frontend:latest/indowater\/frontend:previous-tag/' docker-compose.prod.yml
   ```

4. Restart the services:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Mobile

1. Go to the Google Play Console and App Store Connect.
2. Halt the current rollout.
3. Rollback to the previous version.

## Monitoring and Logging

The IndoWater system uses the following tools for monitoring and logging:

- Prometheus: Metrics collection and alerting.
- Grafana: Metrics visualization.
- ELK Stack: Log collection, indexing, and visualization.

### Accessing Monitoring Tools

- Prometheus: https://prometheus.indowater.com
- Grafana: https://grafana.indowater.com
- Kibana: https://kibana.indowater.com

### Setting Up Alerts

1. Log in to Grafana.
2. Go to Alerting > Notification channels to set up notification channels.
3. Create alert rules in your dashboards.

## Backup and Recovery

The IndoWater system uses the following backup strategy:

1. Daily database backups.
2. Weekly full system backups.
3. Backups are stored in S3 and retained for 30 days.

### Manual Backup

```bash
ssh user@server
cd /opt/indowater
docker-compose -f docker-compose.prod.yml exec backup /backup.sh
```

### Restore from Backup

1. SSH into the server:
   ```bash
   ssh user@server
   cd /opt/indowater
   ```

2. Stop the services:
   ```bash
   docker-compose -f docker-compose.prod.yml down
   ```

3. Restore the database:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d db
   docker cp /path/to/backup.sql indowater-db:/tmp/
   docker-compose -f docker-compose.prod.yml exec db mysql -u root -p${DB_ROOT_PASSWORD} indowater < /tmp/backup.sql
   ```

4. Start the services:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```
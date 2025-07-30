#!/bin/bash

# IndoWater Security Audit Script
# This script performs a security audit of the IndoWater system

echo "Starting IndoWater Security Audit..."
echo "======================================"
echo ""

# Check Docker security
echo "Checking Docker security..."
docker info --format '{{.SecurityOptions}}'
echo ""

# Check container security
echo "Checking container security..."
docker ps --format "{{.Names}}" | while read container; do
  echo "Container: $container"
  docker inspect --format '{{ .HostConfig.Privileged }}' $container
  docker inspect --format '{{ .HostConfig.CapAdd }}' $container
  echo ""
done

# Check for exposed ports
echo "Checking for exposed ports..."
docker ps --format "{{.Names}}: {{.Ports}}"
echo ""

# Check for sensitive environment variables
echo "Checking for sensitive environment variables in Docker Compose..."
grep -r "PASSWORD\|SECRET\|KEY" docker-compose*.yml
echo ""

# Check API security headers
echo "Checking API security headers..."
curl -s -I https://api.indowater.com | grep -E 'Strict-Transport-Security|X-Content-Type-Options|X-Frame-Options|X-XSS-Protection|Content-Security-Policy'
echo ""

# Check Frontend security headers
echo "Checking Frontend security headers..."
curl -s -I https://indowater.com | grep -E 'Strict-Transport-Security|X-Content-Type-Options|X-Frame-Options|X-XSS-Protection|Content-Security-Policy'
echo ""

# Check SSL/TLS configuration
echo "Checking SSL/TLS configuration..."
nmap --script ssl-enum-ciphers -p 443 api.indowater.com
nmap --script ssl-enum-ciphers -p 443 indowater.com
echo ""

# Check for outdated dependencies in API
echo "Checking for outdated dependencies in API..."
cd /workspace/IndoWater/api
composer outdated
echo ""

# Check for outdated dependencies in Frontend
echo "Checking for outdated dependencies in Frontend..."
cd /workspace/IndoWater/frontend
npm outdated
echo ""

# Check for outdated dependencies in Mobile
echo "Checking for outdated dependencies in Mobile..."
cd /workspace/IndoWater/mobile
flutter pub outdated
echo ""

# Check for security vulnerabilities in API
echo "Checking for security vulnerabilities in API..."
cd /workspace/IndoWater/api
composer audit
echo ""

# Check for security vulnerabilities in Frontend
echo "Checking for security vulnerabilities in Frontend..."
cd /workspace/IndoWater/frontend
npm audit
echo ""

# Check for security vulnerabilities in Mobile
echo "Checking for security vulnerabilities in Mobile..."
cd /workspace/IndoWater/mobile
flutter pub deps --style=compact | grep -E 'package:[a-z]'
echo ""

# Check for secrets in Git history
echo "Checking for secrets in Git history..."
cd /workspace/IndoWater
git log -p | grep -i "password\|secret\|key\|token"
echo ""

# Check for open ports
echo "Checking for open ports..."
nmap -sT -p- localhost
echo ""

# Check for database security
echo "Checking for database security..."
docker exec indowater-db mysql -u root -p${DB_ROOT_PASSWORD} -e "SELECT user, host FROM mysql.user;"
echo ""

# Check for Redis security
echo "Checking for Redis security..."
docker exec indowater-redis redis-cli CONFIG GET protected-mode
echo ""

echo "Security Audit Completed!"
echo "=========================="
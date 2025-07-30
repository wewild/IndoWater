# IndoWater Monitoring and Logging Guide

This document provides information about the monitoring and logging setup for the IndoWater system.

## Monitoring Stack

The IndoWater system uses the following tools for monitoring:

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Metrics visualization
- **cAdvisor**: Container metrics
- **Node Exporter**: Host metrics
- **MySQL Exporter**: MySQL metrics
- **Redis Exporter**: Redis metrics

## Logging Stack

The IndoWater system uses the ELK Stack for logging:

- **Elasticsearch**: Log storage and indexing
- **Logstash**: Log processing
- **Kibana**: Log visualization

## Metrics Collected

### System Metrics

- CPU usage
- Memory usage
- Disk usage
- Network traffic
- System load

### Container Metrics

- Container CPU usage
- Container memory usage
- Container network traffic
- Container disk I/O

### Application Metrics

- API request count
- API response time
- API error rate
- Database query count
- Database query time
- Cache hit/miss rate
- User session count
- Payment transaction count
- Payment transaction success/failure rate

### Business Metrics

- Active users
- New user registrations
- Meter registrations
- Payment volume
- Water consumption

## Dashboards

The following Grafana dashboards are available:

1. **System Overview**: Overall system health and resource usage
2. **API Performance**: API request/response metrics
3. **Database Performance**: Database query metrics
4. **User Activity**: User session and activity metrics
5. **Business Metrics**: Key business metrics
6. **Mobile App Performance**: Mobile app usage and performance metrics

## Alerts

The following alerts are configured:

1. **High CPU Usage**: Triggered when CPU usage exceeds 80% for 5 minutes
2. **High Memory Usage**: Triggered when memory usage exceeds 80% for 5 minutes
3. **Low Disk Space**: Triggered when disk space is less than 10% free
4. **High API Error Rate**: Triggered when API error rate exceeds 5% for 5 minutes
5. **High API Response Time**: Triggered when API response time exceeds 500ms for 5 minutes
6. **Database Connection Issues**: Triggered when database connections fail
7. **Redis Connection Issues**: Triggered when Redis connections fail
8. **Payment Gateway Issues**: Triggered when payment gateway connections fail

## Log Types

The following log types are collected:

1. **API Logs**: API request/response logs
2. **Application Logs**: Application-level logs
3. **Database Logs**: Database query logs
4. **Frontend Logs**: Frontend application logs
5. **Mobile App Logs**: Mobile app logs
6. **System Logs**: System-level logs
7. **Security Logs**: Security-related logs

## Log Retention

- **Hot Storage**: 7 days in Elasticsearch
- **Warm Storage**: 30 days in S3
- **Cold Storage**: 1 year in S3 Glacier

## Accessing Monitoring Tools

- **Grafana**: https://grafana.indowater.com (or http://localhost:3001 in development)
- **Prometheus**: https://prometheus.indowater.com (or http://localhost:9090 in development)
- **Kibana**: https://kibana.indowater.com (or http://localhost:5601 in development)

## Setting Up Custom Alerts

1. Log in to Grafana
2. Go to Alerting > Notification channels to set up notification channels
3. Create alert rules in your dashboards

## Setting Up Custom Dashboards

1. Log in to Grafana
2. Click on "Create" > "Dashboard"
3. Add panels to your dashboard
4. Configure each panel to display the metrics you want to monitor
5. Save your dashboard

## Setting Up Custom Log Queries

1. Log in to Kibana
2. Go to "Discover"
3. Select the index pattern for the logs you want to query
4. Use the Kibana Query Language (KQL) to filter the logs
5. Save your search for future use

## Troubleshooting

### Monitoring Issues

1. Check if Prometheus is running:
   ```bash
   docker-compose ps prometheus
   ```

2. Check if Grafana is running:
   ```bash
   docker-compose ps grafana
   ```

3. Check Prometheus targets:
   ```bash
   curl http://localhost:9090/api/v1/targets
   ```

### Logging Issues

1. Check if Elasticsearch is running:
   ```bash
   docker-compose ps elasticsearch
   ```

2. Check if Logstash is running:
   ```bash
   docker-compose ps logstash
   ```

3. Check if Kibana is running:
   ```bash
   docker-compose ps kibana
   ```

4. Check Elasticsearch indices:
   ```bash
   curl http://localhost:9200/_cat/indices
   ```

5. Check Logstash pipeline:
   ```bash
   docker-compose logs logstash
   ```

## Adding New Metrics

1. Identify the metrics you want to collect
2. Add the metrics to your application code
3. Configure Prometheus to scrape the metrics
4. Create Grafana dashboards to visualize the metrics
5. Set up alerts for the new metrics

## Adding New Log Sources

1. Identify the logs you want to collect
2. Configure Logstash to collect the logs
3. Configure Elasticsearch to index the logs
4. Create Kibana visualizations for the logs
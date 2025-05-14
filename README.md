# Actorizer-CDC

## Overview
Actorizer-CDC is a Change Data Capture application designed to track and replicate database changes to an actorizer service. It monitors PostgreSQL databases using logical replication (WAL) and sends the changes to the actorizer service for further processing.

## Description
The Actorizer-CDC application captures changes from PostgreSQL databases and forwards them to an actorizer service. It supports monitoring multiple databases and tables, with configurable replication settings. The application is designed to work with the simulator platform and provides monitoring capabilities through Prometheus.

## Project Structure

```
actorizer-cdc/
├── Chart.yaml             # Helm chart metadata
├── .gitlab-ci.yml         # GitLab CI/CD configuration
├── .helmignore            # Files to ignore in Helm chart
├── mixins/                # Prometheus alert configurations
│   └── alerts.yaml        # Alert rules for monitoring
├── templates/             # Helm templates
│   ├── _helpers.tpl       # Helper templates
│   ├── configmap.yaml     # ConfigMap for application configuration
│   ├── deployment.yaml    # Kubernetes Deployment
│   ├── hpa.yaml           # Horizontal Pod Autoscaler
│   ├── ingress.yaml       # Ingress configuration
│   ├── monitoring.yaml    # ServiceMonitor for Prometheus
│   ├── NOTES.txt          # Installation notes
│   ├── prometheusrule-alerts.yaml # Prometheus alert rules
│   ├── secret.yaml        # Secret for Docker registry credentials
│   ├── service.yaml       # Kubernetes Service
│   └── serviceaccount.yaml # ServiceAccount configuration
└── values.yaml            # Default configuration values
```

## Configuration

### Values File Variables

The following variables in the `values.yaml` file are configurable and should be set according to your environment:

#### Authentication and Connection Variables

| Variable | Description |
|----------|-------------|
| `ACCOUNT_DOMAIN` | The domain URL for the account service |
| `CLIENT_ID` | Client ID for authentication with the account service |
| `SECRET` | Secret key for authentication with the account service |
| `DB_USER_ACTORIZER` | Username for connecting to the actorizer database |
| `DB_PASSWORD_ACTORIZER` | Password for connecting to the actorizer database |
| `DB_HOST_ACTORIZER` | Hostname for the actorizer database |
| `DB_USER_SIMUALTOR` | Username for connecting to the simulator database |
| `DB_PASSWORD_SIMUALTOR` | Password for connecting to the simulator database |
| `DB_HOST_SIMUALTOR` | Hostname for the simulator database |
| `DB_NAME_SIMUALTOR` | Database name for the simulator database |

### Configuration Structure

The configuration is organized in the following structure:

1. **Global Settings**:
   - `serviceMonitor.enabled`: Enable/disable Prometheus ServiceMonitor
   - `alerts.enabled`: Enable/disable Prometheus alerts
   - `repotype`: Repository type, can be "public" or "helm". When set to "helm", imagePullSecrets will be created and used

2. **Actorizer CDC Settings**:
   - `replicaCount`: Number of replicas to run
   - `image`: Container image settings
   - `config`: Application configuration

3. **Application Configuration**:
   - `mode`: Application mode (test, production)
   - `actorizer`: URL of the actorizer service
   - `algorithm`: Signature algorithm (EdDSA or ES256)
   - `srv`: HTTP server settings
   - `account`: Account service connection settings
   - `connection`: Main database connection settings
   - `dbs`: List of databases to monitor

4. **Database Monitoring Configuration**:
   - Each database in the `dbs` list has:
     - `name`: Database name
     - `connection`: Database connection settings
     - `replication`: Replication settings (logical and history)
     - `entities`: List of tables/entities to monitor

5. **Database Connection Parameters**:
   - The database connection URIs include several important parameters:
     - `pool_min_conns`: Minimum number of connections in the pool
     - `pool_max_conns`: Maximum number of connections in the pool
     - `pool_max_conn_lifetime`: Maximum lifetime of a connection
     - `pool_max_conn_idle_time`: Maximum idle time for a connection
     - `pool_health_check_period`: Interval for health checks
     - `pool_max_conn_lifetime_jitter`: Jitter for connection lifetime

## Installation

### Prerequisites
- Kubernetes cluster
- Helm 3.x
- PostgreSQL database with logical replication enabled

### Installing the Chart

```bash
# Add the Helm repository
helm repo add corezoid https://hub.corezoid.com/helm

# Install the chart
helm install actorizer-cdc corezoid/actorizer-cdc \
  --set global.actorizer_cdc.config.account.url=your-account-domain \
  --set global.actorizer_cdc.config.account.client_id=your-client-id \
  --set global.actorizer_cdc.config.account.secret=your-secret \
  --set global.actorizer_cdc.config.connection.uri=postgres://user:password@host:5432/actorizer?pool_min_conns=2&pool_max_conns=20
```

### Configuration Values

To override the default configuration, create a custom values file:

```yaml
global:
  serviceMonitor:
    enabled: true
  alerts:
    enabled: true
  actorizer_cdc:
    replicaCount: 2
    config:
      actorizer: https://your-actorizer-url
      account:
        url: your-account-domain
        client_id: your-client-id
        secret: your-secret
      connection:
        uri: postgres://user:password@host:5432/actorizer?pool_min_conns=2&pool_max_conns=20
      dbs:
        - name: your-database
          connection:
            uri: postgres://user:password@host:5432/your-database
```

Then install the chart with:

```bash
helm install actorizer-cdc corezoid/actorizer-cdc -f custom-values.yaml
```

### Using Private Repository

If you need to use a private Docker repository, set the `repotype` to "helm":

```yaml
global:
  repotype: "helm"
```

This will create a Secret with Docker registry credentials and configure the Deployment to use it.

## Replication Configuration

The Actorizer-CDC application supports two types of replication:

1. **Logical Replication**:
   - Uses PostgreSQL's logical decoding feature with the `wal2json` plugin
   - Captures changes in real-time as they occur in the database
   - Configuration parameters:
     - `enable`: Enable/disable logical replication
     - `slot`: Name of the replication slot
     - `workers`: Number of worker threads for processing changes

2. **History Replication**:
   - Used for initial data loading or catching up after downtime
   - Scans database tables for changes based on timestamps
   - Configuration parameters:
     - `enable`: Enable/disable history replication
     - `cycle`: Whether to continuously scan for changes
     - `threads`: Number of threads for scanning

### Entity Configuration

For each table being monitored, you can configure:

- `name`: Logical name for the entity
- `schema`: Database schema (usually "public")
- `table`: Table name (supports regex patterns like `transactions_[0-9]{6}`)
- `order`: Fields to order by when retrieving changes
- `entity`: Fields that uniquely identify an entity
- `data`: Additional fields to include in the change data

## Monitoring

The chart includes Prometheus alerts for monitoring the application:

- `ActorizerCDCTooManyErrorsInMinute`: Alerts when there are more than 20 errors in a minute
- `ActorizerCDCTooManyErrorsInHour`: Alerts when there are more than 100 errors in an hour

To enable monitoring, set:

```yaml
global:
  serviceMonitor:
    enabled: true
  alerts:
    enabled: true
```

## Maintenance

### Upgrading the Chart

```bash
helm upgrade actorizer-cdc corezoid/actorizer-cdc -f custom-values.yaml
```

### Uninstalling the Chart

```bash
helm uninstall actorizer-cdc
```

## License

Copyright © Corezoid

To deploy the Privacy Toolbox use the helm chart at `ghcr.io/bdsc-cds/charts/privacy-toolbox-chart:v0.1.5`.

```bash
# Run the following if you want to add a custom logo file to the Privacy Toolbox.
# if file exists ./privacy-toolbox-chart/files/logo.png base64 it and put in mktemp
if [ -f "./logo.png" ]; then
  BASE_64_LOGO_PATH=$(mktemp)
  cat ./logo.png | base64 > $BASE_64_LOGO_PATH
fi

helm upgrade --install privacy-toolbox oci://ghcr.io/bdsc-cds/charts/privacy-toolbox-chart \
  --version v0.1.5 \
  --namespace "privacy-toolbox" \
  --create-namespace \
  -f values.yaml \
  --set-file frontend.config.logopngb64=$BASE_64_LOGO_PATH # Remove this if no logo.png file is provided.
```

with the following `values.yaml` to adapt as needed:

```yaml
####################################
# pt-backend-chart configuration
####################################
backend:
  enabled: true
  image:
    repository: ghcr.io/bdsc-cds/pt-backend
  # Sets the secrets for the pt-backend.
  # If this is empty, values are automatically generated at the release installation.
  # Otherwise, the specified value will be used in the secret pt-backend-secret.
  # During Helm upgrades, changes on the secrets will be reflected in the release.
  secrets: {}
    # ptAdminPassword: example-password
    # jwtSecret: # 60 chars
    # adminToken: # 16 chars
    # symmetricEncryptionKey: # 32 chars 
  service:
    enabled: true
  ingress:
    enabled: true
    host: "api-demo.rdeid.unil.ch"
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    className: public
    # annotations: {}
  # Override bakcend container config 
  configOverride:
    daemon:
      public_url: "https://api-demo.rdeid.unil.ch"
    clients:
      jupyterhub:
        host: "https://jupyterhub-demo.rdeid.unil.ch"
      arx:
        host: "http://privacy-toolbox-arx-service.demo:8080/" # <arx service name>.<namespace>:<port>

  ####################################
  # PostgreSQL subchart configuration (see https://artifacthub.io/packages/helm/bitnami/postgresql/15.5.38)
  ####################################
  postgresql:
    fullnameOverride: postgresql
    # This defines the authentication parameters
    auth:
      enablePostgresUser: true # Creates a user "postgres" with admin rights.
      existingSecret: psql-secret # Secret should contain the key postgres-password
      database: pt_backend
    secrets: {}
        # postgresPassword: example-password # PostgreSQL won't use this value if the chart was already deployed.
    primary:
      persistence:
        enabled: true
        size: 100Gi

  ####################################
  # jupyterhub subchart configuration
  ####################################
  jupyterhub:
    enabled: true
    image:
      repository: ghcr.io/bdsc-cds/pt-jupyterhub
    service:
      enabled: true
    ingress:
      enabled: true
      host: "jupyterhub-demo.rdeid.unil.ch"
      tls: true # Secret name should match: {{ .Chart.Name }}-tls
      annotations:
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
        nginx.ingress.kubernetes.io/configuration-snippet: |
            more_clear_headers "Content-Security-Policy";
            add_header content-security-policy "frame-ancestors 'self' https://demo.rdeid.unil.ch" always;
            add_header Access-Control-Allow-Origin "https://demo.rdeid.unil.ch";
    env:
      # Allowed domains within jupyterhub iFrame
      allowedFrameDomains: "https://demo.rdeid.unil.ch" # Space separated list of domains

  ####################################
  # arx-service subchart configuration
  ####################################
  arx:
    enabled: true
    service:
      enabled: true
      type: ClusterIP
      port: 8080
    config:
      datastore:
        host: arx-postgresql
        database: WRK_ARX
        username: postgres
    postgresql:
      nameOverride: arx-postgresql
      fullnameOverride: arx-postgresql
      secrets:
        postgresPassword: example-password # This value must be overridden during the first deployment.

####################################
# pt-frontend-chart configuration
####################################
frontend:
  enabled: true
  image:
    repository: ghcr.io/bdsc-cds/pt-frontend
  service:
    enabled: true
  ingress:
    enabled: true
    host: "demo.rdeid.unil.ch"
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    # annotations: {}
  # Frontend configuration
  config:
    apiUrl: "https://api-demo.rdeid.unil.ch" # Backend API URL
    primaryColor: "#002C5C"
    secondaryColor: "#C5D5DB"
    headerBgColor: "#002C5C"
    footerBgColor: "#002C5C"
```

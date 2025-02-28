To deploy the Privacy Toolbox use the helm chart at `ghcr.io/bdsc-cds/charts/privacy-toolbox-chart:v0.1.3`.

```bash
# if file exists ./privacy-toolbox-chart/files/logo.png base64 it and put in mktemp
if [ -f "./privacy-toolbox-chart/files/logo.png" ]; then
  BASE_64_LOGO_PATH=$(mktemp)
  cat ./privacy-toolbox-chart/files/logo.png | base64 > $BASE_64_LOGO_PATH
fi

helm upgrade --install privacy-toolbox oci://ghcr.io/bdsc-cds/charts/privacy-toolbox-chart \
  --version v0.1.1 \
  --namespace "privacy-toolbox" \
  --create-namespace \
  -f values.yaml \
  --set-file frontend.config.logopngb64=$BASE_64_LOGO_PATH
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
    host: "pt-backend.rdeid.unil.ch"
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    className: public
    # annotations: {}

  # Override container config 
  configOverride:
    daemon:
      public_url: "https://pt-backend.rdeid.unil.ch"
    clients:
      jupyterhub:
        host: "https://jupyterhub.rdeid.unil.ch"

  # Jupyterhub subchart configuration
  jupyterhub:
    enabled: true
    image:
      repository: ghcr.io/bdsc-cds/pt-jupyterhub
    service:
      enabled: true
    ingress:
      enabled: true
      host: "jupyterhub.rdeid.unil.ch"
      tls: true # Secret name should match: {{ .Chart.Name }}-tls
      annotations:
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
        nginx.ingress.kubernetes.io/configuration-snippet: |
            more_clear_headers "Content-Security-Policy";
            add_header content-security-policy "frame-ancestors 'self' https://pt-frontend.rdeid.unil.ch" always;
            add_header Access-Control-Allow-Origin "https://pt-frontend.rdeid.unil.ch";
    env:
      # Allowed domains within jupyterhub iFrame
      allowedFrameDomains: "https://pt-frontend.rdeid.unil.ch" # Space separated list of domains

  # ARX service subchart configuration
  arx:
    enabled: true

  # PostgreSQL subchart configuration (see https://artifacthub.io/packages/helm/bitnami/postgresql/15.5.38)
  postgresql:
    secrets: {}
      # postgresPassword: example-password # PostgreSQL won't use this value if the chart was already deployed.
    primary:
      persistence:
        enabled: true
        # size: 100Gi

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
    host: "pt-frontend.rdeid.unil.ch"
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    # annotations: {}

  # Frontend configuration
  config:
    apiUrl: "" # Backend API URL
    primaryColor: "#306278"
    secondaryColor: "#A1C6D9"
    headerBgColor: "#306278"
    footerBgColor: "#306278"
```

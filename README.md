To deploy the Privacy Toolbox use the helm chart at `ghcr.io/bdsc-cds/charts/privacy-toolbox-chart:v0.0.2`

```bash
helm upgrade --install privacy-toolbox oci://ghcr.io/bdsc-cds/charts/privacy-toolbox-chart \
  --version v0.0.2 \
  --namespace "privacy-toolbox" \
  --create-namespace \
  -f values.yaml
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
  persistence:
    enabled: true
    storageClass: microk8s-hostpath
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
      className: public
      annotations:
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      
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
    className: public
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    # annotations: {}
  env:
    apiUrl: "https://pt-backend.rdeid.unil.ch" # Should match the backend ingress host
```

To deploy the Privacy Toolbox use the helm chart at `ghcr.io/bdsc-cds/charts/privacy-toolbox-chart:0.0.1`

```bash
helm upgrade --install privacy-toolbox oci://ghcr.io/bdsc-cds/charts/privacy-toolbox-chart \
  --version 0.0.1 \
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
      annotations:
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
        nginx.ingress.kubernetes.io/configuration-snippet: |
            more_clear_headers "Content-Security-Policy";
            add_header content-security-policy "frame-ancestors 'self' https://pt-frontend.rdeid.unil.ch" always;
            add_header Access-Control-Allow-Origin "https://pt-frontend.rdeid.unil.ch";

  # ARX service subchart configuration
  arx:
    enabled: true

  # PostgreSQL subchart configuration (see https://artifacthub.io/packages/helm/bitnami/postgresql/15.5.38)
  postgresql:
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
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    # annotations: {}
  env:
    apiUrl: "https://pt-backend.rdeid.unil.ch" # Should match the backend ingress host
```

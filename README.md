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
    host: "pt-backend-test.rdeid.unil.ch"
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
    className: public
  persistence:
    enabled: true
    storageClass: microk8s-hostpath
  
  # Jupyterhub subchart configuration
  jupyterhub:
    enabled: true
    image:
      repository: ghcr.io/bdsc-cds/pt-jupyterhub
    service:
      enabled: true
    ingress:
      enabled: true
      host: "jupyterhub-test.rdeid.unil.ch"

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
    host: "pt-frontend-test.rdeid.unil.ch"
    tls: false # Secret name should match: {{ .Chart.Name }}-tls
  env:
    apiUrl: "https://pt-backend-test.rdeid.unil.ch" # Should match the backend ingress host
```
# 📊 Food Core Observability

Stack de observabilidade para monitoramento de microsserviços do projeto FoodCore, desenvolvida como parte do curso de Arquitetura de Software
da FIAP (Tech Challenge).

<div align="center">
  <a href="#visao-geral">Visão Geral</a> •
  <a href="#tecnologias">Tecnologias</a> •
  <a href="#stack-de-observabilidade">Stack de Observabilidade</a> •
  <a href="#recursos-provisionados">Recursos Provisionados</a> •
  <a href="#estrutura-do-projeto">Estrutura do Projeto</a> •
  <a href="#fluxo-de-deploy">Governança e Fluxo de Deploy</a>
</div><br>

# ☁️ Observabilidade (Azure + Kubernetes)

<h2 id="visao-geral">📖 Visão Geral</h2>

Este repositório contém os **scripts de IaC (Terraform)** e o **Helm Chart** responsáveis por provisionar toda a stack de observabilidade do projeto FoodCore no cluster AKS.

A stack implementa os **três pilares da observabilidade**:
- **Logs** (EFK Stack)
- **Métricas** (Prometheus + Grafana)
- **Traces** (Zipkin)

<h2 id="tecnologias">🚀 Tecnologias</h2>

- **Terraform**
- **Helm**
- **Kubernetes (AKS)**
- **Azure Cloud**
- **GitHub Actions** para CI/CD

<h2 id="stack-de-observabilidade">🔭 Stack de Observabilidade</h2>

### 📋 Logs - EFK Stack

| Componente | Descrição | Versão |
|------------|-----------|--------|
| **Elasticsearch** | Armazenamento e indexação de logs | 8.13.4 |
| **Fluentd** | Coleta e agregação de logs dos containers | v1.18 |
| **Kibana** | Visualização e análise de logs | 8.13.4 |

### 📈 Métricas - Prometheus + Grafana

| Componente | Descrição | Versão |
|------------|-----------|--------|
| **Prometheus** | Coleta e armazenamento de métricas | latest |
| **Grafana** | Dashboards e visualização de métricas | latest |

> 📊 Inclui dashboard JVM Micrometer pré-configurado para monitoramento de aplicações Spring Boot.

### 👣 Traces - Zipkin

| Componente | Descrição | Versão |
|------------|-----------|--------|
| **Zipkin** | Rastreamento distribuído de requisições | latest |

<h2 id="recursos-provisionados">📦 Recursos Provisionados</h2>

### Helm Chart

O chart `foodcore-observability` provisiona no cluster Kubernetes:

- **Elasticsearch StatefulSet** com volume persistente (3Gi)
- **Fluentd DaemonSet** para coleta de logs em todos os nodes
- **Kibana Deployment** com ingress configurado
- **Prometheus Deployment** com ConfigMap de scrape configs
- **Grafana Deployment** com datasources e dashboards pré-configurados
- **Zipkin Deployment** para distributed tracing
- **StorageClass** Azure Disk para volumes persistentes
- **Ingress** para exposição dos serviços via Application Gateway

### Endpoints de Acesso

| Serviço | Path | Porta Interna |
|---------|------|---------------|
| Kibana | `/kibana` | 5601 |
| Prometheus | `/prometheus` | 9090 |
| Grafana | `/grafana` | 3000 |
| Zipkin | `/zipkin` | 9411 |

### Recursos Delegados pelo Repo de Infra

- **Cluster AKS**
- **Namespaces** (monitor, order, catalog, payment)
- **Application Gateway Ingress Controller**
- **FQDN público do Ingress**

<h2 id="estrutura-do-projeto">📁 Estrutura do Projeto</h2>

```
foodcore-observability/
├── .github/
│   ├── CODEOWNERS
│   ├── pull_request_template.md
│   └── workflows/
│       ├── ci.yaml          # Pipeline de CI (Push Chart + Terraform Plan)
│       ├── cd.yaml          # Pipeline de CD (Terraform Apply)
│       └── destroy.yaml     # Pipeline de destruição
├── kubernetes/
│   └── foodcore-observability/
│       ├── Chart.yaml       # Metadata do Helm Chart
│       ├── values.yaml      # Valores de configuração
│       ├── assets/
│       │   └── grafana/
│       │       └── dashboards/
│       │           └── jvm_micrometer_dash.json
│       └── templates/
│           ├── NOTES.txt
│           ├── monitor/
│           │   ├── efk/           # Elasticsearch, Fluentd, Kibana
│           │   ├── grafana/       # Grafana configs
│           │   ├── prometheus/    # Prometheus configs
│           │   └── zipkin/        # Zipkin configs
│           └── volume/
│               └── storageclass.yaml
└── terraform/
    ├── backend.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        └── helm/              # Módulo para deploy do Helm release
```

<h2 id="fluxo-de-deploy">⚙️ Governança e Fluxo de Deploy</h2>

A gestão da stack de observabilidade segue um processo **automatizado, auditável e controlado** via **Pull Requests**.
Esse fluxo garante segurança, rastreabilidade e aprovação formal antes de qualquer mudança aplicada em produção.

---

### 📝 Processo de Alterações

1. **Criação de Pull Request**
   - Todas as alterações (novos recursos, updates, ou ajustes de configuração) devem ser propostas via **Pull Request (PR)**.
   - O PR contém os arquivos `.tf` ou templates Helm modificados e uma descrição detalhando o impacto da mudança.

2. **Execução Automática do CI Pipeline**
   - Ao abrir o PR, o pipeline de CI executa automaticamente:
     - **Build e Push** do Helm Chart para o ACR (Azure Container Registry)
     - **Terraform fmt** e **validate**
     - **Terraform plan** - gerando prévia das alterações
   - O resultado do `plan` é salvo como artefato para uso no deploy.

3. **Revisão e Aprovação**
   - O repositório é **protegido**, exigindo no mínimo **1 aprovação** de um codeowner antes do merge.
   - Nenhum usuário pode aplicar alterações diretamente na branch principal (`main`).
   - Revisores devem garantir:
     - Que o `plan` não tenha destruições indevidas (`destroy`)
     - Que as configurações dos serviços estejam corretas
     - Que os resources requests/limits sejam adequados
   - Todos os checks estipulados nas regras de proteção devem estar passando.

4. **Aplicação no Merge**
   - Após aprovação e merge do PR, o pipeline de CD executa automaticamente:

     ```
     terraform apply -auto-approve tfplan
     ```

   - O **Terraform Apply** aplica as alterações descritas no `plan` aprovado, atualizando o Helm release no cluster AKS.

---

### 🔄 Fluxo CI/CD

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Pull Request  │────▶│   CI Pipeline   │────▶│     Review      │
│     Opened      │     │  - Helm Push    │     │   & Approval    │
└─────────────────┘     │  - TF Plan      │     └────────┬────────┘
                        └─────────────────┘              │
                                                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Observability │◀────│   CD Pipeline   │◀────│      Merge      │
│    Deployed     │     │  - TF Apply     │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```


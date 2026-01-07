# 📊 FoodCore Observability

<div align="center">

Stack de observabilidade para monitoramento de microsserviços do projeto FoodCore. Desenvolvida como parte do curso de Arquitetura de Software da FIAP (Tech Challenge).

</div>

<div align="center">
  <a href="#visao-geral">Visão Geral</a> •
  <a href="#stack">Stack de Observabilidade</a> •
  <a href="#recursos-provisionados">Recursos Provisionados</a> •
  <a href="#debitos-tecnicos">Débitos Técnicos</a> •
  <a href="#deploy">Fluxo de Deploy</a> •
  <a href="#contribuicao">Contribuição</a>
</div><br>

> 📽️ Vídeo de demonstração da arquitetura: [https://www.youtube.com/watch?v=XgUpOKJjqak](https://www.youtube.com/watch?v=XgUpOKJjqak)<br>

---

<h2 id="visao-geral">📋 Visão Geral</h2>

Este repositório contém os scripts **Terraform** e o **Helm Chart** responsáveis por provisionar toda a stack de observabilidade do projeto FoodCore no cluster AKS.

### Três Pilares da Observabilidade

| Pilar | Stack | Descrição |
|-------|-------|-----------|
| **Logs** | EFK | Elasticsearch, Fluentd, Kibana |
| **Métricas** | Prometheus + Grafana | Coleta e visualização de métricas |
| **Traces** | Zipkin | Rastreamento distribuído |

---

<h2 id="stack">🔭 Stack de Observabilidade</h2>

### 📋 Logs - EFK Stack


| Componente | Descrição | Versão |
|------------|-----------|--------|
| **Elasticsearch** | Armazenamento e indexação de logs | 8.13.4 |
| **Fluentd** | Coleta e agregação de logs dos containers | v1.18 |
| **Kibana** | Visualização e análise de logs | 8.13.4 |

**Funcionamento atual**:
- Logs enviados para stdout/stderr pelos microsserviços (SLF4J)
- Containerd redireciona para diretório de logs
- Fluentd (DaemonSet) consome e envia para Elasticsearch

### 📈 Métricas - Prometheus + Grafana

| Componente | Descrição |
|------------|-----------|
| **Prometheus** | Coleta e armazenamento de métricas via scraping |
| **Grafana** | Dashboards e visualização |

> 📊 Inclui dashboard **JVM Micrometer** pré-configurado para aplicações Spring Boot.

### 👣 Traces - Zipkin

| Componente | Descrição |
|------------|-----------|
| **Zipkin** | Rastreamento distribuído de requisições |

**Funcionamento atual**:
- Auto-instrumentação via Micrometer Tracing
- Spring Actuator expõe métricas para Prometheus

---

<h2 id="recursos-provisionados">📦 Recursos Provisionados</h2>

### Helm Chart

O chart `foodcore-observability` provisiona no Kubernetes:

| Recurso | Tipo | Descrição |
|---------|------|-----------|
| **Elasticsearch** | StatefulSet | Volume persistente (3Gi) |
| **Fluentd** | DaemonSet | Coleta em todos os nodes |
| **Kibana** | Deployment | Com Ingress configurado |
| **Prometheus** | Deployment | ConfigMap de scrape configs |
| **Grafana** | Deployment | Datasources e dashboards pré-configurados |
| **Zipkin** | Deployment | Distributed tracing |
| **StorageClass** | - | Azure Disk para volumes |
| **Ingress** | - | Application Gateway |

### Endpoints de Acesso

| Serviço | Path | Porta |
|---------|------|-------|
| Kibana | `/kibana` | 5601 |
| Prometheus | `/prometheus` | 9090 |
| Grafana | `/grafana` | 3000 |
| Zipkin | `/zipkin` | 9411 |

---

<h2 id="debitos-tecnicos">⚠️ Débitos Técnicos</h2>

<details>
<summary>Expandir para mais detalhes</summary>

| Débito | Descrição | Impacto |
|--------|-----------|---------|
| **OpenTelemetry** | Migrar de Zipkin/Micrometer para OpenTelemetry | Padronização e vendor-neutral |
| **Tracing** | Micrometer Tracing + Zipkin | OpenTelemetry SDK + Collector |
| **Métricas** | Spring Actuator + Prometheus | OpenTelemetry Metrics |
| **Logs** | SLF4J + Fluentd | OpenTelemetry Logs |


<h2 id="limitacoes-quota">Limitações de Quota (Azure for Students)</h2>

> A assinatura **Azure for Students** impõe as seguintes restrições:
>
> - **Região**: Brazil South não está disponível. Utilizamos **South Central US** como alternativa
>
> - **Quota de VMs**: Apenas **2 instâncias** do SKU utilizado para o node pool do AKS, tendo um impacto direto na escalabilidade do cluster. Quando o limite é atingido, novos nós não podem ser criados e dão erro no provisionamento de workloads.
>
> ### Erro no CD dos Microsserviços
>
> Durante o deploy dos microsserviços, Pods podem ficar com status **Pending** e o seguinte erro pode aparecer:
>
> <img src=".github/images/error.jpeg" alt="Error" />
>
> **Causa**: O cluster atingiu o limite máximo de VMs permitido pela quota e não há recursos computacionais (CPU/memória) disponíveis nos nós existentes.
>
> **Solução**: Aguardar a liberação de recursos de outros pods e reexecutar CI + CD.

</details>

---

<h2 id="deploy">⚙️ Fluxo de Deploy</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Pipeline CI

1. Build e Push do Helm Chart para ACR
2. `terraform fmt` e `validate`
3. `terraform plan`

### Pipeline CD

1. `terraform apply`
2. Deploy do Helm release no AKS

### Ordem de Provisionamento

```
1. foodcore-infra        (AKS, VNET)
2. foodcore-db           (Bancos de dados)
3. foodcore-observability ← Este repositório
4. foodcore-*            (Microsserviços)
```

</details>

---

<h2 id="contribuicao">🤝 Contribuição</h2>

### Desenvolvimento Local

```bash
# Clonar repositório
git clone https://github.com/FIAP-SOAT-TECH-TEAM/foodcore-observability.git
cd foodcore-observability

# Validar Helm Chart
helm lint kubernetes/foodcore-observability

# Template para debug
helm template foodcore-observability kubernetes/foodcore-observability

# Terraform
cd terraform
terraform init
terraform validate
```

### Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

<div align="center">
  <strong>FIAP - Pós-graduação em Arquitetura de Software</strong><br>
  Tech Challenge
</div>

# 📊 FoodCore Observability

<div align="center">
 
Stack de observabilidade para monitoramento de microsserviços do projeto FoodCore. Desenvolvida como parte do curso de Arquitetura de Software da FIAP (Tech Challenge).

</div>

<div align="center">
  <a href="#visao-geral">Visão Geral</a> •
  <a href="#stack">Stack de Observabilidade</a> •
  <a href="#servicos-expostos">Serviços Expostos</a> •
  <a href="#infra">Infraestrutura</a> •
  <a href="#limitacoes-quota">Limitações de quotas</a> •
  <a href="#deploy">Fluxo de Deploy</a> •
  <a href="#instalacao-e-uso">Instalação e Uso</a> •
  <a href="#debitos-tecnicos">Débitos Técnicos</a> •
  <a href="#contribuicao">Contribuição</a>
</div><br>

> 📽️ Vídeo de demonstração da arquitetura: [https://youtu.be/k3XbPRxmjCw](https://youtu.be/k3XbPRxmjCw)<br>

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

<h2 id="servicos-expostos">📡 Serviços Expostos</h2>

| Serviço | Path | Ingress Port |
|---------|------|--------------|
| Kibana | `/kibana` | 80 (Http) |
| Prometheus | `/prometheus` | 80 (Http) |
| Grafana | `/grafana` | 80 (Http) |
| Zipkin | `/zipkin` | 80 (Http) |

> ⚠️ A URL Base pode ser obtida via output terraform `aks_ingress_public_ip_fqdn` (foodcore-infra).

---

<h2 id="infra">🌐 Infraestrutura</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Recursos Kubernetes

| Recurso | Descrição |
|---------|-----------|
| **Elasticsearch** | StatefulSet | Volume persistente (3Gi) |
| **Fluentd** | DaemonSet | Coleta em todos os nodes |
| **Kibana** | Deployment | Com Ingress configurado |
| **Prometheus** | Deployment | ConfigMap de scrape configs |
| **Grafana** | Deployment | Datasources e dashboards pré-configurados |
| **Zipkin** | Deployment | Distributed tracing |
| **StorageClass** | - | Azure Disk para volumes |
| **Ingress** | - | Roteamento via Azure Application Gateway (LB Layer 7) |

- O **Application Gateway** recebe tráfego em um **Frontend IP Público**
- Roteamento direto para os IPs dos Pods (**Azure CNI + Overlay**)
- Path exposto: `/`

> ⚠️ Após o deploy (CD), aguarde cerca de **5 minutos** para que o **AGIC** finalize a configuração do Application Gateway.

### Integrações

| Serviço | Tipo | Descrição |
|---------|------|-----------|
| **Azure Service Bus** | Assíncrona | Publicação/consumo de eventos |
| **PostgreSQL** | Síncrona | Persistência de dados |
| **FoodCore Catalog** | HTTP | Validação de produtos |

### 🔐 Azure Key Vault Provider (CSI)

- Sincroniza secrets do Azure Key Vault com Secrets do Kubernetes
- Monta volumes CSI com `tmpfs` dentro dos Pods
- Utiliza o CRD **SecretProviderClass**

> ⚠️ Caso o valor de uma secret seja alterado no Key Vault, é necessário **reiniciar os Pods**, pois variáveis de ambiente são injetadas apenas na inicialização.
>
> Referência: <https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options>

### Observabilidade

- **Logs**: Envio para Elasticsearch via Fluentd
- **Métricas**: Exposição para Prometheus via Micrometer
- **Tracing**: Instrumentação com Zipkin
- **Dashboards**: Visualização no Grafana

</details>

---

<h2 id="limitacoes-quota">📉 Limitações de Quota (Azure for Students)</h2>

<details>
<summary>Expandir para mais detalhes</summary>

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
> <img src=".github/images/erroDeploy.jpeg" alt="Error" />
>
> **Causa**: O cluster atingiu o limite máximo de VMs permitido pela quota e não há recursos computacionais (CPU/memória) disponíveis nos nós existentes.
>
> **Solução**: Aguardar a liberação de recursos de outros pods e reexecutar CI + CD.

</details>

---

<h2 id="deploy">⚙️ Fluxo de Deploy</h2>

<details>
<summary>Expandir para mais detalhes</summary>

### Pipeline

1. **Pull Request**
   - Preencher template de pull request adequadamente

2. **Revisão e Aprovação**
   - Mínimo 1 aprovação de CODEOWNER

3. **Merge para Main**

### Proteções

- Branch `main` protegida
- Nenhum push direto permitido
- Todos os checks devem passar

### Ordem de Provisionamento

```
1. foodcore-infra        (AKS, VNET)
2. foodcore-db           (Bancos de dados)
3. foodcore-auth           (Azure Function Authorizer)
4. foodcore-observability (Serviços de Observabilidade)
5. foodcore-order            (Microsserviço de pedido)
6. foodcore-payment            (Microsserviço de pagamento)
7. foodcore-catalog            (Microsserviço de catálogo)
```

> ⚠️ Opcionalmente, as pipelines do repositório `foodcore-shared` podem ser executadas para publicação de um novo package. Atualizar os microsserviços para utilizarem a nova versão do pacote.

</details>

---

<h2 id="instalacao-e-uso">🚀 Instalação e Uso</h2>

### Desenvolvimento Local

```bash
# Clonar repositório
git clone https://github.com/FIAP-SOAT-TECH-TEAM/foodcore-observability.git
cd foodcore-observability

# Configurar variáveis de ambiente (Docker)
cp docker/env-example docker/.env

# Subir dependências
./food start:infra
```

---

<h2 id="debitos-tecnicos">⚠️ Débitos Técnicos</h2>

<details>
<summary>Expandir para mais detalhes</summary>

| Débito | Descrição | Impacto |
|--------|-----------|---------|
| **OpenTelemetry** | Migrar de Micrometer para OpenTelemetry | Padronização de observabilidade |
| **APM** | Usar uma ferramenta de APM ao invés de serviços isolados | Ferramenta unificada de observabilidade |

</details>

---

<h2 id="contribuicao">🤝 Contribuição</h2>

### Fluxo de Contribuição

1. Crie uma branch a partir de `main`
2. Implemente suas alterações
3. Abra um Pull Request
4. Aguarde aprovação de um CODEOWNER

### Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

<div align="center">
  <strong>FIAP - Pós-graduação em Arquitetura de Software</strong><br>
  Tech Challenge 4
</div>

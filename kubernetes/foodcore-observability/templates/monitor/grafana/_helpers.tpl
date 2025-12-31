{{- define "grafana.name" -}}
{{- .Values.grafana.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "grafana.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.grafana.name | trunc 63 | trimSuffix "-" }}
{{- end }}
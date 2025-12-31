{{- define "prometheus.name" -}}
{{- .Values.prometheus.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "prometheus.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.prometheus.name | trunc 63 | trimSuffix "-" }}
{{- end }}
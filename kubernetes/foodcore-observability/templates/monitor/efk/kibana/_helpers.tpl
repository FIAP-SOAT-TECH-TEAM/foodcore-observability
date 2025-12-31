{{- define "kibana.name" -}}
{{- .Values.kibana.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kibana.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.kibana.name | trunc 63 | trimSuffix "-" }}
{{- end }}
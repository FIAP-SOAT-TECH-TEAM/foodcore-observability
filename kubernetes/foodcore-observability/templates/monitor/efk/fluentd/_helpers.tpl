{{- define "fluentd.name" -}}
{{- .Values.fluentd.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "fluentd.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.fluentd.name | trunc 63 | trimSuffix "-" }}
{{- end }}
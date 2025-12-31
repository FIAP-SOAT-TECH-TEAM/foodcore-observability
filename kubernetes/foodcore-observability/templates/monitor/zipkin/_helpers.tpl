{{- define "zipkin.name" -}}
{{- .Values.zipkin.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "zipkin.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.zipkin.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "elasticsearch.name" -}}
{{- .Values.elasticsearch.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "elasticsearch.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.elasticsearch.name | trunc 63 | trimSuffix "-" }}
{{- end }}
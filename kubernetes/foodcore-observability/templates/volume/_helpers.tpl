{{- define "storageclass.name" -}}
{{- .Values.storageClass.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "storageclass.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.storageClass.name | trunc 63 | trimSuffix "-" }}
{{- end }}
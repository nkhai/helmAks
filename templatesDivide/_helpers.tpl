{{/*
Helper template for generating selector labels
*/}}
{{- define "templating deep dive.selectorLabels" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{/*
Expand the name of the chart.
*/}}
{{- define "actorizer_cdc.name" -}}
{{- default .Chart.Name .Values.global.actorizer_cdc.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "actorizer_cdc.fullname" -}}
{{- if .Values.global.actorizer_cdc.fullnameOverride }}
{{- .Values.global.actorizer_cdc.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.global.actorizer_cdc.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "actorizer_cdc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "actorizer_cdc.labels" -}}
helm.sh/chart: {{ include "actorizer_cdc.chart" . }}
{{ include "actorizer_cdc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "actorizer_cdc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "actorizer_cdc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "actorizer_cdc.serviceAccountName" -}}
{{- if .Values.global.actorizer_cdc.serviceAccount.create }}
{{- default (include "actorizer_cdc.fullname" .) .Values.global.actorizer_cdc.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.global.actorizer_cdc.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "common.ServiceMonitor.apiVersion" -}}
monitoring.coreos.com/v1
{{- end -}}

{{- define "common.ServiceMonitor.metadata.labes" -}}
simulator.observability/scrape: "true"
{{- end -}}

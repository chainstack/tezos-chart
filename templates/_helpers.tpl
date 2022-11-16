{{/*
Expand the name of the chart.
*/}}
{{- define "tezos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tezos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create hostname
*/}}
{{- define "tezos.node.hostname" -}}
{{- printf "%s.%s" .Values.node.id .Values.cluster.domain | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "tezos.secret.name" -}}
{{- printf "any.%s" .Values.cluster.domain | replace "." "-" | lower -}}
{{- end -}}

{{/*
Calculate service name
*/}}
{{- define "tezos.serviceName" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "tezos.protocol.mode" -}}
{{- if .Values.archive -}}
{{- printf "tezos-%s-archive" .Values.network.name -}}
{{- else -}}
{{- printf "tezos-%s-full" .Values.network.name -}}
{{- end -}}
{{- end -}}

{{- define "tezos.historyMode" -}}
{{- if .Values.node.archive -}}
{{- printf "archive" -}}
{{- else -}}
{{- printf "full" -}}
{{- end -}}
{{- end -}}

{{- define "tezos.nodeDir" }}
{{- printf "/var/tezos/node" }}
{{- end }}

{{- define "tezos.dataDir" }}
{{- printf "%s/data" (include "tezos.nodeDir" . ) }}
{{- end }}

{{- define "labels.standard" -}}
app.kubernetes.io/name: {{ include "tezos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: {{ include "tezos.name" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
network: {{ .Values.network.id }}
networkName: {{ .Values.network.name }}
nodeId: {{ .Values.node.id }}
historyMode: {{ include "tezos.historyMode" . }}
{{- end -}}

{{- define "labels.deployment" -}}
{{ include "labels.standard" . }}
{{- if .Values.deploymentLabels }}
{{ toYaml .Values.deploymentLabels }}
{{- end -}}
{{- end -}}

{{- define "labels.serviceSelector" -}}
{{- if .Values.service.selector }}
{{- toYaml .Values.service.selector }}
{{- else -}}
app: {{ template "tezos.name" . }}
release: {{ .Release.Name }}
{{- end -}}
{{- end -}}

{{- define "tezos.shouldConfigInit" -}}
{{- if not (.Values.network.genesis) }}
{{- "true" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "tezos.isTestnet" }}
{{- if ne .Values.network.name "mainnet" }}
{{- "true" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "tezos.isMainnet" }}
{{- if eq .Values.network.name "mainnet" }}
{{- "true" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{- define "tezos.snapshotUrl" }}
{{- if eq .Values.network.name "mainnet" }}
{{- .Values.snapshot.mainnet.full }}
{{- else if eq .Values.network.name "testnet" }}
{{- .Values.snapshot.testnet.full }}
{{- end }}
{{- end }}

{{/*
Configure key for ingress stickiness.
*/}}
{{- define "tezos.stickinessHashKey" -}}
{{- default "$ingress_name" .Values.ingress.sticky.hashKey -}}
{{- end -}}

{{/*
Configure the ingressClass
*/}}
{{- define "tezos.ingressClass" -}}
{{- if (not .Values.ingress.class) -}}
{{- printf "nginx" -}}
{{- else -}}
{{- .Values.ingress.class -}}
{{- end -}}
{{- end -}}

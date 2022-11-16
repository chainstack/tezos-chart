{{- define "tezos.init_container.flush_node_identity" }}
- image: "{{ .Values.image.main.repository }}:{{ .Values.image.main.tag }}"
  imagePullPolicy: IfNotPresent
  name: flush-identity
  command:
  - /bin/sh
  - -c
  - |
    (grep {{ .Values.node.id }} /var/tezos/release.version -q && echo 'Lock file belongs to current release. Nothing to do.') || (rm -f  /var/tezos/node/data/identity.json && echo {{ .Values.node.id }} > /var/tezos/release.version && echo 'Identity has been flushed.')

  volumeMounts:
    - mountPath: /etc/tezos
      name: config-volume
    - mountPath: /var/tezos
      name: var-volume
  envFrom:
    - configMapRef:
        name: {{ .Release.Name }}-tezos-config
{{- end }}

{{- define "tezos.init_container.config_init" }}
{{- if include "tezos.shouldConfigInit" . }}
- image: "{{ .Values.image.main.repository }}:{{ .Values.image.main.tag }}"
  imagePullPolicy: IfNotPresent
  name: config-init
  command: ["sh", "-c"]
  args: ["mkdir /tmp/.tezos-node && tezos-node config init --config-file /etc/tezos/data/config.json --data-dir /tmp/.tezos-node --network {{ .Values.network.name }} && cat /etc/tezos/data/config.json"]
  volumeMounts:
    - mountPath: /etc/tezos
      name: config-volume
    - mountPath: /var/tezos
      name: var-volume
  envFrom:
    - configMapRef:
        name: {{ .Release.Name }}-tezos-config
{{- end }}
{{- end }}

{{- define "tezos.init_container.config_generator" }}
- image: "{{ .Values.image.tools.repository }}:{{ .Values.image.tools.tag }}"
  imagePullPolicy: IfNotPresent
  name: config-generator
  args:
    - "config-generator"
    - "--generate-config-json"
  volumeMounts:
    - mountPath: /etc/tezos
      name: config-volume
    - mountPath: /var/tezos
      name: var-volume
  envFrom:
    - secretRef:
        name: {{ .Release.Name }}-tezos-secret
    - configMapRef:
        name: {{ .Release.Name }}-tezos-config
  env:
    - name: MY_POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
{{- end }}

{{- define "tezos.init_container.snapshot_downloader" }}
{{- if .Values.snapshot.useSnapshot }}
- image: "curlimages/curl:latest"
  imagePullPolicy: IfNotPresent
  name: snapshot-downloader
  command: ["/bin/sh"]
  args: ["/tmp/init_scripts/snapshotDownloader.sh"]
  volumeMounts:
    - mountPath: /tmp/init_scripts
      name: snapshot-downloader
    - mountPath: /var/tezos
      name: var-volume
    - mountPath: /etc/tezos
      name: config-volume
  env:
    - name: SNAPSHOT_URL
      value: {{ include "tezos.snapshotUrl" . }}
{{- end }}
{{- end }}

{{- define "tezos.init_container.snapshot_importer" }}
{{- if .Values.snapshot.useSnapshot }}
- image: "{{ .Values.image.main.repository }}:{{ .Values.image.main.tag }}"
  imagePullPolicy: IfNotPresent
  name: snapshot-importer
  command: ["/bin/sh"]
  args: ["/tmp/init_scripts/snapshotImporter.sh"]
  volumeMounts:
    - mountPath: /tmp/init_scripts
      name: snapshot-importer
    - mountPath: /var/tezos
      name: var-volume
    - mountPath: /etc/tezos
      name: config-volume
  envFrom:
    - configMapRef:
        name: {{ .Release.Name }}-tezos-config
{{- end }}
{{- end }}

{{/*
For upgrade full node's storage it's faster to flush and restore from tezos snapshot
There are no snapshots for archive node, so we have to upgrade it with tezos-node tool
*/}}
{{- define "tezos.init_container.storage_upgrade" }}
- image: "{{ .Values.image.main.repository }}:{{ .Values.image.main.tag }}"
  imagePullPolicy: IfNotPresent
  name: storage-upgrade
  command:
  - sh
  - -c
  - |
    if [ -d {{ include "tezos.dataDir" . }} ]; then
        tezos-node upgrade storage --data-dir {{ include "tezos.dataDir" . }}
    else
        echo "Skip upgrade for initial deploy"
    fi
  volumeMounts:
    - mountPath: /var/tezos
      name: var-volume
    - mountPath: /etc/tezos
      name: config-volume
  envFrom:
    - configMapRef:
        name: {{ .Release.Name }}-tezos-config
{{- end }}

# Tezos Public Network

[Tezos](https://github.com/tqtezos) is official OCaml implementation of the Tezos protocol

## Introduction

This chart bootstraps a deployment of Tezos node in a public Tezos network on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart
To install the chart with the release name `my-release`:

```bash
$ helm install my-release .
```

The command deploys Tezos Network on the Kubernetes cluster in the default configuration.
The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release`:

```bash
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

```bash
$ helm install --name my-release -f values.yaml .
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The tezos image stores the tezos node data (ledger and wallets) and configurations in `/var/tezos` inside the container.

By default a PersistentVolumeClaim is created and mounted into that directory. 

## Deployment reference values

The deployment reference values are obtained from https://github.com/tqtezos/tezos-k8s/

## Sample Deployment Command
Listed in `tests` section in .config.yaml

#### Deployment options to note

1. Masternodes
    - snapshot.useSnapshot=true (this does some operations in the init containers)
2. Fresh sync nodes
    - persistence.storageClassName=ssd-dynamic
3. History modes
    - node.archive=false for full node (default)
    - node.archive=true for archive node
4. Networks
    - network.name='mainnet' for mainnet
    - network.name='jakartanet' for jakartanet testnet

#!/bin/sh
set -ex

node_dir="/var/tezos/node"
node_data_dir="$node_dir/data"
snapshot_file=${node_dir}/chain.snapshot

if [ -d ${node_data_dir}/context ]; then
    echo "Blockchain has already been imported, exiting"
    exit 0
fi

# It should be removed in case of restoring from snapshot.
rm -rf /etc/tezos/data
rm -rf /etc/tezos/tezedge.conf
rm -rf /var/tezos/node/data/lock

tezos-node snapshot import ${snapshot_file} --data-dir ${node_data_dir} \
    --network $CHAIN_NAME --config-file /etc/tezos/config.json
find ${node_dir}
rm -rvf ${snapshot_file}

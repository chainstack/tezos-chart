#!/bin/sh
set -ex

data_dir="/var/tezos"
node_dir="$data_dir/node"
node_data_dir="$node_dir/data"
snapshot_file=$node_dir/chain.snapshot
if [ -d ${node_data_dir}/context ]; then
    echo "Blockchain context found, skip downloading snapshot"
    exit 0
fi
echo "Did not find pre-existing data, importing blockchain from $SNAPSHOT_URL to $snapshot_file"
mkdir -p $node_data_dir
echo '{ "version": "0.0.6" }' > $node_dir/version.json
curl -Lf -o $snapshot_file $SNAPSHOT_URL
ls -lR /var/tezos

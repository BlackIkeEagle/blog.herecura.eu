#!/usr/bin/env bash

firecracker --api-sock "$(pwd)"/firecracker.socket --config-file vm_config.json
rm firecracker.socket

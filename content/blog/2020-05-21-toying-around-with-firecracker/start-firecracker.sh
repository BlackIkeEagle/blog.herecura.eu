#!/usr/bin/env bash

firecracker --api-sock "$(pwd)"/firecracker.socket
rm firecracker.socket

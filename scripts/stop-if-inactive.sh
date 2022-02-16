# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#!/bin/bash
set -euo pipefail
CONFIG=$(cat /home/ec2-user/.c9/autoshutdown-configuration)
SHUTDOWN_TIMEOUT=${CONFIG#*=}
if ! [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]*$ ]]; then
    echo "shutdown timeout is invalid"
    exit 1
fi
is_shutting_down() {
    is_shutting_down_ubuntu &> /dev/null || is_shutting_down_al1 &> /dev/null || is_shutting_down_al2 &> /dev/null
}
is_shutting_down_ubuntu() {
    local TIMEOUT
    TIMEOUT=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager ScheduledShutdown)
    if [ "$?" -ne "0" ]; then
        return 1
    fi
    if [ "$(echo $TIMEOUT | awk "{print \$3}")" == "0" ]; then
        return 1
    else
        return 0
    fi
}
is_shutting_down_al1() {
    pgrep shutdown
}
is_shutting_down_al2() {
    local FILE
    FILE=/run/systemd/shutdown/scheduled
    if [[ -f "$FILE" ]]; then
        return 0
    else
        return 1
    fi
}
is_vfs_connected() {
    pgrep -f vfs-worker >/dev/null
}

is_vscode_connected() {
    pgrep -u ec2-user -f .vscode-server/bin/ >/dev/null
}

if is_shutting_down; then
    if [[ ! $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]] || is_vfs_connected || is_vscode_connected; then
        sudo shutdown -c
    fi
else
    if [[ $SHUTDOWN_TIMEOUT =~ ^[0-9]+$ ]] && ! is_vfs_connected && ! is_vscode_connected; then
        sudo shutdown -h $SHUTDOWN_TIMEOUT
    fi
fi
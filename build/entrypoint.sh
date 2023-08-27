#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Cleanup openvpn process
cleanup() {
    kill -SIGTERM "${openvpn_pid}"
    wait "${openvpn_pid}"
}

# If $NAMESERVER is set, rewrite the nameserver IP to the given value in /etc/resolv.conf
if [[ -n "${NAMESERVER:-}" ]]; then
    echo "\$NAMESERVER set; setting DNS address to ${NAMESERVER}..."
    sed "s/^nameserver .*/nameserver ${NAMESERVER}/" /etc/resolv.conf >> /etc/resolv2.conf
    echo "" > /etc/resolv.conf
    cat /etc/resolv2.conf >> /etc/resolv.conf
    rm /etc/resolv2.conf
    # Ugly workaround; docker mounts /etc/resolv.conf, so you can't directly manipulate it with sed -i.
else 
    echo "\$NAMESERVER not set; using default DNS address..."
fi

# If the $CONFIG_FILE variable is set, set config_file to that value, else get a random *.ovpn from the /config directory
if [[ -n "${CONFIG_FILE:-}" ]]; then
    config_file="/config/${CONFIG_FILE}"
else
    config_file="$(find /config -type f -name '*.ovpn' | sort | shuf -n1)"
fi


# If no config files are present, print an error and exit
if [[ ! -f "${config_file}" ]]; then
    echo "No config file found. Please mount a config file to /config."
    exit 1
fi

# Print the config file name as info
echo "Using config file: ${config_file}"

# Set up the openvpn arguments
openvpn_args=(
    "--config" "${config_file}"
    "--cd" "/config"
)

# Start openvpn with the given arguments
openvpn "${openvpn_args[@]}" &

# Set the openvpn_pid variable to the pid of the openvpn process
openvpn_pid=$!

# Set up a trap to cleanup the openvpn process on exit
trap cleanup EXIT

# Wait for the openvpn process to exit
wait $openvpn_pid
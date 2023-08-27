#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Cleanup openvpn process
cleanup() {
    kill -SIGTERM "${openvpn_pid}"
    wait "${openvpn_pid}"
}

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

# If $PASSWORD and $USERNAME are set, set auth_file to a temporary file containing the username and password
if [[ -n "${PASSWORD:-}" && -n "${USERNAME:-}" ]]; then
    auth_file="$(mktemp)"
    echo "${USERNAME}" > "${auth_file}"
    echo "${PASSWORD}" >> "${auth_file}"
fi

# Set up the openvpn arguments for config, cd, and auth file (if set)
if [[ -n "${auth_file:-}" ]]; then
    openvpn_args=(
        "--config" "${config_file}"
        "--cd" "/config"
        "--auth-user-pass" "${auth_file:-}"
    )
else
    openvpn_args=(
        "--config" "${config_file}"
        "--cd" "/config"
    )
fi


# Start openvpn with the given arguments
openvpn "${openvpn_args[@]}" &

# Set the openvpn_pid variable to the pid of the openvpn process
openvpn_pid=$!

# Set up a trap to cleanup the openvpn process on exit
trap cleanup EXIT

# Wait for the openvpn process to exit
wait $openvpn_pid
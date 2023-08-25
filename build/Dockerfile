FROM alpine:3.17

# Install openvpn and dependencies
RUN apk add --no-cache openvpn bash iptables curl

# Copy scripts to working directory
COPY . /usr/local/bin

# Set entrypoint.sh as the entrypoint
ENTRYPOINT ["entrypoint.sh"]
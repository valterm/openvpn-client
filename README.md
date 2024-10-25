# openvpn-client

A container for running an OpenVPN client. Aims to create a lightweight and easily deployable solution to run the client.

## Usage

The following capabilities and devices are needed for the container to work:

### Capabilities

| Capability | Description |
|-------------|--------------------------------------------------------------------------------------------------------|
| `NET_ADMIN` | This capability is needed to manage the virtual network devices. |

### Devices

| Device Path | Description |
|-------------------|---------------------------------------------------------|
| `/dev/net/tun` | This device is necessary for tunneling in VPNs. |

### Network
To set the VPN for your entire host, use network-mode `host`. If you'd prefer to isolate it only for containers within the stack, use `bridge`, but note that ipv4 forwarding must be enabled for it to work.

### Starting the service

#### docker
  
To run the container using Docker:

```bash

docker run -it --cap-add NET_ADMIN --network host -v /dev/net/tun:/dev/net/tun -v /path/to/config:/config -e CONFIG_FILE=your_config.ovpn valtimalti/openvpn-client:latest

```

#### docker compose

Sample file:

```yaml
version: '3'
services:
  openvpn-client:
    container_name: openvpn-client
    image: valtimalti/openvpn-client:latest
    network_mode: bridge
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    dns:
      - 208.67.222.222 # OpenDNS; optional if you want to use your own DNS
    environtment:
      - 'LOCAL_NETWORK=192.168.0.0/24'
    volumes:
      - /path/to/config:/config
```

### Tunneling traffic of other containers through the VPN

You can use the `--network` flag or `network` key to tunnel the traffic of other containers through the VPN container.

#### docker
Create the vpn container, and once it's up and running use the following flag:

```
docker run --network container:openvpn-client example/image
```

#### docker compose
Add the `depends_on: openvpn-client` and `network_mode: service: openvpn-client` key/value pairs to your service:

```yaml
version: '3'
services:
  openvpn-client:
    ... # See above
  other_service:
    container_name: other-service
    image: example/image
    depends_on:
      - openvpn-client
    network_mode: service:openvpn-client

```

### Volumes

The following volumes can be mounted:

| Volume Path | Required? | Description |
|---------------|---------------|---------------------------------------------------------------------------------------------------------|
| `/config` | Yes | This directory should contain your OpenVPN configuration files (`*.ovpn`). |

### Env variables

| Environment Variable | Required? | Description |
|----------------------|---------------|-----------------------------------------------------------------------------------------------------------------|
| `LOCAL_NETWORK` | Conditional | Required if using `bridge` mode. The CIDR of the local network the VPN container should route to. |
| `CONFIG_FILE` | No | Specify a particular OpenVPN configuration file from the `/config` directory. If not set, a random `.ovpn` file from the `/config` directory will be used. |
| `USERNAME` | Conditional | Specify the username in case your config requires authentication. Must be set if `PASSWORD` is set. |
| `PASSWORD` | Conditional | Specify the password in case your config requires authentication. Must be set if `USERNAME` is set. |
| `ADAPTER` | No | Change the default network adapter. If not set, the default tunnel device will be used (most likely `tun0`.) |


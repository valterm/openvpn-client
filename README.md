# openvpn-client

A container for running an OpenVPN client. Aims to create a lightweight and easily deployable solution to run the client.

## Usage

This following capabilities and devices are needed for the container to work:

### Capabilities

| Capability | Description |
|-------------|--------------------------------------------------------------------------------------------------------|
| `NET_ADMIN` | This capability is needed to manage the virtual network devices. |

### Devices

| Device Path | Description |
|-------------------|---------------------------------------------------------|
| `/dev/net/tun` | This device is necessary for tunneling in VPNs. |

### docker
  
To run the container using Docker:

```bash

docker  run  -it  --cap-add  NET_ADMIN  -v  /dev/net/tun:/dev/net/tun  -v  /path/to/config:/config  -e  CONFIG_FILE=your_config.ovpn  valtma/openvpn-client:latest

```

### docker compose

Sample file:

```yaml
version:  '3'
services:
	openvpn-client:
		container_name:  openvpn-client
		image:  valtma/openvpn-client:latest
		cap_add:
			- NET_ADMIN
		devices:
			- /dev/net/tun
		volumes:
			- /path/to/config:/config
```


To use the created container with other containers, add the `depends_on: openvpn-client` and `network_mode: service: openvpn-client` key/value pairs to your service:

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
    network_mode: service:vpn

```

## Volumes

The following volumes can be mounted:

| Volume Path | Required? | Description |
|---------------|---------------|---------------------------------------------------------------------------------------------------------|
| `/config` | Yes | This directory should contain your OpenVPN configuration files (`*.ovpn`). |

## Env variables

| Environment Variable | Required? | Description |
|----------------------|---------------|-----------------------------------------------------------------------------------------------------------------|
| `CONFIG_FILE` | No | Specify a particular OpenVPN configuration file from the `/config` directory. If not set, a random `.ovpn` file from the `/config` directory will be used. |
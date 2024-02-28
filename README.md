# Pi-Hole + Unbound on Docker
![Pi-Hole Unbound](https://github.com/nyirsh/pihole-unbound/blob/main/resources/pihole-unbound.png?raw=true "Pi-Hole Unbound")

### Use Docker to run [Pi-Hole](https://pi-hole.net) with an upstream [Unbound](https://nlnetlabs.nl/projects/unbound/about/) resolver.
This Docker deployment runs both Pi-Hole and Unbound in a single container.

The base image for the container is the [official Pi-Hole container](https://hub.docker.com/r/pihole/pihole), with an extra build step added to install the Unbound resolver directly into to it based on [instructions provided directly by the Pi-Hole team](https://docs.pi-hole.net/guides/unbound/).

[![Auto-Update Pi-Hole](https://github.com/nyirsh/pihole-unbound/actions/workflows/update-pihole-version.yml/badge.svg)](https://github.com/nyirsh/pihole-unbound/actions/workflows/update-pihole-version.yml)

The [Github repository](https://github.com/nyirsh/pihole-unbound/) is set to automatically check for a new PiHole version every day by monitoring the [official Pi-Hole docker repository](https://github.com/pi-hole/docker-pi-hole/). If a new release is detected, a new image is automatically generated and pushed to [dockerhub repository](https://hub.docker.com/repository/docker/nyirsh/pihole-unbound/).

This configuration contacts the DNS root servers directly, please read the Pi-Hole docs on [Pi-hole as All-Around DNS Solution](https://docs.pi-hole.net/guides/unbound/) to understand what this means.

# Quick Start

## Compose file
Download the pre-made `docker-compose.yml` ...

```bash
curl -SO https://raw.githubusercontent.com/nyirsh/pihole-unbound/main/docker-compose.yml
```

... or create one and customize it following the example below:

```yml
version: '3.0'

volumes:
  etc_pihole-unbound:
  etc_pihole_dnsmasq-unbound:

services:
  pihole:
    container_name: pihole-unbound
    image: nyirsh/pihole-unbound:latest
    hostname: ${HOSTNAME:-pihole}
    domainname: ${DOMAIN_NAME:-pihole.local}
    ports:
      - 53:53/tcp
      - 53:53/udp
      - ${PIHOLE_WEBPORT_HTTP:-80}:80/tcp
      - ${PIHOLE_WEBPORT_HTTPS:-443}:80/tcp
    environment:
      - FTLCONF_LOCAL_IPV4=${FTLCONF_LOCAL_IPV4}
      - TZ=${TZ:-UTC}
      - WEBPASSWORD=${WEBPASSWORD}
      - WEBTHEME=${WEBTHEME:-default-dark}
      - REV_SERVER=${REV_SERVER:-false}
      - REV_SERVER_TARGET=${REV_SERVER_TARGET}
      - REV_SERVER_DOMAIN=${REV_SERVER_DOMAIN}
      - REV_SERVER_CIDR=${REV_SERVER_CIDR}
      - PIHOLE_DNS_=127.0.0.1#5335
      - DNSSEC="true"
      - DNSMASQ_LISTENING=single
    volumes:
      - etc_pihole-unbound:/etc/pihole:rw
      - etc_pihole_dnsmasq-unbound:/etc/dnsmasq.d:rw
    restart: unless-stopped
```

## Evironment variables
Create a `.env` file and substitute the values to match what's required for your deployment:

```
HOSTNAME=pihole
DOMAIN_NAME=pihole.local
PIHOLE_WEBPORT_HTTP=80
PIHOLE_WEBPORT_HTTPS=443

FTLCONF_LOCAL_IPV4=192.168.1.10
TZ=America/Los_Angeles
WEBPASSWORD=YourAdminPassword
REV_SERVER=true
REV_SERVER_DOMAIN=local
REV_SERVER_TARGET=192.168.1.1
REV_SERVER_CIDR=192.168.0.0/16
WEBTHEME=default-dark
```

### Docker variables
| Variable | Default | Value | Description |
| -------- | ------- | ----- | ---------- |
| `HOSTNAME` | `pihole` | Container host name | Set to your preferred [docker container hostname](https://docs.docker.com/compose/compose-file/05-services/#hostname) for the Pi-Hole instance
| `DOMAIN_NAME` | `pihole.local` | Container domain name | Set to your preferred [docker container domainname](https://docs.docker.com/compose/compose-file/05-services/#domainname) for the Pi-Hole instance
| `PIHOLE_WEBPORT_HTTP` | `80` | Exposed HTTP Port | Set this to the port you want to use to access Pi-Hole via HTTP. Make sure the port isn't already in use!
| `PIHOLE_WEBPORT_HTTPS` | `443` | Exposed HTTPS Port | Set this to the port you want to use to access Pi-Hole via HTTPS. Make sure the port isn't already in use!

### Pi-Hole variables

| Variable | Default | Value | Description |
| -------- | ------- | ----- | ---------- |
| `FTLCONF_LOCAL_IPV4` | unset | `<Host's IP>` | Set to your server's LAN IP, used by web block modes and lighttpd bind address.
| `TZ` | `UTC` | `<Timezone>` | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight.
| `WEBPASSWORD` | random | `<Admin password>` | http://pi.hole/admin password. Run `docker logs pihole \| grep random` to find your random pass.
| `REV_SERVER` | `false` | `<"true"\|"false">` | Enable DNS conditional forwarding for device name resolution |
| `REV_SERVER_DOMAIN` | unset | Network Domain | If conditional forwarding is enabled, set the domain of the local network router |
| `REV_SERVER_TARGET` | unset | Router's IP | If conditional forwarding is enabled, set the IP of the local network router |
| `REV_SERVER_CIDR` | unset | Reverse DNS | If conditional forwarding is enabled, set the reverse DNS zone (e.g. `192.168.0.0/24`) |
| `WEBTHEME` | `default-light` | `<"default-dark"\|"default-darker"\|"default-light"\|"default-auto"\|"lcars">`| User interface theme to use.
| `CORS_HOSTS` | unset | `<FQDNs delimited by ,>` | List of domains/subdomains on which CORS is allowed. Wildcards are not supported. Eg: `CORS_HOSTS: domain.com,home.domain.com,www.domain.com`.

> For a complete list of possible variables, please refer to the [Pi-Hole official documentation](https://github.com/pi-hole/docker-pi-hole/#environment-variables):

## Run the stack!

```bash
docker-compose up -d
```

> If using Portainer, just paste the `docker-compose.yaml` contents into the stack config and add your *environment variables* directly in the UI.

## FAQ
***- Q: I also want to use Cloudflare or change some other parameters of Pi-Hole!***

A: Please keep in mind that the `docker-compose.yml` and `.env` files provided in this repository are just an example! Please feel free to cumostomize the files so that they can match your expected experience, if you're unsure on how to do so I would highly recommend getting some knowledge on [Docker](https://docs.docker.com/) first.

***- Q: I am running Pi-Hole alongside other containers on the same machine but, despite setting the DNS to match the host machine IP, I still can't resolve any address!***

Yep, it's a docker limitation of some sort, you can find more details [here](https://discourse.pi-hole.net/t/solve-dns-resolution-in-other-containers-when-using-docker-pihole/31413). To keep it short, change these two ports in your `docker-compose.yml` file:
```yml
- "${FTLCONF_LOCAL_IPV4}:53:53/tcp"
- "${FTLCONF_LOCAL_IPV4}:53:53/udp"
```

***- Q: Thank you for this! Do you accept donations?***

A: No I do not, I really did nothing special and everything here is fully automated so I don't think I deserve any kind of donation or recognition. If you're really willing to donate some money please consider giving them to the [Pi-Hole](https://pi-hole.net/donate) itself.

## Credits
Thanks to [Chris Crowe](https://github.com/chriscrowe) for figuring this installation method out.
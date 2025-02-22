# Pi-Hole + Unbound on Docker

![GitHub Tag](https://img.shields.io/github/v/tag/nyirsh/pihole-unbound?label=Repository%20Version&link=https%3A%2F%2Fgithub.com%2Fnyirshy%2Fpihole-unbound%2F)
![GitHub Tag](https://img.shields.io/github/v/tag/pi-hole/docker-pi-hole?logo=pi-hole&label=Pi-Hole%20Version&link=https%3A%2F%2Fgithub.com%2Fpi-hole%2Fdocker-pi-hole%2F)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/nyirsh/pihole-unbound/docker-image-ci.yml?logo=GitHub&label=Auto%20Update&link=https%3A%2F%2Fgithub.com%2Fnyirsh%2Fpihole-unbound%2Factions%2Fworkflows%2Fdocker-image-ci.yml)

![Pi-Hole Unbound](https://github.com/nyirsh/pihole-unbound/blob/main/resources/pihole-unbound.png?raw=true "Pi-Hole Unbound")

### Use Docker to run [Pi-Hole](https://pi-hole.net) with an upstream [Unbound](https://nlnetlabs.nl/projects/unbound/about/) resolver.

This Docker deployment runs both Pi-Hole and Unbound in a single container.

The base image for the container is the [official Pi-Hole container](https://hub.docker.com/r/pihole/pihole), with an extra build step added to install the Unbound resolver directly into to it based on [instructions provided directly by the Pi-Hole team](https://docs.pi-hole.net/guides/unbound/).

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/nyirsh/pihole-unbound/docker-image-ci.yml?logo=GitHub&label=Auto%20Update&link=https%3A%2F%2Fgithub.com%2Fnyirsh%2Fpihole-unbound%2Factions%2Fworkflows%2Fdocker-image-ci.yml)

The [Github repository](https://github.com/nyirsh/pihole-unbound/) is set to automatically check for a new PiHole version every day by monitoring the [official Pi-Hole docker repository](https://github.com/pi-hole/docker-pi-hole/). If a new release is detected, a new image is automatically generated and pushed to [dockerhub repository](https://hub.docker.com/repository/docker/nyirsh/pihole-unbound/).

This configuration contacts the DNS root servers directly, please read the Pi-Hole docs on [Pi-hole as All-Around DNS Solution](https://docs.pi-hole.net/guides/unbound/) to understand what this means.

> [!CAUTION]
>
> <h3>Updating from tag version <= 2024.x.x to >= 2025.x.x</h3>
>
> **Pi-hole v6 has been entirely redesigned from the ground up and contains many breaking changes.**
>
> Environment variable names have changed, script locations may have changed.
>
> If you are using volumes to persist your configuration, be careful.<br>Replacing any `v5` image _(`2024.07.0` and earlier)_ with a `v6` image will result in updated configuration files. **These changes are irreversible**.
>
> Please refer to this guide:
>
> https://docs.pi-hole.net/docker/upgrading/v5-v6/

# Quick Start

## Compose file

Download the pre-made [`docker-compose.yml`](https://raw.githubusercontent.com/nyirsh/pihole-unbound/main/docker-compose.yml) that you can also find in this repository...

```bash
curl -SO https://raw.githubusercontent.com/nyirsh/pihole-unbound/main/docker-compose.yml
```

Please keep in mind that this is a very quick and dirty way to kickstart your instance, it is highly recommended that you customize the `docker-compose.yml` to properly match your environment requirements. If this sentence doesn't make much sense to you, I would highly recommend learning more about `docker`.

## Evironment variables

Create a `.env` file in the same folder where `docker-compose.yml` is and substitute the values to match what's required for your deployment:

```
HOSTNAME=pihole
DOMAINNAME=pihole.local
LOCAL_IPV4=192.168.1.10
PIHOLE_WEBPORT_HTTP=80
PIHOLE_WEBPORT_HTTPS=443

TZ=America/Los_Angeles
WEBPASSWORD=YourAdminPassword
WEBTHEME=default-dark

REV_SERVER=true
REV_SERVER_DOMAIN=local
REV_SERVER_TARGET=192.168.1.1
REV_SERVER_CIDR=192.168.0.0/16
```

### Custom variables

| Variable               | Default        | Value                 | Description                                                                                                                                        |
| ---------------------- | -------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `HOSTNAME`             | `pihole`       | Container host name   | Set to your preferred [docker container hostname](https://docs.docker.com/compose/compose-file/05-services/#hostname) for the Pi-Hole instance     |
| `DOMAINNAME`           | `pihole.local` | Container domain name | Set to your preferred [docker container domainname](https://docs.docker.com/compose/compose-file/05-services/#domainname) for the Pi-Hole instance |
| `LOCAL_IPV4`           |                | Ip address            | Ip address of the machine running Pihole, not `127.0.0.1`!                                                                                         |
| `PIHOLE_WEBPORT_HTTP`  | `80`           | Exposed HTTP Port     | Set this to the port you want to use to access Pi-Hole via HTTP. Make sure the port isn't already in use!                                          |
| `PIHOLE_WEBPORT_HTTPS` | `443`          | Exposed HTTPS Port    | Set this to the port you want to use to access Pi-Hole via HTTPS. Make sure the port isn't already in use!                                         |

### Pi-Hole variables

For a complete list of possible variables, please refer to the [Pi-Hole official documentation](https://docs.pi-hole.net/docker/configuration/):

## Run the stack!

```bash
docker-compose up -d
```

> [!TIP]
> If using Portainer, just paste the `docker-compose.yml` contents into the stack config and add your _environment variables_ directly in the UI.

## FAQ

**_- Q: I also want to use Cloudflare or change some other parameters of Pi-Hole!_**

Please keep in mind that the `docker-compose.yml` and `.env` files provided in this repository are just an example! Feel free to cumostomize the files so that they can match your expected experience, if you're unsure on how to do so I would highly recommend getting some knowledge on [Docker](https://docs.docker.com/) first.

**_- Q: I am running Pi-Hole alongside other containers on the same machine but, despite setting the DNS to match the host machine IP, I still can't resolve any address!_**

Yep, it's a docker limitation of some sort, you can find more details [here](https://discourse.pi-hole.net/t/solve-dns-resolution-in-other-containers-when-using-docker-pihole/31413). To keep it short, change these two ports in your `docker-compose.yml` file:

```yml
- "${LOCAL_IPV4}:53:53/tcp"
- "${LOCAL_IPV4}:53:53/udp"
```

**_- Q: Thank you for this! Do you accept donations?_**

A: No I do not, I really did nothing special and everything here is fully automated so I don't think I deserve any kind of donation or recognition. If you're really willing to donate some money please consider giving them to the [Pi-Hole](https://pi-hole.net/donate) itself.

**_- Q: I updated to a version 2025.x.x from a 2024.x.x and nothing works anymore_**

Yep, this is not my fault. The pihole team redesigned the entire application and changed names of a lot of variables. Please refer to [this guide](https://docs.pi-hole.net/docker/upgrading/v5-v6/).

**_- Q: Why doesn't it work on my system?_**

I don't know, but maybe you can find more details [here](https://hub.docker.com/r/pihole/pihole).

## Credits

Thanks to [Chris Crowe](https://github.com/chriscrowe) for figuring the original (pihole version <= 2024.x.x) installation method out and inspiring this project.

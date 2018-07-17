# op5-docker
> This is a basic example of how you might deploy OP5 Monitor via Docker. This is only a guide and several pre-configuration steps must be taken before this will work. You will need to build the docker image prior to use.

> This docker file is intended as an example to be used with an automation system like chef. To have a stand alone deployment of OP5 Monitor for a lab please use https://hub.docker.com/r/op5com/op5-monitor/

> **Please be aware OP5 does not support docker in production at this time.


# Docker image for OP5 Monitor
OP5 Monitor is a software product for server, Network monitoring and management based on the Open Source project Nagios.
This repository contains the OP5 Monitor software, in docker. It is also available on: [Docker Hub](https://hub.docker.com/r/op5com/op5-monitor)

![OP5 Monitor, in docker](https://user-images.githubusercontent.com/2470979/30489703-398bcd3e-9a38-11e7-88e3-8b2da7b67a4f.png)

> This image is not a OP5 official release and therefore does not adhere to your support agreement you may have with OP5.

## Features

 * Latest version of OP5 monitor to date (currently v7.4.2) on CentOS 6.9
 * Pre-bundled with a trial license
 * Supports **automatically** adding container to an existing infrastructure as a poller or peer.
 * Support for **triggering hooks** on prestart, poststart and poststop. **Slack** hook example is included.
 * Support for **importing OP5 backup files** to help quickly launch testing/development environments
 * Support for **installing OP5 license keys**. Defaults to trial license if none if specified

## Install

Pull the docker image from Docker Hub:

```
TODO
```



or, clone this repo to your docker server and build it:

```sh
$ git clone https://github.com/op5/monitor-docker.git
```

```sh
$ docker build --rm -f Dockerfile -t monitor-docker:latest .
```

## Usage

Run the docker container:

# Standalone OP5 Server
$ docker run -d -p 443:443 -p 2222:2222 monitor-docker:latest

# Standalone OP5 Server from Backup
$ docker run -d -p 443:443 -p 2222:2222 -v /tmp/backups/:/usr/libexec/entrypoint.d/backups/ -e IMPORT_BACKUP=<backup file>.backup monitor-docker:latest

# Standalone OP5 Server with license file
$ docker run -d -p 443:443 -p 2222:2222 -v /tmp/licenses/:/usr/libexec/entrypoint.d/licenses/ -e LICENSE_KEY=<license file>.lic monitor-docker:latest

# Create a Distributed OP5 Instance for lab work

# Create user network
$ docker network create --subnet 172.18.0.0/24 op5net

# Create your first master
docker run -d -p 443:443 -p 2222:2222 -p 15551 -e SELF_HOSTNAME=op5master1.op5.local --name op5master1.op5.local --net=op5net monitor-docker:latest

# Create your first master peer
docker run -d -p 443 -p 2222 -p 15551 -e SELF_HOSTNAME=op5master2.op5.local --name op5master2.op5.local --net=op5net -e IS_PEER="YES" -e PEER_HOSTNAMES="op5master1.op5.local" monitor-docker:latest

# Create a second master peer
docker run -d -p 443 -p 2222 -p 15551 -e SELF_HOSTNAME=op5master3.op5.local --name op5master3.op5.local --net=op5net -e IS_PEER="YES" -e PEER_HOSTNAMES="op5master1.op5.local,op5master2.op5.local" monitor-docker:latest

# Create your first poller ***ENSURE HOSTGROUPS ARE CREATED AND WORKING***
docker run -d -p 443 -p 2222 -p 15551 -e SELF_HOSTNAME=op5poller1.op5.local --name op5poller1.op5.local --net=op5net -e IS_POLLER="YES" -e HOSTGROUPS="pollergroup1" -e MASTER_ADDRESSES="op5master1.op5.local,op5master2.op5.local,op5master3.op5.local" monitor-docker:latest

# Create your first poller peer
docker run -d -p 443 -p 2222 -p 15551 -e SELF_HOSTNAME=op5poller2.op5.local --name op5poller2.op5.local --net=op5net -e IS_POLLER="YES" -e HOSTGROUPS="pollergroup1" IS_PEER="YES" -e PEER_HOSTNAMES="op5poller1.op5.local" -e MASTER_ADDRESSES="op5master1.op5.local,op5master2.op5.local,op5master3.op5.local" monitor-docker:latest

# Create your first poller ***ENSURE HOSTGROUPS ARE CREATED AND WORKING***
docker run -d -p 443 -p 2222 -p 15551 -e SELF_HOSTNAME=op5poller3.op5.local --name op5poller3.op5.local --net=op5net -e IS_POLLER="YES" -e HOSTGROUPS="pollergroup2" -e MASTER_ADDRESSES="op5master1.op5.local,op5master2.op5.local,op5master3.op5.local" monitor-docker:latest

# Create your first poller peer
docker run -d -p 443 -p 2222 -p 15551 -e SELF_HOSTNAME=op5poller4.op5.local --name op5poller4.op5.local --net=op5net -e IS_POLLER="YES" -e HOSTGROUPS="pollergroup2" IS_PEER="YES" -e PEER_HOSTNAMES="op5poller3.op5.local" -e MASTER_ADDRESSES="op5master1.op5.local,op5master2.op5.local,op5master3.op5.local" monitor-docker:latest

# Remove the dynamicly scaled hosts.
#
# Please be aware that this can take some time to remove everything required.
#
# A timeout on your docker stop command is strongly recommended to allow the host to remove itself from the other servers

$ docker stop -t 90 op5poller3.op5.local
$ docker stop -t 90 op5poller1.op5.local
$ docker stop -t 90 op5poller2.op5.local
$ docker stop -t 90 op5poller4.op5.local
$ docker stop -t 90 op5master1.op5.local
$ docker stop -t 90 op5master3.op5.local
$ docker stop -t 90 op5master2.op5.local

Now you can reach OP5 Monitor on:

https://`<docker server>`:443

## Adding hooks (optional)

You can add custom hooks by adding any script to entrypoint.d/hooks/ directory. Ensure that they are well defined in entrypoint.d/hooks.json and that enabled is is true, something like this will work:

```json
{
        "prestart": [
            {
                "path": "/usr/libexec/entrypoint.d/hooks/slack.py",
                "args": ["prestart"],
                "enabled": false
            },
            {
                "path": "/usr/libexec/entrypoint.d/hooks/example.sh",
                "args": ["--action", "contained_started"],
                "enabled": true
            }
        ],
        "poststart": [
            {
                "path": "/usr/libexec/entrypoint.d/hooks/slack.py",
                "args": ["poststart"],
                "enabled": false
            },
            {
                "path": "/usr/libexec/entrypoint.d/hooks/example.sh",
                "args": ["--action", "contained_booted"],
                "enabled": true
            }
        ],
        "poststop":[
            {
                "path": "/usr/libexec/entrypoint.d/hooks/slack.py",
                "args": ["poststop"],
                "enabled": false
            },
            {
                "path": "/usr/libexec/entrypoint.d/hooks/example.sh",
                "args": ["--action", "container_stopped"],
                "enabled": true
            }
        ]
}
```

And then build:

```sh
$ docker build --rm -t op5com/monitor-docker .
```

## Importing OP5 backup files (optional)

You can import existing OP5 backups. This can be helpful when you need to spin up an identical copy of your production OP5 servers, say for testing or development purposes.

In order to do so, you first need to create a **compatible** backup for docker on one of your OP5 master or peer server, using:

Then place the backup file generated by op5-backup (ends with .backup-extension) in a folder locally on your docker host (eg: /tmp/backups/{backup file}.backup), and run your docker container:

## Importing OP5 license keys (optional)

You can import your OP5 license key if needed. If not specified, it defaults to the trial license.

In order to do so, place your license key (eg. op5license.lic) in a folder locally on your docker host: (eg: /tmp/licenses/{license file}.lic), and then run your docker container:

## Contributors

Thanks goes to these wonderful people:

* Caesar Ahlenhed ([@MrFriday AB](https://www.mrfriday.com))
* Christian Nilsson ([@OP5](https://www.op5.com))
* Ken Dobbins ([@OP5](https://www.op5.com))
* Robert Claesson ([@OP5](https://www.op5.com))
* Misiu Pajor [github/misiupajor](https://github.com/misiupajor)

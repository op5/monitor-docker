FROM centos:6

# Install EPEL first or else tmux and multitail wont be installed
COPY /entrypoint.d /usr/libexec/entrypoint.d/

ARG OP5_MONITOR_SOFTWARE_URL=https://d2ubxhm80y3bwr.cloudfront.net/Downloads/op5_monitor_archive/op5-monitor-7.3.14-20170609.tar.gz

LABEL op5_version="OP5 Monitor Latest Version"
LABEL maintainer="OP5,Ken Dobbins"

ENV IS_POLLER=NO \
MASTER_ADDRESSES= \
IS_PEER=NO \
PEER_HOSTNAMES= \
HOSTGROUPS= \
SELF_HOSTNAME=monitormaster \
DEBUG=0 \
ROOT_PASSWORD=monitor \
IMPORT_BACKUP= \
LICENSE_KEY=

STOPSIGNAL SIGTERM

RUN \
    yum -y install epel-release && \
    yum -y install wget nc tmux multitail openssh-server python-requests && \
    wget $OP5_MONITOR_SOFTWARE_URL -O /tmp/op5-software.tar.gz && \
    mkdir -p /tmp/op5-monitor && \
    tar -zxf /tmp/op5-software.tar.gz -C /tmp/op5-monitor --strip-components=1 && \
    cd /tmp/op5-monitor && \
    ./install.sh --silent && \
    rm -f /tmp/op5-software.tar.gz && \
    rm -rf /tmp/op5-monitor && \
    yum clean all && \
    chmod +x /usr/libexec/entrypoint.d/start.sh && \
    # Disable ipv6 binding for postfix
    # sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf && \
    # Replace the system() source because inside Docker we can't access /proc/kmsg.
    # https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
    sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf && \
	sed -i -E '/\proc\/kmsg/ s/^#*/#/' /etc/syslog-ng/syslog-ng.conf


# OP5 Web UI, NRPE, Merlind, SSH, SNMPd 
EXPOSE 80 443 5666 15551 2222 161 162

CMD ["/usr/libexec/entrypoint.d/entrypoint.sh"]

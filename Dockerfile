FROM centos:6

# Install EPEL first or else tmux and multitail wont be installed
COPY /entrypoint.d /usr/libexec/entrypoint.d/

RUN yum -y install epel-release \
    && mv /usr/libexec/entrypoint.d/repo/* /etc/yum.repos.d/ \
    && mv /usr/libexec/entrypoint.d/repo-key/* /etc/pki/rpm-gpg/ \
    && chmod 664 /etc/yum.repos.d/op5* \
    && chmod 644 /etc/pki/rpm-gpg/*op5 \
    && yum -y install wget nc tmux multitail openssh-server python-requests \
    && yum groupinstall "op5 Monitor"
    && yum clean all \
    && sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config \
    && chmod +x /usr/libexec/entrypoint.d/start.sh

# OP5 Web UI, NRPE, Merlind, SSH, SNMPd 
EXPOSE 80 443 5666 15551 2222 161 162

CMD ["/usr/libexec/entrypoint.d/start.sh"]

FROM centos:6

# Install EPEL first or else tmux and multitail wont be installed
RUN yum -y install epel-release && yum -y install nc tmux multitail openssh-server \
&& curl https://s3-eu-west-1.amazonaws.com/op5-filebase/Downloads/op5_monitor_archive/op5-monitor-7.3.18-20171114.tar.gz  | tar -zx -C /tmp \
&& cd /tmp/op5-monitor-7.3.18 && ./install.sh --silent \
&& rm -rf /tmp/op5* \
&& yum -y install perl-IPC-Run \
&& yum clean all


# OP5 Web UI, NRPE, Merlind, SSH, SNMPd 
EXPOSE 80 443 5666 15551 2222 162

ADD ["start.sh","/start.sh"]
ADD ["include/ssh_config","/tmp/ssh_config"]
ADD ["include/Entrypoint.sh","/Entrypoint.sh"]
ADD ["include/tmux.conf","/etc/tmux.conf"]
ADD ["include/setup_interfaces","/setup_interfaces"]

RUN mkdir -p /root/.ssh && chown -R root:root /root/.ssh/ && chmod -R 700 /root/.ssh
RUN mkdir -p /opt/monitor/.ssh && chown -R monitor /opt/monitor/.ssh && chmod -R 700 /opt/monitor/.ssh
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
RUN sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/' /etc/ssh/ssh_config
RUN mkdir -p /etc/snmp && touch /etc/snmp/snmp.local.conf && echo "mibs +all" >> /etc/snmp/snmp.local.conf
RUN cd /usr/share/snmp/mibs && chmod g+w . && chown root:apache .

RUN chmod +x /setup_interfaces
RUN chmod +x /Entrypoint.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
#ENTRYPOINT ["/Entrypoint.sh"]

FROM centos:6

RUN yum -y install openssh-server \
&& curl http://repos.op5.com/tarballs/op5-monitor-7.3.11-20170428.tar.gz | tar -zx -C /tmp \
&& cd /tmp/op5-monitor-7.3.11 && ./install.sh --silent \
&& rm -rf /tmp/op5* \
&& yum clean all


# OP5 Web UI, NRPE, Merlind, SSH, SNMPd 
EXPOSE 80 443 5666 15551 2222 162


ADD ["ssh/","/tmp/ssh"] 
ADD ["Entrypoint.sh","/Entrypoint.sh"]

RUN cp -a /tmp/ssh/ /root/.ssh/ && chown -R root:root /root/.ssh/ && chmod -R 700 /root/.ssh && chmod 600 /root/.ssh/*
RUN cp -a /tmp/ssh/ /opt/monitor/.ssh/ && chown -R monitor /opt/monitor/.ssh && chmod -R 700 /opt/monitor/.ssh && chmod 600 /opt/monitor/.ssh/*
RUN chmod +x /Entrypoint.sh

ENTRYPOINT ["/Entrypoint.sh"]


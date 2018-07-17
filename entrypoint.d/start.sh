#!/bin/bash

mkdir -p /etc/snmp
touch /etc/snmp/snmp.local.conf
echo "mibs +all" >> /etc/snmp/snmp.local.conf
mv -f mibs/* /usr/share/snmp/mibs
chmod g+w /usr/share/snmp/mibs
chown root:apache /usr/share/snmp/mibs

mkdir -p /opt/monitor/.ssh
mkdir -p /root/.ssh

chmod -R 700 /opt/monitor/.ssh
chmod -R 700 /root/.ssh

mv -f /usr/libexec/entrypoint.d/sshd/sshd_config /etc/ssh/sshd_config
chown root /etc/ssh/sshd_config

cp -f /usr/libexec/entrypoint.d/ssh/* /root/.ssh/
mv -f /usr/libexec/entrypoint.d/ssh/* /opt/monitor/.ssh/

chmod 600 /etc/ssh/sshd_config

chmod -R 600 /root/.ssh/id_rsa
chmod -R 640 /root/.ssh/authorized_keys
chmod -R 644 /root/.ssh/id_rsa.pub
chmod -R 600 /root/.ssh/config

chmod -R 600 /opt/monitor/.ssh/id_rsa
chmod -R 640 /opt/monitor/.ssh/authorized_keys
chmod -R 644 /opt/monitor/.ssh/id_rsa.pub
chmod -R 600 /opt/monitor/.ssh/config

chown -R root /root/.ssh
chown -R monitor /opt/monitor/.ssh

chmod -R +x /usr/libexec/entrypoint.d/hooks/ \
chmod +x /usr/libexec/entrypoint.d/entrypoint.sh \
chmod +x /usr/libexec/entrypoint.d/hooks.py \
mv -f /usr/libexec/entrypoint.d/tmux.conf /etc/tmux.conf

/usr/libexec/entrypoint.d/entrypoint.sh
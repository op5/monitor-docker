sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf
sed -i -E '/\proc\/kmsg/ s/^#*/#/' /etc/syslog-ng/syslog-ng.conf

mkdir -p /etc/snmp
touch /etc/snmp/snmp.local.conf
echo "mibs +all" >> /etc/snmp/snmp.local.conf
mv mibs/* /usr/share/snmp/mibs
chmod g+w /usr/share/snmp/mibs
chown root:apache /usr/share/snmp/mibs


mkdir -p /opt/monitor/.ssh
chmod -R 700 /opt/monitor/.ssh
mv /usr/libexec/entrypoint.d/ssh/* /opt/monitor/.ssh/

chmod -R 600 /opt/monitor/.ssh/id_rsa
chmod -R 640 /opt/monitor/.ssh/authorized_keys
chmod -R 644 /opt/monitor/.ssh/id_rsa.pub
chmod -R 600 /opt/monitor/.ssh/

tmp_ip=$(echo $TARGET_HOST | awk -F"." '{print $1"."$2"."$3".*"}')
sed -i "s/SSH_HOST_IP/$tmp_ip/" /tmp/ssh_config
cp /tmp/ssh_config /opt/monitor/.ssh/config
chown -R monitor /opt/monitor/.ssh

grep -q "notifies = no" /opt/monitor/op5/merlin/merlin.conf || sed -i '/module {/a\        notifies = no' /opt/monitor/op5/merlin/merlin.conf

chmod +x /usr/libexec/entrypoint.d/hooks/* \
chmod +x /usr/libexec/entrypoint.d/entrypoint.sh \
chmod +x /usr/libexec/entrypoint.d/hooks.py \
mv /usr/libexec/entrypoint.d/tmux.conf /etc/tmux.conf

/usr/libexec/entrypoint.d/entrypoint.sh
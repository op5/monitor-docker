#!/bin/bash
set -e

if [ -z "${SSH_KEY}" ] || [ -z "${SSH_PUB_KEY}" ]; then
    echo "SSH Key information is required. Run gen_secrets.sh and follow instructions"
    exit 1
fi

if [ -z "${TARGET_HOST}" ]; then
    echo "Can not determain TARGET_HOST. This should be the IP of the HOST the container is being deployed to."
    exit 1
fi 

if [ -z "${PEER_ADDRESSES}" ] || [ -z "${PEER_HOSTNAMES}" ]; then
    echo "Can not determain PEER IP Addresses or Hostnames. Please configure in op5.targetip.env file."
    exit 1
fi

peers=(${PEER_ADDRESSES//,/ })
peer_hn=(${PEER_HOSTNAMES//,/ })

for i in "${!peer_hn[@]}";
do
        tmp_ip=$(awk -v hn="${peer_hn[i]}" '$0 ~ hn{print $1}' /etc/hosts)
        if [[ $tmp_ip == ${peers[i]} ]]; then
                echo "match found"
        else
                echo "${peers[i]} ${peer_hn[i]}" >> /etc/hosts
        fi
done

echo -e $SSH_KEY > /root/.ssh/id_rsa && chmod 600 /root/.ssh/*
echo -e $SSH_PUB_KEY > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/*
echo -e $SSH_PUB_KEY > /root/.ssh/id_rsa.pub && chmod 600 /root/.ssh/*
echo -e $SSH_KEY > /opt/monitor/.ssh/id_rsa && chmod 600 /opt/monitor/.ssh/*
echo -e $SSH_PUB_KEY > /opt/monitor/.ssh/authorized_keys && chmod 600 /opt/monitor/.ssh/*
echo -e $SSH_PUB_KEY > /opt/monitor/.ssh/id_rsa.pub && chmod 600 /opt/monitor/.ssh/*
tmp_ip=$(echo $TARGET_HOST | awk -F"." '{print $1"."$2"."$3".*"}')
sed -i "s/SSH_HOST_IP/$tmp_ip/" /tmp/ssh_config
cp /tmp/ssh_config /root/.ssh/config
cp /tmp/ssh_config /opt/monitor/.ssh/config
chown -R monitor /opt/monitor/.ssh

grep -q "notifies = no" /opt/monitor/op5/merlin/merlin.conf || sed -i '/module {/a\        notifies = no' /opt/monitor/op5/merlin/merlin.conf

/Entrypoint.sh


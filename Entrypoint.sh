#!/bin/bash
#############################################
#
# MASTER_ADDRESSES must be a comma delimited environment variable
# HOSTGROUPS must be a comma delimted environment variable
# SELF_HOSTNAME must be set
# PEER_ADDRESSES must be set
#
# The big assumption around here is that proper DNS is set up and the scheduler 
# will be able to handle setting the environment files upon deployment.
# This should be fine because even if a poller is running with an outdated environment file
# merlind will still know the new topology.
# 
#
#############################################

masters=(${MASTER_ADDRESSES//,/ })
peers=(${PEER_ADDRESSES//,/})


service_online(){
	service sshd start
	service mysqld start
	service merlind start
	service naemon start
	service httpd start
	service nrpe start
	service processor start
	service rrdcached start
	service synergy start
	service smsd start
	service collector start
}


advertise_masters(){
	if [ $1 == "add" ]; then
		action=add
	else
		action=remove
	fi

	echo -e '\033[33m' Performing ${action} on Masters '\033[39;49m'

	for i in "${!masters[@]}"
	do
		mon sshkey fetch ${masters[i]}  
		asmonitor mon sshkey fetch ${masters[i]}
		mon node ${action} ${masters[i]} type=master
		mon node ctrl ${masters[i]} mon node ${action} ${SELF_HOSTNAME} type=poller hostgroup=${HOSTGROUPS} takeover=no
		mon node ctrl ${masters[i]} mon restart
	done
}

advertise_peers(){
  if [ -z ${PEER_ADDRESSES} ]; then
    return
  fi
	if [ $1 == "add" ]; then
		action=add
	else
		action=remove
	fi
	
	echo -e '\033[33m' Performing ${action} On Peers '\033[39;49m'	
	
        for i in "${!peers[@]}"
        do
                mon sshkey fetch ${peers[i]}
                asmonitor mon sshkey fetch ${peers[i]}
                mon node ${action} ${peers[i]} type=peer
                mon node ctrl ${peers[i]} mon node ${action} ${SELF_HOSTNAME} type=peer
                mon node ctrl ${peers[i]} mon restart
        done

}

get_config(){
	# Only getting config from one master because mon oconf always exits 0
	# The fetch will initiate a restart of the the local merlind.
	# This should be the only time we need to to restart locally since new pollers will restart us. 	
	echo -e '\033[33m' Trying To Get Configuration From ${masters[0]} '\033[39;49m'
	mon node ctrl ${masters[0]} asmonitor mon oconf push ${SELF_HOSTNAME}
}


shutdown(){
	# If container is gracefully shutdown with SIGTERM (e.g. docker stop), remove
	# pre-emptively remove itself
	echo -e '\033[33m' Shutdown Initiated, Removing From Peer Lists '\033[39;49m'
	advertise_peers remove
	advertise_masters remove
}

keep_swimming(){	
	echo -e '\033[33m' Done '\033[39;49m'
	tail -f /var/log/op5/merlin/daemon.log &	
	wait $!
}


main(){
	service_online
	advertise_masters remove
	advertise_masters add
	advertise_peers remove
	advertise_peers add
	get_config
	keep_swimming
}

trap "shutdown" SIGTERM
main

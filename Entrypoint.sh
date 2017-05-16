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
	for i in "${!masters[@]}"
	do
		mon sshkey fetch ${masters[i]}  
		asmonitor mon sshkey fetch ${masters[i]}
		mon node add ${masters[i]} type=master
		mon node ctrl ${masters[i]} mon node add ${SELF_HOSTNAME} type=poller hostgroup=${HOSTGROUPS} takeover=no
		mon node ctrl ${masters[i]} mon restart
	done
}

advertise_peers(){
        for i in "${!peers[@]}"
        do
                mon sshkey fetch ${peers[i]}
                asmonitor mon sshkey fetch ${peers[i]}
                mon node add ${peers[i]} type=peer
                mon node ctrl ${peers[i]} mon node add ${SELF_HOSTNAME} type=peer
                mon node ctrl ${peers[i]} mon restart
        done

}

get_config(){
	# Only getting config from one master because mon oconf always exits 0
	# The fetch will initiate a restart of the the local merlind.
	# This should be the only time we need to to restart locally since new pollers will restart us. 
	mon oconf fetch ${masters[1]} 
}

keep_swimming(){
	tail -f /var/log/op5/merlin/daemon.log	
}


main(){
	service_online
	advertise_masters
	advertise_peers
	get_config
	keep_swimming
}

main

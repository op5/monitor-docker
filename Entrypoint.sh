#!/bin/bash
#############################################
#
# MASTER_ADDRESSES must be a comma delimited environment variable
# HOSTGROUPS must be a comma delimted environment variable
# SELF_HOSTNAME must be set
#
#############################################

masters=(${MASTER_ADDRESSES//,/ })

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


advertise(){
	for i in "${!masters[@]}"
	do
		mon sshkey fetch ${masters[i]}  
		asmonitor mon sshkey fetch ${masters[i]}
		mon node add ${masters[i]} type=master
		mon node ctrl ${masters[i]} mon node add ${SELF_HOSTNAME} type=poller hostgroup=${HOSTGROUPS} takeover=no
		mon node ctrl ${masters[i]} mon restart
	done
}


get_config(){
	# Only getting config from one master because mon oconf always exits 0
	mon oconf fetch ${masters[1]} 
}

keep_swimming(){
	tail -f /var/log/op5/merlin/daemon.log	
}


main(){
	service_online
	advertise
	get_config
	keep_swimming
}

main

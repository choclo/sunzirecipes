# Install Load Balancer 

if rpm -qa 'piranha'; then
	echo 'Load Balancer packages are already installed'
else
	echo 'Resilient Storage was not installed, doing so now:'
	yum-config-manager --enable rhel-lb-for-rhel-6-server-rpms
	yum repolist
	yum -y groupinstall 'Load Balancer'
	chkconfig piranha on
	service piranha start
fi
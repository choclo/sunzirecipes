# Install Resilient Storage 

if rpm -qa 'gfs2-utils' | grep -w 'gfs'; then
	echo 'Cluster packages are already installed'
else
	echo 'Resilient Storage was not installed, doing so now:'
	yum-config-manager --enable rhel-rs-for-rhel-6-server-rpms
	yum repolist
	yum -y groupinstall 'Resilient Storage'
fi

# Starts and configures gfs2 service to start at boot
chkconfig gfs2 on
service gfs2 start
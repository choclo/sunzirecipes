# Install High Availability 

if rpm -qa 'cman' | grep -w 'cman'; then
	echo 'Cluster packages are already installed'
else
	yum-config-manager --enable rhel-ha-for-rhel-6-server-rpms
	yum -y groupinstall 'High Availability'
	echo <%= @attributes.riccipass %> | passwd --stdin ricci
	service ricci start
	chkconfig ricci on
	chkconfig cman on
	chkconfig rgmanager on
	chkconfig modclusterd on
fi

# We need to check if firewall is on and if so, load appropriate rules
IPT="$(/sbin/service iptables status)"
IPTEXPR="iptables: Firewall is not running."
if [ "$IPT" = "$IPTEXPR" ];then
  echo 'Firewall no está corriendo!'
else
# These are the iptables rules for cman
iptables -I INPUT -m state --state NEW -m multiport -p udp -s 192.168.1.0/24 -d 192.168.1.0/24 --dports 5404,5405 -j ACCEPT
iptables -I INPUT -m addrtype --dst-type MULTICAST -m state --state NEW -m multiport -p udp -s 192.168.1.0/24 --dports 5404,5405 -j ACCEPT

# These are the iptables rules for dlm
iptables -I INPUT -m state --state NEW -p tcp --dport 21064 -j ACCEPT

# These are the iptables rules for ricci
iptables -I INPUT -m state --state NEW -p tcp --dport 11111 -j ACCEPT

# These are the iptables rules for modclusterd
iptables -I INPUT -m state --state NEW -p tcp --dport 16851 -j ACCEPT

# These are the iptables rules for luci
iptables -I INPUT -m state --state NEW -p tcp --dport 8084 -j ACCEPT

# These are the iptables rules for igmp
iptables -I INPUT -p igmp -j ACCEPT

# Let's restart the firewall
service iptables save ; service iptables restart
fi

# Remove acpi support for correct fencing
chkconfig --del acpid

# We also need to disable NetworkManager if it's activated
chkconfig NetworkManager off
service NetworkManager stop

# Let's set the correct SELinux booleans in case it's running
if getenforce = 'Enforcing' /dev/null 2>&1; then
	setsebool fenced_can_network_connect 1
else
	echo 'SELinux is not running on this system!'
fi

# Enable basic cluster skeleton
mv files/cluster.conf /etc/cluster/cluster.conf
mv files/hosts /etc/hosts
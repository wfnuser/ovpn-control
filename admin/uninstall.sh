source ./openvpn-admin.sh

function removeOpenVPN() {
	echo ""
	# Get OpenVPN port from the configuration
	PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)
	PROTOCOL=$(grep '^proto ' /etc/openvpn/server.conf | cut -d " " -f 2)

	# Stop OpenVPN
	killOpenVPN

	rm /etc/iptables/add-openvpn-rules.sh
	rm /etc/iptables/rm-openvpn-rules.sh

	# TODO: we need to decide where to save ovpn... we need to mount pvc.
	# Cleanup
	find /home/ -maxdepth 2 -name "*.ovpn" -delete
	find /root/ -maxdepth 1 -name "*.ovpn" -delete

	rm -rf /etc/openvpn/
	rm -rf /usr/share/doc/openvpn*
	# rm -f /etc/sysctl.d/99-openvpn.conf
	rm -rf /var/log/openvpn

	echo ""
	echo "OpenVPN removed!"
}

removeOpenVPN
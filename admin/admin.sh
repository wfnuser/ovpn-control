source ./openvpn-admin.sh

function manageMenu() {
	echo "Welcome to OpenVPN-install!"
	echo "The git repository is available at: https://github.com/angristan/openvpn-install"
	echo ""
	echo "It looks like OpenVPN is already installed."
	echo ""
	echo "What do you want to do?"
	echo "   1) Add a new user"
	echo "   2) Revoke existing user"
	echo "   3) Remove OpenVPN"
	echo "   4) Reconfig Certificate"
	echo "   5) Start OpenVPN"
	echo "   6) Exit"
	until [[ $MENU_OPTION =~ ^[1-6]$ ]]; do
		read -rp "Select an option [1-6]: " MENU_OPTION
	done

	case $MENU_OPTION in
	1)
		newClient
		;;
	2)
		revokeClient
		;;
	3)
		removeOpenVPN
		;;
	4)
		reconfigCertificate
		;;
	5)
		startOpenVPN
		;;
	6)
		exit 0
		;;
	esac
}

# Check for root, TUN, OS...
initialCheck

# Check if OpenVPN is already installed
if [[ -e /etc/openvpn/server.conf && ($AUTO_INSTALL != "y" || $MENU_OPTION == 4) ]]; then
	manageMenu
else
	installOpenVPN
fi
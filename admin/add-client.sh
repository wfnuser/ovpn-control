source ./openvpn-admin.sh

function newClient() {
	if [ -z "$CLIENT" ]; then
		echo "ERROR: The \$CLIENT environment variable is not set. Please provide a client name."
		exit 1
	fi

	# Check if the client name is valid
	if ! [[ $CLIENT =~ ^[a-zA-Z0-9_-]+$ ]]; then
		echo "ERROR: The client name must consist of alphanumeric characters, underscores, or dashes."
		exit 1
	fi

    cd /etc/openvpn/easy-rsa/ || return
    if [[ -f "pki/private/$CLIENT.key" ]]; then
        echo ""
        echo "The specified client CN was already found in easy-rsa, please choose another name."
        exit 1
    fi
	./easyrsa --batch build-client-full "$CLIENT" nopass
	echo "Client $CLIENT added."

	# Generates the custom client.ovpn
	cp /etc/openvpn/client-template.txt "$persistDir/$CLIENT.ovpn"
	{
		echo "<ca>"
		cat "/etc/openvpn/easy-rsa/pki/ca.crt"
		echo "</ca>"

		echo "<cert>"
		awk '/BEGIN/,/END CERTIFICATE/' "/etc/openvpn/easy-rsa/pki/issued/$CLIENT.crt"
		echo "</cert>"

		echo "<key>"
		cat "/etc/openvpn/easy-rsa/pki/private/$CLIENT.key"
		echo "</key>"

		echo "<tls-crypt>"
		cat /etc/openvpn/tls-crypt.key
		echo "</tls-crypt>"
	} >>"$persistDir/$CLIENT.ovpn"

	echo ""
	echo "The configuration file has been written to $persistDir/$CLIENT.ovpn."
	echo "Download the .ovpn file and import it in your OpenVPN client."
}

newClient
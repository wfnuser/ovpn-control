source ./openvpn-admin.sh

function resetVPN() {
	echo ""
	# Get OpenVPN port from the configuration
	PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)
	PROTOCOL=$(grep '^proto ' /etc/openvpn/server.conf | cut -d " " -f 2)

	# Stop OpenVPN
	killOpenVPN

	# TODO: we need to decide where to save ovpn... we need to mount pvc.
	# Cleanup
	find /home/ -maxdepth 2 -name "*.ovpn" -delete
	find /root/ -maxdepth 2 -name "*.ovpn" -delete


	if [[ ! -d /etc/openvpn/easy-rsa/ ]]; then
		echo "not even initialized"
		exit 1
	fi

	cd /etc/openvpn/easy-rsa/ || return
	# Generate a random, alphanumeric identifier of 16 characters for CN
	SERVER_CN="cn_$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
	echo "$SERVER_CN" >SERVER_CN_GENERATED
	# Grab the generated SERVER_NAME
	SERVER_NAME=$(cat SERVER_NAME_GENERATED)

	rm -rf /etc/openvpn/easy-rsa/pki

	# Create the PKI, set up the CA, the DH params and the server certificate
	./easyrsa init-pki
	./easyrsa --batch --req-cn="$SERVER_CN" build-ca nopass

	./easyrsa --batch build-server-full "$SERVER_NAME" nopass
	EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl

	openvpn --genkey --secret /etc/openvpn/tls-crypt.key
	
	# Move all the generated files
	cp pki/ca.crt pki/private/ca.key "pki/issued/$SERVER_NAME.crt" "pki/private/$SERVER_NAME.key" /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn

	# Make cert revocation list readable for non-root
	chmod 644 /etc/openvpn/crl.pem

	startOpenVPN
}

resetVPN
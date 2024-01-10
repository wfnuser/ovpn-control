source ./openvpn-admin.sh

function revokeClient() {
    if [[ -z $CLIENT ]]; then
        echo ""
        echo "No client specified to revoke!"
        exit 1
    fi

    NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
    if [[ $NUMBEROFCLIENTS == '0' ]]; then
        echo ""
        echo "You have no existing clients!"
        exit 1
    fi

    cd /etc/openvpn/easy-rsa/ || return
    if [[ ! -f "pki/private/$CLIENT.key" ]]; then
        echo ""
        echo "The specified client '$CLIENT' does not exist!"
        exit 1
    fi

	./easyrsa --batch revoke "$CLIENT"
	EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
	rm -f /etc/openvpn/crl.pem
	cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
	chmod 644 /etc/openvpn/crl.pem
	find /home/ -maxdepth 2 -name "$CLIENT.ovpn" -delete
	rm -f "$persistDir/$CLIENT.ovpn"
	sed -i "/^$CLIENT,.*/d" /etc/openvpn/ipp.txt
	cp /etc/openvpn/easy-rsa/pki/index.txt{,.bk}

	echo ""
	echo "Certificate for client $CLIENT revoked."
}

revokeClient
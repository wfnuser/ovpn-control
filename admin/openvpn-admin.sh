#!/bin/bash
# shellcheck disable=SC1091,SC2164,SC2034,SC1072,SC1073,SC1009

# Secure OpenVPN server installer for Debian, Ubuntu, CentOS, Amazon Linux 2, Fedora, Oracle Linux 8, Arch Linux, Rocky Linux and AlmaLinux.
# https://github.com/angristan/openvpn-install

persistDir="/root/tmp"

function isRoot() {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

function tunAvailable() {
	if [ ! -e /dev/net/tun ]; then
		return 1
	fi
}

function initialCheck() {
	if ! isRoot; then
		echo "Sorry, you need to run this as root"
		exit 1
	fi
	if ! tunAvailable; then
		echo "TUN is not available"
		exit 1
	fi
}

function startOpenVPN() {
	/usr/sbin/openvpn --status /run/openvpn/server.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/server.conf
}

function killOpenVPN() {
	ps -efj | grep /usr/sbin/openvpn | awk '{print $2}' | xargs kill
}

function setConfiguration() {
	echo "Setting OpenVPN Environment!"
	# Set default choices so that no questions will be asked.
	IPV6_SUPPORT=${IPV6_SUPPORT:-n}
	PROTOCOL_CHOICE=${PROTOCOL_CHOICE:-1}
	DNS=${DNS:11} # TODO: DNS choice
	# TODO: COMPRESSION_ENABLED="n"
	CLIENT=${CLIENT:-client}
	PASS=${PASS:-1}

	# TODO: find a way to get public ip 🤔
	# Detect public IPv4 address and pre-fill for the user
	IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
	if [[ -z $IP ]]; then
		# Detect public IPv6 address
		IP=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
	fi

	PORT="1194"
	PROTOCOL="udp" # tcp is another option

	# TODO: encryption config
	CIPHER="AES-128-GCM"
	# CERT_TYPE="1" # ECDSA
	CERT_CURVE="prime256v1"
	CC_CIPHER="TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256"
	# DH_TYPE="1" # ECDH
	DH_CURVE="prime256v1"
	HMAC_ALG="SHA256"
	# TLS_SIG="1" # tls-crypt

	echo ""
	echo "Okay, Configuration is finished."
	echo "You will be able to generate a client at the end of the installation."
}

initialCheck
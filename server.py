from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

# 自动重启 health check
@app.route('/reconfig', methods=['POST'])
def reconfig():
    try:
        subprocess.check_output('AUTO_INSTALL=y MENU_OPTION=4 ./openvpn-install.sh', shell=True)
        subprocess.Popen('MENU_OPTION=5 ./openvpn-install.sh', shell=True)
        return jsonify({'message': 'Reconfig command executed successfully'})
    except subprocess.CalledProcessError as e:
        return jsonify({'error': 'Failed to execute reconfig command'}), 500

@app.route('/client/<client_name>', methods=['POST', 'DELETE'])
def manage_client(client_name):
    if request.method == 'POST':
        try:
            subprocess.check_output(f'MENU_OPTION=1 CLIENT={client_name} ./openvpn-install.sh', shell=True)
            return jsonify({'message': f'Client {client_name} added successfully'})
        except subprocess.CalledProcessError as e:
            return jsonify({'error': f'Failed to add client {client_name}'}), 500
    elif request.method == 'DELETE':
        try:
            subprocess.check_output(f'MENU_OPTION=2 CLIENT={client_name} ./openvpn-install.sh', shell=True)
            return jsonify({'message': f'Client {client_name} deleted successfully'})
        except subprocess.CalledProcessError as e:
            return jsonify({'error': f'Failed to delete client {client_name}'}), 500
    else:
        return jsonify({'error': 'Invalid request method'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
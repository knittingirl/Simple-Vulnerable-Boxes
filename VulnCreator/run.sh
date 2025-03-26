read -p "Are you trying to create a Windows or Linux virtual machine? " machine_type
echo $machine_type
#gusztavvargadr/windows-10"
read -p "Please input the base machine from Vagrant that you wish to use. Just select a newline if you do not have a preference, and Windows 10/Ubuntu 22 will be automatically selected." box
read -p "Also input the box version, please just select a newline if you want it to be selected for you." box_version

if [ -z $box ]; then
	if [ $machine_type == "Linux" ]; then
		box="generic/ubuntu2204"
		box_version="4.3.12"
	fi
	if [ $machine_type == "Windows" ]; then
		box="gusztavvargadr/windows-10"
		box_version="2202.0.2409"
	fi
fi

read -p "Please input a basic, descriptive name for your virtual machine." name
read -p "Also provide an IP address for the VM. It will default to 192.168.56.100." ip

if [ -z $ip ]; then
	ip="192.168.56.100"
fi
boxes="boxes=[{ :name => \"$name\",  :ip => \"$ip\", :box => \"$box\", :box_version => \"$box_version\", :os => \"$machine_type\"}]"

#Inserts the relevant line into the Vagrantfile

sed -i "6i $boxes" Vagrantfile

#Populate inventory files as appropriate:

if [ $machine_type == "Linux" ]; then
	sed -i "1i ; [$name]" inventory_linux.txt
	sed -i "2i  $name ansible_host=$ip" inventory_linux.txt 
fi
if [ $machine_type == "Windows" ]; then
	sed -i "1i ; [$name]" inventory_windows.txt
	sed -i "2i $name ansible_host=$ip" inventory_windows.txt 
fi

sed -i "2i \ \ hosts: $name" main.yaml
if [ $machine_type == "Linux" ]; then
	echo  "      script: setup.sh" >> main.yaml
fi
if [ $machine_type == "Windows" ]; then
	echo "      script: setup.ps1" >> main.yaml
fi

vagrant up
#Occasionally, when setting up multiple labs, the existent recognized SSH fingerprint will change causing Ansible to fail. This line resets the known fingerprint just in case.
ssh-keygen -R $ip

if [ $machine_type == "Linux" ]; then
	ansible-playbook -i inventory_linux.txt main.yaml
fi
if [ $machine_type == "Windows" ]; then
	ansible-playbook -i inventory_windows.txt main.yaml
fi


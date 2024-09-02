#This may take a while on the initial setup
vagrant up
#Occasionally, when setting up multiple labs, the existent recognized SSH fingerprint will change causing Ansible to fail. This line resets the known fingerprint just in case.
ssh-keygen -R 192.168.56.23

ansible-playbook -i inventory.txt setup.yaml
#Note: the timeout was added due to the ansible win_shell module failing to exit after executing its command. You may wish to dial the associated value up or down depending on your system.
ansible-playbook -T 60 -i inventory.txt main.yaml

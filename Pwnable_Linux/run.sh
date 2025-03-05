#This may take a while on the initial setup
vagrant up
#Occasionally, when setting up multiple labs, the existent recognized SSH fingerprint will change causing Ansible to fail. This line resets the known fingerprint just in case.
ssh-keygen -R 192.168.56.33

ansible-playbook -i inventory.txt main.yml

ansible-playbook -i inventory_greetings.txt start_service.yml

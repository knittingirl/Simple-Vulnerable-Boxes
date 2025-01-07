# Simple-Vulnerable-Boxes

This repository provides two sample boxes built with vmware, vagrant, and ansible. If a user has the appropriate tools installed, either box can be initiated easily by simply cloning the repository and running the "run.sh" script in a Linux environment.

![image](https://github.com/user-attachments/assets/0c03f212-4281-4c9d-9624-5970465efb3e)


The Vagrantfile contains basic configuration details for the machines. This includes a fairly significant amount of boilerplate code that could be tweaked to slightly alter the simulated hardware specifications, but the most important information is contained in the structure defining basic box information near the top; altering information here would allow the user to change the box installed using the ":box" and "box_version" variables, as well as altering the IP address and box names.

The inventory.txt files are there to interact with ansible. This file defines the IP address of the target, which should be checked for a match with the Vagrantfile. It also hard-codes in user-password information and a remote connection protocol to allow ansible to connect and make modifications.

The .yaml files set commands for ansible to run. The Windows machine is set up primarily using individual commands within main.yaml and setup.yaml, whereas the Linux machine performs most of its setup via a bash script run by ansible. A user can customize the commands run here in order to generate machines displaying a wide variety of vulnerabilities.

Other files such as custom code and flag files can also be included for upload onto the target machine.

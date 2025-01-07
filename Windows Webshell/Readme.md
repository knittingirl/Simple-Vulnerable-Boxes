This machine is also relatively simple to exploit once the user has started the run.sh script.

An nmap scan of the machine shows that an http website is present, which is worth closer examination:

```knittingirl@knittingirl-OptiPlex-7060:~/Desktop/Simple-Vulnerable-Boxes/Windows Webshell$ nmap 192.168.56.11
Starting Nmap 7.80 ( https://nmap.org ) at 2025-01-06 19:30 EST
Nmap scan report for 192.168.56.11
Host is up (0.00022s latency).
Not shown: 993 closed ports
PORT     STATE SERVICE
80/tcp   open  http
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
443/tcp  open  https
445/tcp  open  microsoft-ds
3306/tcp open  mysql
3389/tcp open  ms-wbt-server

Nmap done: 1 IP address (1 host up) scanned in 2.75 seconds
```

The website includes one box that accepts input from the user. A relatively small amout of experimentation with common web vulnerabilities should eventually lead a user to conclude that the underlying code includes a code injection vulnerability, which allows a user to inject arbitrary commands after the ping by separating them with an "&" symbol. This allows the user to read the flag file.

![image](https://github.com/user-attachments/assets/5b0cb02b-2092-41b1-ad94-5e5d996f05f9)

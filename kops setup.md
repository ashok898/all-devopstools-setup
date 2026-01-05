[azureuser@rhel-vm ~]$ sudo su -
Last login: Sun Jan  4 16:39:07 UTC 2026 on pts/0
Last failed login: Mon Jan  5 06:26:28 UTC 2026 from 45.78.220.142 on ssh:notty
There were 169 failed login attempts since the last successful login.
[root@rhel-vm ~]# ll
total 202992
drwxr-xr-x. 4 root root        60 Nov 21 19:38 digital_marketing
drwxr-xr-x. 2 root root        65 Dec 26 19:33 docker_stack
drwxr-xr-x. 8 root root       182 Dec 23 12:14 dockerswarmimages
drwxr-xr-x. 9 root root       121 Oct 18  2023 jdk-21
-rwxr-xr-x. 1 root root      1507 Jan  3 14:43 nexus.sh
-rw-r--r--. 1 root root 207852818 Oct 24  2023 OpenJDK21U-jdk_x64_linux_hotspot_21.0.1_12.tar.gz
drwxr-xr-x. 2 root root         6 Dec 23 10:01 railroot_proj
drwxr-xr-x. 2 root root         6 Dec 19 21:17 railrootweb
-rw-r--r--. 1 root root      1006 Jan  3 17:59 sonarqube.sh
[root@rhel-vm ~]# vi .bashrc
[root@rhel-vm ~]# cat .bashrc
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
export PATH=$PATH:/use/local/bin/
[root@rhel-vm ~]#

[root@rhel-vm ~]# sudo mount -o remount, rw/
mount: rw/: mount point does not exist.
[root@rhel-vm ~]# sudo mount -o remount rw /
[root@rhel-vm ~]# sudo mount -o remount, rw /
[root@rhel-vm ~]# vi .bashrc
[root@rhel-vm ~]# curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100  263M  100  263M    0     0   184M      0  0:00:01  0:00:01 --:--:--  217M
[root@rhel-vm ~]# chmod +x kops
[root@rhel-vm ~]# sudo mv kops /usr/local/bin/kops
[root@rhel-vm ~]# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0   1769      0 --:--:-- --:--:-- --:--:--  1769
100 55.8M  100 55.8M    0     0   141M      0 --:--:-- --:--:-- --:--:--  141M
[root@rhel-vm ~]# ll
total 260220
drwxr-xr-x. 4 root root        60 Nov 21 19:38 digital_marketing
drwxr-xr-x. 2 root root        65 Dec 26 19:33 docker_stack
drwxr-xr-x. 8 root root       182 Dec 23 12:14 dockerswarmimages
drwxr-xr-x. 9 root root       121 Oct 18  2023 jdk-21
-rw-r--r--. 1 root root  58597560 Jan  5 06:42 kubectl
-rwxr-xr-x. 1 root root      1507 Jan  3 14:43 nexus.sh
-rw-r--r--. 1 root root 207852818 Oct 24  2023 OpenJDK21U-jdk_x64_linux_hotspot_21.0.1_12.tar.gz
drwxr-xr-x. 2 root root         6 Dec 23 10:01 railroot_proj
drwxr-xr-x. 2 root root         6 Dec 19 21:17 railrootweb
-rw-r--r--. 1 root root      1006 Jan  3 17:59 sonarqube.sh
[root@rhel-vm ~]# chmod +x kubectl
[root@rhel-vm ~]# mv kubectl /usr/local/bin/
[root@rhel-vm ~]# ll
total 202992
drwxr-xr-x. 4 root root        60 Nov 21 19:38 digital_marketing
drwxr-xr-x. 2 root root        65 Dec 26 19:33 docker_stack
drwxr-xr-x. 8 root root       182 Dec 23 12:14 dockerswarmimages
drwxr-xr-x. 9 root root       121 Oct 18  2023 jdk-21
-rwxr-xr-x. 1 root root      1507 Jan  3 14:43 nexus.sh
-rw-r--r--. 1 root root 207852818 Oct 24  2023 OpenJDK21U-jdk_x64_linux_hotspot_21.0.1_12.tar.gz
drwxr-xr-x. 2 root root         6 Dec 23 10:01 railroot_proj
drwxr-xr-x. 2 root root         6 Dec 19 21:17 railrootweb
-rw-r--r--. 1 root root      1006 Jan  3 17:59 sonarqube.sh
[root@rhel-vm ~]# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash  # to install the azure cli

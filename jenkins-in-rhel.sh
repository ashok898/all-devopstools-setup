# --- Install prerequisites ---
sudo yum install -y wget git

# --- Install Java 21 manually (Adoptium tarball) ---
cd /opt
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
tar -xvzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
ln -sfn jdk-21.0.5+11 jdk-21

# Register Java with alternatives
sudo alternatives --install /usr/bin/java java /opt/jdk-21/bin/java 1
sudo alternatives --install /usr/bin/javac javac /opt/jdk-21/bin/javac 1
sudo alternatives --set java /opt/jdk-21/bin/java
sudo alternatives --set javac /opt/jdk-21/bin/javac

# Verify Java
java -version

# --- Install Jenkins ---
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins

# --- Configure Jenkins service to use Java 21 ---
sudo systemctl edit jenkins
# Add inside override file:
# [Service]
# Environment="JAVA_HOME=/opt/jdk-21"
# ExecStart=
# ExecStart=/opt/jdk-21/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --httpPort=8080 --webroot=/var/cache/jenkins/war

sudo systemctl daemon-reload

# --- Open firewall port ---
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# --- Start Jenkins ---
sudo systemctl reset-failed jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

# --- Get initial admin password ---
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# --- Access Jenkins UI ---
# Open browser: http://<server-ip>:8080





#####################################Troublshooting########################################

if vm goes to deallocated unexpectly our jenkins server will be stopped and we can't able to even start the server by getting beloe error

    ┌──────────────────────────────────────────────────────────────────────┐
    │                 • MobaXterm Personal Edition v25.3 •                 │
    │               (SSH client, X server and network tools)               │
    │                                                                      │
    │ ⮞ SSH session to azureuser@172.177.239.59                            │
    │   • Direct SSH      :  ✓                                             │
    │   • SSH compression :  ✓                                             │
    │   • SSH-browser     :  ✓                                             │
    │   • X11-forwarding  :  ✗  (disabled or not supported by server)      │
    │                                                                      │
    │ ⮞ For more info, ctrl+click on help or visit our website.            │
    └──────────────────────────────────────────────────────────────────────┘

Activate the web console with: systemctl enable --now cockpit.socket

Register this system with Red Hat Insights: insights-client --register
Create an account or view all your systems at https://red.ht/insights-dashboard
Last login: Fri Nov 21 20:01:05 2025 from 74.225.152.114
[azureuser@rhel-vm ~]$ sudo su -
Last login: Fri Nov 21 20:01:16 UTC 2025 on pts/0
Last failed login: Fri Nov 21 20:12:09 UTC 2025 from 170.64.223.63 on ssh:notty
There were 19 failed login attempts since the last successful login.
[root@rhel-vm ~]# sudo systemctl enable jenkins
[root@rhel-vm ~]# sudo systemctl start jenkins
Job for jenkins.service failed because the control process exited with error code.
See "systemctl status jenkins.service" and "journalctl -xe" for details.
[root@rhel-vm ~]#
[root@rhel-vm ~]# systemctl status jenkins
● jenkins.service - Jenkins Continuous Integration Server
   Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Fri 2025-11-21 20:13:55 UTC; 10s ago
  Process: 13911 ExecStart=/usr/bin/jenkins (code=exited, status=1/FAILURE)
 Main PID: 13911 (code=exited, status=1/FAILURE)

Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Service RestartSec=100ms expired, scheduling restart.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Scheduled restart job, restart counter is at 5.
Nov 21 20:13:55 rhel-vm systemd[1]: Stopped Jenkins Continuous Integration Server.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Start request repeated too quickly.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Failed with result 'exit-code'.
Nov 21 20:13:55 rhel-vm systemd[1]: Failed to start Jenkins Continuous Integration Server.
[root@rhel-vm ~]# journalctl -xeu jenkins.service
-- The result is failed.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Service RestartSec=100ms expired, scheduling restart.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Scheduled restart job, restart counter is at 5.
-- Subject: Automatic restarting of a unit has been scheduled
-- Defined-By: systemd
-- Support: https://access.redhat.com/support
--
-- Automatic restarting of the unit jenkins.service has been scheduled, as the result for
-- the configured Restart= setting for the unit.
Nov 21 20:13:55 rhel-vm systemd[1]: Stopped Jenkins Continuous Integration Server.
-- Subject: Unit jenkins.service has finished shutting down
-- Defined-By: systemd
-- Support: https://access.redhat.com/support
--
-- Unit jenkins.service has finished shutting down.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Start request repeated too quickly.
Nov 21 20:13:55 rhel-vm systemd[1]: jenkins.service: Failed with result 'exit-code'.
-- Subject: Unit failed
-- Defined-By: systemd
-- Support: https://access.redhat.com/support
--
-- The unit jenkins.service has entered the 'failed' state with result 'exit-code'.
Nov 21 20:13:55 rhel-vm systemd[1]: Failed to start Jenkins Continuous Integration Server.
-- Subject: Unit jenkins.service has failed
-- Defined-By: systemd
-- Support: https://access.redhat.com/support
--
-- Unit jenkins.service has failed.
--
-- The result is failed.
[root@rhel-vm ~]#
[root@rhel-vm ~]# java -version
openjdk version "21.0.1" 2023-10-17 LTS
OpenJDK Runtime Environment Temurin-21.0.1+12 (build 21.0.1+12-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.1+12 (build 21.0.1+12-LTS, mixed mode, sharing)
[root@rhel-vm ~]# java -version
openjdk version "21.0.1" 2023-10-17 LTS
OpenJDK Runtime Environment Temurin-21.0.1+12 (build 21.0.1+12-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.1+12 (build 21.0.1+12-LTS, mixed mode, sharing)
[root@rhel-vm ~]#
[root@rhel-vm ~]# sudo systemctl restart jenkins
Job for jenkins.service failed because the control process exited with error code.
See "systemctl status jenkins.service" and "journalctl -xe" for details.
[root@rhel-vm ~]# sudo rm -f /var/run/jenkins/jenkins.pid
[root@rhel-vm ~]# sudo chown -R jenkins:jenkins /var/lib/jenkins /var/cache/jenkins /var/log/jenkins
chown: cannot access '/var/log/jenkins': No such file or directory
[root@rhel-vm ~]#
[root@rhel-vm ~]# sudo systemctl daemon-reload
[root@rhel-vm ~]# sudo systemctl restart jenkins
Job for jenkins.service failed because the control process exited with error code.
See "systemctl status jenkins.service" and "journalctl -xe" for details.
[root@rhel-vm ~]# systemctl status jenkins.service
● jenkins.service - Jenkins Continuous Integration Server
   Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Fri 2025-11-21 20:19:18 UTC; 32s ago
  Process: 16282 ExecStart=/usr/bin/jenkins (code=exited, status=1/FAILURE)
 Main PID: 16282 (code=exited, status=1/FAILURE)

Nov 21 20:19:18 rhel-vm systemd[1]: jenkins.service: Service RestartSec=100ms expired, scheduling restart.
Nov 21 20:19:18 rhel-vm systemd[1]: jenkins.service: Scheduled restart job, restart counter is at 5.
Nov 21 20:19:18 rhel-vm systemd[1]: Stopped Jenkins Continuous Integration Server.
Nov 21 20:19:18 rhel-vm systemd[1]: jenkins.service: Start request repeated too quickly.
Nov 21 20:19:18 rhel-vm systemd[1]: jenkins.service: Failed with result 'exit-code'.
Nov 21 20:19:18 rhel-vm systemd[1]: Failed to start Jenkins Continuous Integration Server.
[root@rhel-vm ~]#
[root@rhel-vm ~]# # Create required directories
[root@rhel-vm ~]# sudo mkdir -p /var/cache/jenkins /var/log/jenkins /var/lib/jenkins
[root@rhel-vm ~]#
[root@rhel-vm ~]# # Set correct ownership
[root@rhel-vm ~]# sudo chown -R jenkins:jenkins /var/cache/jenkins /var/log/jenkins /var/lib/jenkins
[root@rhel-vm ~]#
[root@rhel-vm ~]# # Set proper permissions
[root@rhel-vm ~]# sudo chmod -R 755 /var/cache/jenkins /var/log/jenkins /var/lib/jenkins
[root@rhel-vm ~]#
[root@rhel-vm ~]# sudo systemctl daemon-reload
[root@rhel-vm ~]# sudo systemctl restart jenkins
Job for jenkins.service failed because the control process exited with error code.
See "systemctl status jenkins.service" and "journalctl -xe" for details.
[root@rhel-vm ~]# sudo systemctl status jenkins
● jenkins.service - Jenkins Continuous Integration Server
   Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; vendor preset: disabled)
   Active: activating (auto-restart) (Result: exit-code) since Fri 2025-11-21 20:26:09 UTC; 40ms ago
  Process: 19627 ExecStart=/usr/bin/jenkins (code=exited, status=1/FAILURE)
 Main PID: 19627 (code=exited, status=1/FAILURE)
[root@rhel-vm ~]#
[root@rhel-vm ~]# ls -l /usr/bin/jenkins
-rwxr-xr-x. 1 root root 4592 Nov 12 15:11 /usr/bin/jenkins
[root@rhel-vm ~]# rpm -qa | grep jenkins
jenkins-2.528.2-1.1.noarch
[root@rhel-vm ~]#
[root@rhel-vm ~]# sudo yum remove jenkins -y
Dependencies resolved.
===========================================================================================================================================
 Package                         Architecture                   Version                             Repository                        Size
===========================================================================================================================================
Removing:
 jenkins                         noarch                         2.528.2-1.1                         @jenkins                          91 M

Transaction Summary
===========================================================================================================================================
Remove  1 Package

Freed space: 91 M
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                   1/1
  Running scriptlet: jenkins-2.528.2-1.1.noarch                                                                                        1/1
  Erasing          : jenkins-2.528.2-1.1.noarch                                                                                        1/1
  Running scriptlet: jenkins-2.528.2-1.1.noarch                                                                                        1/1
/sbin/ldconfig: Can't create temporary cache file /etc/ld.so.cache~: Read-only file system
warning: %transfiletriggerpostun(glibc-common-2.28-151.el8.x86_64) scriptlet failed, exit status 1

Error in <unknown> scriptlet in rpm package jenkins
  Verifying        : jenkins-2.528.2-1.1.noarch                                                                                        1/1
Installed products updated.

Removed:
  jenkins-2.528.2-1.1.noarch

Complete!
[root@rhel-vm ~]# sudo yum install jenkins -y
Docker CE Stable - x86_64                                                                                  1.9 kB/s | 397  B     00:00
Errors during downloading metadata for repository 'docker-ce-stable':
  - Status code: 404 for https://download.docker.com/linux/centos/8.4/x86_64/stable/repodata/repomd.xml (IP: 52.85.193.2)
Error: Failed to download metadata for repo 'docker-ce-stable': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
[root@rhel-vm ~]# sudo vi /etc/yum.repos.d/docker-ce.repo


Press ENTER or type command to continue

Press ENTER or type command to continue
[root@rhel-vm ~]# sudo systemctl stop jenkins
[root@rhel-vm ~]# sudo systemctl disable jenkins
Failed to disable unit: Unit file jenkins.service does not exist.
[root@rhel-vm ~]# sudo yum remove jenkins -y
No match for argument: jenkins
No packages marked for removal.
Dependencies resolved.
Nothing to do.
Complete!
[root@rhel-vm ~]#
[root@rhel-vm ~]# sudo dnf remove jenkins -y
No match for argument: jenkins
No packages marked for removal.
Dependencies resolved.
Nothing to do.
Complete!
[root@rhel-vm ~]#
[root@rhel-vm ~]# sudo rm -rf /var/lib/jenkins
[root@rhel-vm ~]# sudo rm -rf /var/log/jenkins
[root@rhel-vm ~]# which jenkins
/usr/bin/which: no jenkins in (/opt/jdk-21/bin:/opt/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin)
[root@rhel-vm ~]# # --- Install prerequisites ---
# Register Java with alternatives
sudo alternatives --install /usr/bin/java java /opt/jdk-21/bin/java 1
sudo alternatives --install /usr/bin/javac javac /opt/jdk-21/bin/javac 1
sudo alternatives --set java /opt/jdk-21/bin/java
sudo alternatives --set javac /opt/jdk-21/bin/javac
[root@rhel-vm ~]# sudo yum install -y wget git

# --- Install Jenkins ---
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins

# --- Configure Jenkins service to use Java 21 ---
sudo systemctl edit jenkins
# Add inside override file:
# [Service]
# Environment="JAVA_HOME=/opt/jdk-21"
# ExecStart=
# ExecStart=/opt/jdk-21/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --httpPort=8080 --webroot=/var/cache/jenkins/war

sudo systemctl daemon-reload

# --- Open firewall port ---
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# --- Start Jenkins ---
sudo systemctl reset-failed jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

# --- Get initial admin password ---
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# --- Access Jenkins UI ---
# Open browser: http://<server-ip>:8080Docker CE Stable - x86_64                              [===                                         Docker CE Stable - x86_64                                                                                  2.7 kB/s | 385  B     00:00
Errors during downloading metadata for repository 'docker-ce-stable':
  - Status code: 404 for https://download.docker.com/linux/centos/8.4/x86_64/stable/repodata/repomd.xml (IP: 52.85.193.37)
Error: Failed to download metadata for repo 'docker-ce-stable': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
[root@rhel-vm ~]#
[root@rhel-vm ~]# # --- Install Java 21 manually (Adoptium tarball) ---
[root@rhel-vm ~]# cd /opt
[root@rhel-vm opt]# wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
--2025-11-21 20:36:57--  https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
Resolving github.com (github.com)... 140.82.114.4
Connecting to github.com (github.com)|140.82.114.4|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://release-assets.githubusercontent.com/github-production-release-asset/602574963/ee5a67ac-5d27-47e0-b566-b04d787fb74b?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-21T21%3A22%3A14Z&rscd=attachment%3B+filename%3DOpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-21T20%3A22%3A08Z&ske=2025-11-21T21%3A22%3A14Z&sks=b&skv=2018-11-09&sig=0GYD24Y0LiwW323IZWpRbN42FNyl5YihQ9DwBVFTvrQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mzc2MTAxOCwibmJmIjoxNzYzNzU3NDE4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.l4R7a9_8T3h7mFlRBsVv4tmUiZyRfOwvYbk7n3DGhTA&response-content-disposition=attachment%3B%20filename%3DOpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz&response-content-type=application%2Foctet-stream [following]
--2025-11-21 20:36:58--  https://release-assets.githubusercontent.com/github-production-release-asset/602574963/ee5a67ac-5d27-47e0-b566-b04d787fb74b?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-11-21T21%3A22%3A14Z&rscd=attachment%3B+filename%3DOpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-11-21T20%3A22%3A08Z&ske=2025-11-21T21%3A22%3A14Z&sks=b&skv=2018-11-09&sig=0GYD24Y0LiwW323IZWpRbN42FNyl5YihQ9DwBVFTvrQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2Mzc2MTAxOCwibmJmIjoxNzYzNzU3NDE4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.l4R7a9_8T3h7mFlRBsVv4tmUiZyRfOwvYbk7n3DGhTA&response-content-disposition=attachment%3B%20filename%3DOpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz&response-content-type=application%2Foctet-stream
Resolving release-assets.githubusercontent.com (release-assets.githubusercontent.com)... 185.199.108.133, 185.199.109.133, 185.199.110.133, ...
Connecting to release-assets.githubusercontent.com (release-assets.githubusercontent.com)|185.199.108.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 206798126 (197M) [application/octet-stream]
OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz: Read-only file system

Cannot write to ‘OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz’ (Read-only file system).
[root@rhel-vm opt]# tar -xvzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz
tar (child): OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz: Cannot open: No such file or directory
tar (child): Error is not recoverable: exiting now
tar: Child returned status 2
tar: Error is not recoverable: exiting now
[root@rhel-vm opt]# ln -sfn jdk-21.0.5+11 jdk-21
ln: failed to create symbolic link 'jdk-21/jdk-21.0.5+11': Read-only file system
[root@rhel-vm opt]#
[root@rhel-vm opt]# # Register Java with alternatives
[root@rhel-vm opt]# sudo alternatives --install /usr/bin/java java /opt/jdk-21/bin/java 1
[root@rhel-vm opt]# sudo alternatives --install /usr/bin/javac javac /opt/jdk-21/bin/javac 1
[root@rhel-vm opt]# sudo alternatives --set java /opt/jdk-21/bin/java
[root@rhel-vm opt]# sudo alternatives --set javac /opt/jdk-21/bin/javac
[root@rhel-vm opt]#
[root@rhel-vm opt]# # Verify Java
[root@rhel-vm opt]# java -version
openjdk version "21.0.1" 2023-10-17 LTS
OpenJDK Runtime Environment Temurin-21.0.1+12 (build 21.0.1+12-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.1+12 (build 21.0.1+12-LTS, mixed mode, sharing)
[root@rhel-vm opt]#
[root@rhel-vm opt]# # --- Install Jenkins ---
[root@rhel-vm opt]# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
/etc/yum.repos.d/jenkins.repo: Read-only file system
[root@rhel-vm opt]# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
[root@rhel-vm opt]# sudo yum install -y jenkins
Docker CE Stable - x86_64                                                                                  2.0 kB/s | 405  B     00:00
Errors during downloading metadata for repository 'docker-ce-stable':
  - Status code: 404 for https://download.docker.com/linux/centos/8.4/x86_64/stable/repodata/repomd.xml (IP: 52.85.193.37)
Error: Failed to download metadata for repo 'docker-ce-stable': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
[root@rhel-vm opt]#
[root@rhel-vm opt]# # --- Configure Jenkins service to use Java 21 ---
[root@rhel-vm opt]# sudo systemctl edit jenkins
No files found for jenkins.service.
Run 'systemctl edit --force jenkins.service' to create a new unit.
[root@rhel-vm opt]# # Add inside override file:
[root@rhel-vm opt]# # [Service]
[root@rhel-vm opt]# # Environment="JAVA_HOME=/opt/jdk-21"
[root@rhel-vm opt]# # ExecStart=
[root@rhel-vm opt]# # ExecStart=/opt/jdk-21/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --httpPort=8080 --webroot=/var/cache/jenkins/war
[root@rhel-vm opt]#
[root@rhel-vm opt]# sudo systemctl daemon-reload
[root@rhel-vm opt]#
[root@rhel-vm opt]# # --- Open firewall port ---
[root@rhel-vm opt]# sudo firewall-cmd --add-port=8080/tcp --permanent
Warning: ALREADY_ENABLED: 8080:tcp
success
[root@rhel-vm opt]# sudo firewall-cmd --reload
success
[root@rhel-vm opt]#
[root@rhel-vm opt]# # --- Start Jenkins ---
[root@rhel-vm opt]# sudo systemctl reset-failed jenkins
[root@rhel-vm opt]# sudo systemctl start jenkins
Failed to start jenkins.service: Unit jenkins.service not found.
[root@rhel-vm opt]# sudo systemctl enable jenkins
Failed to enable unit: Unit file jenkins.service does not exist.
[root@rhel-vm opt]# sudo systemctl status jenkins
Unit jenkins.service could not be found.
[root@rhel-vm opt]#
[root@rhel-vm opt]# # --- Get initial admin password ---
[root@rhel-vm opt]# sudo cat /var/lib/jenkins/secrets/initialAdminPassword
cat: /var/lib/jenkins/secrets/initialAdminPassword: No such file or directory
[root@rhel-vm opt]#
[root@rhel-vm opt]# # --- Access Jenkins UI ---
[root@rhel-vm opt]# # Open browser: http://<server-ip>:8080
[root@rhel-vm opt]# sudo mount -o remount,rw /
[root@rhel-vm opt]# mount | grep ' / '
/dev/mapper/rootvg-rootlv on / type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)
[root@rhel-vm opt]# sudo dmesg | grep -i error
[root@rhel-vm opt]#
[root@rhel-vm opt]# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
--2025-11-21 20:42:15--  https://pkg.jenkins.io/redhat-stable/jenkins.repo
Resolving pkg.jenkins.io (pkg.jenkins.io)... 199.232.90.133, 2a04:4e42:77::645
Connecting to pkg.jenkins.io (pkg.jenkins.io)|199.232.90.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 85
Saving to: ‘/etc/yum.repos.d/jenkins.repo’

/etc/yum.repos.d/jenkins.repo      100%[===============================================================>]      85  --.-KB/s    in 0s

2025-11-21 20:42:15 (1.50 MB/s) - ‘/etc/yum.repos.d/jenkins.repo’ saved [85/85]

[root@rhel-vm opt]# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
[root@rhel-vm opt]# sudo yum install -y jenkins
Docker CE Stable - x86_64                                                                                  2.8 kB/s | 417  B     00:00
Errors during downloading metadata for repository 'docker-ce-stable':
  - Status code: 404 for https://download.docker.com/linux/centos/8.4/x86_64/stable/repodata/repomd.xml (IP: 52.85.193.112)
Error: Failed to download metadata for repo 'docker-ce-stable': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
[root@rhel-vm opt]# sudo yum --disablerepo=docker-ce-stable install -y jenkins
Last metadata expiration check: 21:35:34 ago on Thu 20 Nov 2025 11:07:34 PM UTC.
Dependencies resolved.
===========================================================================================================================================
 Package                         Architecture                   Version                              Repository                       Size
===========================================================================================================================================
Installing:
 jenkins                         noarch                         2.528.2-1.1                          jenkins                          91 M

Transaction Summary
===========================================================================================================================================
Install  1 Package

Total download size: 91 M
Installed size: 91 M
Downloading Packages:
jenkins-2.528.2-1.1.noarch.rpm                                                                              39 MB/s |  91 MB     00:02
-------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                       39 MB/s |  91 MB     00:02
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                   1/1
  Running scriptlet: jenkins-2.528.2-1.1.noarch                                                                                        1/1
  Installing       : jenkins-2.528.2-1.1.noarch                                                                                        1/1
  Running scriptlet: jenkins-2.528.2-1.1.noarch                                                                                        1/1
  Verifying        : jenkins-2.528.2-1.1.noarch                                                                                        1/1
Installed products updated.

Installed:
  jenkins-2.528.2-1.1.noarch

Complete!
[root@rhel-vm opt]# sudo yum install -y jenkins
Docker CE Stable - x86_64                                                                                  2.7 kB/s | 385  B     00:00
Errors during downloading metadata for repository 'docker-ce-stable':
  - Status code: 404 for https://download.docker.com/linux/centos/8.4/x86_64/stable/repodata/repomd.xml (IP: 52.85.193.2)
Error: Failed to download metadata for repo 'docker-ce-stable': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
[root@rhel-vm opt]# sudo yum --disablerepo=docker-ce-stable install -y jenkins
Last metadata expiration check: 21:37:40 ago on Thu 20 Nov 2025 11:07:34 PM UTC.
Package jenkins-2.528.2-1.1.noarch is already installed.
Dependencies resolved.
Nothing to do.
Complete!
[root@rhel-vm opt]# sudo rm -f /etc/yum.repos.d/docker-ce.repo
[root@rhel-vm opt]# sudo yum update --nobest
Last metadata expiration check: 21:38:08 ago on Thu 20 Nov 2025 11:07:34 PM UTC.
Dependencies resolved.
Nothing to do.
Complete!
[root@rhel-vm opt]# sudo yum install -y jenkins
Last metadata expiration check: 21:38:24 ago on Thu 20 Nov 2025 11:07:34 PM UTC.
Package jenkins-2.528.2-1.1.noarch is already installed.
Dependencies resolved.
Nothing to do.
Complete!
[root@rhel-vm opt]# systemctl status jenkins
● jenkins.service - Jenkins Continuous Integration Server
   Loaded: loaded (/usr/lib/systemd/system/jenkins.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

Nov 21 20:26:11 rhel-vm jenkins[19827]:         ... 1 more
Nov 21 20:26:11 rhel-vm systemd[1]: jenkins.service: Main process exited, code=exited, status=1/FAILURE
Nov 21 20:26:11 rhel-vm systemd[1]: jenkins.service: Failed with result 'exit-code'.
Nov 21 20:26:11 rhel-vm systemd[1]: Failed to start Jenkins Continuous Integration Server.
Nov 21 20:26:11 rhel-vm systemd[1]: jenkins.service: Service RestartSec=100ms expired, scheduling restart.
Nov 21 20:26:11 rhel-vm systemd[1]: jenkins.service: Scheduled restart job, restart counter is at 5.
Nov 21 20:26:11 rhel-vm systemd[1]: Stopped Jenkins Continuous Integration Server.
Nov 21 20:26:11 rhel-vm systemd[1]: jenkins.service: Start request repeated too quickly.
Nov 21 20:26:11 rhel-vm systemd[1]: jenkins.service: Failed with result 'exit-code'.
Nov 21 20:26:11 rhel-vm systemd[1]: Failed to start Jenkins Continuous Integration Server.
[root@rhel-vm opt]# systemctl enable jenkins
Created symlink /etc/systemd/system/multi-user.target.wants/jenkins.service → /usr/lib/systemd/system/jenkins.service.
[root@rhel-vm opt]# systemctl start jenkins
[root@rhel-vm opt]# systemctl status jenkins
● jenkins.service - Jenkins Continuous Integration Server
   Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2025-11-21 20:47:52 UTC; 4s ago
 Main PID: 28981 (java)
    Tasks: 47 (limit: 101085)
   Memory: 739.3M
   CGroup: /system.slice/jenkins.service
           └─28981 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080

Nov 21 20:47:49 rhel-vm jenkins[28981]: [LF]> dbcb7fa0d9894dea9e3308bde8f4582e
Nov 21 20:47:49 rhel-vm jenkins[28981]: [LF]>
Nov 21 20:47:49 rhel-vm jenkins[28981]: [LF]> This may also be found at: /var/lib/jenkins/secrets/initialAdminPassword
Nov 21 20:47:49 rhel-vm jenkins[28981]: [LF]>
Nov 21 20:47:49 rhel-vm jenkins[28981]: [LF]> *************************************************************
Nov 21 20:47:52 rhel-vm jenkins[28981]: 2025-11-21 20:47:52.184+0000 [id=47]        INFO        jenkins.InitReactorRunner$1#onAttained: Co>
Nov 21 20:47:52 rhel-vm jenkins[28981]: 2025-11-21 20:47:52.212+0000 [id=33]        INFO        hudson.lifecycle.Lifecycle#onReady: Jenkin>
Nov 21 20:47:52 rhel-vm systemd[1]: Started Jenkins Continuous Integration Server.
Nov 21 20:47:52 rhel-vm jenkins[28981]: 2025-11-21 20:47:52.353+0000 [id=63]        INFO        h.m.DownloadService$Downloadable#load: Obt>
Nov 21 20:47:52 rhel-vm jenkins[28981]: 2025-11-21 20:47:52.353+0000 [id=63]        INFO        hudson.util.Retrier#start: Performed the a>
[root@rhel-vm opt]#



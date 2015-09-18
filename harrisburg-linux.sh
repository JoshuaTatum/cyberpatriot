#!/bin/bash
#CODE CURRENTLY UNTESTED ON UBUNTU SYSTEM. DO NOT RUN OUTSIDE OF VIRTUAL MACHINE
function usermanagement {
    echo "refer to the readme. Is " $1 " in the list of documented users? (y/n)"
    read userbool
    if (( ("$userbool") == "y" )); then
        return
    elif (( ("$userbool") == "n" )); then
        echo "You entered 'n'. Are you sure " $1 " is not in the list of documented users? (responding with 'y' will delete the user) (y/n)"
        read userbool
        if (( ("$userbool") == "y" )); then
            userdel -r $1
        else
            return
        fi
    else
        echo "input not recognized"
    fi
}

function main {
    #variable assignment
    now="$(date +'%d/%m/%Y %r')"
    #intro
    echo "running main ( $now )"
    echo "run as 'sudo sh harrisburg-linux.sh 2>&1 | tee output.log' to output the console output to a log file."
    echo "refer to /root/.logfiles/ folder for program logs"
    #preperation
    mkdir -v $HOME/.log-files
    cd $HOME/.log-files
    #interactive user management
    i = 1;
    cat /etc/passwd | grep "/home" | cut -d: -f1 | sed -e 's/\s*//' | while read line
    do
        array[ $1 ]="$line"
        (( i++ ))
        usermanagement $line
    done
    #installs
    apt-get update
    apt-get upgrade
    apt-get -V -y install firefox, hardinfo, chkrootkit, iptables, portsentry, lynis
    #tar.gz installs
        #checkps
        wget http://downloads.sourceforge.net/project/checkps/checkps/1.3.2/check-ps-1.3.2.1.tar.gz
        tar -zxvf check-ps-1.3.2.1.tar.gz
        cd check-ps-1.3.2.1
        ./configure
        make install
    #information gathering
    hardinfo -r -f html > /root/.logfiles/hardinfo-html.html
    chkrootkit > /root/.logfiles/chkrootkit.log
    checkps > /root/.logfiles/checkps.log
    lynis -c > /root/.logfiles/lynis.log
    #network security
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #Block X-Windows
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #Block X-Windows font server
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
    iptables -A INPUT -p all -s localhost  -i eth0 -j DROP            #Deny outside packets from internet which claim to be from your loopback interface.
    #media file deletion
    find / -name '*.mp3' -type f -delete
    find / -name '*.mov' -type f -delete
    find / -name '*.mp4' -type f -delete
    find / -name '*.avi' -type f -delete
    find / -name '*.mpg' -type f -delete
    find / -name '*.mpeg' -type f -delete
    find / -name '*.flac' -type f -delete
    find / -name '*.m4a' -type f -delete
    find / -name '*.flv' -type f -delete
    find / -name '*.ogg' -type f -delete
    find /home -name '*.gif' -type f -delete
    find /home -name '*.png' -type f -delete
    find /home -name '*.jpg' -type f -delete
    find /home -name '*.jpeg' -type f -delete
}

if [ "$(id -u)" != "0" ]; then
    echo "harrisburg-linux.sh is not being run as root"
    exit
else
    main
fi


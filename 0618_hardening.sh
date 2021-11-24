#! /bin/bash

#nodev
variable_bandera=$(cat /etc/systemd/system/local-fs.target.wants/tmp.mount | grep noexec)
if [ -z "$variable_bandera" ];
then
    printf ",noexec" $SHELL >> /etc/systemd/system/local-fs.target.wants/tmp.mount
    mount -o remount,noexec /tmp
    printf "\n noexec option set on tmp partition\n"  $SHELL >> /var/log/hardening.log
fi
#nodev
variable_bandera=$(cat /etc/systemd/system/local-fs.target.wants/tmp.mount | grep nodev)
if [ -z "$variable_bandera" ];
then
    printf ",nodev" $SHELL >> /etc/systemd/system/local-fs.target.wants/tmp.mount
    mount -o remount,nodev /tmp
    printf "\n nodev option set on tmp partition\n"  $SHELL >> /var/log/hardening.log
fi
#nosuid
variable_bandera=$(cat /etc/systemd/system/local-fs.target.wants/tmp.mount | grep nosuid)
if [ -z "$variable_bandera" ];
then
    printf ",nosuid" $SHELL >> /etc/systemd/system/local-fs.target.wants/tmp.mount
    mount -o remount,nosuid /tmp
    printf "\n  nosuid option set on /tmp partition\n"  $SHELL >> /var/log/hardening.log
fi
#Core dumps
variable_bandera=$(sysctl fs.suid_dumpable | grep 0) 
if [ -z "$variable_bandera" ];
then
    variable_bandera=$(cat /etc/security/limits.conf | grep "hard core 0")
    if [ -z "$variable_bandera" ];
    then
        printf "\n* hard core 0" $SHELL >> /etc/security/limits.conf
    fi
    variable_bandera=$(cat /etc/sysctl.conf | grep "fs.suid_dumpable = 0")
    if [ -z "$variable_bandera" ];
    then
        printf "\nfs.suid_dumpable = 0" $SHELL >> /etc/sysctl.conf
    fi
    sysctl -w fs.suid_dumpable=0

variable_bandera=$(ifconfig -a | grep inet6)
if [ ! -z "$variable_bandera" ]; then
printf "\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" $SHELL >> /etc/sysctl.conf
sysctl -p
fi

if [ ! -z "$variable_bandera" ];
then
    printf "\n ip forwarding is disable \n"

else
    printf "\n desactivando ip forwarding\n"
    sysctl -w net.ipv4.ip_forward=0 
    sysctl -w net.ipv4.route.flush=1
    printf "\n ip forwarding se ha desactivado\n"  $SHELL >> /var/log/hardening.log


fi

if [ ! -z "$variable_bandera" ];
then
printf "\ICMP redirects are not accepted \n " 

else
sysctl -w net.ipv4.conf.all.accept_redirects=0 
sysctl -w net.ipv4.conf.default.accept_redirects=0 
sysctl -w net.ipv4.route.flush=1
printf "las redirecciones ICMP no son aceptadas"  $SHELL >> /var/log/hardening.log

fi

#modulo icmp
variable_bandera=$(sysctl net.ipv4.conf.all.accept_redirects | grep 0)
if [ -z "$variable_bandera" ];
then
    sysctl -w net.ipv4.conf.all.accept_redirects=0 
    sysctl -w net.ipv4.route.flush=1
    printf "\n ICMP redirects are not accepted\n" $SHELL >> /var/log/hardening.log
fi

variable_bandera=$(sysctl net.ipv4.conf.default.accept_redirects | grep 0)
if [ -z "$variable_bandera" ];
then
    sysctl -w net.ipv4.conf.default.accept_redirects=0
    sysctl -w net.ipv4.route.flush=1     
    printf "\n No se aceptan redireccionamientos ICMP\n" $SHELL >> /var/log/hardening.log
fi


variable_bandera=$(sysctl net.ipv4.icmp_echo_ignore_broadcasts | grep 0)
if [ -z "$variable_bandera" ];
then
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 
    sysctl -w net.ipv4.route.flush=1      
    printf "\n broadcast ICMP requests are ignored\n" $SHELL >> /var/log/hardening.log
fi


variable_bandera=$(sysctl net.ipv4.icmp_echo_ignore_bogus_error_responses | grep 1)
if [ -z "$variable_bandera" ];
then
    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1 
    sysctl -w net.ipv4.route.flush=1           
    printf "\n bogus ICMP responses are ignored\n" $SHELL >> /var/log/hardening.log

fi

variable_bandera=$(sysctl net.ipv4.tcp_syncookies | grep 1)
if [ -z "$variable_bandera" ];
then
    sysctl -w net.ipv4.tcp_syncookies=1
    sysctl -w net.ipv4.route.flush=1             
      printf "\n TCP SYN Cookies is enabled\n" $SHELL >> /var/log/hardening.log
fi


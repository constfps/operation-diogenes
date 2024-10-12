#!/bin/bash
echo Password: 
read PASS
cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1 > users
##Looks for users with the UID and GID of 0
hUSER=`cut -d: -f1,3 /etc/passwd | egrep ':[0]{1}$' | cut -d: -f1`
sed -i '/root/ d' users
for x in `cat users`
do
	sudo passwd $x $PASS
done


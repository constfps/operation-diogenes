#!/bin/bash

clean_users_list(){
    if [ -f users.txt ]; then
        cat users.txt | uniq > temp.txt
        mv temp.txt users.txt
        sed -i '/^$/d' users.txt
        echo Cleaned up users.txt
    else
        echo "how did you even get here"
        exit 1
    fi
}

segregate_into_void(){
    awk -F: '$3 >= 1000 {print $1}' /etc/passwd | while IFS= read -r username; do
        if [ "$(id -u "$username")" -ge 1000 ]; then
            if ! grep -Fxq "$username" users.txt; then
                echo "screw you $username"
                sudo userdel "$username"
            fi
        fi
    done < <(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)
}

accouchement() {
    cat users.txt | while IFS= read -r username; do
        if ! id "$username" &>/dev/null; then
            echo "giving birth to $username"
            useradd -m "$username"
        fi
    done
}

#TODO: adding and removing admins

#actual script
if [ ! -f users.txt ]; then
    echo "uh oh! users.txt not found"
    exit 1
fi

clean_users_list
segregate_into_void
accouchement

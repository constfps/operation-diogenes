#!/usr/bin/env bash
read -p "Enter filename: " filename

cleanup_file(){
    if [ -f "$filename" ]; then
        cat "$filename" | uniq > temp.txt
        mv temp.txt "$filename"
        sed -i '/^$/d' "$filename"
    else
        echo "how tf did you get past the initial check"
        exit 1
    fi
}

murder(){
    awk -F: '$3 >= 1000 {print $1} /etc/passwd' | while IFS= read -r username; do
    if ! id "$username" &>/dev/null && [ "$(id -u "$username")" -ge 1000 ]; then
            if ! grep -Fxq "$username" "$filename"; then
                echo "Killing $username"
                userdel "$username"
            fi
        fi
    done
}

birth(){
    cat "$filename" | while IFS= read -r username; do
        if ! id "$username" &>/dev/null; then
            echo "Giving birth to $username"
            useradd -m "$username"
        fi
    done
}

if [ ! -f  "$username"]; then
    echo "Couldn't find that file. Sorry!"
    exit 1
fi

cleanup_file
murder
birth

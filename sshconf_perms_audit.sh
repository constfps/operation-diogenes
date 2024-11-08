#!/usr/bin/env bash

{
    l_output="" l_output2=""
    unset a_sshdfiles && a_sshdfiles=()
    [ -e "/etc/ssh/sshd_config" ] && a_sshdfiles+=("$(stat -Lc '%n^%#a^%U^%G' "/etc/ssh/sshd_config")")

    while IFS= read -r -d $'\0' l_file; do
        [ -e "$l_file" ] && a_sshdfiles+=("$(stat -Lc '%n^%#a^%U^%G' "$l_file")")
    done < <(find /etc/ssh/sshd_config.d -type f \( -perm /077 -o ! -user root -o ! -group root \) -print0)

    if (( ${#a_sshdfiles[@]} != 0 )); then
        perm_mask='0177'
        maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
        while IFS="^" read -r l_file l_mode l_user l_group; do
            l_out2=""
            [ $(( $l_mode & $perm_mask )) -gt 0 ] && l_out2="$l_out2\n - Is mode: \"$l_mode\" should be: \"$maxperm\" or more restrictive"
            [ "$l_user" != "root" ] && l_out2="$l_out2\n - Is owned by \"$l_user\" should be owned by \"root\""
            [ "$l_group" != "root" ] && l_out2="$l_out2\n - Is group owned by \"$l_user\" should be group owned by \"root\""
            if [ -n "$l_out2" ]; then
                l_output2="$l_output2\n - File: \"$l_file\":$l_out2"
            else
                l_output="$l_output\n - File: \"$l_file\":\n - Correct: mode ($l_mode), owner ($l_user), and group owner ($l_group) configured"
            fi
        done <<< "$(printf '%s\n' "${a_sshdfiles[@]}")"
    fi

    unset a_sshdfiles

    if [ -z "$l_output2" ]; then
        echo -e "\n- Audit Result:\n *** PASS ***\n- * Correctly set * :\n$l_output\n"
    else
        echo -e "\n- Audit Result:\n ** FAIL **\n - * Reasons for audit failure * :\n$l_output2\n"
        [ -n "$l_output" ] && echo -e " - * Correctly set * :\n$l_output\n"
    fi
}

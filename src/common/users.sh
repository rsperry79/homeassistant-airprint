#!/command/with-contend bashio

function run() {
    users=()

    if bashio::config.has_value 'logins'; then
        additional_logins=$(bashio::jq "$(bashio::addon.config)" ".logins[]")
        readarray -t additional_logins <<<"${additional_logins}"
        for login in "${additional_logins[@]}"; do
            username=$(bashio::jq "${login}" ".username")
            pw=$(bashio::jq "${login}" ".password")
            level=$(bashio::jq "${login}" ".user_level")
            users+=("$username")

            bashio::log.debug login "$username"
            if [ "$username" != "root" ]; then
                add_or_update_user "$username" "$pw" "$level"
            else
                bashio::exit.nok 'You cannot add or attempt to change root via logins!'
            fi
        done

        # user_groups=("sudo" "lpadmin" "lp")
        # for grp in "${user_groups[@]}"; do
        #     remove_users "$grp" "${users[@]}"
        # done
    fi


}

function add_or_update_user() {
    user=${1:-"printer-admin"}
    pw=${2:-"print"}
    access_level=${3:-"standard"}

    groups=
    case $access_level in
    "standard")
        groups="lp"
        ;;
    "admin")
        groups="lp,lpadmin"
        ;;
    "superuser")
        groups="lp,lpadmin,sudo"
        ;;
    *)
        bashio::exit.nok 'Invalid user level!'
        ;;
    esac

    if ! id "$user" &>/dev/null; then
        useradd \
            --groups="$groups" \
            --create-home \
            --home-dir=/home/"$user" \
            --shell=/bin/bash \
            --password="$(mkpasswd "$pw")" \
            "$user"
    else
        echo "${user}:${pw}" | chpasswd
    fi
}

function remove_users() {
    group_name=${1}
    active_users=${2:-()}

    group_info=$(getent group "$group_name")

    # Check if group exists
    if [[ -z "$group_info" ]]; then
        bashio::exit.nok "User group $group_name: does not exist!"
    fi

    user_list=$(echo "$group_info" | cut -d: -f4)
    IFS=',' read -r -a users <<<"$user_list"
    for user in "${users[@]}"; do
        if [ "$user" != "root" ]; then
            # Loop through active users to check for the group member
            found=false
            for valid_user in "${active_users[@]}"; do
                if [[ "$valid_user" == "$user" ]]; then
                    found=true
                    break
                fi
            done

            if [ "$found" == "false" ]; then
                deluser "$user"
            fi
        fi

    done
}

run

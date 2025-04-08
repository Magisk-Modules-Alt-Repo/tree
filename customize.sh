check_bash() {
    if [ -x "/system/bin/bash" ]; then
        ui_print " => bash found, proceeding normally."
        return 0
    else
        ui_print " => bash not found, downloading appropriate binary."
        return 1
    fi
}
#check for internet
check_internet() {
    ui_print " => Checking for internet connection..."
    if ping -c 1 -W 1 google.com >/dev/null 2>&1; then
        ui_print " => Internet connection detected."
        return 0
    else
        ui_print " => No internet connection detected. Please connect to the internet and try again."
        return 1
    fi
}

# download the appropriate bash binary
download_bash() {
    arch=$(getprop ro.product.cpu.abi)
    ui_print " => Detected architecture: $arch"
    case "$arch" in
        x86) bash_binary="bash-x86" ;;
        x86_64) bash_binary="bash-x64" ;;
        armeabi-v7a) bash_binary="bash-arm" ;;
        arm64-v8a) bash_binary="bash-arm64" ;;
        *) 
            ui_print " => Unsupported architecture: $arch"
            abort
            ;;
    esac
    ui_print " => Downloading $bash_binary..."
    url="https://raw.githubusercontent.com/Magisk-Modules-Alt-Repo/mkshrc/master/common/bash/$bash_binary"
    wget -qO "$MODPATH/system/bin/bash" "$url"

    # Check if download was successful
    if [ $? -eq 0 ] && [ -f "$MODPATH/system/bin/bash" ]; then
        ui_print " => Download successful."
        chmod 0755 "$MODPATH/system/bin/bash"
    else
        ui_print " => Download failed. Please check your internet connection."
        abort
    fi
}
if ! check_bash; then
    if check_internet; then
        download_bash
    else
        ui_print " => Exiting due to lack of internet connection."
        abort
    fi
fi
# Set permissions for the entire system directory
set_perm_recursive "$MODPATH" 0 0 0755 0755
ui_print " => Tree"
ui_print " => Installation Completed"
ui_print ""

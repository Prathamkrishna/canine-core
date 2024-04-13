
function getOs(){
    if [[ $(cat /etc/os-release) == *"fedora"* ]]; then
        echo "fedora"
    elif [[ $(cat /etc/os-release) == *"debian"* ]]; then
        echo "debian"
    fi
}


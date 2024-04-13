#!/bin/bash
pathtocanine=/opt/canine
echo "Greetings from canine"

print_help(){
    echo "It seems as though no arguments were passed, you can run one of the following commands next"
    echo "help: Prints the help screen"
    echo "install: Installs canine"
}

install_k8s(){
    source $pathtocanine/install.sh
}

if [ $# -eq 0 ]
then
    print_help
    exit 0 
fi

if [ $1 == "help" ]
then
    print_help
elif [ $1 == "install" ]
then
    install_k8s
else
    echo "please enter the command that you would want to run"
fi

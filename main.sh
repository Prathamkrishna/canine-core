# Startup
echo "Welcome to the canine installer, a simple kubernetes deployment tool"
# copy files to a designated directory
pathtocanine=/opt/canine
sudo mkdir $pathtocanine
sudo cp -a . $pathtocanine

# set alias
filepath=$pathtocanine/commands.sh
echo $filepath
alias canine="bash ${filepath}"
source ~/.bash_profile

echo "Canine has been installed, printing to validate virtualisation"
docker --version
podman version
nerdctl version
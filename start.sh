echo "Welcome to the canine installer, a simple kubernetes deployment tool"
# copy files to a designated directory
pathtocanine=/opt/canine
sudo mkdir $pathtocanine
sudo cp -a . $pathtocanine

# set alias
filepath=$pathtocanine/commands.sh
echo $filepath
alias canine="bash ${filepath}"
count_bash_profile=$(find ~/ -name .bash_profile | wc -l)
if [ $count_bash_profile -eq 0 ]
then 
  source ~/.profile
  source ~/.bashrc
else
  source ~/.bash_profile
fi
source ~/.bash_profile || source ~/.profile
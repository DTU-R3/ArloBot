#!/bin/bash
# ROS Indigo Automated Install - credit goes to everyone
# Blame goes to ChrisL8

# Run this straight off of github like this:
# bash <(wget -qO- --no-cache https://raw.githubusercontent.com/chrisl8/ArloBot/master/setup.sh)

BLACK='\033[0;30m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m' # or brown
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTBLUE='\033[1;34m'
LIGHTGREEN='\033[1;32m'
LIGHTCYAN='\033[1;36m'
LIGHTRED='\033[1;31m'
LIGHTPURPLE='\033[1;35m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # NoColor

printf "\n${YELLOW}SETTING UP ROBOT OPERATING SYSTEM FOR YOUR ARLOBOT!${NC}\n"
printf "\n${YELLOW}---------------------------------------------------${NC}\n"
printf "${GREEN}You will be asked for your password for running commands as root!${NC}\n"

version=`lsb_release -sc`

printf "\n${YELLOW}[Checking the Ubuntu version]${NC}\n"
printf "${BLUE}Ubuntu ${version} found${NC}\n"
case $version in
  "saucy" | "trusty")
;;
*)
printf "${RED}[This script will only work on ubuntu saucy(13.10) or trusty(14.04)]${NC}\n"
exit 0
esac

printf "\n${YELLOW}[Updating & upgrading all existing Ubuntu packages]${NC}\n"
printf "${BLUE}silently . . .${NC}\n"
# NOTE: You have to pipe /dev/null INTO apt-get to make it work from wget.
sudo apt-get update -qq < /dev/null
sudo apt-get upgrade -qq < /dev/null

# I never use this, but if you are having time issues maybe uncomment this.
#printf "${YELLOW}[Installing chrony and setting the ntpdate]${NC}\n"
#sudo apt-get install -y chrony
#sudo ntpdate ntp.ubuntu.com

printf "\n${YELLOW}[Checking for ROS repository]${NC}\n"
if ! [ -e /etc/apt/sources.list.d/ros-latest.list ]
    then
    printf "${BLUE}[Adding the ROS repository]${NC}\n"
    sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu ${version} main\" > /etc/apt/sources.list.d/ros-latest.list"
    printf "${BLUE}[Checking the ROS keys]${NC}\n"
    roskey=`apt-key list | grep -i "ROS builder"`
    if [ -z "$roskey" ]
        then
        printf "${BLUE}[Adding the ROS keys]${NC}\n"
        wget --quiet https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
        printf "${BLUE}^^ He says it is 'OK'.${NC}\n"
        printf "${YELLOW}[Update & upgrade the packages again with the new repository]${NC}\n"
        printf "${BLUE}silently . . .${NC}\n"
        sudo apt-get update -qq < /dev/null
        sudo apt-get upgrade -qq < /dev/null
    fi
else
    printf "${BLUE}Found existing ROS repository. No need to recreate.${NC}\n"
fi

# This should follow the official ROS install instructions closely.
# That is why there is a separate section for extra packages that I need for Arlo.
printf "\n${YELLOW}[Installing ROS:]${NC}\n"
sudo apt-get install -qy ros-indigo-desktop-full ros-indigo-rqt-* < /dev/null
printf "${YELLOW}[ROS installed!]${NC}\n"
printf "\n${YELLOW}[rosdep init and python-rosinstall]${NC}\n"
if ! [ -e /etc/ros/rosdep/sources.list.d/20-default.list ]
    then
    sudo sh -c "rosdep init"
fi
rosdep update
source /opt/ros/indigo/setup.bash
sudo apt-get install -qy python-rosinstall < /dev/null
# END Offical ROS Install section

printf "\n${YELLOW}[Installing additional Ubuntu and ROS Packages for Arlo]${NC}\n"
# For 8-CH USB Relay board:
# Reference: https://code.google.com/p/drcontrol/wiki/Install_RaspberryPi">https://code.google.com/p/drcontrol/wiki/Install_RaspberryPi
# python-ftdi,  python-pip and sudo pip install pylibftdi
# TEST:
#python -m pylibftdi.examples.list_devices
#Should return:
#FTDI:FT245R USB FIFO:A9026EI5
#If you have a USB Relay board attached via USB.
sudo apt-get install -qy ros-indigo-turtlebot ros-indigo-turtlebot-apps ros-indigo-turtlebot-interactions ros-indigo-turtlebot-simulator ros-indigo-kobuki-ftdi python-ftdi python-pip python-serial ros-indigo-openni-* ros-indigo-openni2-* ros-indigo-freenect-* ros-indigo-vision-opencv libopencv-dev python-opencv < /dev/null
# For 8-CH USB Relay board:
sudo pip install pylibftdi

if ! [ -d ~/catkin_ws/src ]
    then
    printf "\n${YELLOW}[Creating the catkin workspace and testing with catkin_make]${NC}\n"
    mkdir -p ~/catkin_ws/src
    cd ~/catkin_ws/src
    catkin_init_workspace
    cd ~/catkin_ws/
    catkin_make
    source ~/catkin_ws/devel/setup.bash
    rospack profile
fi

printf "\n${YELLOW}[Cloning or Updating git repositories]${NC}\n"
cd ~/catkin_ws/src
if ! [ -d ~/catkin_ws/src/hector_slam ]
    then
    git clone https://github.com/chrisl8/hector_slam.git
else
    cd ~/catkin_ws/src/hector_slam
    git pull
fi

if ! [ -d ~/catkin_ws/src/hector_navigation ]
    then
    git clone https://github.com/chrisl8/hector_navigation.git
else
    cd ~/catkin_ws/src/hector_navigation
    git pull
fi

if ! [ -d ~/catkin_ws/src/ArloBot ]
    then
    git clone https://github.com/chrisl8/ArloBot.git
else
    cd ~/catkin_ws/src/ArloBot
    git pull
fi

# Optionally:
if ! [ -d ~/catkin_ws/src/Metatron ]
    then
    git clone https://github.com/chrisl8/Metatron.git
else
    cd ~/catkin_ws/src/Metatron
    git pull
fi

# If you have an XV-11 "Neato" Scanner
if ! [ -d ~/catkin_ws/src/xv_11_laser_driver ]
    then
    git clone https://github.com/chrisl8/xv_11_laser_driver.git
else
    cd ~/catkin_ws/src/xv_11_laser_driver
    git pull
fi

# If you have the excellent ROS by Example book now is a good time to clone the code for following along in the book:
if ! [ -d ~/catkin_ws/src/rbx1 ]
    then
    git clone -b indigo-devel https://github.com/pirobot/rbx1.git
else
    cd ~/catkin_ws/src/rbx1
    git pull
fi

# If you want to use the USB Camera code from the ROS by Example book:
if ! [ -d ~/catkin_ws/src/usb_cam ]
    then
    git clone https://github.com/bosch-ros-pkg/usb_cam.git
else
    cd ~/catkin_ws/src/usb_cam
    git pull
fi

printf "\n${YELLOW}[(Re)Building ROS Source files.]${NC}\n"
cd ~/catkin_ws
catkin_make
source ~/catkin_ws/devel/setup.bash
rospack profile

printf "\n${YELLOW}[Setting the ROS environment in your .bashrc file]${NC}\n"
if ! (grep ROS_HOSTNAME ~/.bashrc>/dev/null)
    then
    sh -c "echo \"export ROS_HOSTNAME=`uname -n`.local\" >> ~/.bashrc"
fi
if ! (grep ROSLAUNCH_SSH_UNKNOWN ~/.bashrc>/dev/null)
    then
    sh -c "echo \"export ROSLAUNCH_SSH_UNKNOWN=1\" >> ~/.bashrc"
fi
if ! (grep catkin_ws ~/.bashrc>/dev/null)
    then
    sh -c "echo \"source ~/catkin_ws/devel/setup.bash\" >> ~/.bashrc"
fi

printf "\n${YELLOW}[Setting up the Metatron Package.]${NC}\n"
# Run Metatron Setup Script:
~/catkin_ws/src/Metatron/scripts/setup.sh

# Arlobot Specific settings:

if ! (id|grep dialout>/dev/null)
    then
    printf "\n${GREEN}Adding your user to the 'dialout' group.${NC}\n"
    sudo adduser ${USER} dialout > /dev/null
    printf "${RED}You may have to reboot before you can use the Propeller Board.${NC}\n"
fi

# We will use ~/.arlobot to store "private" data
# That is data that doesn't need to be part of
# the public github repo like user tokens,
# sounds, and room maps and per robot settings
if ! [ -d ${HOME}/.arlobot ]
    then
    mkdir ${HOME}/.arlobot
fi

ARLOHOME=${HOME}/.arlobot

if [ -e ${ARLOHOME}/arlobot.yaml ]
    then
    if ! (diff ${HOME}/catkin_ws/src/ArloBot/src/arlobot/arlobot_bringup/param/arlobot.yaml ${ARLOHOME}/arlobot.yaml)
        then
        printf "\n${GREEN}The arlobot.yaml file in the repository is different from the one${NC}\n"
        printf "${GREEN}in your local settings.${NC}\n"
        printf "${GREEN}This is expected, but just in case, please look over the differences,${NC}\n"
        printf "${GREEN}and see if you need to copy in any new settings, or overwrite the file completely:${NC}\n"
        diff ${HOME}/catkin_ws/src/ArloBot/src/arlobot/arlobot_bringup/param/arlobot.yaml ${ARLOHOME}/arlobot.yaml
        cp -i ${HOME}/catkin_ws/src/ArloBot/src/arlobot/arlobot_bringup/param/arlobot.yaml ${ARLOHOME}/
        printf "\n"
    fi
else
    printf "\n"
    cp ${HOME}/catkin_ws/src/ArloBot/src/arlobot/arlobot_bringup/param/arlobot.yaml ${ARLOHOME}/
    printf "${GREEN}A brand new ${RED}~/.arlobot/arlobot.yaml${GREEN} file has been created,${NC}\n"
    printf "${RED}please edit this file to customize according to your robot!\n${NC}\n"
fi

printf "\n${YELLOW}-----------------------------------${NC}\n"
printf "${YELLOW}ALL DONE! REBOOT AND START TESTING!${NC}\n"
printf "${GREEN}Look at README.md for testing ideas.${NC}\n"
printf "${GREEN}See here for your next step: ${BLUE}http://ekpyroticfrood.net/?p=165\n${NC}\n"
#!/bin/bash

vSavePath=$(grep -i "using path" /etc/systemd/system/arma_auto_save.service  | cut -d':' -f 2)

if [ $EUID != 0 -o $HOME == "/root" ];  # Exit if effective user is not root or the actual user is root (force user to run via  with his/her normal user)
then
  printf "\nPlease run this script as your normal user but using \n"
  printf "  Example: \"user001:\$  ./arma_auto_save.sh\"\n"
  exit 100
fi

while :
do

  if [ $1 -gt 0 ] &> /dev/null; # Output hidden since error raised if no option passed
  then
    printf "Accepted passed option $1 \n"
    vMainMenu=$1
  else
    printf "\n"
    printf "Current path: $vSavePath\n"
    printf "1: Find existing paths for saved games\n"
    printf "2: Set path for saved games\n"
    printf "3: Setup systemd service and path for auto-save\n"
    printf "4: Start/enable or stop/disable path service\n"
    printf "5: Load last saved game (will be copied to \"continue\" file):!EXIT CURRENT GAME FIRST!\n"
    printf "6: Load specified save (starting from "1" being last save)\n"
    printf "7: Remove systemd services (i.e., uninstall)\n"
    ###### "9": # Move discovered "save.fps" (for use by service only)
    printf "0: Exit\n"
    printf "\n"
    read vMainMenu
  fi

  case $vMainMenu in
  1 ) # 1: Find existing paths for saved games
    printf "Searching $HOME for saved games\n\n"
    find ~/ -name save.fps* -type f -print | grep ARMA | sed "s/\/save.fps.*//" | uniq
  ;;

  2 ) # 2: Set path for saved games
    printf "Enter the path \n"
    printf " (e.x., /home/user001/ARMA Cold War Assault/Users/User001/Saved/campaigns/1985)\n\n"
    read vSavePath
  ;;

  3 ) # 3: Setup systemd service and path for auto-save
    # Write systemd service file
    echo "[Unit]" > /etc/systemd/system/arma_auto_save.service
    echo "Description=Automatically refresh ARMA Cold War Assault saves (effecivly, unlimited saves, just have to rename desired save to "save.fps" and turn off this service" >> /etc/systemd/system/arma_auto_save.service
    echo "ConditionPathExists=\"$vSavePath/save.fps\"" >> /etc/systemd/system/arma_auto_save.service
    echo "" >> /etc/systemd/system/arma_auto_save.service
    echo "[Service]" >> /etc/systemd/system/arma_auto_save.service
    echo "Type=oneshot" >> /etc/systemd/system/arma_auto_save.service
    echo "RemainAfterExit=no" >> /etc/systemd/system/arma_auto_save.service
    echo "ExecStart=`pwd`/arma_auto_save.sh 9 \"$vSavePath\"" >> /etc/systemd/system/arma_auto_save.service  # Set script path to "present workind directory" and pass Option 9 + save path to this script
    echo "" >> /etc/systemd/system/arma_auto_save.service
    echo "[Install]" >> /etc/systemd/system/arma_auto_save.service
    echo "WantedBy=graphical.target" >> /etc/systemd/system/arma_auto_save.service
    echo "" >> /etc/systemd/system/arma_auto_save.service
    echo "#Using Path :$vSavePath" >> /etc/systemd/system/arma_auto_save.service

    # Write systemd path file
    echo "[Path]" > /etc/systemd/system/arma_auto_save.path
    echo "PathExists=$vSavePath/save.fps" >> /etc/systemd/system/arma_auto_save.path
    echo "" >> /etc/systemd/system/arma_auto_save.path
    echo "[Install]" >> /etc/systemd/system/arma_auto_save.path
    echo "WantedBy=graphical.target" >> /etc/systemd/system/arma_auto_save.path

     systemctl daemon-reload
    ;;

  4 ) # Start/enable or stop/disable path service
    # Check if path file exsit (back to loop if it doesn't)
    if [ ! -f /etc/systemd/system/arma_auto_save.path ];
    then
      printf "\nNo path file found...\n"
      printf "Please ues Option 3 to generate required systemd files.\n"
      continue
    fi

    # Check if path service is running (inquire about stopping/disabling)
     systemctl status arma_auto_save.path | grep "Active: active"
    if [ $? == 0 ];  # Will be always-true in testing mode
    then
      printf "Stop/disable path service? (Y/N)\n"
      read vResponse
      if [ $vResponse == "Y" ];
      then
        printf "Stopping service\n"  # "printf" required so there is something executable for "then"
         systemctl stop arma_auto_save.path
         systemctl disable arma_auto_save.path
      else
        printf "No action taken\n"
      fi
    # Otherwise, inquire about starting/enabling
    else
      printf "Start/enable path service? (Y/N)\n"
      read vResponse
      if [ $vResponse == "Y" ];
      then
        printf "Starting service\n"  # "printf" required so there is something executable for "then"
         systemctl start arma_auto_save.path
         systemctl enable arma_auto_save.path
      else
        printf "No action taken\n"
      fi
    fi
  ;;

  5 )  # Load last saved game
    # Check if service file exsit (back to loop if it doesn't)
    if [ ! -f /etc/systemd/system/arma_auto_save.service ];
    then
      printf "\nNo service file found...\n"
      printf "Please ues Option 3 to generate required systemd files.\n"
      continue
    fi
    printf "Copying last save to \"Contine\" file\n"
    printf "NOTE: You must exit your current game before runnings this command\n"
    printf "    Otherwise, your currnet game will overwrite it at exit...\n"
    cp -f "$vSavePath"/$(ls "$vSavePath" | sort -r | head -1) "$vSavePath"/continue.fps
  ;;

  6 )
  # Check if service file exsit (back to loop if it doesn't)
  if [ ! -f /etc/systemd/system/arma_auto_save.service ];
  then
    printf "\nNo service file found...\n"
    printf "Please ues Option 3 to generate required systemd files.\n"
    continue
  fi
  printf "Enter the number of the save you wish to load\n"
  printf "\"1\" being the most recent save, \"2\" being your second most recent save, etc\n"
  read vSaveNum
  if [ "$vSaveNum" -lt 1 -o "$vSaveNum" -gt 9999 ];
  then
    printf "Pleae try a value between 1 and 9999\n"
    continue
  fi
  printf "Copying the $vSaveNum newest save to \"Contine\" file\n"
  cp -f "$vSavePath"/$(ls "$vSavePath" | sort -r | head -$vSaveNum | tail -1) "$vSavePath"/continue.fps
  #find ~/ -name save.fps.* -type f -print | grep ARMA | sort -r | head -$vSaveNum | tail -1
  ;;

  7 )  # Remove systemd services
    printf "Are you sure you want to uninstall? (Y/N)"
    read vResponse
    if [ $vResponse == "Y" ];
    then
      printf "Stopping service (if running)\n"  # "printf" required so there is something executable for "then
       systemctl stop arma_auto_save.path
       systemctl disable arma_auto_save.path

       rm -f /etc/systemd/system/arma_auto_save.service
       rm -f /etc/systemd/system/arma_auto_save.paths

       systemctl daemon-reload
    else
      printf "No action taken\n"
    fi
  ;;

  9 ) # Move discovered "save.fps" (for use by service only)
    printf "Moving save file...\n"
    mv "$2/save.fps" "$2/save.fps.$(date +%s)"
    exit 0
  ;;

  0 | [eE]xit )
    exit
  ;;

  * )
  printf "Pleaes enter a valid option\n"

  esac

done

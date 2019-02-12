#!/bin/bash

while :
do

echo ""
grep "testing/" arma_auto_save.sh > /dev/null
if [ $? -gt 0 ];
then
  echo "Test mode: False"
  vTestStatus=0
else
  echo "Test mode: True"
  vTestStatus=1
fi

if [ -f testing/etc/systemd/system/arma_auto_save.service ] && [ -f testing/etc/systemd/system/arma_auto_save.path ];
then
  echo "\"Test\" Service installed"
else
  echo "\"Test\" Service not installed"
fi

echo ""
echo "1: Toogle Test Status"
echo "0: Exit"
echo " "
read vTestMenu

case $vTestMenu in
  1 )
  if [ $vTestStatus = 0 ];  # If test mode is disabled, enable test mode
  then
    sed -i 's/\/etc\/systemd/testing\/etc\/systemd/g' arma_auto_save.sh  #Set "/etc/systemd" path to test mode
    sed -i 's/\/usr\/bin/testing\/usr\/bin/g' arma_auto_save.sh
    sed -i 's/sudo\ systemctl/#sudo\ systemctl/g' arma_auto_save.sh  # Comment out systemctl commands
    sed -i 's/sudo\ echo/echo/g' arma_auto_save.sh  # Change sudo echo to echo (to write to testing dir without requring root priv)
    mkdir -p testing/etc/systemd/system
    mkdir -p testing/usr/bin
    mkdir -p testing/ARMA
    touch testing/ARMA/save.fps
    echo "Wait 3 seconds before coping (for a more unique timestamp)"
    sleep 3
    echo SAVE3 > testing/ARMA/save.fps  # echo text into file befor copying to as respective "save"
    cp testing/ARMA/save.fps testing/ARMA/save.fps.$(date +%s)
    echo "Wait 2 seconds before coping (for a more unique timestamp)"
    sleep 2
    echo SAVE2 > testing/ARMA/save.fps  # echo text into file befor copying to as respective "save"
    cp testing/ARMA/save.fps testing/ARMA/save.fps.$(date +%s)
    echo SAVE1 > testing/ARMA/save.fps  # echo text into orginal file last, making timestamp "most recent"
    touch testing/ARMA/continue.fps
    echo CONTINUE > testing/ARMA/continue.fps
    echo "Test mode enabled"
  fi

  if [ $vTestStatus = 1 ];  # If test mode is enabled, disable test mode
  then
    sed -i 's/testing\/etc\/systemd/\/etc\/systemd/g' arma_auto_save.sh  #Unset "/etc/systemd" path from test mode
    sed -i 's/testing\/usr\/bin/\/usr\/bin/g' arma_auto_save.sh  #Unset "/usr/bin" path from test mode
    sed -i 's/#sudo\ systemctl/sudo\ systemctl/g' arma_auto_save.sh  #Uncomment systemctl commands
    sed -i 's/echo/sudo\ echo/g' arma_auto_save.sh  # Change echo to sudo (to write to /etc/systemd/system)
    rm -rf testing
    echo "Test mode disabled"
  fi
  exit
  ;;

0 | [eE]xit )
  exit
  ;;

* )
  echo "Pleaes enter a valid option"
  echo " "
esac

done

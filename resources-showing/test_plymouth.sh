#!/bin/bash
# =======>2019-20<==========
# : >> nikonik@chita.ru << :
# ==========================
# Copyright © 2018-2020 Nikolay Andriychuk.
# called from menu item
# called by ./check_plymouuth.sh
# test_plymouth
#sudo update-alternatives --config default.plymouth &
#sudo update-initramfs -u &

##----------------------------------------------------------------------
if [ $EUID -ne 0 ]; then pkexec $0; exit; else :; fi

sudo plymouthd ; sudo plymouth --show-splash ; for ((I=0; I<10; I++)); do sleep 1 ; sudo plymouth --update=test$I ; done ; sudo plymouth --quit

exit 0
##----------------------------------------------------------------------



exit 0

#!/bin/bash
clear
echo
echo
echo "WARNING! "
echo
echo "1. Если ваш настольный ПК не имеет источника бесперебойного питания, ИЛИ,"
echo "2. ЕСЛИ ваша батарея для ноутбука почти мертва и не может поддерживать ноутбук" 
echo "    в течение более чем нескольких минут от зарядного устройства,"
echo "то имейте в виду, что ... "
echo "Ваша система может быть не загружаемой, если произойдет перебой в электропитании во время"
echo "    выполнение этого сценария установщика. Этот риск может быть небольшим. Но..."
echo "    Обновлены ли ваши резервные копии?"
echo
read -p "Нажмите CTRL+C, чтобы прервать ИЛИ нажмите ENTER, чтобы продолжить, если уверенность высока."
clear
echo
echo

currentsplash=`sed -n '2p' /usr/share/plymouth/themes/default.plymouth`;
if [ "$currentsplash" != "Name=ultimate_spacefun theme" ]; then
  clear
  echo
  echo
  echo "ultimate_spacefun это не текущий bootsplash.."
  echo "Чтобы сделать текущую загрузку и обновление, нажмите [ENTER]."
  read -p "Чтобы прервать, нажмите CTRL+C" 
  clear
  echo
  echo
  echo
  sudo ln -sfn /usr/share/plymouth/themes/ultimate_spacefun/ultimate_spacefun.plymouth /etc/alternatives/default.plymouth
fi

echo
sudo update-initramfs -u
echo
echo "Запуск 10-секундного теста ... Если анимация остановилась, двигайте мышь."
sudo plymouthd ; sudo plymouth --show-splash ; for ((I=0; I<10; I++)); do sleep 1 ; sudo plymouth --update=test$I ; done ; sudo plymouth --quit
clear
echo
echo
exit


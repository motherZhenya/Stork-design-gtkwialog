#!/bin/bash -x
# =======>2018-20<==========
# : >> nikonik@chita.ru << :
# ==========================
# Copyright © 2018-2020 Nikolay Andriychuk.
# Theme Ful applu...xfwm....

theme_n="${1}"
LC_NUMERIC=C
# Применить общие настройки по возможности в едином стиле

 # Gtk-2.0
  flag=0
  for x in /usr/share/themes/${theme_n} $HOME/.themes/${theme_n}; do
    if [[ -e "${x}/gtk-2.0" ]]; then
       xfconf-query -c xsettings -p /Net/ThemeName -s "${theme_n}"
      flag=1
    fi
  done

theme_name="$(xfconf-query -c xsettings -p /Net/ThemeName -v)"

 # Gtk-3.0
  flag=0
  for x in /usr/share/themes/${theme_name} $HOME/.themes/${theme_name}; do
    if [[ -e "${x}/gtk-3.0" ]]; then
       [[ -e "${HOME}/.config/gtk-3.0" ]] && find "${HOME}/.config/gtk-3.0/"  -delete
       [[ -e "${x}/gtk-3.0" ]] && cp -a ${x}/gtk-3.0 ${HOME}/.config
       [[ -e "${x}/gtk-3.0" ]] && echo "${theme_name:Default}" > ${HOME}/.config/gtk-3.0/themename
      flag=1
    fi
  done

 # xfwm4
  flag=0
  for x in /usr/share/themes/${theme_name} $HOME/.themes/${theme_name}; do
    if [[ -e "${x}/xfwm4" ]]; then
       xfconf-query -c xfwm4 -p /general/theme -s "${theme_name}"
      flag=1
    fi
  done

 # metacity-1
  flag=0
  for x in /usr/share/themes/${theme_name} $HOME/.themes/${theme_name}; do
    if [[ -e "${x}/metacity-1" ]]; then
       gsettings set org.gnome.metacity.theme type  metacity
       gsettings set org.gnome.metacity.theme name "${theme_name}"
      flag=1
    fi
  done

# icons
  flag=0
  for x in /usr/share/icons/${theme_name} $HOME/.icons/${theme_name}; do
    if [[ -e "${x}/index.theme" ]]; then
       grep -qo '^Directories=' "${x}/index.theme" && xfconf-query -c xsettings -p /Net/IconThemeName -s "${theme_name}"
      flag=1
    fi
  done

 # cursor
  flag=0
  for x in /usr/share/icons/${theme_name} $HOME/.icons/${theme_name}; do
    if [[ -e "${x}/cursors" ]]; then
       xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "${theme_name}"
      flag=1
    fi
  done

echo "${theme_name}"

# emerald
TEMAD=$(find "${HOME}/.emerald/themes/" -name "${theme_name}" 2> /dev/null)
[[ -z ${TEMAD} ]] && TEMAD=$(find "/usr/share/emerald/themes/" -name "${theme_name}" 2> /dev/null)

  if [[ -d "${TEMAD}" ]]; then
     find "${HOME}/.emerald/theme/"  -delete
     cp -a "${TEMAD}/". "${HOME}/.emerald/theme"
     echo "${theme_name:Default}" > "${HOME}/.emerald/theme/themename"
  fi

 # panels
#theme_name="$(xfconf-query -c xsettings -p /Net/ThemeName -v)"
bg_panel=$(find "$HOME/.themes/${theme_name}/gtk-2.0" "/usr/share/themes/${theme_name}/gtk-2.0" -type f -name "panel-bg.*g" 2> /dev/null | head -n1)
mime_type=$(file --mime-type -b ${bg_panel} 2> /dev/null)

Panel_num1=$(grep --only-matching --max-count=1 'panel-[0-1]' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml)
Panel_num2=$(grep --only-matching --max-count=2 'panel-[1-2]' ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml | tail -n 1)

  if [[ ! ${mime_type} == image/* ]]; then
      xfconf-query -c xfce4-panel -p /panels/${Panel_num1}/background-style -s  "0"
      xfconf-query -c xfce4-panel -p /panels/${Panel_num1}/size -s  "31"
      notify-send -i info Information " Panel background Invalid image, ${theme_name} "
  fi

  if [[ ${mime_type} == image/* ]]; then
      xfconf-query -c xfce4-panel -p /panels/${Panel_num1}/background-image -n -t string -s "${bg_panel}"
      xfconf-query -c xfce4-panel -p /panels/${Panel_num1}/background-style -s  "2"
      SIZEH="$(identify -format "%h" "${bg_panel}")"
      xfconf-query -c xfce4-panel -p /panels/${Panel_num1}/size  -n -t int -s "${SIZEH}"
  fi

  if [[ -n ${Panel_num2} && ${mime_type} == image/* ]]; then
      xfconf-query -c xfce4-panel -p /panels/${Panel_num2}/background-image -n -t string -s "${bg_panel}"
      xfconf-query -c xfce4-panel -p /panels/${Panel_num2}/background-style -s "2"
      xfconf-query -c xfce4-panel -p /panels/${Panel_num2}/size  -n -t int -s "${SIZEH}"
      else
      xfconf-query -c xfce4-panel -p /panels/${Panel_num2}/background-style -s "0"
  fi

 # bacground
#monitor_wspace=$(xfconf-query -c xfce4-desktop -l | grep -w workspace0/last-image | head -n1 | sed 's|0/last-image||')
monitor_wspace=$(xfconf-query -c xfce4-desktop  -lv | awk -F '0/l' '/0\/last/{print $1}' | grep -w workspace)
DIRPICTURE=$(xdg-user-dir PICTURES)

set-backdrop-property() {
   xfconf-query --channel xfce4-desktop --property "$@" 2> /dev/null
  [[ $(echo "$@" | grep -o 'workspace0' | awk '{print $1}') == 'workspace0' ]] && xfconf-query --channel xfce4-desktop --property /backdrop/single-workspace-mode --set true  2> /dev/null
  [[ $(echo "$@" | grep -o 'workspace2' | awk '{print $1}') == 'workspace2' ]] && xfconf-query --channel xfce4-desktop --property /backdrop/single-workspace-mode --set false 2> /dev/null
}

workspace=$(xfconf-query --channel xfwm4 --property /general/workspace_count)
count=0
  until [[ $count == $workspace ]]; do
        BIMAGE=$(find /usr/share/backgrounds/ /usr/share/xfce4/backdrops/ ${DIRPICTURE}/ -iname "*${theme_name}${count}*" -a -name "*g" | sort | head -n 1) 2> /dev/null
        [[ -n "$BIMAGE" ]] && BIGEXT=$(echo "$BIMAGE" | grep "$count" | head -n 1) && set-backdrop-property "$monitor_wspace$count"/last-image -s "${BIGEXT}"
        count=$(( $count + 1 ))
  done

      sleep 0.4
## Replace the default Xfce panel
  if [[ $(pidof xfce4-panel) ]]; then
      killall -SIGUSR1 xfce4-panel
      else
      xfce4-panel &
  fi

      until p=$(pidof xfce4-panel)
do
      sleep 0.2
done


      sleep 0.3
      xfsettingsd --replace &
      sleep 1
      xfdesktop    --reload &
      sleep 1


exit 0



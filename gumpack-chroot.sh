#!/usr/bin/env bash
main() {
  echo "Hiya!
  [continue]"
  read gpksetup_chrmn
  case "$gpksetup_chrmn" in
    continue)
      step_six
    ;;
    *)
      echo "Not valid input"
      main
  ;;
  esac
}

step_six() {
  
  clear
  echo "Choose a region"
  read gpksetup_region
  case "$gpksetup_region" in
    *)
      echo $gpksetup_region" has been set as region"
  esac
  echo "Choose a city"
  read gpksetup_city
  case "$gpksetup_city" in
    *)
      echo $gpksetup_city" has been set as city"
  esac
  ln -sf /usr/share/zoneinfo/$gpksetup_region/$gpksetup_city /etc/localtime || step_six
  hwclocl --systohc
  step_seven
}

step_seven() {
  echo "Uncomment the locale 'en_US.UTF-8 UTF-8' and other needed locales
  [ok]"
  read gpksetup_chrlocale
  case "$gpksetup_chrlocale" in
    ok)
      nano /etc/locale.gen
    ;;
  esac
  locale-gen
  touch /etc/locale.conf
  echo "Choose a locale."
  read gpksetup_chrlocale2
  case "$gpksetup_chrlocale2" in
    *)
      echo $gpksetup_chrlocale2 >> /etc/locale.conf
    ;;
  esac
  echo "Choose the keyboard layout you chose at the beginning of the setup."
  read gpksetup_chrlocale3
  case "$gpksetup_chrlocale3" in
    *)
      echo $gpksetup_chrlocale3 >> /etc/vconsole.conf
    ;;
  esac
  step_eight
}

step_eight() {
  clear
  echo "Choose a hostname."
  read gpksetup_chrhost
  case "$gpksetup_chrhost" in
    *)
      echo $gpksetup_chrhost >> /etc/vconsole.conf
    ;;
  esac
  step_nine
}

step_nine() {
  mkinitcpio -P
  /bin/passwd
  voithos
}

voithos() {
  git clone https://aur.archlinux.org/grub-git.git
  cd ./grub-git/
  /usr/bin/makepkg -sri
  exit
}

main

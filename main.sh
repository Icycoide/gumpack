#!/usr/bin/env bash
main() {
  clear
  echo "
  /\
  \ \ GUMPACK
   \ \  INSTALLER
    \/ 0.1
  "
  echo "Welcome to Gumpack installer.
  [continue] [exit] [shutdown] [reboot]
  Type any of those options to continue."
  read gpksetup_start
  case "$gpksetup_start" in
    continue)
      step_one
    ;;
    exit)
      exit
    ;;
    *) # default
      main
    ;;
  esac
}

step_one() {
  clear
  echo "Listing available keyboard layouts..."
  ls /usr/share/kbd/keymaps/**/*.map.gz
  echo "Set a keyboard layout (for example: de-latin1)"
  read gpksetup_kblayout
  loadkeys $gpksetup_kblayout || step_one
  step_two
}

step_two() {
  clear
  echo "Verifying the boot mode..."
  echo "If there are no errors, you are currently running in UEFI Mode"
  echo "If an error shows up, you're currently in BOIS (or CSM) mode."
  echo "If the system did not boot in the mode you desired, refer to your motherboard's manual."
  ls /sys/firmware/efi/efivars
  step_three
}

step_three() {
    clear
    echo "Connect to the internet"
    echo "Checking if Network interface is listed and enabled..."
    ip link
    sleep 7
    clear
    step_three_network() {
      clear
      echo "How would you like to connect?"
      echo "[ethernet] [wi-fi] [mbm (Mobile Broadband Modem)]"
      read gpksetup_intcon
      case "$gpksetup_intcon" in
        ethernet)
          echo "Plug in the Ethernet cable."
          echo "[continue] [back]"
          read gpksetup_intcon_eth
          case "$gpksetup_intcon_eth" in
            continue)
              step_four
            ;;
            back)
              step_three_network
            ;;
            *) 
              echo "Unknown command"
              step_three_network
            ;;
          esac
        ;;
        wi-fi)
          nmtui || iwctl
        ;;
        mbm)
          echo "For now, you'll have to do this step after the install
          since we haven't implemented this in the Gumpack Installer 0.1 yet.
          Newer updates of Arctine might include this feature."
        ;;
        *)
          step_three_network
      esac
    }
    timedatectl set-ntp true
    pacman -Sy
    pacman -Syu nano
}

step_four() {
  clear
  echo "Listing devices..."
  fdisk -l
  echo -e "Please specify the disk you would like to partition.
  \033[1mFor example, /dev/sda, /dev/sdb etc.\033[0m
  Results ending in rom, loop or airoot may be ignored.

The following partitions are required for a chosen device:

    One partition for the root directory /.
    For booting in UEFI mode: an EFI system partition.

If you want to create any stacked block devices for LVM, system encryption or RAID, do it now.
Read the installation guide on the Arch Wiki and go to the 'Partition the disks' part so you may
have an idea of how to partition your disk."
  read gpksetup_diskpart
  case "$gpksetup_diskpart" in
    *)
      fdisk $gpksetup_diskpart || parted $gpksetup_diskpart
    ;;
  esac
  step_four_filesystem() {
  echo "Set a filesystem now. (for example 'ext4')"
  read gpksetup_filesys
  case "$gpksetup_filesys" in
    *)
      echo "You have set "$gpksetup_filesys" as your file system!"
    ;;
  esac
  }
  echo "Enter the root partition you chose
  Or, Type 'EXIT' to go back."
  read gpksetup_part_root
  case "$gpksetup_part_root" in
    EXIT)
      step_four_filesystem
    ;;
    *)
      mkfs.$gpksetup_filesys $gpksetup_part_root
    ;;
  esac

  echo "Now enter the partition you're going to use as swap.
  Alternatively, Type 'NULL' to skip this, incase you haven't
  made a partition for swap."
  read gpksetup_part_swap
  case "$gpksetup_part_swap" in
    NULL)
      echo "Skipped."
      sleep 7
    ;;
    *)
      mkswap $gpksetup_part_swap
    ;;
  esac

  clear
  echo -e "\e[1;41mWarning: 
  Only format the EFI system partition if you created it during the partitioning step. 
  If there already was an EFI system partition on disk beforehand, 
  reformatting it can destroy the boot loaders of other installed operating systems.
  type 'SKIP' if you would not like to format."
  echo "If you created an EFI partition, enter the partition below."
  read gpksetup_part_efi
  case "$gpksetup_part_efi" in
    SKIP)
      step_five
    ;;
    *)
      mkfs.fat -F 32 $gpksetup_part_efi
    ;;
  esac
}

step_five() {
  mount $gpksetup_part_root /mnt
  mount $gpksetup_part_efi /mnt/boot
  swapon $gpksetup_part_swap
  pacstrap /mnt base linux linux-firmware
  genfstab -U mnt
  sudo cp /bin/gumpack-chroot $gpksetup_diskpart
  echo "Execute the 'git clone https://github.com/Icycoide/gumpack' command, and execute the gumpack-chroot.sh shell script in it."
  arch-chroot /mnt
}


main

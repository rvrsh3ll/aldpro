#!/usr/bin/env bash
# Очищаем экран
clear
# Подгружаем переменнные
#source <(curl -s http://repo.ald.minfin.ru/repo/sos/foo)
# или указываем вручную
#------------------------------------------#
dc_name="dc01"
ald_name="ald.minfin.ru"
arm_name=$(cat /etc/hostname | awk -F "." '{print $1}')
repo_proto="https"
repo_name="dl.astralinux.ru"
#------------------------------------------#
dc_ver="1.7.3"
dc_build="1.7.3.7"
dc_kernel="5.15.0-33-generic"
#------------------------------------------#
arm_ver=$(cat /etc/astra_version)
arm_build=$(cat /etc/astra/build_version)
arm_kernel=$(uname -r)
#------------------------------------------#
dc_user="admin"
#dc_pass="Donald"
#set_repo="true"
ald_pkg="1.4.1-5"
pakets="fly-notifications remmina freerdp2-x11"
#------------------------------------------#
# Выполняем проверку прав суперпользователя
if [ "$USER" != "root" ]; then
    whiptail --title "Проверка прав sudo" --msgbox "Для выполнения скрипта нужны права sudo, запустите скрипт с правами суперпользователя" 10 60
    #echo "Для выполнения скрипта нужны права sudo, запустите скрипт с правами суперпользователя"
#else
    exit 1
fi
####################################################################
#                                                                  #
#     Проверка членства в домене                                   #
#                                                                  #
####################################################################
#
#if [ -z "$var" ]; then echo "var is blank"; else echo "var is set to '$var'"; fi
ald_info=$(astra-freeipa-client -i)
#ald_domain=$(astra-freeipa-client -i | awk '{print $NF}')
ald_domain=$(astra-freeipa-client -i | awk '{print $6}')
#ald_server=$(astra-freeipa-client | grep 'server' | awk '{print $3}')
#ald_client=$(astra-freeipa-client)
####################################################################
if [ -n "$ald_domain" ]; then
####################################################################
    whiptail --title "Проверка членства в домене" --msgbox "\n$ald_info" 10 60
    #exit 1
####################################################################
#                                                                  #
#     Меню настроек домена                                         #
#                                                                  #
####################################################################
    OPTION=$(whiptail --title "Дополнительные настройки" --menu "Выберите дальнейшие действия" 15 60 6 \
    "1" "Вывести из домена" \
    "2" "Включить обновление IP адреса" \
    "3" "Выключить групповые политик от MS AD" \
    "4" "Проверить настройки UserGate" \
    "5" "Добавить сетевую папку" \
    "6" "Переименновать компьютер" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    # "1" "Вывести из домена" \
        if [ $OPTION == 1 ]; then
            echo "Вы выбрали:" "Вывести из домена"
            sudo astra-freeipa-client -U -y > /tmp/ald_in.log 2>&1
            if [ $? -eq 0 ]
                then
                echo "Successfully"
                #exit 0
            else
                echo "Not Successfully" >&2
                exit 1
            fi
            echo "Выведен из домена"
            hostnamectl set-hostname $arm_name
            echo "Имя компьютера сброшено!"
            sleep 10
            sudo reboot
    # "2" "Вывести из домена" \
        elif [ $OPTION == 2 ]; then
            echo -e "Вы выбрали: $OPTION \n Функционал в разработке.\n"
    # "3" "Вывести из домена" \
        elif [ $OPTION == 3 ]; then
            echo -e "Вы выбрали: $OPTION \n Функционал в разработке.\n"
    # "4" "Вывести из домена" \
        elif [ $OPTION == 4 ]; then
            echo -e "Вы выбрали: $OPTION \n Функционал в разработке.\n"
    # "5" "Вывести из домена" \
        elif [ $OPTION == 5 ]; then
            echo -e "Вы выбрали: $OPTION \n Функционал в разработке.\n"
    # "6" "Вывести из домена" \
        elif [ $OPTION == 6 ]; then
            echo -e "Вы выбрали: $OPTION \n Функционал в разработке.\n"
        fi
    #echo "Вы выбрали:" $OPTION
    else
        echo -e "Вы нажали отмену.\n"
        #whiptail --title "Компьютер в домене" --msgbox "Выбрали отмену, запустите повторно когда будет нужно." 10 60
    fi
    exit 1
fi

echo -e "\nОтлично - Компьютер не в домене - продолжаем!\n"

####################################################################
#                                                                  #
#     Проверка ОС и Ядра                                           #
#                                                                  #
####################################################################

#------------------------------------------#
#echo -e "Версия сборки: $arm_ver\Ядро: $arm_kernel"
#------------------------------------------#
# Проверка версии ОС
if [[ "$arm_ver" > "$dc_ver" ]]; then
    #echo -e "${arm_ver}  больше, чем ${dc_ver}\n"
    echo -e "\nУстановка прервана по причине:"
    echo -e "Версия OS ${arm_ver} (Build: $arm_build), необходимо переустановить на версию ${dc_ver} (Build: $dc_build)\n"
    exit 1
elif [[ "$arm_ver" < "$dc_ver" ]]; then
    #echo -e "${arm_ver}  меньше, чем ${dc_ver}\n"
    echo -e "\nУстановка прервана по причине:"
    echo -e "Версия OS ${arm_ver} (Build: $arm_build), необходимо обновление до версии ${dc_ver} (Build: $dc_build)\n"
    exit 1
#else
#    echo "Строки равны"
fi
echo "Версии ОС одинаковые! Продолжаем!"

# Проверка версии обвноления ОС
if [[ "$arm_build" > "$dc_build" ]]; then
    #echo -e "${arm_build}  больше, чем ${dc_build}\n"
    echo -e "\nУстановка прервана по причине:"
    echo -e "Версия OS ${arm_ver} (Build: $arm_build), необходимо переустановить на версию ${dc_ver} (Build: $dc_build)\n"
    exit 1
elif [[ "$arm_build" < "$dc_build" ]]; then
    #echo -e "${arm_build}  меньше, чем ${dc_build}\n"
    echo -e "\nУстановка прервана по причине:"
    echo -e "Версия OS ${arm_ver} (Build: $arm_build), необходимо обновление до версии ${dc_ver} (Build: $dc_build)\n"
    exit 1
#else
#    echo "Строки равны"
fi
echo "Версии обновлений одинаковые! Продолжаем!"


# Проверка версии ядра ОС
if [[ "$arm_kernel" != "$dc_kernel" ]]; then
    echo -e "\nУстановка прервана по причине:"
    echo -e "Версия ядра ${arm_kernel}, требуется версия: ${dc_kernel}\n"
    exit 1
fi
echo -e "Версии ядра одинаковые! Продолжаем!\n"

####################################################################
#                                                                  #
#     Ввод переменных                                              #
#                                                                  #
####################################################################
#name=$(gdialog --title "Ввод данных" --inputbox "Введите ваше имя:" 50 60 Дима 2>&1)
#    echo "Ваше имя: $name"
#name2=$(whiptail --title "Тестируем поле ввода" --inputbox "Какое имя?" 10 60 repo 3>&1 1>&2 2>&3)
#    echo "Вы выбрали:" $name2".ald.minfin.ru"


# Введите имя АРМ
#read -e -p "Введите имя АРМ: " -i "$arm_name" arm_name
arm_name=$(whiptail --title "Установка клиента ALDPro" --inputbox "\nВведите имя АРМ: " 10 60 $arm_name 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    echo "  "
    else
    echo "Вы выбрали отмену."
    exit 1
    fi
# Введите имя домена
#read -e -p "Введите имя домена: " -i "$ald_name"  ald_name
ald_name=$(whiptail --title "Установка клиента ALDPro" --inputbox "\nВведите имя домена: " 10 60 $ald_name 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    echo "  "
    else
    echo "Вы выбрали отмену."
    exit 1
    fi
# Введите имя контроллера домена
#read -e -p "Введите имя контроллера домена: " -i "$dc_name"  dc_name
dc_name=$(whiptail --title "Установка клиента ALDPro" --inputbox "\nВведите имя контроллера домена: " 10 60 $dc_name 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    echo "  "
    else
    echo "Вы выбрали отмену."
    exit 1
    fi
# Введите имя репозитория
#read -e -p "Введите имя репозитория " -i "$repo_name"  repo_name
repo_name=$(whiptail --title "Установка клиента ALDPro" --inputbox "\nВведите имя репозитория: " 10 60 $repo_name 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    echo "  "
    else
    echo "Вы выбрали отмену."
    exit 1
    fi
# Выберете протокол репозитория
#read -e -p "Введите протокол репозитория " -i "$repo_proto"  repo_proto
OPTION=$(whiptail --title "Установка клиента ALDPro" --menu "\nВыберите протокол репозитория: " 10 60 3 \
    "1" "https" \
    "2" "http" \
    "3" "ftp" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    #echo "Вы выбрали:" $OPTION
    # "1" "https" \
        if [ $OPTION == 1 ]; then
            #echo "https"
            repo_proto="https"
    # "2" "http" \
        elif [ $OPTION == 2 ]; then
            #echo "https"
            repo_proto="http"
    # "3" "ftp" \
        elif [ $OPTION == 3 ]; then
            #echo "ftp"
            repo_proto="ftp"
        fi
    else
        echo "Вы нажали отмену."
        exit 1
    fi
# Введите имя пользователя
#read -e -p "Введите имя пользователя: " -i "$dc_user"  dc_user
dc_user=$(whiptail --title "Установка клиента ALDPro" --inputbox "\nВведите имя пользователя: " 10 60 $dc_user 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
    echo "  "
    else
    echo "Вы выбрали отмену."
    exit 1
    fi
# Введите пароль пользователя
#read -sp "Введите пароль пользователя: " dc_pass
while true; do
  #read -s -p "Password: " dc_pass
  dc_pass=$(whiptail --title "Установка клиента ALDPro" --passwordbox "\nВведите пароль пользователя: " 10 60 3>&1 1>&2 2>&3)
  echo
  #read -s -p "Password (again): " dc_pass2
  dc_pass2=$(whiptail --title "Установка клиента ALDPro" --passwordbox "\nВведите пароль пользователя повторно: " 10 60 3>&1 1>&2 2>&3)
  echo
  [ "$dc_pass" = "$dc_pass2" ] && [ -n "$dc_pass" ] && break
  #echo "Пароли не совпадают! Попробуйте еще раз!"
  whiptail --title "Установка клиента ALDPro" --msgbox "Пароли не совпадают! Попробуйте еще раз! \n\nНажмите Ok для продолжения." 10 60
done

####################################################################
#                                                                  #
#     Вывод переменных                                             #
#                                                                  #
####################################################################
#suffix=".*";
#string=${dc_name%$suffix}; #Remove suffix
#echo $string; #Prints "hello_kitty"
#$ [[ "$dc_name" =~ ^[A-Za-z0-9]*$ ]] ; echo $?
#echo $dc_name | awk '/[[:alnum:]]/{print $0}'

echo -e "\n"
echo -e "\nИмя домена: $ald_name"
echo -e "Имя контроллера домена: $dc_name"
echo -e "Имя контроллера fqdn $dc_name.$ald_name"
echo -e "Имя сервера репозитория: $repo_name"
echo -e "Имя пользователя домена: $dc_user"
#echo -e "Пароль пользователя домена: $dc_pass\n"

####################################################################
#                                                                  #
#    Проверка доступности ресурсов                                 #
#                                                                  #
####################################################################
if ping -c 4 -W 1 $dc_name.$ald_name &> /dev/null; then
echo “Success”
echo "$dc_name.$ald_name - доступен"
else
echo “Проверте сетевые настройки: $?”
echo "Недоступен $dc_name.$ald_name"
exit 1
fi

if ping -c 4 -W 1 $dc_name &> /dev/null; then
echo “Success”
echo "$dc_name - доступен"
else
echo “Проверте сетевые настройки: $?”
echo "Недоступен $dc_name"
exit 1
fi

if [ "$repo_name" == "dl.astralinux.ru" ]; then
    echo "пропускаем проверку для родного репозитория"
else
    if ping -c 4 -W 1 $repo_name &> /dev/null; then
        echo “Success”
        echo "$repo_name - доступен"
    else
        echo “Проверте сетевые настройки: $?”
        echo "Недоступен $repo_name"
        exit 1
    fi
fi


#if ping -c 4 -W 1 $repo_name &> /dev/null; then
#echo “Success”
#echo "$repo_name - доступен"
#else
#echo “Проверте сетевые настройки: $?”
#echo "Недоступен $repo_name"
#exit 1
#fi

####################################################################
#                                                                  #
#    Установка                                                     #
#                                                                  #
####################################################################
echo -e "Продолжаем \n"

ald_arm_pkg="aldpro-client"
#aldpro_pkg_ver=$(dpkg -l $ald_arm_pkg | awk '$2=="aldpro-client" { print $3 }')
#ald_arm_pkg_ver=$(dpkg -l $ald_arm_pkg | grep -i $ald_arm_pkg | awk '{print $3}')
dkpg_chk=$(dpkg -l | grep ^ii | grep "$ald_arm_pkg " | awk '{ print $3}')

  if [ -n "$dkpg_chk" ]; #если строка не пуста,
        then
            echo пакет $ald_arm_pkg" версии $dkpg_chk установлен!" #то пакет установлен,

            if [ "$dkpg_chk" == "$ald_pkg" ]; then
                echo установлена нужная версия не будем мучить репозитории!
                set_repo=false
                #exit 1
            fi

            if [ "$dkpg_chk" \> "$ald_pkg" ]; then
                echo установлена верся выше чем $ald_pkg
                echo Выполните переустановку ОС!
                exit 1
            fi

            if [ "$dkpg_chk" \< "$ald_pkg" ]; then
                echo установлена верся ниже чем $ald_pkg
                echo Выполним обновление!
                #exit 1
            fi
        else
            echo $ald_arm_pkg" не установлен!" #коли пуста, то не установлен. Логично?
    fi

echo -e "Продолжаем установку! \n"
#set_repo=true

sleep 12

####################################################################
#                                                                  #
#    Репозитории                                                   #
#                                                                  #
####################################################################

if $set_repo ; then
    echo 'set_repo - true'

#repo_name2=(sed 's/http:\/\//https:\/\//g')
# sources.list
    sed -i 's/^deb/#deb/g' /etc/apt/sources.list
    sed -i 's/http:\/\//https:\/\//g' /etc/apt/sources.list
    sed -i 's/ftp:\/\//https:\/\//g' /etc/apt/sources.list
    sed -i 's/download.astralinux/dl.astralinux/g' /etc/apt/sources.list
    echo -e "#deb https://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.3/repository-base 1.7_x86-64 main non-free contrib" | tee -a /etc/apt/sources.list > /dev/null
    echo -e "#deb https://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.3/repository-extended 1.7_x86-64 main contrib non-free" | tee -a /etc/apt/sources.list >/dev/null
    sort -u /etc/apt/sources.list -o /etc/apt/sources.list
    sed -i "s/deb https:\/\/dl.astralinux.ru/deb $repo_proto:\/\/$repo_name/g" /etc/apt/sources.list
    sed -i "/$repo_proto:\/\/$repo_name\/astra\/frozen\/1.7_x86-64\/1.7.3\/repository-base/s/^#\+//" /etc/apt/sources.list # убираем комент в строке по найденому слову
    sed -i "/$repo_proto:\/\/$repo_name\/astra\/frozen\/1.7_x86-64\/1.7.3\/repository-extended/s/^#\+//" /etc/apt/sources.list # убираем комент в строке по найденому слову
    #sed -i "s/deb https:\/\/dl.astralinux.ru/deb $repo_proto:\/\/$repo_name/g" /etc/apt/sources.list
    echo -e "\nРепозитории astra обновлены"
# sources.list.d
    #find /etc/apt/sources.list.d/ -type f -exec sed -i 's/^deb/#deb/g' {} +
    find /etc/apt/sources.list.d/ -type f -exec sed -i 's/^deb/#deb/g' {} \;
    find /etc/apt/sources.list.d/ -type f -exec sed -i 's/http:\/\//https:\/\//g' {} \;
    find /etc/apt/sources.list.d/ -type f -exec sed -i 's/ftp:\/\//https:\/\//g' {} \;
    find /etc/apt/sources.list.d/ -type f -exec sed -i 's/download.astralinux/dl.astralinux/g' {} \;
    echo -e "#deb https://dl.astralinux.ru/aldpro/stable/repository-main/ 1.4.1 main" | sudo tee -a /etc/apt/sources.list.d/aldpro.list >/dev/null
    echo -e "#deb https://dl.astralinux.ru/aldpro/stable/repository-extended/ generic main" | sudo tee -a /etc/apt/sources.list.d/aldpro.list >/dev/null
    find /etc/apt/sources.list.d/ -type f -exec sort -u {} -o {} \;
    find /etc/apt/sources.list.d/ -type f -exec sed -i "s/deb https:\/\/dl.astralinux.ru/deb $repo_proto:\/\/$repo_name/g" {} \;
    sed -i "/$repo_proto:\/\/$repo_name\/aldpro\/stable\/repository-main\/ 1.4.1/s/^#\+//" /etc/apt/sources.list.d/aldpro.list # убираем комент в строке по найденому слову
    sed -i "/$repo_proto:\/\/$repo_name\/aldpro\/stable\/repository-extended\/ generic/s/^#\+//" /etc/apt/sources.list.d/aldpro.list # убираем комент в строке по найденому слову
    #find /etc/apt/sources.list.d/ -type f -exec sed -i "s/deb https:\/\/dl.astralinux.ru/deb $repo_proto:\/\/$repo_name/g" {} \;
    echo -e "\nРепозитории ald обновлены"
    #sort -u test.txt | tee test.txt >/dev/null
    #sort -u test.txt | tee test.txt
    #grep -rl 'frozen' ./test/test/sources.list | xargs sed -i '/repository-base/s/^#\+//'
    #find ./test/ -type f -exec grep -rl 'frozen' ./test/test/sources.list | xargs sed -i '/repository-base/s/^#\+//'
# preferences.d
cat > /etc/apt/preferences.d/aldpro <<EOF
Package: *
Pin: release n=generic
Pin-Priority: 900
EOF

echo -e "\nРепозитории обновлены"
else
    echo 'set_repo - false'
fi


####################################################################
#                                                                  #
#    Создание пользователя                                         #
#                                                                  #
####################################################################
echo -e "Устанавливаем пакеты\n"

# Создаем своего пользователя
admr="admroot"
# Самый точный поиск по пользователю
#grep «^test1:» /etc/passwd
#grep $admr /etc/passwd >/dev/null
#if [[ -n $? ]] ; then
getent passwd $admr > /dev/null
if [[ $? -ne 0 ]] ; then
#if [ $? -eq 0 ]; then
    echo 'Пользователь не найден!'
    #adduser
    sudo useradd -m -p pa0hdn0X/T8WE $admr
    sudo gpasswd -a $admr astra-admin
    mkdir /home/$admr/.ssh
    touch /home/$admr/.ssh/authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvxsnex6iznCLNJCtkGXLlNYudJfQG14XTqV+8RUxuPl7HSU8VmEw3OYEvynAq1i6q+a6XiLbkdRlgmzrXqJOyRFTw/U/RL7F3AlNV3sOv1+4fg2cvU6FwEBdT0fn6vC8EcXPP+FRC/ZfPt2o53/peix394ASfzADrmLNYD3PWfOqG7tkh02N+3cz/O4XjySq3NJWLOK2PyW2XlXk4PTR+0YZXD9dhWMcP10iOl1v3y9CyRywhRwaiaxE1c8KLIhHVpjd5aFIYaD3cJultKR7UxRgS8/QCnJlM4CwxGG/bpgFJTSZTDx/BPIg0CVSQJJnk3r0j3bB/HP4dkrNV/gSV rsa-key-20230504" >> /home/$admr/.ssh/authorized_keys
    chmod 600 /home/$admr/.ssh/authorized_keys
    chown -R $admr:$admr /home/$admr/.ssh
    echo 'Пользователь добавлен!'
    #userdel -r $admr
    #sudo deluser --remove-home $admr
    #useradd -G astra-admin -p pa0hdn0X/T8WE $admr
    #useradd -m -p $(perl -e 'print crypt($ARGV[0], "password")' 'Donald-1919') $admr
fi

####################################################################
#                                                                  #
#    Обновление                                                    #
#                                                                  #
####################################################################

echo 'Все готово к установке!'
sudo apt update && sudo apt dist-upgrade -y > /tmp/apt_update.log 2>&1
{
    for ((i = 0 ; i <= 100 ; i+=20)); do
        sleep 1
        echo $i
    done
} | whiptail --gauge "Please wait while installing" 6 60 0
if [ $? -eq 0 ]
then
  echo "Обновление завершено"
  # exit 0
else
  echo "Ошибка установки обновлений" >&2
  exit 1
fi


####################################################################
#                                                                  #
#    Установка пакетов IPA                                         #
#                                                                  #
####################################################################

if $set_repo ; then
    #echo 'set_repo - true'
    echo 'Установка клиента ALDPro'
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y aldpro-client > /tmp/adl_install.log 2>&1
    echo 'Установка клиента ALDPro'
    if [ $? -eq 0 ]
    then
        echo "Установка завершена"
        #exit 0
    else
        echo "Ошибка установки" >&2
        exit 1
    fi

else
    echo 'set_repo - false'
fi

####################################################################
#                                                                  #
#    Ввод в домен                                                  #
#                                                                  #
####################################################################

echo 'Ожидайте ввода в домен ...'
sudo /opt/rbta/aldpro/client/bin/aldpro-client-installer -c $ald_name -u $dc_user -p $dc_pass -d $arm_name -i -f > /tmp/ald_in.log 2>&1

ald_in=$(cat /tmp/ald_in.log | grep failed:)
if [ -n $ald_in ]
then
  echo "Введено в домен"
  #exit 0
else
  echo "Ошибка ввода в домен" >&2
  echo "$ald_in"
  exit 1
fi

####################################################################
#                                                                  #
#    Сетевые папки                                                 #
#                                                                  #
####################################################################
if [ ! -e "/etc/xdg/rusbitech/fly-fm-vfs.conf" ]; then
    echo 'Настраваем сетевые папки'
    sudo kwriteconfig5 --file /etc/xdg/rusbitech/fly-fm-vfs.conf --group "Network Place 1" --key Name L
    sudo kwriteconfig5 --file /etc/xdg/rusbitech/fly-fm-vfs.conf --group "Network Place 1" --key Url smb://netdisk.main.minfin.ru/files
    sudo kwriteconfig5 --file /etc/xdg/rusbitech/fly-fm-vfs.conf --group "Network Place 2" --key Name U
    sudo kwriteconfig5 --file /etc/xdg/rusbitech/fly-fm-vfs.conf --group "Network Place 2" --key Url smb://netdisk.main.minfin.ru/FilesNew
    sudo kwriteconfig5 --file /etc/xdg/rusbitech/fly-fm-vfs.conf --group "Network Place 3" --key Name X
    sudo kwriteconfig5 --file /etc/xdg/rusbitech/fly-fm-vfs.conf --group "Network Place 3" --key Url smb://netdisk.main.minfin.ru/Soft
    sudo chmod 644 /etc/xdg/rusbitech/fly-fm-vfs.conf
    killall fly-vfs-service fly-fops-service fly-open-service fly-fm-service
    echo 'Сетевые папки настроены'
fi
####################################################################
#                                                                  #
#    Авторизация на прокси                                         #
#                                                                  #
####################################################################
#echo "ssh-rsa" >> /etc/X11/Xsession.d/98-UGate-proxy
if [ ! -e "/etc/X11/Xsession.d/98-fly-usergate-login" ]; then
echo "Настриваем авторизацию UserGate"
cat > /etc/X11/Xsession.d/98-fly-usergate-login <<EOF
#! /bin/bash
/usr/bin/curl --proxy-negotiate -u:user -x uproxy.main.minfin.ru:8090 http://cbr.ru> /dev/null
EOF
chmod +x /etc/X11/Xsession.d/98-fly-usergate-login
fi
echo "Авторизация UserGate настроена"

####################################################################
#                                                                  #
#    Установка дополнительных пакетов                              #
#                                                                  #
####################################################################

echo "Установка дополнительных пакетов"
for planet in $pakets
do
    #echo $planet
    to_install=$(dpkg -l | grep ^ii | grep "$planet" | awk '{ print $3}')
    if [ -n "$to_install" ]; #если строка не пуста,
    then
        echo "пакет $planet установлен!" #то пакет установлен,
    else
        echo "$planet не установлен!" #коли пуста, то не установлен. Логично?
        echo "Устанавливаваю пакет $planet"
        apt install $planet -y > /tmp/apt_pkg_install.log 2>&1
            if [ $? -eq 0 ]
            then
                echo "Установка пакета $planet завершена"
            # exit 0
            else
                echo "Ошибка установки пакета $planet" >&2
                exit 1
            fi
    fi
done

####################################################################
#                                                                  #
#    Перезагрузка                                                  #
#                                                                  #
####################################################################
echo "Внимание!"
echo "Не перезагружайте компьютер!"
echo "Автоматическая перезагрузка через 2 минуты"
sleep 120
reboot
#dpkg -s aldpro-mp | grep -i version |
#apt-cache policy "$arg" | \
#  tr -d '\n' | \
#  awk -F' ' \
#  '{printf("%s\n\tcurrent version: %s\n\trepo version: %s\n", $1, $3, $5);}'

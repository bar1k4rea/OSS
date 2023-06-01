#!/bin/bash

err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S')]: $*" >&2
}


if [ "$EUID" -ne 0 ]; then
	echo "Запустите скрипт с правами root"
	exit
fi

if [ "$1" = "--help" ]; then
	echo "Лабораторная работа по управлению файловыми системами"
	exit
fi

function help() {
	local -n choos=$1
	choos+=("Помощь" "Выход")
	while true
	do
		select opt in "${choos[@]}"
		do
		case $opt in
			"Помощь")
			echo -e "Выберете номер из списка"
			break;;
			
			"Выход")
			return 0
			;;
			
			*)
			if [ ! -z $opt ]; then 
				return $REPLY
			else
				echo "Номер должен быть из списка"
				break
			fi
		esac
		done
	done
}

function showFSTable() {
	df -x proc -x sys -x tmpfs -x devtmpfs --output=source,fstype,target
}

function mountFS() {
	read -p "Введите путь до файла/устройства: " path
	if [ ! -b $path ] && [ ! -f $path ]; then
			err "Неверный путь"
			return 1
	fi

	read -p "Введите путь для монтирования: " mountPath
	if [ ! -e $mountpath ]; then
		mkdir $mountpath
		if [ $? -ne 0 ]; then
			echo "Ошибка при создании директрии $mountpath" >&2
			return 1
		fi
	fi

	if [ -d $mountPath ]; then
		if [ ! -z "$(ls -A $mountPath)" ]; then
			echo "Директория не пуста" >&2
			return 1
		fi
		else
			echo "Это не директория" >&2
			continue
		fi
	
	if [ -f $path ]; then
		device=$(losetup --find --show $path)
		mount $device $mountpath
	else
		echo ok
		mount $filepath $mountpath
	fi

	if [ $? -ne 0 ]; then
		echo "Не удалось монтировать" >&2
		return 1
	else
		echo "Успешно примонтировано" >&2
	fi
	mount | grep $mountPath
	return 0
}

function unmountFS() {
	read -p "Введите путь до файловой системы: " path
	if [ ! -z $path ]; then
		umount $path
	else
		IFS=$'\n' read -r -d '' -a arr < <(df -x proc -x sys -x devtmpfs -x tmpfs --output=target | tail -n+2 && printf '\0')
		help hp
		ret=$?
		if [ $ret -eq 0 ]; then return 0
		fi
		umount ${hp[ret-1]}
		if [ $? -ne 0]; then echo 'Ошибка' >&2
		else echo 'Успешно отмонтированио'
		fi
	fi
}

function changeMountedFSParametrs() {
	IFS=$'\n' read -r -d '' -a arr < <(df -x proc -x sys -x devtmpfs -x tmpfs --output=target | tail -n+2 && printf '\0')
	echo "введите цифру для изменения параметров\n"
	help arr
	ret=$?
	if [ $ret -ne 0 ]; then path-${arr[ret-1]}
	else
		echo -e "Ошибка" >&2
		return 1
	fi
	echo -e "Выберете параметры файловой системы: \n1) Read only\n2) Read & write\n3) Quit\n"
	read -p "> " input
	case $input in
		1)
			mount -o remount,ro $path;;
		2)
			mount -o remount,rw $path;;
		3)
			exit;;
		*)
			echo "Ошибка. Выберете число из списка"
			return 1;;
	esac
}

function showMountedFSParametrs() {
	read -p "Введите путь до файловой системы: " path
	if [ ! -z $path ]; then mount | grep $path
	else
		IFS=$'\n' read -r -d '' -a arr < <(df -x proc -x sys -x devtmpfs -x tmpfs --output=target | tail -n+2 && printf '\0')
		help hp
		ret=$?
		if [ $ret -eq 0 ]; then return 0
		fi
		mount | grep ${hp[ret-1]}
		if [ $? -ne 0]; then echo 'Ошибка' >&2
		fi
	fi
}

function showDetailed() {
	IFS=$'\n' read -r -d '' -a eArr < <(df -t ext2 -t ext3 -t ext4 -t excow --output=source | tail -n+2)
	IFS=$'\n' read -r -d '' -a deviceArr < <(df -t ext2 -t ext3 -t ext4 -t excow --output=source | tail -n+2 && echo -e '\0')
	echo  "Введите номер: "
	help eArr
	ret=$?
	if [ $ret -ne 0 ]; then dev=${deviceArr[ret-1]}
	else
		echo "Ошибка" >&2
		return 1
	fi
	tune2fs -l $dev | tail -n+2
}

PS3=$'\n '
options=("Вывести таблицу файловых систем" "Монтировать файловую систему" "Отмонтировать файловую систему" "Изменить параметры монтирования примонтированной файловой системы" "Вывести параметры монтирования примонтированной файловой системы" "Вывести детальную информацию о файловой системе ext*"
	"Справка" "Выйти")
while true
do
	select opt in "${options[@]}"
	do
	case $opt in
	"Вывести таблицу файловых систем")
		showFSTable
		break;;
	"Монтировать файловую систему")
		mountFS
		break;;
	"Отмонтировать файловую систему")
		unmountFS
		break;;
	"Изменить параметры монтирования примонтированной файловой системы")
		changeMountedFSParametrs
		break;;
	"Вывести параметры монтирования примонтированной файловой системы")
		showMountedFSParametrs
		break;;
	"Вывести детальную информацию о файловой системе ext*")
		showDetailed
		break;;
	"Справка")
		echo "Введите интересующую вас команду"
		break;;
	"Выйти")
		exit;;
	*) echo "Неверная команда"
	esac
	done
done

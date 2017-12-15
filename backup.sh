#!/bin/sh
#Script will make backup

# Функция вывода справки
printHelp() {
	echo "\n"
	echo "  -----   HELP   -----"
	echo "Как пользоваться скриптом? все очень просто!"
	echo "Вызов скрипта: sh backup.sh папка_для_копирования маска папка_куда_сохранить_бэкап"
	echo "Указывать папку для копирования обязательно, остальные параметры нет."
	echo "По умолчанию: маска '*', т.е. все файлы, папка для сохранения резервной копии /home/backup"
	echo "\n"
}

# Функция создания резервной копии
makeBackup() {
	mainDir=$1
	fileMask=$2
	backupDir=$3

	dateNow=$(date +%Y-%m-%d-%T)
	printf "\n\ndate now: ${dateNow} \n\n"
	mkdir "${backupDir}/${dateNow}"
	dateDir="${backupDir}/${dateNow}"

	printf "Будем копировать в: ${dateDir}  \n\n"
	printf "По маске ${fileMask} \n\n"

	if [ "${fileMask}" = "*" ] || [ "${fileMask}" = "*.*" ]; then
		cp -rp ${mainDir}/* $dateDir
	else
		cp -i $(find $mainDir -name ${fileMask}) $dateDir
	fi
}

# Функция для ввода да или нет
yesOrNo() {
	correct="false"
	while [ $correct = "false" ]
	do
		read choice
			if [ $choice ] && ([ $choice = "y" ] || [ $choice = "n" ]); then
			correct="true"
		fi
	done

	case $choice in
                y) printf "true";;
		n) printf "false";;
        esac
}

if [ ! $1 ]; then # проверка на наличие первого аргумента
	printf "Необходимо ввести параметры.\nДля получения справки воспользуйтесь --help"
	exit 0
else
	case "$1" in
		--help) printHelp
			exit 0;;
	esac
	# проверка на существование директории
	if [ ! -d $1 ]; then
		printf "\n Вы ввели несуществующую директорию для создания резервной копии. \n\n"
		printHelp
		exit 0
	else
		mainDirection=$1
	fi
fi

# проверка на наличие маски
if [ $2 ]; then
	mask=$2
else
	mask="*" # Стандартная маска
fi

if [ $3 ]; then # проверка на существование введеной директории для резервной копии
	if [ -d $3 ]; then
		backupDirection=$3
	else
		printf "Вы ввели несуществующую директорию для создания резервной копии. \n"
		printf "Создать эту директорию? [y/n]"
		answer=$(yesOrNo)
		if [ $answer="true" ]; then
			mkdir $3
			backupDirection=$3
		else
			printHelp
			exit 0
		fi
	fi
else
	username=$(whoami)
	printf "Использовать директорию для резервной копии \" home/${username}/backup \" по умолчанию? \n [y/n]"
	answer=$(yesOrNo)

	if [ $answer = "true" ]; then
		defaultDir="/home/${username}/backup"
		printf $defaultDir
		if [ ! -d $defaultDir ]; then # проверка на существование стандартной директории для бэкапа
			mkdir "/home/${username}/backup"
		fi
		backupDirection="/home/${username}/backup"
	else
		printHelp
		exit 0
	fi
fi

makeBackup $mainDirection "${mask}" $backupDirection



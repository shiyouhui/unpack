#!/bin/bash
USER=`whoami`
if [ $USER != "root" ];then
	echo Example: sudo ./decode.sh
	exit
fi

ROOT=$PWD
SIMG2IMG=$ROOT/tool/simg2img
UNPACK=$ROOT/tool/unpack.pl

calc()
{
	if [ "$1" = "r" ];then
		return 4
	elif [ "$1" = "w" ];then
		return 2
	elif [ "$1" = "x" ];then
		return 1
	else
		return 0
	fi
}

spare_mod()
{
	ONE=${1:0:1}
	TWO=${1:1:1}
	THREE=${1:2:1}
	calc $ONE
	RET1=$?
	calc $TWO
	RET2=$?
	calc $THREE
	RET3=$?
	RESULT=$((RET1 + RET2 + RET3))
	return $RESULT
}

Parser()
{
	REALMOD=${1:1:9}
	ROOT_MOD=${REALMOD:0:3}
	GROUP_MOD=${REALMOD:3:3}
	OTHER_MOD=${REALMOD:6:3}
	spare_mod $ROOT_MOD
	ROOT=$?
	spare_mod $GROUP_MOD
	GROUP=$?
	spare_mod $OTHER_MOD
	OTHER=$?
	echo $ROOT$GROUP$OTHER
}

list()
{
    for file in `ls $1`
    do
		if [ -f $file ];then
			MOD=` ls -l $1"/"$file | awk -F" " '{print $1}'`
		else
			MOD=` ls -ld $1"/"$file | awk -F" " '{print $1}'`
		fi
		NUMMOD=`Parser "$MOD"`
		echo $1"/"$file $NUMMOD>> $ROOT/list.txt
		
		if [ -d $1"/"$file ] 
        then
			cd $1"/"$file
            list $1"/"$file
        fi
    done
}
if [ -e $ROOT/list.txt ];then
	rm  $ROOT/list.txt
fi

DATE_MOUNTED=`mount | grep "/out/data"`
if [ ! -z "$DATE_MOUNTED" ];then
	umount $ROOT/out/data/
fi

SYSTEM_MOUNTED=`mount | grep "/out/system"`
if [ ! -z "$SYSTEM_MOUNTED" ];then
	umount $ROOT/out/system/
fi

if [ -e "$ROOT"/out/userdata.img.ext4 ];then
	rm "$ROOT"/out/userdata.img.ext4
fi

if [ -e "$ROOT"/out/userdata.img.ext4 ];then
	rm "$ROOT"/out/userdata.img.ext4
fi

rm out/* -rf

if [ -e  $ROOT/img/boot.img ];then
	mkdir $ROOT/out/boot
	$UNPACK $ROOT/img/boot.img $ROOT/out
	echo "unpack boot.img >>>>>> OK"
else
	echo ">>>>>>Skip unpack boot.img"
fi

if [ -e  $ROOT/img/logo.bin ];then
	mkdir $ROOT/out/logo
	$UNPACK $ROOT/img/logo.bin $ROOT/out
	echo "unpack logo.bin >>>>>> OK"
else
	echo ">>>>>>Skip unpack logo.bin"
fi

if [ -e  img/userdata.img ];then
	mkdir  $ROOT/out/data
	$SIMG2IMG img/userdata.img out/userdata.img.ext4
	mount -t ext4 -o loop out/userdata.img.ext4 out/data/
	list $ROOT/out/data
	chmod 777 $ROOT/out/data/ -R
	echo "unpack userdata.img >>>>>> OK"
else
	echo ">>>>>>Skip unpack userdata.img"
fi

if [ -e  img/system.img ];then
	mkdir $ROOT/out/system
	$SIMG2IMG img/system.img out/system.img.ext4
	mount -t ext4 -o loop out/system.img.ext4 out/system/
	list $ROOT/out/system
	chmod 777 $ROOT/out/system/ -R
	echo "unpack system.img >>>>>> OK"
else
	echo ">>>>>>Skip unpack system.img"
fi	

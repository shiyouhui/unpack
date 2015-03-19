#!/bin/bash
ROOT=$PWD
SIMG2IMG=$ROOT/tool/simg2img
UNPACK=$ROOT/tool/unpack.pl

if [ -d "out/userdata.img.ext4" ]; then  
	sudo umount out/data/
	rm -rf out/data;
	mkdir out/data; 
fi

	
if [ -d "out/system.img.ext4" ]; then 
	sudo umount out/system/
	rm -rf out/system;
	mkdir out/system;
fi

rm out/* -rf

if [ -e  $ROOT/img/boot.img ];then
	mkdir out/boot
	$UNPACK $ROOT/img/boot.img $ROOT/out
	echo "unpack boot.img >>>>>> OK "
else
	echo ">>>>>>Skip unpack boot.img"
fi

if [ -e  $ROOT/img/logo.bin ];then
	mkdir out/logo
	$UNPACK $ROOT/img/logo.bin $ROOT/out
	echo "unpack logo.bin >>>>>> OK "
else
	echo ">>>>>>Skip unpack logo.bin"
fi

if [ -e  img/userdata.img ];then
	mkdir out/data
	$SIMG2IMG img/userdata.img out/userdata.img.ext4
	sudo mount -t ext4 -o loop out/userdata.img.ext4 out/data/
	sudo chmod 777 out/data/ -R
	echo "unpack userdata.img >>>>>> OK "
else
	echo ">>>>>>Skip unpack userdata.img"
fi

if [ -e  img/system.img ];then
	mkdir out/system
	$SIMG2IMG img/system.img out/system.img.ext4
	sudo mount -t ext4 -o loop out/system.img.ext4 out/system/
	sudo chmod 777 out/system/ -R
	echo "unpack system.img >>>>>> OK "
else
	echo ">>>>>>Skip unpack system.img"
fi	

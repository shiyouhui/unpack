#!/bin/bash
ROOT=$PWD
BMP2RAW=$ROOT/tool/bmp_to_raw
MAKE_EXT4FS=$ROOT/tool/make_ext4fs
SIMG2IMG=$ROOT/tool/simg2img
REPACK=$ROOT/tool/repack.pl
MKBOOTIMG=$ROOT/tool/mkbootimg
FILE_CONTEXTS=$ROOT/out/boot/boot-ramdisk/file_contexts

if [ -e $ROOT/out/system.img.ext4 ];then
	SYSTEMSIZE=`ls -alh $ROOT/out/system.img.ext4 | awk '{print $5}'`
	echo "system.img size is $SYSTEMSIZE"
	SYSTEMSIZE_1=`ls -al $ROOT/out/system.img.ext4 | awk '{print $5}'`
	$MAKE_EXT4FS -s -T -1 -S $FILE_CONTEXTS -l $SYSTEMSIZE_1 -a system $ROOT/out/system.img $ROOT/out/system/
	sudo fuser -km $ROOT/out/system/
	sudo umount $ROOT/out/system/
	rm $ROOT/out/system.img.ext4 -f 
fi

if [ -e $ROOT/out/userdata.img.ext4 ];then
	USERDATASIZE=`ls -alh $ROOT/out/userdata.img.ext4 | awk '{print $5}'`
	echo "userdata.img size is $USERDATASIZE"
	USERDATASIZE_1=`ls -al $ROOT/out/userdata.img.ext4 | awk '{print $5}'`
	$MAKE_EXT4FS -s -T -1 -S $FILE_CONTEXTS -l $USERDATASIZE_1 -a system $ROOT/out/userdata.img $ROOT/out/data/
	sudo fuser -km $ROOT/out/system/
	sudo umount $ROOT/out/data/
	rm $ROOT/out/userdata.img.ext4 -f 
fi

if [ -e $ROOT/out/boot ];then
	$REPACK -boot $ROOT/out/boot/boot-kernel.img $ROOT/out/boot/boot-ramdisk $ROOT/out/boot.img
	rm $ROOT/out/boot -rf
fi

if [ -e $ROOT/out/logo ];then
	if [ -e  $ROOT/pic/uboot.bmp ];then
		convert $ROOT/pic/uboot.bmp $ROOT/pic/uboot.bmp
		SIZE=`ls -al $ROOT/out/logo/logo_00.raw | awk '{print $5}'`
		$BMP2RAW "$ROOT"/out/logo/logo_00.raw "$ROOT"/pic/uboot.bmp  1
		OUTSIZE=`ls -al $ROOT/out/logo/logo_00.raw | awk '{print $5}'`
		if [ SIZE !=  OUTSIZE ];then
			$BMP2RAW "$ROOT"/out/logo/logo_00.raw "$ROOT"/pic/uboot.bmp  2
		fi
	fi
	
	if [ -e  $ROOT/pic/kernel.bmp ];then
		convert $ROOT/pic/uboot.bmp $ROOT/pic/kernel.bmp
		SIZE=`ls -al $ROOT/out/logo/logo_38.raw | awk '{print $5}'`
		$BMP2RAW "$ROOT"/out/logo/logo_38.raw "$ROOT"/pic/kernel.bmp  1
		OUTSIZE=`ls -al $ROOT/out/logo/logo_38.raw | awk '{print $5}'`
		if [ SIZE !=  OUTSIZE ];then
			$BMP2RAW "$ROOT"/out/logo/logo_38.raw "$ROOT"/pic/kernel.bmp  2
		fi
	fi

	$REPACK -logo $ROOT/out/logo $ROOT/out/logo.bin
	rm $ROOT/out/logo -rf
fi








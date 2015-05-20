#!/bin/bash
USER=`whoami`
if [ $USER != "root" ];then
	echo Example: sudo ./encode.sh
	exit
fi

ROOT=$PWD
BMP2RAW=$ROOT/tool/bmp_to_raw
MAKE_EXT4FS=$ROOT/tool/make_ext4fs
MAKE_EXT4FS_OLD=$ROOT/tool/make_ext4fs_old
SIMG2IMG=$ROOT/tool/simg2img
REPACK=$ROOT/tool/repack.pl
MKBOOTIMG=$ROOT/tool/mkbootimg
FILE_CONTEXTS=$ROOT/out/boot/boot-ramdisk/file_contexts
OLD_LOGO=0
if [ -e $ROOT/out/system.img.ext4 ];then
	PLATFORM=`awk -F"=" '{if(/^ro.mediatek.platform/)print $2}' $ROOT/out/system/build.prop`
	RELEASE=`awk -F"=" '{if(/^ro.build.version.release/)print $2}' $ROOT/out/system/build.prop`
	OLD_RELEASE=(4.2.2 4.4.2 4.1.2 4.4.4)
	if [ $RELEASE = "4.2.2" ];then
		$OLD_LOGO=1
	fi
	if [ ! -e $FILE_CONTEXTS ];then
		if [ "$PLATFORM" = "MT6582" ];then
			if [ "$RELEASE" = "5.0" ];then
				FILE_CONTEXTS=$ROOT/root/lo82/file_contexts
			fi
		elif [  "$PLATFORM" = "MT6752" ];then
			if [ "$RELEASE" = "5.0" ];then
				FILE_CONTEXTS=$ROOT/root/lo52/file_contexts
			fi
		elif [  "$PLATFORM" = "MT8127" ];then
			if [ "$RELEASE" = "5.0" ];then
				FILE_CONTEXTS=$ROOT/root/lo27/file_contexts
			fi
		elif [  "$PLATFORM" = "MT6735" ];then
			if [ "$RELEASE" = "5.0" ];then
				FILE_CONTEXTS=$ROOT/root/lo35/file_contexts
			elif [ "$RELEASE" = "5.1" ];then
				$FILE_CONTEXTS=$ROOT/root/lo35m/file_contexts
			fi
		fi
	fi
fi

set_mod()
{
	for file in `awk -F" " '{print $1}' list.txt`
	do
		 MOD=`grep -F "$file " list.txt | awk -F" " '{print $2}'`
		 if [ -e "$file" ];then
			if [ ! -z "$file" ];then
				chmod $MOD $file
			fi
		 fi
	done
}
if [ -e $ROOT/out/system.img.ext4 -o -e $ROOT/out/userdata.img.ext4 ];then
	set_mod
fi

if [ -e $ROOT/out/system.img.ext4 ];then
	SYSTEMSIZE_1=`ls -al $ROOT/out/system.img.ext4 | awk '{print $5}'`
	echo ${OLD_RELEASE[@]} | grep -wq "$RELEASE"
	
	if [ $? = 0 ];then
		$MAKE_EXT4FS_OLD -s -l $SYSTEMSIZE_1 -a system $ROOT/out/system.img $ROOT/out/system/
	else
		$MAKE_EXT4FS -s -T -1 -S $FILE_CONTEXTS -l $SYSTEMSIZE_1 -a system $ROOT/out/system.img $ROOT/out/system/
	fi
	fuser -km $ROOT/out/system/
	umount $ROOT/out/system/
	rm $ROOT/out/system.img.ext4 -f
	echo "repack system.img >>>>>> OK"
fi

if [ -e $ROOT/out/userdata.img.ext4 ];then
	USERDATASIZE_1=`ls -al $ROOT/out/userdata.img.ext4 | awk '{print $5}'`
	echo ${OLD_RELEASE[@]} | grep -wq "$RELEASE"
	if [ $? = 0 ];then
		$MAKE_EXT4FS_OLD -s -l $USERDATASIZE_1 -a system $ROOT/out/userdata.img $ROOT/out/data/
	else
		$MAKE_EXT4FS -s -T -1 -S $FILE_CONTEXTS -l $USERDATASIZE_1 -a system $ROOT/out/userdata.img $ROOT/out/data/
	fi
	fuser -km $ROOT/out/data/
	umount $ROOT/out/data/
	rm $ROOT/out/userdata.img.ext4 -f 
	echo "repack userdata.img >>>>>> OK"
fi

if [ -e $ROOT/out/boot ];then
	$REPACK -boot $ROOT/out/boot/boot-kernel.img $ROOT/out/boot/boot-ramdisk $ROOT/out/boot.img
	echo "repack boot.img >>>>>> OK"
fi

if [ -e $ROOT/out/logo ];then
	if [ -e  $ROOT/pic/uboot.bmp ];then
		convert $ROOT/pic/uboot.bmp $ROOT/pic/uboot.bmp
		SIZE=`ls -al $ROOT/out/logo/logo_00.raw | awk '{print $5}'`
		$BMP2RAW $ROOT/out/logo/logo_00.raw $ROOT/pic/uboot.bmp  1
		OUTSIZE=`ls -al $ROOT/out/logo/logo_00.raw | awk '{print $5}'`
		if [ SIZE !=  OUTSIZE ];then
			$BMP2RAW $ROOT/out/logo/logo_00.raw $ROOT/pic/uboot.bmp  2
		fi
	fi
	
	if [ -e  $ROOT/pic/kernel.bmp ];then
		convert $ROOT/pic/kernel.bmp $ROOT/pic/kernel.bmp
		SIZE=`ls -al $ROOT/out/logo/logo_38.raw | awk '{print $5}'`
		$BMP2RAW $ROOT/out/logo/logo_38.raw $ROOT/pic/kernel.bmp  1
		if [ $OLD_LOGO = 1 ];then
			cp $ROOT/out/logo/logo_38.raw $ROOT/out/system/media/boot_logo
		fi
		OUTSIZE=`ls -al $ROOT/out/logo/logo_38.raw | awk '{print $5}'`
		if [ SIZE !=  OUTSIZE ];then
			$BMP2RAW $ROOT/out/logo/logo_38.raw $ROOT/pic/kernel.bmp  2
		fi
	fi

	$REPACK -logo $ROOT/out/logo $ROOT/out/logo.bin
	rm $ROOT/out/logo -rf
	echo "repack logo.bin >>>>>> OK"
fi








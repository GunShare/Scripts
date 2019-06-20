#!/usr/bin/env bash
# Copyright (C) 2018 Abubakar Yagoub (Blacksuan19)

BOT_API_KEY=517042878:AAEOC6q3ZYcwQr8p8Z-dsd7tE-SyAx0OdbY
KERN_IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$PWD/Zipper
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
CONFIG=vince_defconfig
THREAD="-j8"

# Push kernel installer to channel
function push() {
	JIP=$ZIP_DIR/$ZIP
	curl -F document=@"$JIP"  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
			-F chat_id="-1001348786090"
}

function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
		-d "parse_mode=markdown" \
		-d text="${1}" \
		-d chat_id="@da_ci" \
		-d "disable_web_page_preview=true"
}

# Errored prober
function finerr() {
	tg_sendinfo "$(echo -e "Reep build Failed, Check log for more Info")"
	exit 1
}

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADAQADRQADS3HZGKLNCg7b540CAg" \
		-d chat_id="-1001348786090" >> /dev/null
}

# Fin prober
function fin() {
	tg_sendinfo "$(echo "Build Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
}

# Export
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Blacksuan19"
export KBUILD_BUILD_HOST="Dark-Castle"
export CROSS_COMPILE="$PWD/toolchains/Toolchains/bin/aarch64-elf-"

# Install build package
sudo apt install bc

# Clone toolchain
git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x toolchains/Toolchains

# Clone AnyKernel2
git clone https://github.com/Blacksuan19/AnyKernel2 $PWD/Zipper

# Build start
DATE=`date`
BUILD_START=$(date +"%s")

tg_sendstick

tg_sendinfo "*Dark Ages* Kernel New Build!  
*Started on:* ${KBUILD_BUILD_HOST}  
*At branch:* ${BRANCH}  
*commit:* $(git log --pretty=format:'"%h : %s"' -1)  
*Started on:* $(date)  "

make  O=out $CONFIG $THREAD
make  O=out $THREAD

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

if ! [ -a $KERN_IMG ]; then
	finerr
	exit 1
fi

cd $ZIP_DIR
make clean &>/dev/null
NAME=Dark-Ages	
DATE=$(date "+%d%m%Y-%I%M")	
CODE=Sexto	
ZIP=${NAME}-${CODE}-${DATE}.zip
cp $KERN_IMG $ZIP_DIR/zImage
make normal &>/dev/null
echo "Flashable zip generated under $ZIP_DIR."
push
cd ..
fin
# Build end
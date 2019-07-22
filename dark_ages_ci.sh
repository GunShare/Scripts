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
	MD5=$ZIP_DIR/$ZIP.sha1
	curl -F document=@"$JIP"  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
			-F chat_id="-1001348786090"

	curl -F document=@"$MD5"  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
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
export CROSS_COMPILE="$PWD/toolchains/aarch64/bin/aarch64-linux-android-"
export CROSS_COMPILE_ARM32="$PWD/toolchains/aarch32/bin/arm-eabi-"

# Install build package

sudo apt install bc

# Clone toolchain
git clone https://github.com/GrowtopiaJaw/aarch64-linux-android-4.9.git -b google toolchains/aarch64
git clone https://github.com/arter97/arm-eabi-5.1.git toolchains/aarch32

# Clone AnyKernel2
git clone https://github.com/Blacksuan19/AnyKernel2 $PWD/Zipper

# Build start
DATE=`date`
BUILD_START=$(date +"%s")

tg_sendstick

if [ $BRANCH == "darky" ]; then
tg_sendinfo "*Dark Ages*  Kernel New *Stable* Build!  
*Started on:* ${KBUILD_BUILD_HOST}  
*At branch:* ${BRANCH}  
*commit:* $(git log --pretty=format:'"%h : %s"' -1)  
*Started on:* $(date)  "
else if [ $BRANCH == "darky-3.18" ]; then
tg_sendinfo "*Dark Ages* 3.18 Kernel New Build!  
*Started on:* ${KBUILD_BUILD_HOST}  
*At branch:* ${BRANCH}  
*commit:* $(git log --pretty=format:'"%h : %s"' -1)  
*Started on:* $(date)  "
else
tg_sendinfo "*Dark Ages*  Kernel New *Beta* Build!  
*Started on:* ${KBUILD_BUILD_HOST}  
*At branch:* ${BRANCH}  
*commit:* $(git log --pretty=format:'"%h : %s"' -1)  
*Started on:* $(date)  "
fi

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
cp $KERN_IMG $ZIP_DIR/zImage
NAME=Dark-Ages	
DATE=$(date "+%d%m%Y-%I%M")	
CODE=El-Octavo
VERSION=4.9
if [ $BRANCH == "darky" ]; then
ZIP=${NAME}-${CODE}-${VERSION}-STABLE-${DATE}.zip
make stable &>/dev/null
else if [ $BRANCH == "darky-3.18" ]; then
git checkout 3.18
CODE=Septimo
VERSION=3.18
ZIP=${NAME}-${CODE}-${VERSION}-STABLE-${DATE}.zip
make stable &>/dev/null
else
ZIP=${NAME}-${CODE}-${VERSION}-BETA-${DATE}.zip
make beta &>/dev/null
fi
echo "Flashable zip generated under $ZIP_DIR."
push
cd ..
fin
# Build end
#! /bin/bash

set -e

REPO="caristo"

DIR="zig-out/bin"

TARGETS=(
	"aarch64-linux"
	"x86_64-linux"
	"aarch64-macos"
	"x86_64-macos"
	"x86_64-windows"
)

clear

for target in "${TARGETS[@]}"; do
	ARCH=$(echo $target | cut -d '-' -f 1)
	OS=$(echo $target | cut -d '-' -f 2)
	DTARGET="$ARCH-$OS"
	PROG="$REPO-$OS-$ARCH"
	OUTPUT="$DIR/$PROG"

	echo "Making $OS-$ARCH..."

	zig build -Dtarget=$DTARGET -Doptimize=ReleaseSmall || {
		echo -e "\033[31m✗\033[0m Could not make $PROG"
		sleep 1
		continue
	}

	if [ -f "$DIR/$REPO" ]; then
		mv "$DIR/$REPO" "$OUTPUT"
	elif [ -f "$DIR/$REPO.exe" ]; then
		mv "$DIR/$REPO.exe" "$OUTPUT.exe"
	fi

	if [ -f "$OUTPUT" ] || [ -f "$OUTPUT.exe" ]; then
		echo -e "\033[32m✓\033[0m Made $OUTPUT"
		echo
	else
		echo -e "\033[31m✗\033[0m Output file not found for $PROG"
		echo
	fi
	sleep 1
done

echo "Making checksums.txt with sha256sum..."
echo
sleep 1

sha256sum "$DIR"/caristo-* > "$DIR/checksums.txt"

echo "Making caristo for this machine..."
echo
zig build -Dtarget=x86_64-linux -Doptimize=ReleaseSmall

echo "Moving caristo to PATH..."
echo
cp zig-out/bin/caristo /usr/local/bin

echo -e "\033[32m✓\033[0m All done!"

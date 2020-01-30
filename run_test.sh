#!/bin/bash
#exec 2> /dev/null

LC=./main.native

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

clean=""
if [ ! -x ./main.native ]; then
	ocamlbuild -use-menhir main.native -pkgs str > /dev/null || exit 1
	clean="1"
fi

all=0
err=0
ok=0
echo "Levy Language Auto-verification Tool"
echo ------------------
for f in `ls examples`; do
	name=${f%%.levy}.out
	echo -n "testing `tput bold` $f `tput sgr0`... "
	if [ -f "tests/$name" ]; then
		d=`diff <( $LC examples/$f ) tests/$name`
	else
		if [ "`cat tests/.ignore | grep $f | wc -l`" -eq 1 ]; then
			d="ignored"
		else
			d="err"
		fi
	fi
	all=$((all + 1))
	if [ -z "$d" ]; then
		ok=$((ok + 1))
		echo -ne "${GREEN}`tput bold`PASS"
	else
		if [ "$d" = "ignored" ]; then
			echo -ne "`tput bold`SKIP"
		else
			err=$((err + 1))
			echo -ne "${RED}`tput bold`FAIL"
		fi
	fi
	echo -e "${NC}"
done

echo ------------------
if [ $err -eq 0 ]; then
	echo -e "Your software is ${GREEN}`tput bold`Bug-Free\U2122`tput sgr0`${NC}!"
else
	echo -e "Auto-verification ${RED}`tput bold`failed`tput sgr0`${NC} - please correct interpreter or tests!"
fi

[ -n "$clean" ] && ocamlbuild -clean > /dev/null

#! /usr/bin/env bash
# shows all devices sorted by firmware-layout
MYPWD="$(dirname $(realpath $0))"

TWS="$(printf '\342\200\212')"
for FWL in $(sed -rn 's/.* FREETZ_AVM_HAS_FWLAYOUT_//p' "$MYPWD/../config/.img/separate/"*.in | sort -u); do
	echo "# Gen$FWL"
	for IN in $(grep FREETZ_AVM_HAS_FWLAYOUT_$FWL "$MYPWD/../config/.img/separate/"*.in -l); do
		HWREV="$(grep " FREETZ_AVM_PROP_HWREV$" -A2 "$IN" | sed -rn 's/.* "(.*)"$/\1/p')"
		[ -z "$HWREV" ] && IN="${IN%.in}*.in"  # && echo "INHERITED: $IN"
		for INN in $IN; do
			[ -z "$HWREV" ] && HWREV="$(grep " FREETZ_AVM_PROP_HWREV$" -A2 $INN | sed -rn 's/.* "(.*)"$/\1/p')"
			[ -z "$HWREV" ] && echo "BAD: $INN" && continue
			NAME="$(grep " FREETZ_AVM_PROP_NAME$" -A2 ${INN%.in}*.in | sed -rn 's/.* "(.*)"$/\1/p' | tail -n1)"
			[ -n "$1" ] && SYMB="$(grep "^if " "${INN}" | sed -rn 's/^if \(*([^ ]*).*/\1/p')"
			[ -z "$NAME" ] && echo "NON: $INN" && continue
			echo "$HWREV -$SYMB- $NAME" | sed "s/$TWS/ /g"
			break
		done
	done | sort -n | uniq |  tac|awk -F"[. ]" '!a[$1]++'|tac
done

exit 0


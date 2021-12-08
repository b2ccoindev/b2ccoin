#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

B2CCOIND=${B2CCOIND:-$SRCDIR/b2ccoind}
B2CCOINCLI=${B2CCOINCLI:-$SRCDIR/b2ccoin-cli}
B2CCOINTX=${B2CCOINTX:-$SRCDIR/b2ccoin-tx}
B2CCOINQT=${B2CCOINQT:-$SRCDIR/qt/b2ccoin-qt}

[ ! -x $B2CCOIND ] && echo "$B2CCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
B2CVER=($($B2CCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$B2CCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $B2CCOIND $B2CCOINCLI $B2CCOINTX $B2CCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${B2CVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${B2CVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m

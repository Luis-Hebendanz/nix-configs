#!/usr/bin/env bash

cp result/talon ldd-talon.sh
chmod +w ldd-talon.sh
sed -i 's/exec.*//g' ldd-talon.sh


cat << EOF >> ldd-talon.sh
echo "=====FILE: \$1"
ldd "\$1"

EOF

fd ".so.*" -t x result --exec "./ldd-talon.sh"

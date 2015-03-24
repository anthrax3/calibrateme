#!/bin/bash -eu
touch calibratedb
rm calibratedb
urweb -dbms sqlite -ccompiler "gcc -D_FORTIFY_SOURCE=2 -g -O2 -fstack-protector-strong -Wformat -Werror=format-security" calibrate
sqlite3 calibratedb < sql.sql
./calibrate.exe

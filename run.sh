#!/bin/sh

for i in $(seq 1 100); do echo ${i}; if [ -e "./out/${i}.out" ]; then unlink "./out/${i}.out"; fi; perl ./asd.pl "${i}" 1>>./out/${i}.out 2>>./out/${i}.out ; done

cat out/* | perl qwe.pl


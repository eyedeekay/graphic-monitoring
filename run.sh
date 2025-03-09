#! /usr/bin/env sh
# launch the conky script _dot_conkyrc
git submodule update --init --recursive
git submodule update --recursive --remote
conky -c _dot_conkyrc
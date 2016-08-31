#!/bin/bash

switch=$1
shift

~/bin/gitls.sh -1 $switch $@ | tr '\n' '\0' | xargs -0 git checkout

#!/bin/bash

URL=$1
category=$2
weight=$3

docker run --rm -v $(pwd):/data williamyeh/wrk -d20s -s random-category.lua $URL -- $category $weight
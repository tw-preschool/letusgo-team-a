#!/bin/bash
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

rackup -s 'thin' -p '8080'

#!/bin/bash

case $1 in
   "master")
      ./master-uninstall.sh
      ;;
   "node")
      ./node-uninstall.sh
      ;;
esac

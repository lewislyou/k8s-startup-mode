#!/bin/bash

case $1 in
   "master")
      cli download -f master-uninstall.sh
      chmod +x master-uninstall.sh
      ./master-uninstall.sh
      ;;
   "node")
      cli download -f node-uninstall.sh
      chmod +x node-uninstall.sh
      ./node-uninstall.sh
      ;;
esac

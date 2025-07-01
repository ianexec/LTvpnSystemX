#!/bin/bash

#Mengunduh dan mengekstrak menu.zip
apt update -y
apt install -y unzip

    wget https://raw.githubusercontent.com/ianexec/LTvpnSystemX/main/HandlerSentry/LunatiX_sh
    unzip LunatiX_sh
    chmod +x menu/*
    mv menu/* /usr/local/sbin
    rm -rf menu
    rm -rf LunatiX_sh
    
    wget https://raw.githubusercontent.com/ianexec/LTvpnSystemX/main/HandlerSentry/LunatiX_py
    unzip LunatiX_py
    chmod +x menu/*
    mv menu/* /usr/bin
    rm -rf menu
    rm -rf LunatiX_py    

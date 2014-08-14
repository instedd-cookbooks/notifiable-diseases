#!/bin/sh

grep -q 'RES_OPTIONS' /etc/sysconfig/network || sudo sed -E -i '$ a\RES_OPTIONS=single-request-reopen' /etc/sysconfig/network
grep -q 'single-request-reopen' /etc/resolv.conf || sudo sed -E -i '$ a\options single-request-reopen' /etc/resolv.conf
#!/bin/bash

echo "=== CPU 信息 ===" && lscpu | grep 'Model name'
echo
echo "=== 内存使用 ===" && free -h
echo
echo "=== 磁盘使用 ===" && df -h
echo
echo "=== 网络信息 ===" && hostname -I
echo
echo "=== 系统负载 ===" && uptime

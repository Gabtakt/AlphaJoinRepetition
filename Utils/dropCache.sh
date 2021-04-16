#!/bin/sh
echo 'imdb' | sudo -S /bin/systemctl restart postgresql-12
echo 'imdb' | sudo -S sysctl -w vm.drop_caches=3

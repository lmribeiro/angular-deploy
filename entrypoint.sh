#!/bin/bash

mkdir -p /root/.ssh
ssh-keyscan -H "$2" >> /root/.ssh/known_hosts

if [ -z "$DEPLOY_KEY" ];
then
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
else
	printf '%b\n' "$DEPLOY_KEY" > /root/.ssh/id_rsa
	chmod 400 /root/.ssh/id_rsa

	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
fi

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='.editorconfig' \
	--exclude='.styleci.yml' \
	--exclude='.idea/' \
	--exclude='.vscode' \
	--exclude='.prettierrc' \
	--exclude='.browserslistrc' \
	--exclude='action.yml' \
	--exclude='angular.json' \
	--exclude='Dockerfile' \
	--exclude='readme.md' \
	--exclude='README.md' \
	--exclude='node_modules/' \
	--exclude='tsconfig.*' \
	--exclude='src/' \
	--exclude='package*' \
	--exclude='server.ts' \
	--exclude='karma.conf.js' \
	-e "ssh -i /root/.ssh/id_rsa" \
	--rsync-path="sudo rsync " . $1@$2:$3

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'

	ssh -i /root/.ssh/id_rsa -tt $1@$2 "sudo chown -R $4:$4 $3"

	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi

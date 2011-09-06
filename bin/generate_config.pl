#!/bin/sh

echo "###########################################################################" > $1
echo "### DO NOT EDIT THIS FILE, see ~/$1.global or ~/$1.site ###" >>$1
echo "###########################################################################" >> $1
echo '' >> $1
echo '' >> $1

if [ -f $1.global ]
then 
  echo "############## From ~/$1.global ##############" >> $1
  echo '' >> $1
  cat ~/.gitconfig.global >> $1
fi

if [ -f $1.site ]
then
  echo "############## From ~/$1.site ##############" >> $1
  echo '' >> $1
  cat ~/.gitconfig.site >> $1
fi

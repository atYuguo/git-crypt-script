#!/bin/bash
mainpath=$(pwd)
echo ----------------------------------------
echo            正在初始化...
echo ----------------------------------------
if [ ! -d ~/.git_secure ]
then
    mkdir ~/.git_secure
fi
if [ ! -f ~/.git_secure/writeTemp.o ]
then
    gcc writeTemp.c -o ~/.git_secure/writeTemp.o
fi
if [ ! -f ~/.git_secure/gitcryptDigst.o ]
then
    gcc gitcryptDigst.c -lssl -lcrypto -o ~/.git_secure/gitcryptDigst.o
fi
echo
echo ----------------------------------------
echo           请输入本地库路径：
echo ----------------------------------------
read repoPath
cd $repoPath 2>/dev/null
if [ $? -eq 1 ]
then
    echo 版本库不存在，将创建新版本库。。。
    mkdir $repoPath
    cd $repoPath
    git init
fi
repoPath=$(pwd)
cd $mainpath
reponame=$(echo $repoPath | grep -oP '(?<=/)[^/]*(?=$)')
if [ ! -d ~/.git_secure/$reponame ]
then
    mkdir ~/.git_secure/$reponame
fi
if [ ! -f ~/.git_secure/$reponame/clean_filter_openssl ]
then
    existFlag=0
    echo ----------------------------------------
    echo            请输入密码：
    echo ----------------------------------------
    read theKey
    cp *.template ~/.git_secure/$reponame
    cd ~/.git_secure/$reponame
    for template in $(ls *.template)
    do
	chmod 750 $template
	mv $template $(echo $template | grep -oP '.*(?=.template)')
    done
    sed -i 's/<your-password>/'$theKey'/g' *
    sed -i 's/<your-reponame>/'$reponame'/g' *
    useRepopath=$(echo $repoPath | sed 's/\//\\\//g')
    sed -i 's/<your-repopath>/'$useRepopath'/g' *
    if [ ! -f ~/.git_secure/$reponame/hashandsalt ]
    then
	touch ~/.git_secure/$reponame/hashandsalt
    fi
else
    existFlag=1
    cd ~/.git_secure/$reponame
fi
cat ./config >> $repoPath/.git/config
cat ./gitattributes >>$repoPath/.gitattributes
echo ".gitattributes" >>$repoPath/.gitignore
if [ $existFlag -eq 1 ]
then
    cd $repoPath
    git reset --hard HEAD
fi
echo ----------------------------------------
echo               初始化完成。
echo ----------------------------------------

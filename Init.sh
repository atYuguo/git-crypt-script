#!/bin/bash
mainpath=$(pwd)
echo ----------------------------------------
echo            正在初始化...
echo ----------------------------------------
if [ ! -d ~/.git_secure ]
then
    mkdir ~/.git_secure
fi
echo
echo ----------------------------------------
echo           请输入本地库路径：
echo ----------------------------------------
read repoPath
echo ----------------------------------------
echo            请输入密码：
echo ----------------------------------------
read theKey
cd $repoPath
repoPath=$(pwd)
cd $mainpath
reponame=$(echo $repoPath | grep -oP '(?<=/)[^/]*(?=$)')
if [ ! -d ~/.git_secure/$reponame ]
then
    mkdir ~/.git_secure/$reponame
fi
cp *.template ~/.git_secure/$reponame
cd ~/.git_secure/$reponame
for template in $(ls *.template)
do
    chmod 777 $template
    mv $template $(echo $template | grep -oP '.*(?=.template)')
done
sed -i 's/<your-password>/'$theKey'/g' *
sed -i 's/<your-reponame>/'$reponame'/g' *
touch hashandsalt
cat ./config >> $repoPath/.git/config
cat ./.gitattributes >>$repoPath/.gitattributes
echo ----------------------------------------
echo               初始化完成。
echo ----------------------------------------

#!/bin/bash

# Author:  txlstars
# Date:    2018-06-02

touch .0531tmp .0532tmp

if [ $# -lt 2 ]; then
    echo "please input ./vimdiff.sh dir1 dir2"
    exit -1
fi

# 脚本执行目录
EXEPATH=$(pwd)

# 对"dir"和"dir/"目录输入格式兼容
DIR1_LAST_CHAR_INDEX=$((${#1}-1))
DIR1=
if [ ${1:$DIR1_LAST_CHAR_INDEX} = "/" ]; then
    DIR1="$EXEPATH/$1"
else 
    DIR1="$EXEPATH/$1/"
fi

# 检查目录是否存在
if [ ! -d $DIR1 ]; then
    echo "$DIR1 not exit"
    exit -1
fi

# 同上
DIR2_LAST_CHAR_INDEX=$((${#2}-1))
DIR2=
if [ ${2:$DIR2_LAST_CHAR_INDEX} = "/" ]; then
    DIR2="$EXEPATH$2/"
else 
    DIR2="$EXEPATH/$2/"
fi

if [ ! -d $DIR2 ]; then
    echo "$DIR2 not exit"
    exit -1
fi

# -------------------------------------------------------
# 获取dir目录下的所有文件
OLD_IFS=$IFS
IFS=" "

RESULT=($(find $DIR1 -name "*.h" -o -name "*.cpp" -o -name "*.c" -o -name "*.jce" -o -name "*.sh"))

IFS=$OLD_IFS

START=${#DIR1}

for v in ${RESULT[@]}
do
    echo ${v:$START} >> .0531tmp
done

# 同上
OLD_IFS=$IFS
IFS=" "

RESULT=($(find $DIR2 -name "*.h" -o -name "*.cpp" -o -name "*.c" -o -name "*.jce" -o -name "*.sh"))

IFS=$OLD_IFS

START=${#DIR2}

for v in ${RESULT[@]}
do
    echo ${v:$START} >> .0532tmp
done

# 去重两个目录下相同的文件
ALL_FILE=$(cat .0531tmp .0532tmp | sort | uniq)

# 循环遍历比较所有的文件
OLD_IFS=$IFS
IFS=" "

RESULT=($ALL_FILE)

IFS=$OLD_IFS

for v in ${RESULT[@]}
do
    diff $DIR1$v $DIR2$v > /dev/null
    if [ $? -ne 0 ]; then
        vimdiff $DIR1$v $DIR2$v
    fi
done

# delete tmp file
rm .0531tmp .0531seantmp1 &>/dev/null

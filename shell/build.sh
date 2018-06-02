#!/bin/bash

# Author:  txlstars
# Date:    2018-05-28

# --------------------------------------------------------------------------------------------
if [ $# -gt 0 ] && ([ $1 = "-h" ] || [ $1 = "help" ]); then
    echo "------------------------------------------------------------"
    echo "./tools/build.sh                     make->cpplint->cppcheck"
    echo
    echo "./tools/build.sh make                make"
    echo
    echo "./tools/build.sh cpplint             cpplint"
    echo
    echo "./tools/build.sh cppcheck            cppcheck"
    echo
    echo "./tools/build.sh lintcheck           cpplint->cppcheck"
    echo
    echo "./tools/build.sh upload              upload"
    echo
    echo "./tools/build.sh -h                  show help"
    echo
    echo "./tools/build.sh help                show help"
    echo "------------------------------------------------------------"
    exit 0
fi


echo "----------------------------------- build start -------------------------------------"

SERVER_JCE_NAME="VideoLogAccess"

# --------------------------------------------------------------------------------------------
# 1.make

if ([ $# -gt 0 ] && [ $1 = "make" ]) || [ $# -eq 0 ]; then
    OLDPATH=$PATH
    PATH=/usr/bin:$PATH

    make -j8 1>/dev/null 2>error

    if [ $? -eq 0 ]; then
    echo make success
    else
    echo "make fail, please see file error"
    exit -1
    fi

    PATH=$OLDPATH
fi

# --------------------------------------------------------------------------------------------
# 2.cpplint

SERVER_FILES=$(find ./ \( -path "./wsd" -o -path "./tools" \) -prune -o -name "*.h" -print -o -name "*.cpp" -print \
        | grep -v "./$SERVER_JCE_NAME.h"\
        | grep -v "./$SERVER_JCE_NAME.cpp")

if ([ $# -gt 0 ] && ([ $1 = "cpplint" ] || [ $1 = "lintcheck" ])) || [ $# -eq 0 ]; then

    CPPLINT_FILTER=('whitespace/braces',
            'whitespace/parens',
            'runtime/indentation_namespace',
            'readability/namespace',
            'whitespace/newline',
            'build/header_guard',
            'build/include_what_you_use',
            'whitespace/indent',
            'runtime/references',
            'build/include_subdir',
            'build/include',
            'runtime/int',
            'build/c++tr1');
            
    CPPLINT='./tools/cpplint.py --filter='

    for v in ${CPPLINT_FILTER[@]}
    do
        CPPLINT="$CPPLINT-$v"
    done

    CPPLINT="$CPPLINT --linelength=120"

    $CPPLINT $SERVER_FILES 2>error

    if [ $? -eq 0 ]; then
        echo cpplint success
    else
        echo "cpplint fail, please see file error"
        exit -2
    fi
fi

# --------------------------------------------------------------------------------------------
# 3.cppcheck

if ([ $# -gt 0 ] && ([ $1 = "cppcheck" ] || [ $1 == "lintcheck" ])) || [ $# -eq 0 ]; then

    cppcheck -j 4 --enable=all --std=c++03 --language=c++ -iwsd/* $SERVER_FILES 1>/dev/null 2>/tmp/errorTmp

    grep -v "wsd" /tmp/errorTmp | grep -v "$SERVER_JCE_NAME.h" &>error

    if [ $(cat error | wc -l) -eq 0 ]; then
        echo cppcheck success
    else
        echo "cppcheck fail, please see file error"
        exit -2
    fi

fi

# --------------------------------------------------------------------------------------------
# 4.upload

if [ $# -gt 0 ] && [ $1 = "upload" ]; then
    OLDPATH=$PATH
    PATH=/usr/bin:$PATH

    make -j8 upload

    PATH=$OLDPATH
fi

echo "----------------------------------- build   end -------------------------------------"

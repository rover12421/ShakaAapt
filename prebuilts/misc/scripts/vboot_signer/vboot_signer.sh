#!/bin/sh

#
# Copyright (C) 2015 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

usage()
{
	echo usage: $0 futility input.img key.vbpubk key.vbprivk subkey.vbprivk output.keyblock output.img
}

cleanup()
{
	rm -f ${EMPTY}
}

if [ "$#" -ne 7 ]; then
	echo ERROR: invalid number of arguments
	usage
	exit 1
fi

futility=$1
input=$2
pubkey=$3
privkey=$4
subkey=$5
keyblock=$6
output=$7

EMPTY=$(mktemp /tmp/tmp.XXXXXXXX)
trap cleanup EXIT
echo " " > ${EMPTY}

echo signing ${input} with ${privkey} to generate ${output}
${futility} vbutil_keyblock --pack ${keyblock} --datapubkey ${pubkey} --signprivate ${subkey} --flags 0x7
if [ $? -ne 0 ]; then
	echo ERROR: unable to generate keyblock
	exit $?
fi

${futility} vbutil_kernel --pack ${output} --keyblock ${keyblock} --signprivate ${privkey} --version 1 --vmlinuz ${input} --config ${EMPTY} --arch arm --bootloader ${EMPTY} --flags 0x1
if [ $? -ne 0 ]; then
	echo ERROR: unable to sign image
	exit $?
fi


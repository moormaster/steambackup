#!/bin/bash

RETVALUE_SUCC=0
RETVALUE_ERR=1

function steambackup()
{
	if [ $# -lt 2 ]
	then
		usage
		return ${RETVALUE_ERR}
	fi

	local arg_sourcedir="$1"
	local arg_targetdir="$2"

	local abs_sourcedir="$( realpath "$1" )"
	local abs_targetdir="$( realpath "$2" )"

	shift 2

	local arg_rsyncopts="$*"

	if ! [ -d "${arg_sourcedir}" ]
	then
		echo "${arg_sourcedir}" not found 2>&1
		usage 2>&1
		return ${RETVALUE_ERR}
	fi

	if ! [ -d "${arg_sourcedir}/common" ]
	then
		echo "${arg_sourcedir}/common" not found 2>&1
		usage 2>&1
		return ${RETVALUE_ERR}
	fi

	if ! [ -d "${arg_targetdir}" ]
	then
		echo "${arg_targetdir}" not found 2>&1
		usage 2>&1
		return ${RETVALUE_ERR}
	fi
	
	if ! [ -d "${arg_targetdir}/common" ]
	then
		echo "${arg_targetdir}/common" not found 2>&1
		usage 2>&1
		return ${RETVALUE_ERR}
	fi

	rsync -auv ${arg_rsyncopts} "${arg_sourcedir}"/*.acf "${arg_targetdir}/"

	pushd "${arg_sourcedir}/common"
		find -mindepth 1 -maxdepth 1 -type d | while read d
		do
			local dname="$( basename "$d" )"

			rsync -auv --delete ${arg_rsyncopts} "${abs_sourcedir}/common/${dname}/" "${abs_targetdir}/common/${dname}/"
		done		
	popd

	pushd "${abs_targetdir}/common"
		find -mindepth 1 -maxdepth 1 -type d | while read d
		do
			local dname="$( basename "$d" )"

			if ! [ -d "${abs_sourcedir}/common/${dname}" ]
			then
				echo "$dname is not installed anymore and was NOT backed up"
			fi
		done
	popd
}

function usage()
{
	echo "$0 <source SteamApps dir> <target SteamApps dir> [rsync opts]"
}

steambackup "$@"



_PROD="/u01/camel/12.0"
_DEBUG="on"
_LOG="_srcs.log"

fname_srcs="$_PROD/$2"
fname=$(basename "${fname_srcs}")
fdir=`echo "${fname_srcs}" | sed 's/'"$fname"'$//'`
fver="$fdir/RCS/${fname},v"
	
function DEBUG()
{
	[ "$_DEBUG" == "on" ] && $@ || :
}

function checkout()
{
	version=`tail -3 $fver | egrep "^version#" | sed 's/^version#//'`
	cp $fname_srcs ${fname}.tmp.$1
	for (( v=$version; v>$1; v-- ))
	do
		let delta=$v-1
		_l1=`nl "$fver" | egrep "version#$delta" | sed "s/version#$delta//" | sed 's/^\s*|\s*$//g'`
		_l2=`nl "$fver" | egrep "version#$v" | sed "s/version#$v//" | sed 's/^\s*|\s*$//g'`
		sed -n "${_l1},${_l2}p" "$fver" | patch ${fname}.tmp.$1 -i - >> /dev/null
	done
}

if [ $1 == "diff" ]; then
	##
	# diff a file with two versions. 
	# This command will diff the v5 and v6 of admin/sql/test.sql: srcs.sh diff admin/sql/test.sql 5 6 
	# This command will diff the v5 and local copy of admin/sql/test.sql: srcs.sh diff admin/sql/test.sql 5 
	##
	echo "Diff $2 $3 $4 from SRCS..." | tee -a $_LOG
	if [ "$#" -lt 3 ]; then
		echo "Please provide at least one revision for diff...<FAILED>" | tee -a $_LOG
		exit 1
	fi
	if [ ! -f "$fver" ]; then
		echo "$fname doesn't exist in SRCS...<FAILED>" | tee -a $_LOG
		exit 1
	else
		if egrep -v "^\s*$" $fver | wc -l | egrep "^0" > /dev/null ; then 
			echo "$fname is just initialled in SRCS...<FAILED>" | tee -a $_LOG
			exit 1
		else
			if ! cat $fver | egrep "^version#$3" > /dev/null ; then
				echo "Version $3 doesn't exist...<FAILED>" | tee -a $_LOG
				exit 1
			else
				checkout $3
			fi
		fi
		if [ "$#" -lt 4 ]; then 	
			echo "Diff $2 $3 from SRCS with the local copy..." | tee -a $_LOG
			if [ ! -f "$fname" ]; then
				echo "$fname doesn't exist in local directory...<FAILED>" | tee -a $_LOG
				exit 1
			fi
			diff ${fname}.tmp.$3 $fname | tee -a $_LOG
			echo "Diff $2 $3 from SRCS with the local copy...<SUCCESSED>" | tee -a $_LOG
		else 
			if ! cat $fver | egrep "^version#$4" > /dev/null ; then
				echo "Version $4 doesn't exist...<FAILED>" | tee -a $_LOG
				exit 1
			fi
			checkout $4
			diff ${fname}.tmp.$3 ${fname}.tmp.$4 | tee -a $_LOG
			echo "Diff $2 $3 $4 from SRCS...<SUCCESSED>" | tee -a $_LOG
		fi
	fi
elif [ $1 == "init" ]; then
	##
	# initial a file in revision repository
	# this command will initial a placeholoder of admin/sql/test.sql in revision repository: srcs.sh init admin/sql/test.sql
	##
	date | tee -a $_LOG
	echo "Initial $2 in SRCS..." | tee -a $_LOG
	mkdir -p "$fdir/RCS" 
	if [ -f "$fver" ]; then
		echo "$2 exists in SRCS already...<FAILED>" | tee -a $_LOG
		echo "Initial $2 in SRCS...<FAILED>" | tee -a $_LOG
		exit 1	
	fi
	touch "$fver"
	if [ $? -gt 0 ];then
		echo "Initial $2 in SRCS...<FAILED>" | tee -a $_LOG
		exit 1
	fi
	echo "Initial $2 in SRCS...<SUCCESSED>" | tee -a $_LOG
	exit 0
elif [ $1 == "ci" ]; then
	##
	# check in a file in revision repository
	# this command will check in a new version of admin/sql/test.sql in revision repository: srcs.sh ci admin/sql/test.sql 
	##
	echo "Checkin $2 in SRCS..." | tee -a $_LOG
	if [ ! -f "$fname" ]; then
		echo "$fname doesn't exist in local directory...<FAILED>" | tee -a $_LOG
		exit 1
	elif [ ! -f "$fver" ]; then
		echo "$fname doesn't exist in SRCS. Run init command to init it firstly...<FAILED>" | tee -a $_LOG
		exit 1
	else
		if egrep -v "^\s*$" $fver | wc -l | egrep "^0" > /dev/null ; then 
			version=1
		else
			version=`tail -3 $fver | egrep "^version#" | sed 's/^version#//'`
			let version=1+$version
		fi
			echo "Input comment for this checkin: "
			read comment
			touch "${fname_srcs}"
			diff $fname $fname_srcs >> $fver
			echo "comment#$comment" >> $fver
			echo "version#$version" >> $fver
			echo "" >> $fver
			cp $fname $fname_srcs
			echo "Checkin $2 in SRCS...<SUCCESSED>" | tee -a $_LOG
	fi
elif [ $1 == "co" ]; then
	##
	# check out a file with a specified version from revision repository
	# this command will check out the latest version of admin/sql/test.sql from revision repository: srcs.sh co admin/sql/test.sql 
	# this command will check out the v5 of admin/sql/test.sql from revision repository: srcs.sh co admin/sql/test.sql 5
	##
	echo "Checkout $2 $3 from SRCS..." | tee -a $_LOG
	if [ ! -f "$fver" ]; then
		echo "$fname doesn't exist in SRCS. Run init and ci command to version control it firstly...<FAILED>" | tee -a $_LOG
		exit 1
	else
		if egrep -v "^\s*$" $fver | wc -l | egrep "^0" > /dev/null ; then 
			echo "$fname is just initialled in SRCS. Run ci command to version control it firstly...<FAILED>" | tee -a $_LOG
		elif ! cat $fver | egrep "^version#$3" > /dev/null ; then
			echo "Version $3 doesn't exist...<FAILED>" | tee -a $_LOG
			exit 1
		elif [ "$#" -lt 3 ]; then 	
			cp $fname_srcs $fname
			echo "Checkout $2 $3 from SRCS...<SUCCESSED>" | tee -a $_LOG
		else
			version=`tail -3 $fver | egrep "^version#" | sed 's/^version#//'`
			cp $fname_srcs $fname
			for (( v=$version; v>$3; v-- ))
			do
				let delta=$v-1
				_l1=`nl "$fver" | egrep "version#$delta" | sed "s/version#$delta//" | sed 's/^\s*|\s*$//g'`
				_l2=`nl "$fver" | egrep "version#$v" | sed "s/version#$v//" | sed 's/^\s*|\s*$//g'`
				sed -n "${_l1},${_l2}p" "$fver" | patch $fname -i - >> /dev/null
			done
			echo "Checkout $2 $3 from SRCS...<SUCCESSED>" | tee -a $_LOG
		fi
	fi
elif [ $1 == "log" ]; then
	##
	# print all the metadata for a file including a complete version history and the checkin comments from revision repository
	# this command will print the metadata for admin/sql/test.sql in revision repository: srcs.sh log admin/sql/test.sql 
	##
	echo "Log for $2 from SRCS..." | tee -a $_LOG
	if [ ! -f "$fver" ]; then
		echo "$fname doesn't exist in SRCS...<FAILED>" | tee -a $_LOG
		exit 1
	else
		if egrep -v "^\s*$" $fver | wc -l | egrep "^0" > /dev/null ; then 
			echo "$fname is just initialled in SRCS and has no revision...<FAILED>" | tee -a $_LOG
		else
			logs=`cat $fver | egrep "^version#|comment"`
			echo "$logs" | tee -a $_LOG
		fi
	fi
else
	##
	# when all options fail 
	##
	echo "$1 is not a supported parameter in SRCS..." | tee -a $_LOG
	exit 1
fi

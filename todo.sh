#!/bin/bash

#declaring variables
#modify todo to change path of the file (e.g. $HOME/todo)
todo=$HOME/.todo
today=$(date +%Y-%m-%d)
day=$(date -d $today +%s)
year=$(date +%Y)

#defining all the functions used
banner()
{
	printf "`tput bold ; tput setaf 3 ; tput smso`%-s`tput sgr0`\n" "$@"
}

question()
{
	printf "`tput bold ; tput setaf 2 ; tput smso`%-s`tput sgr0`\n" "$@"
}

update()
{
	for value in $(grep $year $todo | cut -c2-11 )
	do
		valuetest=$(($(date -d $value +%s) - $day)) 
		if [ $valuetest -eq 0 ]
		then
			ligne=$(grep -n $value $todo | cut -c1-1)
			$(sed -i "$ligne"'i (today)' $todo)
			if [ $ligne -gt 1 ]
			then
				$(sed -i "$ligne"',$!d' $todo)
			fi
			break
		elif [ $valuetest -gt 0 ]
		then
			ligne=$(grep -n $value $todo | cut -c1-1)
			$(sed -i "$ligne"'i (days to come)' $todo)
			if [ $ligne -gt 1 ]
			then
				$(sed -i "$ligne"',$!d' $todo)
			fi
			break
		fi
	done
}

show()
{
banner "To do list."
cat $todo
}

what()
{
	echo
	question "What do ?" "(a)dd, (m)odify, (*)exit"
	read modif
	
	case $modif in
		a)
			add
			;;
		m)
			modify
			;;
		*)
			exit
			;;
	esac
}

add()
{
	 
	show
	banner "Adding an event ."
	question "Limit date ?(MM-DD)"
	read limit
	limit=$year-$limit
	diff=$(($(date -d $limit +%s) - $day))

	if [ $diff -lt 0 ]
	then
		limit=$(date -d $limit+"1 year" +%Y-%m-%d)
	fi

	echo
	question "Event to add ?"
	read addtolist
	read -d '' -r -a listdate <<< $(grep -F "[" $todo | cut -c2-11 )
	lastdate=${listdate[-1]}
	diffddate=$(( $(date -d $lastdate +%s) - $(date -d $limit +%s) ))
	if [ $diffddate -lt 0 ]
	then
		$(sed -i '$a'"[$limit]\n-$addtolist" $todo)
	else
		for value in ${listdate[@]}
		do
			valuetest=$(( $(date -d $value +%s) - $(date -d $limit +%s) )) 
			if [ $valuetest -gt 0 ]
			then
				ligne=$(grep -n $value $todo | awk -F ':' '{print $1}')
				$(sed -i "$ligne"'i'"[$limit]\n-$addtolist" $todo)
				break
			elif [ $valuetest -eq 0 ]
			then
				ligne=$(grep -n $value $todo | awk -F ':' '{print $1}')
				$(sed -i "$ligne"'a'"-$addtolist" $todo)
				break
			fi
		done
	fi
	
	 
	banner "Event added ."
	show
	what
}

modify()
{
	 
	banner "Modify list." "Printing list :"
	cat -n $todo
	question "Select lines to remove.(descending order)"
	read -a listdate
	echo ${listdate[*]}
	for value in ${listdate[@]}
	do
		$(sed -i "$value"'d' $todo )
	done
	 
	show
	what
}

begin()
{
	 
	update
	show
	what
}

#starting script
if [ -f "$todo" ]
then
	begin
else
	touch $todo
	echo "[$today]" >> $todo
	begin
fi

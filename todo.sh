#!/bin/bash

#déclaration des variable
#modifier todo pour changer le path du fichier (e.g. $HOME/todo)
todo=$HOME/.todo
jour=$(date +%Y-%m-%d)
jour=$(date -d $jour +%s)
annee=$(date +%Y)

#déclaration des fonctions
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
	for value in $(grep $annee $todo | cut -c2-11 )
	do
		valuetest=$(($(date -d $value +%s) - $jour)) 
		if [ $valuetest -eq 0 ]
		then
			ligne=$(grep -n $value $todo | cut -c1-1)
			$(sed -i "$ligne"'i (date du jour)' $todo)
			if [ $ligne -gt 1 ]
			then
				$(sed -i "$ligne"',$!d' $todo)
			fi
			break
		elif [ $valuetest -gt 0 ]
		then
			ligne=$(grep -n $value $todo | cut -c1-1)
			$(sed -i "$ligne"'i (jours à venir)' $todo)
			if [ $ligne -gt 1 ]
			then
				$(sed -i "$ligne"',$!d' $todo)
			fi
			break
		fi
	done
}

afficher()
{
banner "To do list."
cat $todo
}

faire()
{
	echo
	question "Que faire ?" "(a)jouter, (m)odifier, (*)quitter"
	read modif
	
	case $modif in
		a)
			ajout
			;;
		m)
			modifier
			;;
		*)
			exit
			;;
	esac
}

ajout()
{
	clear
	afficher
	banner "Ajout d'un évenement."
	question "Date limite ?(MM-JJ)"
	read limite
	limite=$annee-$limite
	diff=$(($(date -d $limite +%s) - $jour))

	if [ $diff -lt 0 ]
	then
		limite=$(date -d $limite+"1 year" +%Y-%m-%d)
	fi

	echo
	question "Événement à ajouter ?"
	read addtolist
	read -d '' -r -a listedate <<< $(grep -F "[" $todo | cut -c2-11 )
	dernieredate=${listedate[-1]}
	diffddate=$(( $(date -d $dernieredate +%s) - $(date -d $limite +%s) ))
	if [ $diffddate -lt 0 ]
	then
		$(sed -i '$a'"[$limite]\n-$addtolist" $todo)
	else
		for value in ${listedate[@]}
		do
			valuetest=$(( $(date -d $value +%s) - $(date -d $limite +%s) )) 
			if [ $valuetest -gt 0 ]
			then
				ligne=$(grep -n $value $todo | awk -F ':' '{print $1}')
				$(sed -i "$ligne"'i'"[$limite]\n-$addtolist" $todo)
				break
			elif [ $valuetest -eq 0 ]
			then
				ligne=$(grep -n $value $todo | awk -F ':' '{print $1}')
				$(sed -i "$ligne"'a'"-$addtolist" $todo)
				break
			fi
		done
	fi
	
	clear
	banner "Événement ajouté."
	afficher
	faire
}

modifier()
{
	clear
	banner "Modifier la liste." "Affichage de la liste :"
	cat -n $todo
	question "Selectionner les lignes à supprimer.(par ordre décroissant)"
	read -a listedate
	echo ${listedate[*]}
	for value in ${listedate[@]}
	do
		$(sed -i "$value"'d' $todo )
	done
	clear
	afficher
	faire
}

begin()
{
	clear
	update
	afficher
	faire
}

#début du script
begin

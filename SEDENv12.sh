#!/bin/sh

#Initialize variables

NONE=0

#change type is assigned 1 or combination of 2...

CHANGE_TYPE=$NONE
LOWERCASE=1
UPPERCASE=2
SED_MODE=3
RECURSIVE=10
SED_PATTERN=""
SCRIPTNAME=`basename $0`

getHelp() {       
cat<<EOT
  Usage rules:
  The command requires minimum of 2 parameters to work
  $0 [-r] [-l|-u] <dir/file names...>
  $0 [-r] <sed pattern> <dir/file names...>
  $0 [-h]

  Where:
	-l lowerizes specified filenames
	-u uppersizes specified filenames
	-r runs the script with recursion
	-h prints this help
EOT
exit

}

#----------------------------------------------------------------------------------------
#modifies a file

modify_a_file(){

                current_file_name=`basename "$filename"`
                current_path=`dirname "$filename"`
 
                #Don't modify the script
                if [ "$current_file_name" = "$SCRIPTNAME" ] ; then
                        return
                fi
 
                case $CHANGE_TYPE in
                        1|11) NEW_NAME=`echo "$current_file_name" |  tr [:upper:] [:lower:]` ;;
                        2|12) NEW_NAME=`echo "$current_file_name" |  tr [:lower:] [:upper:]` ;;
                        3|13) NEW_NAME=`echo "$current_file_name" |  sed -s $SED_PATTERN` ;;
                esac


   		#check if new file already exists then name modified is failed

                if [ -f "$current_path/$NEW_NAME" ] ; then
                         `echo "File $NEW_NAME already exists, name modifying is failed" 1>&2`
                        return
                else
                        #rename the file 

   			mv "$current_path/$current_file_name" "$current_path/$NEW_NAME"
			echo "The $current_file_name is changed to $NEW_NAME"

                fi  
		
   
}
# ----------------------------------------------------------------------------------------
#Chek the file name if it is a folder

CHECK_IF_FOLDER(){


        #Check if the file exists

        if [ ! -f "$filename" -a ! -d "$filename" ] ; then
                        `echo "Neither file name nor directory --$1-- exists" 1>&2`
			getHelp
                        exit
        fi

 	#Check if the file could be modified

        if [ ! -w "$filename" -a -f "$filename" ]; then
                `echo "File $filename cannot be modified" 1>&2`
                exit
        fi

	#if change_type is greater than recursive and a file name then do to RecursiveChange function

	if [ $CHANGE_TYPE -gt $RECURSIVE -a -d $filename ] ; then
		RecursiveChange 
	#else goes to modify a file

	elif [ $CHANGE_TYPE -lt $RECURSIVE -a -f $filename ] ; then
		modify_a_file
	else
		
	getHelp

	fi

}

#---------------------------------------------------------------------------------

#RecursiveChange function when there is a recursion

RecursiveChange () {

	recursive_dir_name=$filename

	#use find comment to recurse into directory tree and return all the file names in the tree

	for recursive_file_name in $(find $recursive_dir_name -depth -type f)
	do
  	
  	filename=$recursive_file_name
	modify_a_file

	done

}


#------------------------------------------------------------------------------
#body of the script

if [ $# -eq 0 ]; then
        getHelp
fi
 
while [ "$1" != "" ]; do
        case $1 in
                -r)  CHANGE_TYPE=`expr $CHANGE_TYPE + $RECURSIVE`;;
                -l)  CHANGE_TYPE=`expr $CHANGE_TYPE + $LOWERCASE` ;;
                -u)  CHANGE_TYPE=`expr $CHANGE_TYPE + $UPPERCASE` ;;
                -h)  getHelp

                      exit ;;
                *)
                
                #if [ $CHANGE_TYPE -eq 0 -o $CHANGE_TYPE -eq 10 ]; then
		if [ $CHANGE_TYPE = $NONE ]; then
		echo $CHANGE_TYPE $SED_MODE
                       CHANGE_TYPE=`expr $CHANGE_TYPE + $SED_MODE`
                        SED_PATTERN=$1
                else
			filename=$1
                        CHECK_IF_FOLDER 
                fi
                ;;
        esac
shift
done

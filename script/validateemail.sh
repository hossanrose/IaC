#!/bin/bash 

###################################################################
#Script Name	:validateemail.sh                                                                                             
#Description	:Checks a list of emails and prints out the invalid mails based on RFC 5322
		# Email syntax local-part@domain

		## local-part rules
		# * uppercase and lowercase Latin letters A to Z and a to z
		# * digits 0 to 9
		# * printable characters !#$%&'*+-/=?^_`{|}~
		# * dot ., provided that it is not the first or last character and provided also that it does not appear consecutively (e.g., John..Doe@example.com is not allowed).[8]
		# * space and special characters "(),:;<>@[\] are allowed with restrictions (they are only allowed inside a quoted string, as described in the paragraph below, and in addition, a backslash or double-quote must be preceded by a backslash);

		## domain rules
		# * uppercase and lowercase Latin letters A to Z and a to z
		# * digits 0 to 9, provided that top-level domain names are not all-numeric
		# * hyphen -, provided that it is not the first or last character
		# * domain may be an IP address literal, surrounded by square brackets []
#Author       	:Hossan Rose                                                
#Email         	:hossan.rose@                                          
###################################################################

IFS=$'\n'
email_list=email_addresses.txt
counter=0
output=/tmp/output.txt; > $output

for email in `cat $email_list`
do 
	counter=$(($counter+1)) 
    	if [[ $email =~ (^[a-z0-9*+\/=?_{|}~-]+(\.[a-z0-9*+\/=?_{|}~-]+)*|\"([\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*\")@(([a-zA-Z0-9]+[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|(\[((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3})(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])\]|(example)) ]]
    	then
#        	echo "Email address $email is valid."
		echo "Valid -------- $email"
    	else
#        	echo "$counter $email"
        	echo "$counter $email" >> $output
	
    	fi
done

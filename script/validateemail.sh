#!/bin/bash 

###################################################################
#Script Name	:validateemail.sh                                                                                             
#Description	:Checks a list of emails and prints out the invalid mails based on RFC 5322
		# Email syntax local-part@domain

		## local-part rules
		# * uppercase and lowercase Latin letters A to Z and a to z
		# * digits 0 to 9
		# * printable characters, ex:  +-_
		# * dot ., provided that it is not the first or last character and provided also that it does not appear consecutively (e.g., John..Doe@example.com is not allowed)
		# * space and special characters "(),:;<>@[\] are allowed with restrictions (they are only allowed inside a quoted string, ex: ".John.Doe"@example.com, "John.Doe."@example.com and "John..Doe"@example.com are allowed.

		## domain rules
		# * uppercase and lowercase Latin letters A to Z and a to z
		# * digits 0 to 9, provided that top-level domain names are not all-numeric
		# * hyphen -, provided that it is not the first or last character
		# * domain may be an IP address literal, surrounded by square brackets []

		## Comment rule
		# Comments are allowed in the domain as well as in the local-part. ex: john.smith@(comment)example.com and john.smith@example.com(comment) 

#Author       	:Hossan Rose                                                
###################################################################

IFS=$'\n'
email_list=email_addresses.txt
counter=0
output=/tmp/output.txt; > $output

for email in `cat $email_list`
do 
	counter=$(($counter+1)) 
	if [[ $email =~ (^[a-z0-9+_-]+(\.[a-z0-9+_-]+)*|\"([\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*\")@((([a-zA-Z0-9]+[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|(example$))|(\[((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3})(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])\]) ]]
    	then
		echo "Valid email: $email"
    	else
        	echo "$counter $email" >> $output
	
    	fi
done

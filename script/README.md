## Validate email
Checks a list of emails and prints out the invalid mails based on RFC 5322

__Email syntax:__ local-part@domain

### local-part rules
* uppercase and lowercase Latin letters A to Z and a to z
* digits 0 to 9
* printable characters, ex:  +-_
* dot ., provided that it is not the first or last character and provided also that it does not appear consecutively (e.g., John..Doe@example.com is not allowed)
* space and special characters "(),:;<>@[\] are allowed with restrictions (they are only allowed inside a quoted string, ex: ".John.Doe"@example.com, "John.Doe."@example.com and "John..Doe"@example.com are allowed.

### domain rules
* uppercase and lowercase Latin letters A to Z and a to z
* digits 0 to 9, provided that top-level domain names are not all-numeric
* hyphen -, provided that it is not the first or last character
* domain may be an IP address literal, surrounded by square brackets []
* some special cases like example , localhost are accepted without top level domain


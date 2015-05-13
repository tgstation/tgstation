//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
	Class: Token
	Represents an entity and position in the source code.
*/
/token
	var/value
	var/line
	var/column

	New(v, l=0, c=0)
		value=v
		line=l
		column=c

	string
	symbol
	word
	keyword
	number
		New()
			.=..()
			if(!isnum(value))
				value=text2num(value)
				ASSERT(!isnull(value))
	accessor
		var/object
		var/member

		New(object, member, l=0, c=0)
			src.object=object
			src.member=member
			src.value="[object].[member]" //for debugging only
			src.line=l
			src.column=c

	end

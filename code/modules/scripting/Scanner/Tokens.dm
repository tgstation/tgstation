/*
	Class: Token
	Represents an entity and position in the source code.
*/
/token
	var
		value
		line
		column

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
		var
			object
			member

		New(object, member, l=0, c=0)
			src.object=object
			src.member=member
			src.value="[object].[member]" //for debugging only
			src.line=l
			src.column=c

	end
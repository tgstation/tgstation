/*
	Class: Token
	Represents an entity and position in the source code.
*/
/datum/token
	var/value
	var/line
	var/column

/datum/token/New(v, l = 0, c = 0)
	value = v
	line = l
	column = c

/datum/token/string

/datum/token/symbol

/datum/token/word

/datum/token/keyword

/datum/token/number/New()
	. = ..()
	if(!isnum(value))
		value = text2num(value)
		ASSERT(!isnull(value))

/datum/token/accessor
	var/object
	var/member

/datum/token/accessor/New(object, member, l = 0, c = 0)
	src.object	= object
	src.member	= member
	src.value	= "[object].[member]" //for debugging only
	src.line	= l
	src.column	= c

/datum/token/end

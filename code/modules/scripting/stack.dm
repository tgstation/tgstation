/datum/stack
	var/list/contents = list()

/datum/stack/proc/Push(value)
	contents += value

/datum/stack/proc/Pop()
	if(!contents.len)
		return null

	. = contents[contents.len]
	contents.len--

/datum/stack/proc/Top() //returns the item on the top of the stack without removing it
	if(!contents.len)
		return null

	return contents[contents.len]

/datum/stack/proc/Copy()
	var/datum/stack/S = new()
	S.contents = src.contents.Copy()
	return S

/datum/stack/proc/Clear()
	contents.Cut()
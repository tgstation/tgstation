/datum/fantasy_affix
	///only used for admins adding the affix, this is not what players will see.
	var/name = "SOMEONE DIDN'T SET AN ADMIN NAME FOR THIS"
	var/placement // A bitflag of "slots" this affix takes up, for example pre/suffix
	var/alignment
	var/weight = 10

// For those occasional affixes which only make sense in certain circumstances
/datum/fantasy_affix/proc/validate(obj/item/attached)
	return TRUE

/datum/fantasy_affix/proc/apply(datum/component/fantasy/comp, newName)
	return newName

/datum/fantasy_affix/proc/remove(datum/component/fantasy/comp)

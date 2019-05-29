/datum/fantasy_affix
	var/placement // A bitflag of "slots" this affix takes up, for example pre/suffix
	var/alignment
	var/weight = 10

/datum/fantasy_affix/proc/apply(datum/component/fantasy/comp, newName)
	return newName

/datum/fantasy_affix/proc/remove(datum/component/fantasy/comp)
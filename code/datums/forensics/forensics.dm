//////////////////////FORENSICS DATUM
/datum/forensics
	var/list/gsr
	var/list/prints
	var/list/hiddenprints
	var/list/fibers
	var/list/blood
	var/maxSize = 5

/datum/forensics/proc/enforceSize(list/templist, newthing)
	if(templist.len >= maxSize)
		templist.Remove(templist[1])
		templist |= newthing
	return newthing

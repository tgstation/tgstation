//////////////////////FORENSICS DATUM
/datum/forensics
	var/gsr = list()
	var/prints = list()
	var/blood = list()
	var/maxSize = 5

/datum/forensics/proc/enforceSize(templist, newthing)
	if(templist.len >= maxSize)
		templist.Remove(templist[1])
		templist |= newthing
	return newthing


/datum/forensics/proc/addResidue(residueref)
	var/tgsr = gsr.Copy()
	if(!tgsr.Find(residueref))
		gsr = enforceSize(tgsr, residueref)
		return TRUE
	return FALSE

/datum/forensics/proc/addPrint(printref)
	var/tprint = prints.Copy()
	if(!tprint.Find(printref))
		prints = enforceSize(tprint, printref)
		return TRUE
	return FALSE

/datum/forensics/proc/addBlood(bloodref)
	var/tblood = blood.Copy()
	if(!tblood.Find(bloodref))
		blood = enforceSize(tblood, bloodref)
		return TRUE
	return FALSE

/datum/forensics/proc/getPrints()
	return prints

/datum/forensics/proc/getResidue()
	return gsr

/datum/forensics/proc/getBlood()
	return blood
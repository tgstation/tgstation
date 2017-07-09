//////////////////////FORENSICS DATUM
/datum/forensics
	var/gsr = list()
	var/prints = list()
	var/blood = list()
	var/maxSize = 5

/datum/forensics/proc/enforceSize(list/templist, newthing)
	if(templist.len >= maxSize)
		templist.Remove(templist[1])
		templist |= newthing
	return newthing


/datum/forensics/proc/addResidue(residueref)
	var/tgsr = src.gsr.Copy()
	if(!tgsr.Find(residueref))
		src.gsr = enforceSize(tgsr, residueref)
		return TRUE
	return FALSE

/datum/forensics/proc/addPrint(printref)
	var/tprint = src.prints.Copy()
	if(!tprint.Find(printref))
		src.prints = enforceSize(tprint, printref)
		return TRUE
	return FALSE

/datum/forensics/proc/addBlood(bloodref)
	var/tblood = src.blood.Copy()
	if(!tblood.Find(bloodref))
		src.blood = enforceSize(tblood, bloodref)
		return TRUE
	return FALSE

/datum/forensics/proc/getPrints()
	return src.prints

/datum/forensics/proc/getResidue()
	return src.gsr

/datum/forensics/proc/getBlood()
	return src.blood
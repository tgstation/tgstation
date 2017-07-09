//////////////////////FORENSICS DATUM
/datum/forensics
	var/list/gsr
	var/list/prints
	var/list/blood
	var/maxSize = 5

/datum/forensics/proc/enforceSize(list/templist, newthing)
	if(templist.len >= maxSize)
		templist.Remove(templist[1])
		templist |= newthing
	return newthing


/datum/forensics/proc/addResidue(residueref)
	if(!gsr.Find(residueref))
		src.gsr = enforceSize(gsr, residueref)
		return TRUE
	return FALSE

/datum/forensics/proc/addPrint(printref)
	if(!prints.Find(printref))
		src.prints = enforceSize(prints, printref)
		return TRUE
	return FALSE

/datum/forensics/proc/addBlood(bloodref)
	if(!blood.Find(bloodref))
		src.blood = enforceSize(blood, bloodref)
		return TRUE
	return FALSE

/datum/forensics/proc/getPrints()
	return src.prints

/datum/forensics/proc/getResidue()
	return src.gsr

/datum/forensics/proc/getBlood()
	return src.blood
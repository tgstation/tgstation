//////////////////////FORENSICS DATUM
/datum/forensics
	var/list/gsr
	var/list/prints
	var/list/hiddenprints
	var/list/fibers
	var/list/blood
	var/maxSize = 5

/datum/forensics/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = blood
	if(!new_blood_dna)
		return 0
	var/old_length = blood.len
	blood |= new_blood_dna
	if(blood.len == old_length)
		return 0
	return 1

/obj/proc/transfer_mob_blood_dna(mob/living/L)
	. = forensics.transfer_mob_blood_dna(L)

//to add blood dna info to the object's blood_DNA list
/datum/forensics/proc/transfer_blood_dna(list/blood_dna)
	var/old_length = blood.len
	blood |= blood_dna
	if(blood.len > old_length)
		return 1//some new blood DNA was added

/obj/proc/transfer_blood_dna(list/blood_dna)
	. = forensics.transfer_blood_dna(blood_dna)

//to add blood from a mob onto something, and transfer their dna info
/datum/forensics/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.forensics.blood
	if(!blood_dna)
		return 0
	return add_blood(blood_dna)

/obj/proc/add_mob_blood(mob/living/M)
	. = forensics.add_mob_blood(M)


/datum/forensics/proc/add_blood(list/blood_dna)
	return 0

/obj/proc/add_blood(list/blood_dna)
	. = forensics.transfer_blood_dna(blood_dna)

//to add blood onto something, with blood dna info to include.


/obj/item/add_blood(list/blood_dna)
	var/blood_count = !forensics.blood ? 0 : forensics.blood.len
	if(!..())
		return 0
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay()
	return 1 //we applied blood to the item

/datum/forensics/proc/clean_blood()
	if(islist(blood))
		blood = null
		return 1

/obj/proc/clean_blood()
	. = forensics.clean_blood()
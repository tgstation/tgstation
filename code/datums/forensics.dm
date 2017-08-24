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
		return FALSE
	var/old_length = blood.len
	blood |= new_blood_dna
	if(blood.len == old_length)
		return FALSE
	return TRUE

/obj/proc/transfer_mob_blood_dna(mob/living/L)
	. = forensics.transfer_mob_blood_dna(L)

//to add blood dna info to the object's blood_DNA list
/datum/forensics/proc/transfer_blood_dna(list/blood_dna)
	var/old_length = blood.len
	blood |= blood_dna
	if(blood.len > old_length)
		return TRUE //some new blood DNA was added

/obj/proc/transfer_blood_dna(list/blood_dna)
	. = forensics.transfer_blood_dna(blood_dna)

//to add blood from a mob onto something, and transfer their dna info
/datum/forensics/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.forensics.blood
	if(!blood_dna)
		return FALSE
	return add_blood(blood_dna)

/obj/proc/add_mob_blood(mob/living/M)
	. = forensics.add_mob_blood(M)

/datum/forensics/proc/add_blood(list/blood_dna)
	return FALSE

/obj/proc/add_blood(list/blood_dna)
	. = forensics.transfer_blood_dna(blood_dna)

//to add blood onto something, with blood dna info to include.


/obj/item/add_blood(list/blood_dna)
	var/blood_count = !forensics.blood ? 0 : forensics.blood.len
	if(!..())
		return FALSE
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay()
	return TRUE //we applied blood to the item

/datum/forensics/proc/clean_blood()
	if(islist(blood))
		blood = list()
		return TRUE
	return FALSE

/obj/proc/clean_blood()
	. = forensics.clean_blood()

/datum/forensics/proc/clean_prints()
	if(islist(prints))
		prints = list()
		return TRUE
	return FALSE

/obj/proc/clean_prints()
	. = forensics.clean_prints()


/datum/forensics/proc/add_hiddenprint(mob/living/M)
	if(!M || !M.key)
		return

	if(M.forensics.hiddenprints) //Add the list if it does not exist
		M.forensics.hiddenprints = list()

	var/hasgloves = ""
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			hasgloves = "(gloves)"

	var/current_time = time_stamp()
	if(!M.forensics.hiddenprints[M.key])
		M.forensics.hiddenprints[M.key] = "First: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"
	else
		var/laststamppos = findtext(M.forensics.hiddenprints[M.key], " Last: ")
		if(laststamppos)
			M.forensics.hiddenprints[M.key] = copytext(M.forensics.hiddenprints[M.key], 1, laststamppos)
		M.forensics.hiddenprints[M.key] += " Last: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"

	fingerprintslast = M.ckey

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/datum/forensics/proc/add_fingerprint(mob/living/M, ignoregloves = 0)
	if(!M || !M.key)
		return

	M.add_hiddenprint(M)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		M.forensics.add_fibers(H)

		if(H.gloves) //Check if the gloves (if any) hide fingerprints
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = 1

			if(!ignoregloves)
				H.gloves.add_fingerprint(H, 1) //ignoregloves = 1 to avoid infinite loop.
				return

		if(!M.forensics.prints) //Add the list if it does not exist
			M.forensics.prints = list()
		var/full_print = md5(H.dna.uni_identity)
		M.forensics.prints[full_print] = full_print

/datum/forensics/proc/add_fibers(mob/living/carbon/human/M)
	var/datum/forensics/forensics = M.forensics
	if(M.gloves && istype(M.gloves, /obj/item/clothing/))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(forensics.add_blood(G.forensics.blood)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		if(forensics.add_blood(M.forensics.blood))
			M.bloody_hands--
	if(!forensics.fibers) forensics.fibers = list()
	var/fibertext
	var/item_multiplier = isitem(src)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in forensics.fibers))
			forensics.fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & CHEST))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !(fibertext in forensics.fibers)) //Wearing a suit means less of the uniform exposed.
					forensics.fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				forensics.fibers = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !(fibertext in forensics.fibers))
					forensics.fibers += fibertext
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in forensics.fibers))
			// "Added fibertext: [fibertext]"
			forensics.fibers += fibertext
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !(fibertext in forensics.fibers))
				forensics.fibers += "Material from a pair of [M.gloves.name]."
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in forensics.fibers))
			forensics.fibers += "Material from a pair of [M.gloves.name]."

/atom/proc/add_fibers(mob/living/carbon/human/M)
	. = forensics.add_fibers(M)

/datum/forensics/proc/transfer_fingerprints_to(atom/A)

	// Make sure everything are lists.
	if(!islist(A.forensics.prints))
		A.forensics.prints = list()
	if(!islist(A.forensics.hiddenprints))
		A.forensics.hiddenprints = list()

	if(!islist(prints))
		prints = list()
	if(!islist(hiddenprints))
		hiddenprints = list()

	// Transfer
	if(LAZYLEN(prints))
		A.forensics.prints |= prints.Copy()            //detective
	if(LAZYLEN(hiddenprints))
		A.forensics.hiddenprints |= hiddenprints.Copy()    //admin
	A.fingerprintslast = fingerprintslast


/atom/proc/transfer_fingerprints_to(atom/A)
	return forensics.transfer_fingerprints_to(A)

/atom/proc/add_fingerprint(mob/living/M, ignoregloves = 0)
	return forensics.add_fingerprint(M, ignoregloves)

/atom/proc/add_hiddenprint(mob/living/M)
	return forensics.add_hiddenprint(M)
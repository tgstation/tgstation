//CONTAINS: Suit fibers and Detective's Scanning Computer

/atom/proc/return_fingerprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		return D.fingerprints

/atom/proc/return_hiddenprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		return D.hiddenprints

/atom/proc/return_blood_DNA()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		return D.blood_DNA

/atom/proc/blood_DNA_length()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		return length(D.blood_DNA)

/atom/proc/return_fibers()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		return D.fibers

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/M, ignoregloves = FALSE)
	var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
	. = D.add_fingerprint(M, ignoregloves)

/atom/proc/add_fibers(mob/living/carbon/human/M)
	var/old = 0
	if(M.gloves && istype(M.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/G = M.gloves
		old = length(G.return_blood_DNA())
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(G.return_blood_DNA()) && length(G.return_blood_DNA()) > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		old = length(M.return_blood_DNA())
		if(add_blood_DNA(M.return_blood_DNA()) && length(M.return_blood_DNA()) > old)
			M.bloody_hands--
	var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
	. = D.add_fibers(M)

/atom/proc/add_hiddenprint(mob/M)
	var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
	. = D.add_hiddenprint(M)

/atom/proc/add_blood_DNA(list/dna)						//ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/dna)
	. = ..()
	if(length(dna))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		D.blood_DNA = D.blood_DNA | dna //Use of | and |= being different here is INTENTIONAL.
		D.check_blood()

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	B.add_blood_DNA(blood_dna) //give blood info to the blood decal.
	return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_dna)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_dna)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood_DNA(blood_dna)
	else if(length(blood_dna))
		var/datum/component/forensics/D = LoadComponent(/datum/component/forensics)
		D.blood_DNA = D.blood_DNA | blood_dna //Use of | and |= being different here is INTENTIONAL.
		D.check_blood()
		bloody_hands = rand(2, 4)
	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE

/atom/proc/transfer_fingerprints_to(atom/A) //Use of | and |= being different here is INTENTIONAL.
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(!D) // no point transferring fingerprints etc. if we don't even have the fuckin tracker
		return
	var/datum/component/forensics/AD = A.LoadComponent(/datum/component/forensics)
	AD.fingerprints = AD.fingerprints | D.fingerprints
	AD.hiddenprints = AD.hiddenprints | D.hiddenprints
	A.fingerprintslast = fingerprintslast
	AD.check_blood()

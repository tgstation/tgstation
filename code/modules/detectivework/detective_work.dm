//CONTAINS: Suit fibers, GSR, and Detective's Scanning Computer

/atom/var/list/suit_fibers

/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && istype(M.gloves, /obj/item/clothing/))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(forensics.add_blood(G.forensics.blood)) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		if(forensics.add_blood(M.forensics.blood))
			M.bloody_hands--
	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = isitem(src)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & CHEST))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !(fibertext in suit_fibers)) //Wearing a suit means less of the uniform exposed.
					suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
					suit_fibers += fibertext
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in suit_fibers))
			// "Added fibertext: [fibertext]"
			suit_fibers += fibertext
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
				suit_fibers += "Material from a pair of [M.gloves.name]."
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += "Material from a pair of [M.gloves.name]."


/atom/proc/add_hiddenprint(mob/living/M)
	if(!M || !M.key)
		return

	if(forensics.hiddenprints) //Add the list if it does not exist
		forensics.hiddenprints = list()

	var/hasgloves = ""
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			hasgloves = "(gloves)"

	var/current_time = time_stamp()
	if(!forensics.hiddenprints[M.key])
		forensics.hiddenprints[M.key] = "First: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"
	else
		var/laststamppos = findtext(forensics.hiddenprints[M.key], " Last: ")
		if(laststamppos)
			forensics.hiddenprints[M.key] = copytext(forensics.hiddenprints[M.key], 1, laststamppos)
		forensics.hiddenprints[M.key] += " Last: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"

	fingerprintslast = M.ckey


//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/living/M, ignoregloves = 0)
	if(!M || !M.key)
		return

	add_hiddenprint(M)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		add_fibers(H)

		if(H.gloves) //Check if the gloves (if any) hide fingerprints
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = 1

			if(!ignoregloves)
				H.gloves.add_fingerprint(H, 1) //ignoregloves = 1 to avoid infinite loop.
				return

		if(!forensics.prints) //Add the list if it does not exist
			forensics.prints = list()
		var/full_print = md5(H.dna.uni_identity)
		forensics.prints[full_print] = full_print




/atom/proc/transfer_fingerprints_to(atom/A)

	// Make sure everything are lists.
	if(!islist(A.forensics.prints))
		A.forensics.prints = list()
	if(!islist(A.forensics.hiddenprints))
		A.forensics.hiddenprints = list()

	if(!islist(forensics.prints))
		forensics.prints = list()
	if(!islist(forensics.hiddenprints))
		forensics.hiddenprints = list()

	// Transfer
	if(forensics && forensics.prints)
		A.forensics.prints |= forensics.prints.Copy()            //detective
	if(forensics.hiddenprints)
		A.forensics.hiddenprints |= forensics.hiddenprints.Copy()    //admin
	A.fingerprintslast = fingerprintslast

/atom/proc/add_gsr(mob/living/carbon/human/M, gsrtype)
	if(M.gloves && istype(M.gloves,/obj/item/clothing/))
		var/obj/item/clothing/gloves/G = M.gloves
		G.forensics.gsr |= gsrtype


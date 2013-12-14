/proc/getAssignedBlock(var/name,var/list/blocksLeft, var/activity_bounds=DNA_DEFAULT_BOUNDS)
	var/assigned = pick(blocksLeft)
	blocksLeft.Remove(assigned)
	assigned_blocks[assigned]=name
	dna_activity_bounds[assigned]=activity_bounds
	//testing("[name] assigned to block #[assigned].")
	return assigned

/proc/setupgenetics()

	if (prob(50))
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	//Thanks to nexis for the fancy code
	// BITCH I AIN'T DONE YET

	// SE blocks to assign.
	var/list/numsToAssign=new()
	for(var/i=1;i<STRUCDNASIZE;i++)
		numsToAssign += i

	//testing("Assigning DNA blocks:")

	// Standard muts
	BLINDBLOCK         = getAssignedBlock("BLIND",         numsToAssign)
	DEAFBLOCK          = getAssignedBlock("DEAF",          numsToAssign)
	HULKBLOCK          = getAssignedBlock("HULK",          numsToAssign, DNA_HARD_BOUNDS)
	TELEBLOCK          = getAssignedBlock("TELE",          numsToAssign, DNA_HARD_BOUNDS)
	FIREBLOCK          = getAssignedBlock("FIRE",          numsToAssign, DNA_HARDER_BOUNDS)
	XRAYBLOCK          = getAssignedBlock("XRAY",          numsToAssign, DNA_HARDER_BOUNDS)
	CLUMSYBLOCK        = getAssignedBlock("CLUMSY",        numsToAssign)
	FAKEBLOCK          = getAssignedBlock("FAKE",          numsToAssign)
	COUGHBLOCK         = getAssignedBlock("COUGH",         numsToAssign)
	GLASSESBLOCK       = getAssignedBlock("GLASSES",       numsToAssign)
	EPILEPSYBLOCK      = getAssignedBlock("EPILEPSY",      numsToAssign)
	TWITCHBLOCK        = getAssignedBlock("TWITCH",        numsToAssign)
	NERVOUSBLOCK       = getAssignedBlock("NERVOUS",       numsToAssign)

	// Bay muts
	HEADACHEBLOCK      = getAssignedBlock("HEADACHE",      numsToAssign)
	NOBREATHBLOCK      = getAssignedBlock("NOBREATH",      numsToAssign, DNA_HARD_BOUNDS)
	REMOTEVIEWBLOCK    = getAssignedBlock("REMOTEVIEW",    numsToAssign, DNA_HARDER_BOUNDS)
	REGENERATEBLOCK    = getAssignedBlock("REGENERATE",    numsToAssign, DNA_HARDER_BOUNDS)
	INCREASERUNBLOCK   = getAssignedBlock("INCREASERUN",   numsToAssign, DNA_HARDER_BOUNDS)
	REMOTETALKBLOCK    = getAssignedBlock("REMOTETALK",    numsToAssign, DNA_HARDER_BOUNDS)
	MORPHBLOCK         = getAssignedBlock("MORPH",         numsToAssign, DNA_HARDER_BOUNDS)
	COLDBLOCK          = getAssignedBlock("COLD",          numsToAssign)
	HALLUCINATIONBLOCK = getAssignedBlock("HALLUCINATION", numsToAssign)
	NOPRINTSBLOCK      = getAssignedBlock("NOPRINTS",      numsToAssign, DNA_HARD_BOUNDS)
	SHOCKIMMUNITYBLOCK = getAssignedBlock("SHOCKIMMUNITY", numsToAssign)
	SMALLSIZEBLOCK     = getAssignedBlock("SMALLSIZE",     numsToAssign, DNA_HARD_BOUNDS)

	// And the genes that actually do the work. (domutcheck improvements)
	var/list/blocks_assigned[STRUCDNASIZE]
	for(var/gene_type in typesof(/datum/dna/gene))
		var/datum/dna/gene/G = new gene_type
		if(G.block)
			if(G.block in blocks_assigned)
				warning("DNA2: Gene [G.name] trying to use already-assigned block [G.block] (used by [english_list(blocks_assigned[G.block])])")
			dna_genes.Add(G)
			var/list/assignedToBlock[0]
			if(blocks_assigned[G.block])
				assignedToBlock=blocks_assigned[G.block]
			assignedToBlock.Add(G.name)
			blocks_assigned[G.block]=assignedToBlock
			testing("DNA2: Gene [G.name] assigned to block [G.block].")

// Run AFTER genetics setup and AFTER species setup.
/proc/setup_species()
	// SPECIES GENETICS FUN
	for(var/name in all_species)
		// I hate BYOND.  Can't just call while it's in the list.
		var/datum/species/species = all_species[name]
		if(species.default_block_names.len>0)
			testing("Setting up genetics for [species.name] (needs [english_list(species.default_block_names)])")
			species.default_blocks.Cut()
			for(var/block=1;block<STRUCDNASIZE;block++)
				if(assigned_blocks[block] in species.default_block_names)
					testing("  Found [assigned_blocks[block]] ([block])")
					species.default_blocks.Add(block)
			if(species.default_blocks.len)
				all_species[name]=species


/proc/setupfactions()

	// Populate the factions list:
	for(var/x in typesof(/datum/faction))
		var/datum/faction/F = new x
		if(!F.name)
			del(F)
			continue
		else
			ticker.factions.Add(F)
			ticker.availablefactions.Add(F)

	// Populate the syndicate coalition:
	for(var/datum/faction/syndicate/S in ticker.factions)
		ticker.syndicate_coalition.Add(S)


/* This was used for something before, I think, but is not worth the effort to process now.
/proc/setupcorpses()
	for (var/obj/effect/landmark/A in landmarks_list)
		if (A.name == "Corpse")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			del(A)
			continue
		if (A.name == "Corpse-Engineer")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/device/pda/engineering(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(M), slot_shoes)
		//	M.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_r_store)
			//M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			if (prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if (prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(M), slot_head)
			else
				if (prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/welding(M), slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Engineer-Space")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space(M), slot_wear_suit)
		//	M.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if (prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(M), slot_head)
			else
				if (prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/welding(M), slot_head)
				else
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space(M), slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Engineer-Chief")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/utilitybelt(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_engineer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(M), slot_shoes)
		//	M.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/t_scanner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			if (prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if (prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/hardhat(M), slot_head)
			else
				if (prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/welding(M), slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Syndicate")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			//M.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/jetpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(M), slot_wear_mask)
			if (prob(50))
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/syndicate(M), slot_wear_suit)
				if (prob(50))
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
				else
					M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/syndicate(M), slot_head)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(M), slot_head)
			del(A)
			continue
*/

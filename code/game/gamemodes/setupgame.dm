/proc/setupgenetics()

	if (prob(50))
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	var/list/avnums = list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26)
	var/tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HULKBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	TELEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	FIREBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	XRAYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	CLUMSYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	FAKEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	DEAFBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	BLINDBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HEADACHEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	COUGHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	TWITCHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NERVOUSBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NOBREATHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REMOTEVIEWBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REGENERATEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	INCREASERUNBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REMOTETALKBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	MORPHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	BLENDBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HALLUCINATIONBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NOPRINTSBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	SHOCKIMMUNITYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	SMALLSIZEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	GLASSESBLOCK = tempnum


	// HIDDEN MUTATIONS / SUPERPOWERS INITIALIZTION

/*
	for(var/x in typesof(/datum/mutations) - /datum/mutations)
		var/datum/mutations/mut = new x

		for(var/i = 1, i <= mut.required, i++)
			var/datum/mutationreq/require = new/datum/mutationreq
			require.block = rand(1, 13)
			require.subblock = rand(1, 3)

			// Create random requirement identification
			require.reqID = pick("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", \
							 "B", "C", "D", "E", "F")

			mut.requirements += require


		global_mutations += mut// add to global mutations list!
*/


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
	for (var/obj/effect/landmark/A in world)
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
			M.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/device/pda/engineering(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/rank/engineer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/orange(M), M.slot_shoes)
		//	M.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/clothing/gloves/yellow(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/t_scanner(M), M.slot_r_store)
			//M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(M), M.slot_head)
			else
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Engineer-Space")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/rank/engineer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/orange(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/suit/space(M), M.slot_wear_suit)
		//	M.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/clothing/gloves/yellow(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/t_scanner(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(M), M.slot_head)
			else
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
				else
					M.equip_if_possible(new /obj/item/clothing/head/helmet/space(M), M.slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Engineer-Chief")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/weapon/storage/utilitybelt(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/orange(M), M.slot_shoes)
		//	M.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/clothing/gloves/yellow(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/t_scanner(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(M), M.slot_head)
			else
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Syndicate")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			//M.equip_if_possible(new /obj/item/weapon/gun/revolver(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/syndicate(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/swat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/weapon/tank/jetpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/suit/space/syndicate(M), M.slot_wear_suit)
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/swat(M), M.slot_head)
				else
					M.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate(M), M.slot_head)
			else
				M.equip_if_possible(new /obj/item/clothing/suit/armor/vest(M), M.slot_wear_suit)
				M.equip_if_possible(new /obj/item/clothing/head/helmet/swat(M), M.slot_head)
			del(A)
			continue
*/

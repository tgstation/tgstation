/proc/setupgenetics()

	if (prob(50))
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	var/list/avnums = new/list()
	var/tempnum

	avnums.Add(2)
	avnums.Add(12)
	avnums.Add(10)
	avnums.Add(8)
	avnums.Add(4)
	avnums.Add(11)
	avnums.Add(13)
	avnums.Add(6)

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

/proc/setupcorpses()
	for (var/obj/landmark/A in world)
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
/mob/living/proc/check_devil_bane_multiplier(obj/item/weapon, mob/living/attacker)
	var/datum/antagonist/devil/devilInfo = mind.has_antag_datum(ANTAG_DATUM_DEVIL)
	switch(devilInfo.bane)
		if(BANE_WHITECLOTHES)
			if(ishuman(attacker))
				var/mob/living/carbon/human/H = attacker
				if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
					var/obj/item/clothing/under/U = H.w_uniform
					var/static/list/whiteness = list (
						/obj/item/clothing/under/color/white = 2,
						/obj/item/clothing/under/rank/bartender = 1,
						/obj/item/clothing/under/rank/chef = 1,
						/obj/item/clothing/under/rank/chief_engineer = 1,
						/obj/item/clothing/under/rank/scientist = 1,
						/obj/item/clothing/under/rank/chemist = 1,
						/obj/item/clothing/under/rank/chief_medical_officer = 1,
						/obj/item/clothing/under/rank/geneticist = 1,
						/obj/item/clothing/under/rank/virologist = 1,
						/obj/item/clothing/under/rank/nursesuit = 1,
						/obj/item/clothing/under/rank/medical = 1,
						/obj/item/clothing/under/rank/det = 1,
						/obj/item/clothing/under/suit_jacket/white = 0.5,
						/obj/item/clothing/under/burial = 1
					)
					if(U && whiteness[U.type])
						src.visible_message("<span class='warning'>[src] seems to have been harmed by the purity of [attacker]'s clothes.</span>", "<span class='notice'>Unsullied white clothing is disrupting your form.</span>")
						return whiteness[U.type] + 1
		if(BANE_TOOLBOX)
			if(istype(weapon,/obj/item/weapon/storage/toolbox))
				src.visible_message("<span class='warning'>The [weapon] seems unusually robust this time.</span>", "<span class='notice'>The [weapon] is your unmaking!</span>")
				return 2.5 // Will take four hits with a normal toolbox to crit.
		if(BANE_HARVEST)
			if(istype(weapon,/obj/item/weapon/reagent_containers/food/snacks/grown/))
				src.visible_message("<span class='warning'>The spirits of the harvest aid in the exorcism.</span>", "<span class='notice'>The harvest spirits are harming you.</span>")
				src.Weaken(2)
				qdel(weapon)
				return 2
	return 1
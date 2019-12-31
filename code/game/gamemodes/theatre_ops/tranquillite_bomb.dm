/obj/machinery/nuclearbomb/syndicate/tranquillite
	name = "tranquillite fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "tranquillitebomb_base"

/obj/machinery/nuclearbomb/syndicate/tranquillite/update_icon_state()
	if(deconstruction_state != NUKESTATE_INTACT)
		icon_state = "tranquillitebomb_base"
		return
	
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
			icon_state = "tranquillitebomb_base"
		if(NUKE_ON_TIMING)
			icon_state = "tranquillitebomb_timing"
		if(NUKE_ON_EXPLODING)
			icon_state = "tranquillitebomb_exploding"

/obj/machinery/nuclearbomb/syndicate/tranquillite/get_cinematic_type(off_station)
	switch(off_station)
		if(0)
			return CINEMATIC_NUKE_MIMEOP
		if(1)
			return CINEMATIC_NUKE_MISS
		if(2)
			return CINEMATIC_NUKE_NO_CORE //it's silent
	return CINEMATIC_NUKE_NO_CORE

/obj/machinery/nuclearbomb/syndicate/tranquillite/really_actually_explode(off_station)
	Cinematic(get_cinematic_type(off_station), world)
	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/H = i
		var/turf/T = get_turf(H)
		if(!T || T.z != z)
			continue
		H.Stun(10)
		var/obj/item/clothing/C
		if(!H.w_uniform || H.dropItemToGround(H.w_uniform))
			C = new /obj/item/clothing/under/rank/civilian/mime(H)
			ADD_TRAIT(C, TRAIT_NODROP, MIME_NUKE_TRAIT)
			H.equip_to_slot_or_del(C, ITEM_SLOT_ICLOTHING)

		if(!H.wear_suit || H.dropItemToGround(H.wear_suit))
			C = new /obj/item/clothing/suit/toggle/suspenders(H)
			ADD_TRAIT(C, TRAIT_NODROP, MIME_NUKE_TRAIT)
			H.equip_to_slot_or_del(C, ITEM_SLOT_OCLOTHING)

		if(!H.wear_mask || H.dropItemToGround(H.wear_mask))
			C = new /obj/item/clothing/mask/gas/mime(H)
			ADD_TRAIT(C, TRAIT_NODROP, MIME_NUKE_TRAIT)
			H.equip_to_slot_or_del(C, ITEM_SLOT_MASK)

		H.dna.add_mutation(MUT_MUTE)
		H.gain_trauma(/datum/brain_trauma/mild/phobia/mimes, TRAUMA_RESILIENCE_LOBOTOMY) //MWA HA HA
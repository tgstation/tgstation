/datum/round_event_control/wizard/cursed_items //fashion disasters
	name = "Cursed Items"
	weight = 3
	typepath = /datum/round_event/wizard/cursed_items/
	max_occurrences = 3
	earliest_start = 0

//Note about adding items to this: Because of how NODROP works if an item spawned to the hands can also be equiped to a slot
//it will be able to be put into that slot from the hand, but then get stuck there. To avoid this make a new subtype of any
//item you want to equip to the hand, and set its slots_flags = null. Only items equiped to hands need do this.

/datum/round_event/wizard/cursed_items/start()
	var/item_set = pick("wizardmimic", "swords", "bigfatdoobie", "boxing", "voicemodulators")
	var/list/wearslots	= list(slot_wear_suit, slot_shoes, slot_head, slot_wear_mask, slot_r_hand, slot_gloves, slot_ears)
	var/list/loadout = list()
	var/ruins_spaceworthiness
	loadout.len = 7

	switch(item_set)
		if("wizardmimic")
			loadout = list(/obj/item/clothing/suit/wizrobe, /obj/item/clothing/shoes/sandal, /obj/item/clothing/head/wizard)
			ruins_spaceworthiness = 1
		if("swords")		loadout[5] = /obj/item/weapon/katana/cursed
		if("bigfatdoobie")
			loadout[4] = /obj/item/clothing/mask/cigarette/rollie/trippy/
			ruins_spaceworthiness = 1
		if("boxing")
			loadout[4] = /obj/item/clothing/mask/luchador
			loadout[6] = /obj/item/clothing/gloves/boxing
			ruins_spaceworthiness = 1
		if("voicemodulators")	loadout[4] = /obj/item/clothing/mask/gas/voice

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(ruins_spaceworthiness && (H.z != 1 || istype(H.loc, /turf/space)))	continue	//#savetheminers
		var/list/slots		= list(H.wear_suit, H.shoes, H.head, H.wear_mask, H.r_hand, H.gloves, H.ears) //add new slots as needed to back
		for(var/i = 1, i <= loadout.len, i++)
			if(loadout[i])
				var/obj/item/J = loadout[i]
				var/obj/item/I = new J //dumb but required because of byond throwing a fit anytime new gets too close to a list
				H.unEquip(slots[i])
				H.equip_to_slot_or_del(I, wearslots[i])
				I.flags |= NODROP
				I.name = "cursed " + I.name

	for(var/mob/living/carbon/human/H in living_mob_list)
		var/datum/effect/effect/system/smoke_spread/smoke = new
		smoke.set_up(max(1,1), 0, H.loc)
		smoke.start()
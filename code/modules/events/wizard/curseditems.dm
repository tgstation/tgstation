/// Turns them into a psuedo-wizard costume.
#define WIZARD_MIMICRY "wizardmimic"
/// Gives them a cursed sword.
#define CURSED_SWORDS "swords"
/// Gives them a blunt that they need to smoke
#define BIG_FAT_DOOBIE "bigfatdoobie"
/// Gives them boxing gloves and a luchador mask
#define BOXING "boxing"
/// Gives them a chameleon mask
#define VOICE_MODULATORS "voicemodulators"
/// Gives them kitty ears and also modifies their gender to FEMALE
#define CATGIRLS_2015 "catgirls2015"

/datum/round_event_control/wizard/cursed_items //fashion disasters
	name = "Cursed Items"
	weight = 3
	typepath = /datum/round_event/wizard/cursed_items
	max_occurrences = 3
	earliest_start = 0 MINUTES
	description = "Gives everyone a cursed item."

//Note about adding items to this: Because of how NODROP_1 works if an item spawned to the hands can also be equiped to a slot
//it will be able to be put into that slot from the hand, but then get stuck there. To avoid this make a new subtype of any
//item you want to equip to the hand, and set its slots_flags = null. Only items equiped to hands need do this.

/datum/round_event/wizard/cursed_items/start()
	var/item_set = pick(
		BIG_FAT_DOOBIE,
		BOXING,
		CATGIRLS_2015,
		CURSED_SWORDS,
		VOICE_MODULATORS,
		WIZARD_MIMICRY,
	)
	var/list/loadout = list()
	var/ruins_spaceworthiness = FALSE
	var/ruins_wizard_loadout = FALSE

	switch(item_set)
		if(BIG_FAT_DOOBIE)
			loadout += /obj/item/clothing/mask/cigarette/rollie/trippy
			ruins_spaceworthiness = TRUE
		if(BOXING)
			loadout += /obj/item/clothing/mask/luchador
			loadout += /obj/item/clothing/gloves/boxing
			ruins_spaceworthiness = TRUE
		if(CATGIRLS_2015)
			loadout += /obj/item/clothing/head/costume/kitty
			ruins_spaceworthiness += TRUE
			ruins_wizard_loadout += TRUE
		if(CURSED_SWORDS)
			loadout += /obj/item/katana/cursed
		if(VOICE_MODULATORS)
			loadout += /obj/item/clothing/mask/chameleon
		if(WIZARD_MIMICRY)
			loadout += /obj/item/clothing/suit/wizrobe
			loadout += /obj/item/clothing/shoes/sandal/magic
			loadout += /obj/item/clothing/head/wizard
			ruins_spaceworthiness = TRUE

	var/list/mob/living/carbon/human/victims = list()

	for(var/mob/living/carbon/human/target in GLOB.alive_mob_list)
		if(isspaceturf(target.loc) || !isnull(target.dna.species.outfit_important_for_life) || (ruins_spaceworthiness && !is_station_level(target.z)))
			continue //#savetheminers
		if(ruins_wizard_loadout && IS_WIZARD(target))
			continue
		if(item_set == CATGIRLS_2015) //Wizard code means never having to say you're sorry
			target.gender = FEMALE
		for(var/item_to_equip in loadout)
			var/obj/item/new_item = new item_to_equip
			var/slot_to_equip_to = ITEM_SLOT_HANDS
			if(isclothing(new_item))
				var/obj/item/clothing/clothing_item = new_item
				slot_to_equip_to = clothing_item.slot_flags

			target.dropItemToGround(target.get_item_by_slot(slot_to_equip_to), TRUE)
			target.equip_to_slot_or_del(new_item, slot_to_equip_to, indirect_action = TRUE)
			ADD_TRAIT(new_item, TRAIT_NODROP, CURSED_ITEM_TRAIT(new_item))
			new_item.item_flags |= DROPDEL
			new_item.name = "cursed " + new_item.name

		victims += target

	for(var/mob/living/carbon/human/victim as anything in victims)
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(0, holder = victim, location = victim.loc)
		smoke.start()

#undef BIG_FAT_DOOBIE
#undef BOXING
#undef CATGIRLS_2015
#undef CURSED_SWORDS
#undef VOICE_MODULATORS
#undef WIZARD_MIMICRY

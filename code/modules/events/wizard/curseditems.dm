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
	var/list/loadout[SLOTS_AMT]
	var/ruins_spaceworthiness = FALSE
	var/ruins_wizard_loadout = FALSE

	switch(item_set)
		if(BIG_FAT_DOOBIE)
			loadout[ITEM_SLOT_MASK] = /obj/item/clothing/mask/cigarette/rollie/trippy
			ruins_spaceworthiness = TRUE
		if(BOXING)
			loadout[ITEM_SLOT_MASK] = /obj/item/clothing/mask/luchador
			loadout[ITEM_SLOT_GLOVES] = /obj/item/clothing/gloves/boxing
			ruins_spaceworthiness = TRUE
		if(CATGIRLS_2015)
			loadout[ITEM_SLOT_HEAD] = /obj/item/clothing/head/costume/kitty
			ruins_spaceworthiness = TRUE
			ruins_wizard_loadout = TRUE
		if(CURSED_SWORDS)
			loadout[ITEM_SLOT_HANDS] = /obj/item/katana/cursed
		if(VOICE_MODULATORS)
			loadout[ITEM_SLOT_MASK] = /obj/item/clothing/mask/chameleon
		if(WIZARD_MIMICRY)
			loadout[ITEM_SLOT_OCLOTHING] = /obj/item/clothing/suit/wizrobe
			loadout[ITEM_SLOT_FEET] = /obj/item/clothing/shoes/sandal/magic
			loadout[ITEM_SLOT_HEAD] = /obj/item/clothing/head/wizard
			ruins_spaceworthiness = TRUE

	var/list/mob/living/carbon/human/victims = list()

	for(var/mob/living/carbon/human/target in GLOB.alive_mob_list)
		if(isspaceturf(target.loc) || !isnull(target.dna.species.outfit_important_for_life) || (ruins_spaceworthiness && !is_station_level(target.z)))
			continue //#savetheminers
		if(ruins_wizard_loadout && IS_WIZARD(target))
			continue
		if(item_set == CATGIRLS_2015) //Wizard code means never having to say you're sorry
			target.gender = FEMALE
		for(var/iterable in 1 to loadout.len)
			if(!loadout[iterable])
				continue

			var/obj/item/item_type = loadout[iterable]
			var/obj/item/thing = new item_type //dumb but required because of byond throwing a fit anytime new gets too close to a list

			target.dropItemToGround(target.get_item_by_slot(iterable), TRUE)
			target.equip_to_slot_or_del(thing, iterable, indirect_action = TRUE)
			ADD_TRAIT(thing, TRAIT_NODROP, CURSED_ITEM_TRAIT(thing))
			thing.item_flags |= DROPDEL
			thing.name = "cursed " + thing.name

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

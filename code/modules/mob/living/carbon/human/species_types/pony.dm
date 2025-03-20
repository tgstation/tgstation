/datum/species/pony
	name = "\improper Pony"
	plural_form = "Ponies"
	id = SPECIES_PONY
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR_ONLY,
		TRAIT_NO_UNDERSHIRT_ONLY,
		TRAIT_PONY_PREFS, // provides access to the preference for selecting what organ to have
	)
	sexes = WOMAN_ONLY
	inherent_biotypes = MOB_ORGANIC
	mutant_organs = list(
		/obj/item/organ/ears/pony = "Pony",
		/obj/item/organ/tail/pony = "Pony",
	)
	conditional_mutant_organs = list(
		/obj/item/organ/pony_horn,
		/obj/item/organ/pony_wings,
		/obj/item/organ/earth_pony_core
	)
	mutanteyes = /obj/item/organ/eyes/pony
	mutantears = /obj/item/organ/ears/pony

	payday_modifier = 0.8
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	no_equip_flags = ITEM_SLOT_GLOVES
	species_cookie = /obj/item/food/grown/apple
	inert_mutation = /datum/mutation/human/telekinesis
	species_language_holder = /datum/language_holder/pony

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pony,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pony,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pony,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pony,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pony,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pony,
	)

/datum/species/pony/randomize_features()
	var/list/features = ..()
	//features["lizard_markings"] = pick(SSaccessories.lizard_markings_list)
	return features

/datum/species/pony/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_UPDATE_HELD_ITEMS, PROC_REF(on_updated_held_items))

/datum/species/pony/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(human, COMSIG_MOB_UPDATE_HELD_ITEMS)

/datum/species/pony/proc/update_movespeed(mob/living/holding_mob)
	holding_mob.remove_movespeed_modifier(/datum/movespeed_modifier/pony_holding_no_items)
	holding_mob.remove_movespeed_modifier(/datum/movespeed_modifier/pony_holding_two_items)
	if(HAS_TRAIT(holding_mob, TRAIT_FLOATING_HELD))
		holding_mob.add_movespeed_modifier(/datum/movespeed_modifier/pony_holding_no_items)
		return
	var/amount_of_held_items = 0
	for(var/obj/item/held in holding_mob.held_items)
		amount_of_held_items++
	if(amount_of_held_items >= 2)
		holding_mob.add_movespeed_modifier(/datum/movespeed_modifier/pony_holding_two_items)
	else if(amount_of_held_items == 0)
		holding_mob.add_movespeed_modifier(/datum/movespeed_modifier/pony_holding_no_items)


/datum/species/pony/proc/on_updated_held_items(mob/living/holding_mob)
	SIGNAL_HANDLER
	update_movespeed(holding_mob)

/datum/species/pony/regenerate_organs(mob/living/carbon/organ_holder, datum/species/old_species, replace_current, list/excluded_zones, visual_only)
	. = ..()
	for(var/organ_path in conditional_mutant_organs)
		var/obj/item/organ/current_organ = organ_holder.get_organ_by_type(organ_path)
		if(current_organ)
			current_organ.Remove(organ_holder, special = TRUE)
	switch(organ_holder.dna.features["pony_archetype"])
		if("Unicorn")
			var/obj/item/organ/pony_horn/horn = new(organ_holder)
			horn.Insert(organ_holder)
		if("Pegasus")
			var/obj/item/organ/pony_wings/wings = new(organ_holder)
			wings.Insert(organ_holder)
		if("Earth")
			var/obj/item/organ/earth_pony_core/core = new(organ_holder)
			core.Insert(organ_holder)

// TODO: GET WRITEUPS FROM WINTERSSHIELD ON THESE
/datum/species/pony/get_physical_attributes()
	return "Lizardpeople can withstand slightly higher temperatures than most species, but they are very vulnerable to the cold \
		and can't regulate their body-temperature internally, making the vacuum of space extremely deadly to them."

/datum/species/pony/get_species_description()
	return "The militaristic Lizardpeople hail originally from Tizira, but have grown \
		throughout their centuries in the stars to possess a large spacefaring \
		empire: though now they must contend with their younger, more \
		technologically advanced Human neighbours."

/datum/species/pony/get_species_lore()
	return list(
		"The face of conspiracy theory was changed forever the day mankind met the lizards.",

		"Hailing from the arid world of Tizira, lizards were travelling the stars back when mankind was first discovering how neat trains could be. \
		However, much like the space-fable of the space-tortoise and space-hare, lizards have rejected their kin's motto of \"slow and steady\" \
		in favor of resting on their laurels and getting completely surpassed by 'bald apes', due in no small part to their lack of access to plasma.",

		"The history between lizards and humans has resulted in many conflicts that lizards ended on the losing side of, \
		with the finale being an explosive remodeling of their moon. Today's lizard-human relations are seeing the continuance of a record period of peace.",

		"Lizard culture is inherently militaristic, though the influence the military has on lizard culture \
		begins to lessen the further colonies lie from their homeworld - \
		with some distanced colonies finding themselves subsumed by the cultural practices of other species nearby.",

		"On their homeworld, lizards celebrate their 16th birthday by enrolling in a mandatory 5 year military tour of duty. \
		Roles range from combat to civil service and everything in between. As the old slogan goes: \"Your place will be found!\"",
	)

/datum/species/pony
	name = "\improper Equestrian"
	plural_form = "Equestrians"
	id = SPECIES_PONY
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR_ONLY,
		TRAIT_NO_UNDERSHIRT_ONLY,
		TRAIT_PONY_PREFS, // provides access to the preference for selecting what organ to have
	)
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
	mutanttongue = /obj/item/organ/tongue/pony
	mutantbrain = /obj/item/organ/brain/pony
	mutantlungs = /obj/item/organ/lungs/pony
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/cutie_mark = SPRITE_ACCESSORY_NONE
	)

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
	used_outfit_for_preview = /datum/outfit/deathmatch_loadout/naked

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

/datum/species/pony/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.features["mcolor"] = "#FFFFFF"
	human_for_preview.dna.features["pony_archetype"] = "Unicorn"
	human_for_preview.hair_color = "#990000"
	human_for_preview.hairstyle = "Soldier (Equestrian)"
	var/obj/item/organ/pony_horn/horn = new(human_for_preview)
	horn.Insert(human_for_preview)
	var/obj/item/organ/eyes/pony/pony_eyes = human_for_preview.get_organ_by_type(/obj/item/organ/eyes/pony)
	if (pony_eyes)
		pony_eyes.eye_color_left = "#3366CC"
		pony_eyes.eye_color_right = "#3366CC"
	human_for_preview.update_body(TRUE)

/datum/species/pony/check_roundstart_eligible()
	return TRUE

/datum/species/pony/get_physical_attributes()
	return "Equestrians are a species of small, long-lived, colorful, psychic quadrupeds, with big eyes and no hands, that bear superficial resemblance to \
	Old Earth's equines. They are quick on their feet in both senses and can do impossible things, but they struggle with accessibility generally \
	when living or working among aliens."

/datum/species/pony/get_species_description()
	return "Born from an anomalous garden world of their name sake, Equestrians lived under a primitive but global feudal empire for centuries until fairly recently, \
	when they were liberated by TerraGov as part of Operation Swift Sword. Today, they live in diaspora and under human rule, struggling to integrate into a \
	galactic community that doesn't care."

/datum/species/pony/get_species_lore()
	return list(
	"Changing the world with just the power of thought sounds pretty neat: until it's someone else doing it, and now everybody's scared.",

	"Equestrians are small, long-lived, alien ungulates, and the only all-psychic species on the galactic stage. \
	Desired on one hand and feared on the other for their capacity for the impossible. They come in three kinds (pegasi, unicorns, Earth ponies) \
	that served different social roles in their primitive society, and are still today distinguished by their particular psionic talents — flight and cloudwalking, \
	telekinesis and complex formulae, and other respectively. ",

	"TerraGov liberated them from a \"dictatorship of daisy-chained psionic malefactors\" some decades ago, as part of a brutally efficient first \
	strike called Operation Swift Sword. Broad resistance to TerraGov occupation lasted days, sometimes a few weeks in some locations, but guerrilla \
	fighting upon the part of some of the primitive military and subordinate paramilitaries continues to today.",

	"What became of Equestria's world government has since fallen into TerraGov's sphere influence, and is following through on a commitment \
	to integrate with the galactic community. The flagship program of this push is the Modern Citizenship Academy, which has campuses across Equestria \
	and beyond. These schools provide various forms and levels of education, to both rear the youth up \"right\", and upskill the existing Equestrian \
	workforce to meet the demands of a galactic market.",

	"While the most obvious place for working ponies is as professional psions (of some description) or weather engineers, they are also found in all \
	manner of positions within TerraGov's public services — specifically the military, first responder orgs — and (now, increasingly) major human corporations.",
	)

/datum/species/pony/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fa-wand-magic-sparkles",
			SPECIES_PERK_NAME = "Unicorn Kinesis",
			SPECIES_PERK_DESC = "Equestrians of the Unicorn tribe can use their heightened psionics to hold things telekinetically and grab items from a distance. \
				They are, however, more vulnerable to EMPs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fa-feather",
			SPECIES_PERK_NAME = "Pegasus Flight",
			SPECIES_PERK_DESC = "Equestrians of the Pegasus tribe can use their psionically-enhanced wings to take flight over obstacles and fly in zero-gravity. \
				Take care not to get yourself stuck somewhere dangerous, especially near moving vehicles.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fa-apple-whole",
			SPECIES_PERK_NAME = "Earth Endurance",
			SPECIES_PERK_DESC = "Equestrians of the Earth tribe have significantly better constitution than their bretheren, recovering faster with hearty meals, \
				lack the disease weakness of their bretheren, and have strong hind-legs that they can utilize in combat and for tree harvesting.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fa-horse",
			SPECIES_PERK_NAME = "Quadrupedal",
			SPECIES_PERK_DESC = "Equestrians are quadrupedal beings, and their speed is impacted by this. Keeping their hooves empty allows them to traverse \
			faster than the average crewmember, but they lose this advantage if they try to hold anything with their fore-hooves.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-handshake-slash",
			SPECIES_PERK_NAME = "No Gloves",
			SPECIES_PERK_DESC = "Equestrians don't have hands, and thus, don't wear gloves. \
				They also move slower if their hooves are full, or if they lost a fore-leg.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-head-side-cough",
			SPECIES_PERK_NAME = "Disease Weakness",
			SPECIES_PERK_DESC = "Equestrians aren't used to the germ ecosystem of the station, and thus are far more susceptible to disease.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-computer",
			SPECIES_PERK_NAME = "Can't Reach The Keyboard",
			SPECIES_PERK_DESC = "Equestrians aren't the right height to comfortably reach the keyboard on most computers, \
				and will need a chair or elevation to use them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-biohazard",
			SPECIES_PERK_NAME = "Sensitive Smell",
			SPECIES_PERK_DESC = "Equestrian lungs are used to crisp, clean air. Bad smells will disgust them quickly and heavily.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-heart-crack",
			SPECIES_PERK_NAME = "Mirror Neurons",
			SPECIES_PERK_DESC = "Equestrians react negatively to seeing people wounded due to their latent psionics. \
				They feel the pain emotionally, if not physically.",
		),
	)

	return to_add

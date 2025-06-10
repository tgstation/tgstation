#define MONKEY_SPEC_ATTACK_BITE_MISS_CHANCE 25

/datum/species/monkey
	name = "\improper Monkey"
	id = SPECIES_MONKEY
	mutant_organs = list(
		/obj/item/organ/tail/monkey = "Monkey",
	)
	mutanttongue = /obj/item/organ/tongue/monkey
	mutantbrain = /obj/item/organ/brain/primate
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	inherent_traits = list(
		TRAIT_NO_AUGMENTS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
	)
	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	species_cookie = /obj/item/food/grown/banana
	inherent_factions = list(FACTION_MONKEY)
	sexes = FALSE
	species_language_holder = /datum/language_holder/monkey

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
	)
	fire_overlay = "monkey"
	gib_anim = "gibbed-m"

	payday_modifier = 1.5
	ai_controlled_species = TRUE

/datum/species/monkey/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	if (pref_load)
		ADD_TRAIT(human_who_gained_species, TRAIT_BORN_MONKEY, INNATE_TRAIT) // Not a species trait, you cannot escape your genetic destiny
	passtable_on(human_who_gained_species, SPECIES_TRAIT)
	human_who_gained_species.dna.add_mutation(/datum/mutation/race, MUTATION_SOURCE_ACTIVATED)
	human_who_gained_species.AddElement(/datum/element/human_biter)
	human_who_gained_species.update_mob_height()

/datum/species/monkey/on_species_loss(mob/living/carbon/human/C)
	. = ..()
	passtable_off(C, SPECIES_TRAIT)
	C.dna.remove_mutation(/datum/mutation/race, MUTATION_SOURCE_ACTIVATED)
	C.RemoveElement(/datum/element/human_biter)
	C.update_mob_height()

/datum/species/monkey/update_species_heights(mob/living/carbon/human/holder)
	if(HAS_TRAIT(holder, TRAIT_DWARF))
		return MONKEY_HEIGHT_DWARF

	if(HAS_TRAIT(holder, TRAIT_TOO_TALL))
		return MONKEY_HEIGHT_TALL

	return MONKEY_HEIGHT_MEDIUM

/datum/species/monkey/check_roundstart_eligible()
	// STOP ADDING MONKEY SUBTYPES YOU HEATHEN
	// ok we killed monkey subtypes but we're keeping this in cause we can't trust you fuckers
	if(check_holidays(MONKEYDAY) && id == SPECIES_MONKEY)
		return TRUE
	return ..()

/datum/species/monkey/get_scream_sound(mob/living/carbon/human/monkey)
	return get_sfx(SFX_SCREECH)

/datum/species/monkey/get_hiss_sound(mob/living/carbon/human/monkey)
	return 'sound/mobs/humanoids/human/hiss/human_hiss.ogg'
	// we're both great apes, or something..

/datum/species/monkey/get_physical_attributes()
	return "Monkeys are slippery, can crawl into vents, and are more dextrous than humans.. but only when stealing things. \
		Natural monkeys cannot operate machinery or most tools with their paws, but unusually clever monkeys or those that were once something else can."

/datum/species/monkey/get_species_description()
	return "Monkeys are a type of primate that exist between humans and animals on the evolutionary chain. \
		Every year, on Monkey Day, Nanotrasen shows their respect for the little guys by allowing them to roam the station freely."

/datum/species/monkey/get_species_lore()
	return list(
		"Monkeys are commonly used as test subjects on board Space Station Thirteen. \
		But what if... for one day... the Monkeys were allowed to be the scientists? \
		What experiments would they come up it? Would they (stereotypically) be related to bananas somehow? \
		There's only one way to find out.",
	)

/datum/species/monkey/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Monkeys can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Monkeys are primitive humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
	)

	return to_add

/datum/species/monkey/create_pref_language_perk()
	var/list/to_add = list()
	// Holding these variables so we can grab the exact names for our perk.
	var/datum/language/common_language = /datum/language/common
	var/datum/language/monkey_language = /datum/language/monkey

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You may be able to understand [initial(common_language.name)], but you can't speak it. \
			You can only speak [initial(monkey_language.name)].",
	))

	return to_add

/obj/item/organ/brain/primate //Ook Ook
	name = "Primate Brain"
	desc = "This wad of meat is small, but has enlarged occipital lobes for spotting bananas."
	organ_traits = list(TRAIT_CAN_STRIP, TRAIT_PRIMITIVE, TRAIT_GUN_NATURAL) // No literacy or advanced tool usage.
	actions_types = list(/datum/action/item_action/organ_action/toggle_trip)
	/// Will this monkey stumble if they are crossed by a simple mob or a carbon in combat mode? Toggable by monkeys with clients, and is messed automatically set to true by monkey AI.
	var/tripping = TRUE

/datum/action/item_action/organ_action/toggle_trip
	name = "Toggle Tripping"
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "lesser_form"
	background_icon_state = "bg_default_on"
	overlay_icon_state = "bg_default_border"

/datum/action/item_action/organ_action/toggle_trip/do_effect(trigger_flags)
	var/obj/item/organ/brain/primate/monkey_brain = target
	if(monkey_brain.tripping)
		monkey_brain.tripping = FALSE
		background_icon_state = "bg_default"
		to_chat(monkey_brain.owner, span_notice("You will now avoid stumbling while colliding with people who are in combat mode."))
	else
		monkey_brain.tripping = TRUE
		background_icon_state = "bg_default_on"
		to_chat(monkey_brain.owner, span_notice("You will now stumble while colliding with people who are in combat mode."))
	build_all_button_icons()
	return TRUE

/obj/item/organ/brain/primate/on_mob_insert(mob/living/carbon/primate)
	. = ..()
	RegisterSignal(primate, COMSIG_LIVING_MOB_BUMPED, PROC_REF(on_mob_bump))

/obj/item/organ/brain/primate/on_mob_remove(mob/living/carbon/primate)
	. = ..()
	UnregisterSignal(primate, COMSIG_LIVING_MOB_BUMPED)

/obj/item/organ/brain/primate/proc/on_mob_bump(mob/source, mob/living/crossing_mob)
	SIGNAL_HANDLER
	if(!tripping || !crossing_mob.combat_mode)
		return
	crossing_mob.knockOver(owner)

/obj/item/organ/brain/primate/get_attacking_limb(mob/living/carbon/human/target)
	if(!HAS_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER))
		return owner.get_bodypart(BODY_ZONE_HEAD)
	return ..()

#undef MONKEY_SPEC_ATTACK_BITE_MISS_CHANCE

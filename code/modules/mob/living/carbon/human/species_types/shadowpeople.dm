/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadow"
	plural_form = "Shadowpeople"
	id = SPECIES_SHADOW
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/shadow
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NEVER_WOUNDED
	)
	inherent_factions = list(FACTION_FAITHLESS)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC

	mutantbrain = /obj/item/organ/brain/shadow
	mutanteyes = /obj/item/organ/eyes/shadow
	mutantheart = null
	mutantlungs = null

	species_language_holder = /datum/language_holder/shadowpeople

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)

/datum/species/shadow/on_species_gain(mob/living/carbon/carbon_mob, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(carbon_mob, COMSIG_MOB_FLASH_OVERRIDE_CHECK, PROC_REF(on_flashed))

/datum/species/shadow/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(human, COMSIG_MOB_FLASH_OVERRIDE_CHECK)

/datum/species/shadow/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/shadow/get_physical_attributes()
	return "These cursed creatures heal in the dark, but suffer in the light much more heavily. Their eyes let them see in the dark as though it were day."

/datum/species/shadow/get_species_description()
	return "Victims of a long extinct space alien. Their flesh is a sickly \
		seethrough filament, their tangled insides in clear view. Their form \
		is a mockery of life, leaving them mostly unable to work with others under \
		normal circumstances."

/datum/species/shadow/get_species_lore()
	return list(
		"Long ago, the Spinward Sector used to be inhabited by terrifying aliens aptly named \"Shadowlings\" \
		after their control over darkness, and tendancy to kidnap victims into the dark maintenance shafts. \
		Around 2558, the long campaign Nanotrasen waged against the space terrors ended with the full extinction of the Shadowlings.",

		"Victims of their kidnappings would become brainless thralls, and via surgery they could be freed from the Shadowling's control. \
		Those more unlucky would have their entire body transformed by the Shadowlings to better serve in kidnappings. \
		Unlike the brain tumors of lesser control, these greater thralls could not be reverted.",

		"With Shadowlings long gone, their will is their own again. But their bodies have not reverted, burning in exposure to light. \
		Nanotrasen has assured the victims that they are searching for a cure. No further information has been given, even years later. \
		Most shadowpeople now assume Nanotrasen has long since shelfed the project.",
	)

/datum/species/shadow/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Shadowborn",
			SPECIES_PERK_DESC = "Their skin blooms in the darkness. All kinds of damage, \
				no matter how extreme, will heal over time as long as there is no light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Nightvision",
			SPECIES_PERK_DESC = "Their eyes are adapted to the night, and can see in the dark with no problems.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Lightburn",
			SPECIES_PERK_DESC = "Their flesh withers in the light. Any exposure to light is \
				incredibly painful for the shadowperson, charring their skin.",
		),
	)

	return to_add

/obj/item/organ/eyes/shadow
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	iris_overlay = null
	color_cutoffs = list(20, 10, 40)
	pepperspray_protect = TRUE
	flash_protect = FLASH_PROTECTION_SENSITIVE

/// the key to none of their powers
/obj/item/organ/brain/shadow
	name = "shadowling tumor"
	desc = "Something that was once a brain, before being remolded by a shadowling. It has adapted to the dark, irreversibly."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

/datum/species/shadow/get_scream_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/shadow/shadow_wail.ogg'

/datum/species/shadow/proc/on_flashed(source, mob/living/carbon/flashed, flash, deviation)
	SIGNAL_HANDLER

	if(deviation == DEVIATION_FULL) //If no deviation, we can assume it's a non-assembly flash and should do max flash damage.
		flashed.apply_damage(16, BURN, attacking_item = flash)
		flashed.adjust_confusion_up_to(3 SECONDS, 6 SECONDS)
	else //If it's anything less than a full hit, it does less than stellar damage. Bear in mind that this damage is dished out much faster since flashes have a quicker cooldown on clicks.
		flashed.apply_damage(8, BURN, attacking_item = flash)
		flashed.adjust_confusion_up_to(1 SECONDS, 3 SECONDS)

	INVOKE_ASYNC(flashed, TYPE_PROC_REF(/mob, emote), "scream")
	flashed.visible_message(span_danger("[flashed] wails in pain as a burst of light singes their flesh!"), \
		span_danger("You wail in pain as the sudden burst of light singes your flesh!"), \
		span_danger("Something wails in pain! It sounds like a terrifying monster! Good thing you can't see it, or you'd probably be freaking out right now."))

	return FLASH_OVERRIDDEN

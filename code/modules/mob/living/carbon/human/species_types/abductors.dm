/datum/species/abductor
	name = "Abductor"
	id = SPECIES_ABDUCTOR
	sexes = FALSE
	inherent_traits = list(
		TRAIT_CHUNKYFINGERS_IGNORE_BATON,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NO_UNDERWEAR,
		TRAIT_VIRUSIMMUNE,
	)
	mutanttongue = /obj/item/organ/internal/tongue/abductor
	mutantstomach = null
	mutantheart = null
	mutantlungs = null
	mutantbrain = /obj/item/organ/internal/brain/abductor
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/abductor,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/abductor,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/abductor,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/abductor,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/abductor,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/abductor,
	)

/datum/species/abductor/get_physical_attributes()
	return "Abductors do not need to breathe, eat, do not have blood, a heart, stomach, or lungs and cannot be infected by human viruses. \
		Their hardy physique prevents their skin from being wounded or dismembered, but their chunky tridactyl hands make it hard to operate human equipment."

/datum/species/abductor/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.show_to(C)

/datum/species/abductor/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.hide_from(C)

/datum/species/abductor/get_species_description()
	return "Abductors, colloquially known as \"Greys\" (or \"Grays\"), \
		are, three fingered, pale skinned inquisitive aliens who can't communicate well to the average crew-member."

/datum/species/abductor/get_species_lore()
	return list(
		"Little are known about Abductors. \
		While they (as a species) have been known to abduct other species of 'lesser intellect' for experimentation, \
		some have been known to - on rare occasions - work with the very species they abduct, for reasons unknown.",
	)

/datum/species/abductor/create_pref_traits_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_WIND,
		SPECIES_PERK_NAME = "Lungs Optional",
		SPECIES_PERK_DESC = "Abductors don't need to breathe, though exposure to a vacuum is still a hazard.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD,
		SPECIES_PERK_NAME = "Resilient Skin",
		SPECIES_PERK_DESC = "The grey (or gray) skin of an Abductor is tough and resistant. \
			They cannot be wounded or dismembered by conventional means.",
	))
	return perks

/datum/species/abductor/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SYRINGE,
		SPECIES_PERK_NAME = "Disease Immunity",
		SPECIES_PERK_DESC = "Abductors are immune to all viral infections found naturally on the station.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK, // It may be a stretch to call nohunger a neutral perk but the Abductor's tongue describes it as much, so.
		SPECIES_PERK_ICON = FA_ICON_UTENSILS,
		SPECIES_PERK_NAME = "Hungry for Knowledge",
		SPECIES_PERK_DESC = "Abductors have a greater hunger for knowledge than food, and as such don't need to eat. \
			Which is fortunate, as their speech matrix prevents them from consuming food.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_VOLUME_XMARK,
		SPECIES_PERK_NAME = "Superlingual Matrix",
		SPECIES_PERK_DESC = "Abductors cannot physically speak with their natural tongue. \
			They intead naturally communicate telepathically to other Abductors, a process which all other species cannot hear. \
			Great for secret conversations, not so great for ordering something from the bar.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_HANDSHAKE_SLASH,
		SPECIES_PERK_NAME = "Tridactyl Hands",
		SPECIES_PERK_DESC = "Abductor hands are not designed for human equipment. Utilizing the station's equipment is difficult for them.",
	))
	return perks

/// Species for the voidwalker antagonist
/datum/species/voidwalker
	name = "\improper Voidling"
	id = SPECIES_VOIDWALKER
	sexes = FALSE
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_NO_UNDERWEAR,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NEVER_WOUNDED,
		TRAIT_MOVE_FLYING,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOHUNGER,
		TRAIT_FREE_HYPERSPACE_MOVEMENT,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_THROWING,
		TRAIT_GENELESS,
	)
	changesource_flags = MIRROR_BADMIN

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/voidwalker,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/voidwalker,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/voidwalker,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/voidwalker,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/voidwalker,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/voidwalker,
	)

	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_ICLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_FEET | ITEM_SLOT_BACK | ITEM_SLOT_EARS | ITEM_SLOT_EYES

	mutantbrain = /obj/item/organ/internal/brain/voidwalker
	mutanteyes = /obj/item/organ/internal/eyes/voidwalker
	mutantheart = null
	mutantlungs = null
	mutanttongue = null

	siemens_coeff = 0

/datum/species/voidwalker/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()

	human_who_gained_species.AddComponent(/datum/component/glass_passer)
	human_who_gained_species.AddComponent(/datum/component/space_dive)
	human_who_gained_species.AddComponent(/datum/component/space_kidnap)

	var/obj/item/implant/radio = new /obj/item/implant/radio/voidwalker (human_who_gained_species)
	radio.implant(human_who_gained_species, null, TRUE, TRUE)

	human_who_gained_species.AddComponent(/datum/component/planet_allergy)

	human_who_gained_species.fully_replace_character_name(null, pick(GLOB.voidwalker_names))

/datum/species/voidwalker/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	qdel(human.GetComponent(/datum/component/glass_passer))
	qdel(human.GetComponent(/datum/component/space_dive))
	qdel(human.GetComponent(/datum/component/space_kidnap))

	var/obj/item/implant/radio = locate(/obj/item/implant/radio/voidwalker) in human
	if(radio)
		qdel(radio)

	qdel(human.GetComponent(/datum/component/planet_allergy))

/datum/species/voidwalker/check_roundstart_eligible()
	return FALSE

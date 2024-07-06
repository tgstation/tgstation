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
		TRAIT_ADVANCEDTOOLUSER
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

	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_ICLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_FEET | ITEM_SLOT_BACK | ITEM_SLOT_EARS

	mutantbrain = /obj/item/organ/internal/brain/voidwalker
	mutanteyes = /obj/item/organ/internal/eyes/voidwalker
	mutantheart = null
	mutantlungs = null
	mutanttongue = null

/datum/species/voidwalker/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()

	human_who_gained_species.AddComponent(/datum/component/glass_passer)
	human_who_gained_species.AddComponent(/datum/component/space_dive)

	var/obj/item/implant/radio = new /obj/item/implant/radio/voidwalker (human_who_gained_species)
	radio.implant(human_who_gained_species, null, TRUE, TRUE)

	human_who_gained_species.AddComponent(/datum/component/planet_allergy)

/datum/species/voidwalker/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	qdel(human.GetComponent(/datum/component/glass_passer))
	qdel(human.GetComponent(/datum/component/space_dive))

	var/obj/item/implant/radio = locate(/obj/item/implant/radio/voidwalker) in human
	if(radio)
		qdel(radio)

	qdel(human.GetComponent(/datum/component/planet_allergy))

/datum/component/planet_allergy/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ENTER_AREA, PROC_REF(entered_area))

/datum/component/planet_allergy/proc/entered_area(mob/living/parent, area/new_area)
	SIGNAL_HANDLER

	if(is_on_a_planet(parent) && parent.has_gravity())
		parent.apply_status_effect(/datum/status_effect/planet_allergy) //your gamer body cant stand real gravity
	else
		parent.remove_status_effect(/datum/status_effect/planet_allergy)

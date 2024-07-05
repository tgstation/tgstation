/datum/species/voidling
	name = "\improper Voidling"
	id = SPECIES_VOIDLING
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
	)
	changesource_flags = MIRROR_BADMIN

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/voidling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/voidling,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/voidling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/voidling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/voidling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/voidling,
	)

	no_equip_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_ICLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_MASK | ITEM_SLOT_HEAD | ITEM_SLOT_FEET | ITEM_SLOT_BACK

	mutantbrain = /obj/item/organ/internal/brain/voidling
	mutanteyes = /obj/item/organ/internal/eyes/voidling
	mutantheart = null
	mutantlungs = null
	mutanttongue = null

/datum/species/voidling/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()

	RegisterSignal(human_who_gained_species, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_temporary_shatter))
	human_who_gained_species.apply_status_effect(/datum/status_effect/glass_passer)

/datum/species/voidling/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	UnregisterSignal(human, COMSIG_MOVABLE_CAN_PASS_THROUGH)
	human.remove_status_effect(/datum/status_effect/glass_passer)

/datum/species/voidling/proc/try_temporary_shatter(mob/living/carbon/human/human, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/structure/window))
		var/obj/structure/window/window = target
		window.temporary_shatter()
	else if(istype(src, /obj/structure/grille))
		var/obj/structure/grille/grille = target
		grille.temporary_shatter()
	else
		return
	return COMPONENT_CANCEL_ATTACK_CHAIN

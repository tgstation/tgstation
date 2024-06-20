/datum/species/voidling
	name = "\improper Voidling"
	id = SPECIES_VOIDLING
	sexes = FALSE
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NEVER_WOUNDED,
		TRAIT_MOVE_FLYING,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
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

/datum/species/voidling/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()

	human_who_gained_species.pass_flags |= PASSWINDOW

/datum/species/voidling/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	human.pass_flags &= ~PASSWINDOW

/obj/item/organ/internal/eyes/voidling
	name = "black orbs"
	desc = "Dark, blackened orbs, invisible against the rest of the voidlings body."
	eye_icon_state = null
	pepperspray_protect = TRUE
	flash_protect = FLASH_PROTECTION_WELDER
	color_cutoffs = list(20, 10, 40)

/obj/item/organ/internal/brain/voidling
	name = "..."
	desc = "...."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

	organ_traits = list(TRAIT_ALLOW_HERETIC_CASTING) //allows use of space phase and also just cool I think
	/// Alpha we have in space
	var/space_alpha = 50
	/// Alpha we have elsewhere
	var/non_space_alpha = 200
	/// We space in phase
	var/datum/action/space_phase = /datum/action/cooldown/spell/jaunt/space_crawl

/obj/item/organ/internal/brain/voidling/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	RegisterSignal(organ_owner, COMSIG_ENTER_AREA, PROC_REF(on_area_entered))
	organ_owner.remove_from_all_data_huds()
	space_phase = new space_phase ()
	space_phase.Grant(organ_owner)

/obj/item/organ/internal/brain/voidling/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ENTER_AREA)
	alpha = 255
	organ_owner.add_to_all_human_data_huds()
	space_phase.Remove()
	space_phase = initial(space_phase)

/obj/item/organ/internal/brain/voidling/proc/on_area_entered(mob/living/carbon/organ_owner, area/new_area)
	SIGNAL_HANDLER

	if(istype(new_area, /area/space))
		animate(organ_owner, alpha = space_alpha, time = 0.5 SECONDS)
		organ_owner.remove_movespeed_modifier(/datum/movespeed_modifier/grounded_voidling)
	else
		animate(organ_owner, alpha = non_space_alpha, time = 0.5 SECONDS)
		organ_owner.add_movespeed_modifier(/datum/movespeed_modifier/grounded_voidling)

/datum/movespeed_modifier/grounded_voidling
	multiplicative_slowdown = 1.3

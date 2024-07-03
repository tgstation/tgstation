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

	passwindow_on(human_who_gained_species, SPECIES_TRAIT) //if this is here when its PRd im dumb please remind me to move it somewhere else
	RegisterSignal(human_who_gained_species, COMSIG_MOVABLE_CAN_PASS_THROUGH, PROC_REF(can_pass_through))
	human_who_gained_species.generic_canpass = FALSE

	RegisterSignal(human_who_gained_species, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_temporary_shatter))

/datum/species/voidling/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()

	passwindow_off(human, SPECIES_TRAIT)
	UnregisterSignal(human, COMSIG_MOVABLE_CAN_PASS_THROUGH)

/datum/species/voidling/proc/can_pass_through(mob/living/carbon/human/human, atom/blocker, direction)
	SIGNAL_HANDLER

	if(istype(blocker, /obj/structure/grille))
		var/obj/structure/grille/grille = blocker
		if(grille.shock(human, 100))
			return COMSIG_COMPONENT_REFUSE_PASSAGE

	return null

/datum/species/voidling/proc/try_temporary_shatter(mob/living/carbon/human/human, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/structure/window))
		var/obj/structure/window/window = target
		window.temporary_shatter()
	else if(istype(src, /obj/structure/grille))
		var/obj/structure/grille/grille = target
		grille.temporary_shatter()

/obj/item/organ/internal/eyes/voidling
	name = "black orbs"
	desc = "Dark, blackened orbs, invisible against the rest of the voidlings body."
	eye_icon_state = null
	pepperspray_protect = TRUE
	flash_protect = FLASH_PROTECTION_WELDER
	color_cutoffs = list(20, 10, 40)
	sight_flags = SEE_MOBS

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
	/// Regen effect we have in space
	var/datum/status_effect/regen = /datum/status_effect/shadow_regeneration

/obj/item/organ/internal/brain/voidling/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	RegisterSignal(organ_owner, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))
	organ_owner.remove_from_all_data_huds()
	space_phase = new space_phase ()
	space_phase.Grant(organ_owner)

/obj/item/organ/internal/brain/voidling/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ENTER_AREA)
	alpha = 255
	organ_owner.add_to_all_human_data_huds()
	space_phase.Remove(organ_owner)
	space_phase = initial(space_phase)

/obj/item/organ/internal/brain/voidling/proc/on_atom_entering(mob/living/carbon/organ_owner, atom/entering)
	SIGNAL_HANDLER

	if(!isturf(entering))
		return

	var/turf/new_turf = entering

	//apply debufs for being in gravity
	if(new_turf.has_gravity())
		animate(organ_owner, alpha = non_space_alpha, time = 0.5 SECONDS)
		organ_owner.add_movespeed_modifier(/datum/movespeed_modifier/grounded_voidling)
	//remove debufs for not being in gravity
	else
		animate(organ_owner, alpha = space_alpha, time = 0.5 SECONDS)
		organ_owner.remove_movespeed_modifier(/datum/movespeed_modifier/grounded_voidling)
		organ_owner.apply_status_effect(/datum/status_effect/space_regeneration)

	//only get the actual regen when we're in space, not no-grav
	if(isspaceturf(new_turf))
		organ_owner.apply_status_effect(/datum/status_effect/space_regeneration)
	else
		organ_owner.remove_status_effect(/datum/status_effect/space_regeneration)

/datum/movespeed_modifier/grounded_voidling
	multiplicative_slowdown = 1.3

/datum/status_effect/space_regeneration
	id = "space_regeneration"
	duration = INFINITE

/datum/status_effect/space_regeneration/on_apply()
	. = ..()
	if (!.)
		return FALSE
	heal_owner()
	return TRUE

/datum/status_effect/space_regeneration/refresh(effect)
	. = ..()
	heal_owner()

/// Regenerate health whenever this status effect is applied or reapplied
/datum/status_effect/space_regeneration/proc/heal_owner()
	owner.heal_overall_damage(brute = 1, burn = 1, required_bodytype = BODYTYPE_ORGANIC)

/datum/brain_trauma/voided
	name = "Voided"
	desc = "They've seen the secrets of the cosmis, in exchange for a curse that keeps them chained."
	scan_desc = "cosmic neural pattern"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	random_gain = FALSE
	/// Type for the bodypart texture we add
	var/bodypart_overlay_type = /datum/bodypart_overlay/texture/spacey

/datum/brain_trauma/voided/on_gain()
	. = ..()

	ADD_TRAIT(owner, list(TRAIT_MUTE, TRAIT_PACIFISM), TRAUMA_TRAIT)
	RegisterSignal(owner, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(texture_limb))
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(untexture_limb))

	for(var/obj/item/bodypart as anything in owner.bodyparts)
		texture_limb(owner, bodypart)

	//your underwear is belong to us
	owner.underwear = "Nude"
	owner.undershirt = "Nude"
	owner.socks = "Nude"

	owner.update_body()

/datum/brain_trauma/voided/on_lose()
	. = ..()

	REMOVE_TRAIT(owner, list(TRAIT_MUTE, TRAIT_PACIFISM), TRAUMA_TRAIT)
	UnregisterSignal(owner, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))

	for(var/obj/item/bodypart/bodypart as anything in owner.bodyparts)
		untexture_limb(owner, bodypart)

/datum/brain_trauma/voided/proc/texture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	limb.add_bodypart_overlay(new bodypart_overlay_type)
	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags &= ~HEAD_EYESPRITES

/datum/brain_trauma/voided/proc/untexture_limb(atom/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	var/overlay = locate(bodypart_overlay_type) in limb.bodypart_overlays
	if(overlay)
		limb.remove_bodypart_overlay(overlay)

	if(istype(limb, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/head = limb
		head.head_flags = initial()


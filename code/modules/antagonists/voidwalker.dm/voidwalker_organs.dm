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
	var/non_space_alpha = 250
	/// We space in phase
	var/datum/action/space_phase = /datum/action/cooldown/spell/jaunt/space_crawl
	/// We settle the un
	var/datum/action/unsettle = /datum/action/cooldown/spell/pointed/unsettle
	/// Regen effect we have in space
	var/datum/status_effect/regen = /datum/status_effect/shadow_regeneration

/obj/item/organ/internal/brain/voidling/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	RegisterSignal(organ_owner, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))
	organ_owner.remove_from_all_data_huds()

	space_phase = new space_phase ()
	space_phase.Grant(organ_owner)

	unsettle = new unsettle ()
	unsettle.Grant(organ_owner)

/obj/item/organ/internal/brain/voidling/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ENTER_AREA)
	alpha = 255
	organ_owner.add_to_all_human_data_huds()

	space_phase.Remove(organ_owner)
	space_phase = initial(space_phase)

	unsettle.Remove(organ_owner)
	unsettle = initial(unsettle)

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

/obj/item/organ/internal/brain/voidling/on_death()
	. = ..()
	var/static/list/shards = list(/obj/item/shard = 2, /obj/item/shard/plasma = 1, /obj/item/shard/titanium = 1, /obj/item/shard/plastitanium = 1)
	for(var/i in 1 to rand(4, 6))
		var/shard_type = pick_weight(shards)
		var/obj/shard = new shard_type (get_turf(owner))
		shard.pixel_x = rand(-16, 16)
		shard.pixel_y = rand(-16, 16)

	new /obj/item/cosmic_skull (get_turf(owner))
	playsound(get_turf(owner), SFX_SHATTER, 100)

	qdel(owner)

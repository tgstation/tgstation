/// Voidwalker eyes with nightvision and thermals
/obj/item/organ/internal/eyes/voidwalker
	name = "blackened orbs"
	desc = "These orbs will withstand the light of the sun, yet still see within the darkest voids."
	eye_icon_state = null
	pepperspray_protect = TRUE
	flash_protect = FLASH_PROTECTION_WELDER
	color_cutoffs = list(20, 10, 40)
	sight_flags = SEE_MOBS

/// Voidwalker brain stacked with a lot of the abilities
/obj/item/organ/internal/brain/voidwalker
	name = "cosmic brain"
	desc = "A mind fully integrated into the cosmic thread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

	organ_traits = list(TRAIT_ALLOW_HERETIC_CASTING) //allows use of space phase and also just cool I think
	/// Alpha we have in space
	var/space_alpha = 30
	/// Alpha we have elsewhere
	var/non_space_alpha = 220
	/// We settle the un
	var/datum/action/unsettle = /datum/action/cooldown/spell/pointed/unsettle
	/// Regen effect we have in space
	var/datum/status_effect/regen = /datum/status_effect/shadow_regeneration
	/// The void eater armblade
	var/obj/item/glass_breaker = /obj/item/void_eater

/obj/item/organ/internal/brain/voidwalker/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	RegisterSignal(organ_owner, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))
	organ_owner.remove_from_all_data_huds()

	unsettle = new unsettle ()
	unsettle.Grant(organ_owner)

	glass_breaker = new/obj/item/void_eater
	organ_owner.put_in_hands(glass_breaker)

/obj/item/organ/internal/brain/voidwalker/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ENTER_AREA)
	alpha = 255
	organ_owner.add_to_all_human_data_huds()

	unsettle.Remove(organ_owner)
	unsettle = initial(unsettle)

	if(glass_breaker)
		qdel(glass_breaker)

/obj/item/organ/internal/brain/voidwalker/proc/on_atom_entering(mob/living/carbon/organ_owner, atom/entering)
	SIGNAL_HANDLER

	if(!isturf(entering))
		return

	var/turf/new_turf = entering

	//apply debufs for being in gravity
	if(new_turf.has_gravity())
		animate(organ_owner, alpha = non_space_alpha, time = 0.5 SECONDS)
		organ_owner.add_movespeed_modifier(/datum/movespeed_modifier/grounded_voidwalker)
	//remove debufs for not being in gravity
	else
		animate(organ_owner, alpha = space_alpha, time = 0.5 SECONDS)
		organ_owner.remove_movespeed_modifier(/datum/movespeed_modifier/grounded_voidwalker)
		organ_owner.apply_status_effect(/datum/status_effect/space_regeneration)

	//only get the actual regen when we're in space, not no-grav
	if(isspaceturf(new_turf))
		organ_owner.apply_status_effect(/datum/status_effect/space_regeneration)
	else
		organ_owner.remove_status_effect(/datum/status_effect/space_regeneration)

/obj/item/organ/internal/brain/voidwalker/on_death()
	. = ..()

	// explode into glass wooooohhoooo
	var/static/list/shards = list(/obj/item/shard = 2, /obj/item/shard/plasma = 1, /obj/item/shard/titanium = 1, /obj/item/shard/plastitanium = 1)
	for(var/i in 1 to rand(4, 6))
		var/shard_type = pick_weight(shards)
		var/obj/shard = new shard_type (get_turf(owner))
		shard.pixel_x = rand(-16, 16)
		shard.pixel_y = rand(-16, 16)

	new /obj/item/cosmic_skull (get_turf(owner))
	playsound(get_turf(owner), SFX_SHATTER, 100)

	qdel(owner)

/obj/item/implant/radio/voidwalker
	radio_key = /obj/item/encryptionkey/heads/captain
	actions_types = null

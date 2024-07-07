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

	/// Alpha we have in space
	var/space_alpha = 30
	/// Alpha we have elsewhere
	var/non_space_alpha = 255
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

	organ_owner.AddComponent(/datum/component/space_camo, space_alpha, non_space_alpha, 2 SECONDS)

	unsettle = new unsettle ()
	unsettle.Grant(organ_owner)

	glass_breaker = new/obj/item/void_eater
	organ_owner.put_in_hands(glass_breaker)

/obj/item/organ/internal/brain/voidwalker/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ENTER_AREA)
	alpha = 255
	organ_owner.add_to_all_human_data_huds()

	qdel(organ_owner.GetComponent(/datum/component/space_camo))

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
		organ_owner.add_movespeed_modifier(/datum/movespeed_modifier/grounded_voidwalker)
	//remove debufs for not being in gravity
	else
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

/// Camouflage us when we enter space by increasing alpha and or changing color
/datum/component/space_camo
	/// Alpha we have in space
	var/space_alpha
	/// Alpha we have elsewhere
	var/non_space_alpha
	/// How long we can't enter camo after hitting or being hit
	var/reveal_after_combat
	/// The world time after we can camo again
	VAR_PRIVATE/next_camo

/datum/component/space_camo/Initialize(space_alpha, non_space_alpha, reveal_after_combat)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.space_alpha = space_alpha
	src.non_space_alpha = non_space_alpha
	src.reveal_after_combat = reveal_after_combat

	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))

	if(isliving(parent))
		RegisterSignals(parent, list(COMSIG_ATOM_WAS_ATTACKED, COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_REVEAL), PROC_REF(force_exit_camo))

/datum/component/space_camo/proc/on_atom_entering(atom/movable/entering, atom/entering)
	SIGNAL_HANDLER

	if(!attempt_enter_camo())
		exit_camo(parent)

/datum/component/space_camo/proc/attempt_enter_camo()
	if(!isspaceturf(get_turf(parent)) || next_camo > world.time)
		return FALSE

	enter_camo(parent)
	return TRUE

/datum/component/space_camo/proc/force_exit_camo()
	SIGNAL_HANDLER

	exit_camo(parent)
	next_camo = world.time + reveal_after_combat
	addtimer(CALLBACK(src, PROC_REF(attempt_enter_camo)), reveal_after_combat, TIMER_OVERRIDE | TIMER_UNIQUE)

/datum/component/space_camo/proc/enter_camo(atom/movable/parent)
	if(parent.alpha != space_alpha)
		animate(parent, alpha = space_alpha, time = 0.5 SECONDS)
	parent.add_atom_colour(SSparallax.get_parallax_color(), TEMPORARY_COLOUR_PRIORITY)

/datum/component/space_camo/proc/exit_camo(atom/movable/parent)
	animate(parent, alpha = non_space_alpha, time = 0.5 SECONDS)
	parent.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

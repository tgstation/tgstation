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
	/// Image we show to our jaunter so they can see where they are
	var/image/position_indicator
	/// Icon we draw our position indicator from
	var/phased_mob_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	/// Icon state we use for our position indicator
	var/phased_mob_icon_state = "solarflare"

/datum/component/space_camo/Initialize(space_alpha, non_space_alpha, reveal_after_combat)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.space_alpha = space_alpha
	src.non_space_alpha = non_space_alpha
	src.reveal_after_combat = reveal_after_combat

/datum/component/space_camo/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(on_atom_entering))
	if(!isliving(parent))
		return

	var/mob/living/living_parent = parent
	position_indicator = image(phased_mob_icon, living_parent, phased_mob_icon_state, ABOVE_LIGHTING_PLANE)
	SET_PLANE_EXPLICIT(position_indicator, ABOVE_LIGHTING_PLANE, living_parent)
	position_indicator.appearance_flags |= RESET_ALPHA
	position_indicator.alpha = 0

	RegisterSignals(parent, list(COMSIG_ATOM_WAS_ATTACKED, COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_REVEAL), PROC_REF(force_exit_camo))
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(show_client_image))
	show_client_image(parent)

/datum/component/space_camo/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ENTERING,
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_REVEAL,
		COMSIG_MOB_LOGIN,
	))
	remove_client_image(parent)

/datum/component/space_camo/Destroy(force)
	. = ..()
	position_indicator = null

/datum/component/space_camo/proc/on_atom_entering(atom/movable/entering, atom/entered)
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
		if (position_indicator)
			animate(position_indicator, alpha = 255, time = 0.5 SECONDS)
	parent.remove_from_all_data_huds()
	parent.add_atom_colour(SSparallax.get_parallax_color(), TEMPORARY_COLOUR_PRIORITY)

/datum/component/space_camo/proc/exit_camo(atom/movable/parent)
	animate(parent, alpha = non_space_alpha, time = 0.5 SECONDS)
	if (position_indicator)
		animate(position_indicator, alpha = 0, time = 0.5 SECONDS)
	parent.add_to_all_human_data_huds()
	parent.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

/datum/component/space_camo/proc/show_client_image(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= position_indicator

/datum/component/space_camo/proc/remove_client_image(mob/remove_from)
	SIGNAL_HANDLER
	remove_from.client?.images -= position_indicator

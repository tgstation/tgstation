/// Remain in someones view without breaking line of sight
/datum/action/cooldown/spell/pointed/unsettle
	name = "Unsettle"
	desc = "Stare directly into someone who doesn't see you. Remain in their view for a bit to stun them for 2 seconds and announce your presence to them. "
	button_icon_state = "terrify"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	panel = null
	spell_requirements = NONE
	cooldown_time = 8 SECONDS
	cast_range = 9
	active_msg = "You prepare to stare down a target..."
	deactive_msg = "You refocus your eyes..."
	/// how long we need to stare at someone to unsettle them (woooooh)
	var/stare_time = 8 SECONDS
	/// how long we stun someone on succesful cast
	var/stun_time = 2 SECONDS
	/// stamina damage we doooo
	var/stamina_damage = 80

/datum/action/cooldown/spell/pointed/unsettle/is_valid_target(atom/cast_on)
	. = ..()

	if(!ishuman(cast_on))
		cast_on.balloon_alert(owner, "cannot be targeted!")
		return FALSE

	if(!check_if_in_view(cast_on))
		owner.balloon_alert(owner, "cannot see you!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(do_after(owner, stare_time, cast_on, IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_if_in_view), cast_on), hidden = TRUE))
		spookify(cast_on)
		return
	owner.balloon_alert(owner, "line of sight broken!")
	return SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/unsettle/proc/check_if_in_view(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(target.is_blind() || !(owner in viewers(target, world.view)))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/proc/spookify(mob/living/carbon/human/target)
	target.Paralyze(stun_time)
	target.adjustStaminaLoss(stamina_damage)
	target.apply_status_effect(/datum/status_effect/speech/slurring/generic)
	target.emote("scream")

	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(owner))
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(target))
	SEND_SIGNAL(owner, COMSIG_ATOM_REVEAL)

/obj/effect/temp_visual/circle_wave/unsettle
	color = COLOR_PURPLE

/// Lets us dive under the station from space
/datum/component/space_dive
	/// holder we use when we're in dive
	var/jaunt_type = /obj/effect/dummy/phased_mob/space_dive
	/// time it takes to enter the dive
	var/dive_time = 2 SECONDS
	/// the time it takes to exit our space dive
	var/surface_time = 2 SECONDS

/datum/component/space_dive/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(bump))

/datum/component/space_dive/proc/bump(mob/living/parent, atom/bumped)
	SIGNAL_HANDLER

	if(!isspaceturf(get_turf(parent)))
		return

	if(ismovable(bumped))
		if(istype(bumped, /obj/machinery/door))//door check is kinda lame but it just plays better
			return

		var/atom/movable/mover = bumped
		if(!mover.anchored)
			return

	INVOKE_ASYNC(src, PROC_REF(attempt_dive), parent, bumped)

/datum/component/space_dive/proc/attempt_dive(mob/living/parent, atom/bumped)
	if(!do_after(parent, dive_time, bumped))
		return

	dive(bumped)

/datum/component/space_dive/proc/dive(atom/bumped)
	var/obj/effect/dummy/phased_mob/jaunt = new jaunt_type(get_turf(bumped), parent)

	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(surface))
	RegisterSignal(jaunt, COMSIG_MOB_PHASED_CHECK, PROC_REF(move_check))
	parent.add_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), REF(src))

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(parent, COMSIG_MOB_ENTER_JAUNT, src, jaunt)

/datum/component/space_dive/proc/move_check(obj/effect/dummy/phased_mob/jaunt, mob/living/parent, turf/new_turf)
	SIGNAL_HANDLER

	if(!isspaceturf(new_turf))
		return

	INVOKE_ASYNC(src, PROC_REF(attempt_surface), parent, new_turf)
	return COMPONENT_BLOCK_PHASED_MOVE

/// try and surface by doing a do_after
/datum/component/space_dive/proc/attempt_surface(mob/living/parent, turf/new_turf)
	if(do_after(parent, surface_time, new_turf, extra_checks = CALLBACK(src, PROC_REF(check_if_moved), parent, get_turf(parent))))
		surface(null, parent, new_turf)

// we check if we moved for the do_after, since relayed movements arent caught that well by the do_after
/datum/component/space_dive/proc/check_if_moved(mob/living/parent, turf/do_after_turf)
	return get_turf(parent) == do_after_turf

/datum/component/space_dive/proc/surface(atom/holder, mob/living/parent, turf/target)
	SIGNAL_HANDLER

	var/obj/effect/dummy/phased_mob/jaunt = parent.loc
	if(!istype(jaunt))
		return FALSE

	parent.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE), REF(src))

	parent.forceMove(target || get_turf(parent))
	qdel(jaunt)

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(parent, COMSIG_MOB_AFTER_EXIT_JAUNT, src)

/obj/effect/dummy/phased_mob/space_dive
	movespeed = 1

/// Allows us to move through glass but not electrified glass. Can also do a little slowdown before passing through
/datum/component/glass_passer
	/// How long does it take us to move into glass?
	var/pass_time = 0 SECONDS

/datum/component/glass_passer/Initialize(pass_time)
	if(!ismob(parent)) //if its not a mob then just directly use passwindow
		return COMPONENT_INCOMPATIBLE

	src.pass_time = pass_time

	if(!pass_time)
		passwindow_on(parent, type)
	else
		RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(bumped))

	var/mob/mobbers = parent
	mobbers.generic_canpass = FALSE
	RegisterSignal(parent, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(cross_over))

/datum/component/glass_passer/Destroy()
	. = ..()
	if(parent)
		passwindow_off(parent, type)

/datum/component/glass_passer/proc/cross_over(mob/passer, atom/crosser)
	SIGNAL_HANDLER

	if(istype(crosser, /obj/structure/grille))
		var/obj/structure/grille/grille = crosser
		if(grille.shock(passer, 100))
			return COMPONENT_BLOCK_CROSS

	return null

/datum/component/glass_passer/proc/bumped(mob/living/owner, atom/bumpee)
	SIGNAL_HANDLER

	if(!istype(bumpee, /obj/structure/window))
		return

	INVOKE_ASYNC(src, PROC_REF(phase_through_glass), owner, bumpee)

/datum/component/glass_passer/proc/phase_through_glass(mob/living/owner, atom/bumpee)
	if(!do_after(owner, pass_time, bumpee))
		return
	passwindow_on(owner, type)
	try_move_adjacent(owner, get_dir(owner, bumpee))
	passwindow_off(owner, type)

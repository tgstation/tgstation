/datum/action/cooldown/spell/jaunt/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell turns your form ethereal, temporarily making you invisible and able to pass through walls."
	button_icon_state = "jaunt"
	sound = 'sound/magic/ethereal_enter.ogg'

	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS

	spell_requirements = (SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_NON_ABSTRACT|SPELL_REQUIRES_UNPHASED)

	var/exit_jaunt_sound = 'sound/magic/ethereal_exit.ogg'
	/// For how long are we jaunting?
	var/jaunt_duration = 5 SECONDS
	/// For how long we become immobilized after exiting the jaunt.
	var/jaunt_in_time = 0.5 SECONDS
	/// For how long we become immobilized when using this spell.
	var/jaunt_out_time = 0 SECONDS
	/// Visual for jaunting
	var/obj/effect/jaunt_in_type = /obj/effect/temp_visual/wizard
	/// Visual for exiting the jaunt
	var/obj/effect/jaunt_out_type = /obj/effect/temp_visual/wizard/out
	/// List of valid exit points
	var/list/exit_point_list

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/cast(mob/living/cast_on)
	. = ..()
	do_jaunt(cast_on)

/**
 * Begin the jaunt, and the entire jaunt chain.
 * Put cast_on in a phased mob holder.
 *
 * Calls do_jaunt_out:
 * - if jaunt_out_time is set to more than 0,
 * Or immediately calls start_jaunt:
 * - if jaunt_out_time = 0
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_jaunt(mob/living/cast_on)
	// Make sure they don't die or get jostled or something
	cast_on.notransform = TRUE

	var/turf/cast_turf = get_turf(cast_on)
	var/obj/effect/dummy/phased_mob/spell_jaunt/holder = new /obj/effect/dummy/phased_mob/spell_jaunt(cast_turf)
	new jaunt_out_type(cast_turf, cast_on.dir)

	cast_on.extinguish_mob()
	cast_on.forceMove(holder)
	cast_on.reset_perspective(holder)

	// They're in the holder safely, disable this again
	cast_on.notransform = FALSE

	do_steam_effects(cast_turf)

	if(jaunt_out_time > 0)
		ADD_TRAIT(cast_on, TRAIT_IMMOBILIZED, type)
		addtimer(CALLBACK(src, .proc/do_jaunt_out, cast_on, holder), jaunt_out_time)
	else
		start_jaunt(cast_on, holder)

/**
 * The wind-up to the jaunt.
 * Optional, not always called.
 *
 * Calls start_jaunt.
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_jaunt_out(mob/living/cast_on, obj/effect/dummy/phased_mob/spell_jaunt/holder)
	REMOVE_TRAIT(cast_on, TRAIT_IMMOBILIZED, type)
	start_jaunt(cast_on, holder)

/**
 * The actual process of starting the jaunt.
 * Sets up the signals and exit points and allows
 * the caster to actually start moving around.
 *
 * Calls stop_jaunt after the jaunt runs out.
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/start_jaunt(mob/living/cast_on, obj/effect/dummy/phased_mob/spell_jaunt/holder)
	LAZYINITLIST(exit_point_list)
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, .proc/update_exit_point, target)
	addtimer(CALLBACK(src, .proc/stop_jaunt, cast_on, holder, get_turf(holder)), jaunt_duration)

/**
 * The stopping of the jaunt.
 * Unregisters and signals and places
 * the jaunter on the turf they will exit at.
 *
 * Calls do_jaunt_in:
 * - if jaunt_in_time is less than 2.5 seconds,
 * Or immediately calls end_jaunt:
 * - if jaunt_in_time >= 2.5 seconds
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/stop_jaunt(mob/living/cast_on, obj/effect/dummy/phased_mob/spell_jaunt/holder, turf/start_point)
	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
	// Caster escaped our holder somehow
	if(cast_on.loc != holder)
		qdel(holder)
		return

	var/turf/found_exit
	for(var/turf/possible_exit as anything in exit_point_list)
		if(possible_exit.is_blocked_turf_ignore_climbable())
			continue
		found_exit = possible_exit
		break

	if(!found_exit)
		to_chat(cast_on, span_danger("Unable to find an unobstructed space, you find yourself ripped back to where you started."))
		found_exit = start_point

	exit_point_list = null
	holder.forceMove(found_exit)
	do_steam_effects(found_exit)
	holder.reappearing = TRUE
	playsound(found_exit, exit_jaunt_sound, 50, TRUE)

	ADD_TRAIT(cast_on, TRAIT_IMMOBILIZED, type)

	if(2.5 SECONDS - jaunt_in_time <= 0)
		end_jaunt(cast_on, holder, found_exit)
	else
		addtimer(CALLBACK(src, .proc/do_jaunt_in, cast_on, holder, found_exit), 2.5 SECONDS - jaunt_in_time)

/**
 * The wind-up (wind-out?) of exiting the jaunt.
 * Optional, not always called.
 *
 * Calls end_jaunt.
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_jaunt_in(mob/living/cast_on, obj/effect/dummy/phased_mob/spell_jaunt/holder, turf/final_point)
	new jaunt_in_type(final_point, holder.dir)
	cast_on.setDir(holder.dir)

	addtimer(CALLBACK(src, .proc/end_jaunt, cast_on, holder, final_point), jaunt_in_time)

/**
 * Finally, the actual veritable end of the jaunt chains.
 * Deletes the phase holder, ejecting the caster at final_point.
 *
 * If the final_point is dense for some reason,
 * tries to put the caster in an adjacent turf.
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/end_jaunt(mob/living/cast_on, obj/effect/dummy/phased_mob/spell_jaunt/holder, turf/final_point)
	qdel(holder)
	if(!QDELETED(cast_on) && final_point.density)
		var/list/aside_turfs = get_adjacent_open_turfs(final_point)
		if(length(aside_turfs))
			cast_on.forceMove(pick(aside_turfs))
		REMOVE_TRAIT(cast_on, TRAIT_IMMOBILIZED, type)

/**
 * Updates the exit point of the jaunt
 *
 * Called when the jaunting mob holder moves, this updates the backup exit-jaunt
 * location, in case the jaunt ends with the mob still in a wall. Five
 * spots are kept in the list, in case the last few changed since we passed
 * by (doors closing, engineers building walls, etc)
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/update_exit_point(mob/living/source)
	SIGNAL_HANDLER

	var/turf/location = get_turf(source)
	if(location.is_blocked_turf_ignore_climbable())
		return
	exit_point_list.Insert(1, location)
	if(length(exit_point_list) >= 5)
		exit_point_list.Cut(5)

/// Does some steam effects from the jaunt at passed loc.
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_steam_effects(turf/loc)
	var/datum/effect_system/steam_spread/steam = new()
	steam.set_up(10, FALSE, loc)
	steam.start()


/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls."
	background_icon_state = "bg_demon"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"

	cooldown_time = 25 SECONDS
	spell_requirements = (SPELL_REQUIRES_NON_ABSTRACT|SPELL_REQUIRES_UNPHASED)

	jaunt_duration = 5 SECONDS
	jaunt_in_time = 0.6 SECONDS
	jaunt_out_time = 0.6 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/do_steam_effects(mobloc)
	return

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/angelic
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith/angelic
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out/angelic

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/mystic
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith/mystic
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out/mystic

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/golem
	cooldown_time = 80 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out


/// The dummy that holds people jaunting. Maybe one day we can replace it.
/obj/effect/dummy/phased_mob/spell_jaunt
	movespeed = 2 //quite slow.
	var/reappearing = FALSE

/obj/effect/dummy/phased_mob/spell_jaunt/phased_check(mob/living/user, direction)
	if(reappearing)
		return
	. = ..()
	if(!.)
		return
	if (locate(/obj/effect/blessing, .))
		to_chat(user, span_warning("Holy energies block your path!"))
		return null

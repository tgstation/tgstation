// This could probably be an aoe spell but it's a little cursed, so I'm not touching it
/datum/action/cooldown/spell/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate..."
	sound = 'sound/effects/magic.ogg'
	button_icon_state = "spacetime"

	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_STATION
	spell_max_level = 1

	/// Weather we're ready to cast again yet or not
	var/ready = TRUE
	/// The radius of the scramble around the caster
	var/scramble_radius = 7
	/// The duration of the scramble
	var/duration = 15 SECONDS
	/// A lazylist of all scramble effects this spell has created.
	var/list/effects

/datum/action/cooldown/spell/spacetime_dist/Destroy()
	QDEL_LAZYLIST(effects)
	return ..()

/datum/action/cooldown/spell/spacetime_dist/can_cast_spell(feedback = TRUE)
	return ..() && ready

/datum/action/cooldown/spell/spacetime_dist/set_statpanel_format()
	. = ..()
	if(!islist(.))
		return

	if(!ready)
		.[PANEL_DISPLAY_STATUS] = "NOT READY"

/datum/action/cooldown/spell/spacetime_dist/cast(atom/cast_on)
	. = ..()
	var/list/turf/to_switcharoo = get_targets_to_scramble(cast_on)
	if(!length(to_switcharoo))
		to_chat(cast_on, span_warning("For whatever reason, the strings nearby aren't keen on being tangled."))
		reset_spell_cooldown()
		return

	ready = FALSE

	for(var/turf/swap_a as anything in to_switcharoo)
		var/turf/swap_b = to_switcharoo[swap_a]
		var/obj/effect/cross_action/spacetime_dist/effect_a = new /obj/effect/cross_action/spacetime_dist(swap_a, antimagic_flags)
		var/obj/effect/cross_action/spacetime_dist/effect_b = new /obj/effect/cross_action/spacetime_dist(swap_b, antimagic_flags)
		effect_a.linked_dist = effect_b
		effect_a.add_overlay(swap_b.photograph())
		effect_b.linked_dist = effect_a
		effect_b.add_overlay(swap_a.photograph())
		effect_b.set_light(4, 30, "#c9fff5")
		LAZYADD(effects, effect_a)
		LAZYADD(effects, effect_b)

/datum/action/cooldown/spell/spacetime_dist/after_cast()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(clean_turfs)), duration)

/// Callback which cleans up our effects list after the duration expires.
/datum/action/cooldown/spell/spacetime_dist/proc/clean_turfs()
	QDEL_LAZYLIST(effects)
	ready = TRUE

/**
 * Gets a list of turfs around the center atom to scramble.
 *
 * Returns an assoc list of [turf] to [turf]. These pairs are what turfs are
 * swapped between one another when the cast is done.
 */
/datum/action/cooldown/spell/spacetime_dist/proc/get_targets_to_scramble(atom/center)
	// Get turfs around the center
	var/list/turfs = spiral_range_turfs(scramble_radius, center)
	if(!length(turfs))
		return

	var/list/turf_steps = list()

	// Go through the turfs we got and pair them up
	// This is where we determine what to swap where
	var/num_to_scramble = round(length(turfs) * 0.5)
	for(var/i in 1 to num_to_scramble)
		turf_steps[pick_n_take(turfs)] = pick_n_take(turfs)

	// If there's any turfs unlinked with a friend,
	// just randomly swap it with any turf in the area
	if(length(turfs))
		var/turf/loner = pick(turfs)
		var/area/caster_area = get_area(center)
		turf_steps[loner] = get_turf(pick(caster_area.contents))

	return turf_steps


/obj/effect/cross_action
	name = "cross me"
	desc = "for crossing"
	anchored = TRUE

/obj/effect/cross_action/spacetime_dist
	name = "spacetime distortion"
	desc = "A distortion in spacetime. You can hear faint music..."
	icon_state = ""
	/// A flags which save people from being thrown about
	var/antimagic_flags = MAGIC_RESISTANCE
	var/obj/effect/cross_action/spacetime_dist/linked_dist
	var/busy = FALSE
	var/sound
	var/walks_left = 50 //prevents the game from hanging in extreme cases (such as minigun fire)

/obj/effect/cross_action/singularity_act()
	return

/obj/effect/cross_action/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/cross_action/spacetime_dist/Initialize(mapload, flags = MAGIC_RESISTANCE)
	. = ..()
	setDir(pick(GLOB.cardinals))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	antimagic_flags = flags

/obj/effect/cross_action/spacetime_dist/proc/walk_link(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		if(M.can_block_magic(antimagic_flags, charge_cost = 0))
			return
	if(linked_dist && walks_left > 0)
		flick("purplesparkles", src)
		linked_dist.get_walker(AM)
		walks_left--

/obj/effect/cross_action/spacetime_dist/proc/get_walker(atom/movable/AM)
	busy = TRUE
	flick("purplesparkles", src)
	AM.forceMove(get_turf(src))
	playsound(get_turf(src),sound,70,FALSE)
	busy = FALSE

/obj/effect/cross_action/spacetime_dist/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!busy)
		walk_link(AM)

/obj/effect/cross_action/spacetime_dist/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(user.temporarilyRemoveItemFromInventory(W))
		walk_link(W)
	else
		walk_link(user)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/cross_action/spacetime_dist/attack_hand(mob/user, list/modifiers)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/attack_paw(mob/user, list/modifiers)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/Destroy()
	busy = TRUE
	linked_dist = null
	return ..()

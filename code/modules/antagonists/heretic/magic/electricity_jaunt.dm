/datum/action/cooldown/spell/jaunt/electricity
	name = "Wire Walk"
	desc = "Allows you to enter the powernet of the station below you via powered cables. \
		While in this form, you will slowly regenerate stamina. However, the cable you are \
		occupying is suddenly depowered, you will be ejected violently."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	sound = 'sound/effects/light_flicker.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 6 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/electricity
	spell_requirements = NONE

	/// When we enter jaunt, this is how long the cooldown will be before we can exit.
	var/coolown_time_on_entry = 6 SECONDS
	/// When we exit jaunt, this is how long the cooldown will be before we can re-enter.
	var/cooldown_time_on_exit = 36 SECONDS

	/// A cache of all nearby cabes when we are casted
	var/list/obj/structure/cable/nearby_cables_cached = list()

/datum/action/cooldown/spell/jaunt/electricity/New(Target, original)
	. = ..()
	cooldown_time = coolown_time_on_entry

/datum/action/cooldown/spell/jaunt/electricity/Destroy()
	nearby_cables_cached.Cut()
	return ..()

/datum/action/cooldown/spell/jaunt/electricity/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	find_nearby_cable(cast_on)

	if(!length(nearby_cables_cached))
		cast_on.balloon_alert(cast_on, "no nearby powered cables!")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/jaunt/electricity/cast(atom/cast_on)
	. = ..()
	var/obj/structure/cable/jaunting_into = pick(nearby_cables_cached)
	nearby_cables_cached.Cut()

	if(is_jaunting(cast_on))
		. = exit_jaunt(cast_on, get_turf(jaunting_into))
	else
		. = enter_jaunt(cast_on, get_turf(jaunting_into))

	if(!.)
		to_chat(cast_on, span_warning("You are unable to wire walk!"))

/datum/action/cooldown/spell/jaunt/electricity/enter_jaunt(mob/living/jaunter, turf/loc_override)
	. = ..()
	if(!.)
		return

	cooldown_time = coolown_time_on_entry

	var/turf/wire_turf = get_turf(jaunter)
	to_chat(jaunter, span_notice("In a spark of light, you melt into the cabling below [wire_turf]!"))
	flash_nearby_witnesses(
		center = wire_turf,
		flashed_message = span_warning("[jaunter] suddenly disappears in a spark of light!"),
		immune_message = span_boldwarning("[jaunter] suddenly melts into [wire_turf], disappearing!"),
	)

/datum/action/cooldown/spell/jaunt/electricity/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	. = ..()
	if(!.)
		return

	cooldown_time = cooldown_time_on_exit

	var/turf/wire_turf = get_turf(unjaunter)
	to_chat(unjaunter, span_notice("In a spark of light, you reform from the cabling below [wire_turf]!"))
	flash_nearby_witnesses(
		center = wire_turf,
		flashed_message = span_warning("[unjaunter] suddenly appears in a spark of light!"),
		immune_message = span_boldwarning("[unjaunter] suddenly reforms out of [wire_turf], appearing out of nowhere!"),
	)

/**
 * Helper to flash every mob nearby the past center turf, providng messages depending on success.
 *
 * center - the center of the flash
 * flashed_message - message sent to all mobs affected by the flash
 * immune_message - message sent to all mbos immune to the flash (NOT blind mobs)
 */
/datum/action/cooldown/spell/jaunt/electricity/proc/flash_nearby_witnesses(turf/center, flashed_message, immune_message)
	for(var/mob/living/nearby_mob as anything in view(center))
		if(nearby_mob.is_blind()) // No messages for these guys
			continue
		if(nearby_mob.flash_act(2, affect_silicon = TRUE, visual = TRUE))
			to_chat(nearby_mob, flashed_message)
		else
			to_chat(nearby_mob, immune_message)

/**
 * Finds (and caches) all cables in a small radius around the passed center atom.
 *
 * Returns nothing, caches all the cables nearby in the nearby_cables_cached list.
 */
/datum/action/cooldown/spell/jaunt/electricity/proc/find_nearby_cable(atom/center)
	nearby_cables_cached.Cut()
	for(var/obj/structure/cable/cable in range(1, center))
		if(!cable.powernet || cable.powernet.avail <= 0)
			continue

		nearby_cables_cached += cable

// Our electricity jaunt holder, which spits people out if a cable's unpowered
/obj/effect/dummy/phased_mob/electricity
	name = "spark"

/obj/effect/dummy/phased_mob/electricity/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/electricity/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/electricity/process(delta_time)
	if(check_turf_for_cable(get_turf(src)))
		if(isliving(jaunter))
			var/mob/living/living_jaunter = jaunter
			if(DT_PROB(10, delta_time) && living_jaunter.getStaminaLoss())
				to_chat(jaunter, span_notice("You feel [pick("energized", "rejuvinated", "charged", "refreshed", "electric")]."))

			living_jaunter.adjustStaminaLoss(-2 * delta_time)
			living_jaunter.AdjustAllImmobility(-1 SECONDS)
		return

	eject_jaunter(TRUE)

/obj/effect/dummy/phased_mob/electricity/phased_check(mob/living/user, direction)
	var/turf/new_loc = ..()
	if(!new_loc || !check_turf_for_cable(new_loc))
		return

	return new_loc

/// Checks that the passed turf has a powered cable. Returns TRUE if so, FALSE otherwise.
/obj/effect/dummy/phased_mob/electricity/proc/check_turf_for_cable(turf/to_check)
	// Multi layer cable support because why not
	for(var/obj/structure/cable/possible_cable in to_check)
		if(possible_cable.powernet?.avail > 0)
			return TRUE

	return FALSE

/obj/effect/dummy/phased_mob/electricity/set_jaunter(atom/movable/new_jaunter)
	. = ..()
	if(!ismob(jaunter))
		return

	// We can do this pretty safely, as we're tied to the existence of this object
	var/datum/action/adjust_vision/electric_jaunt/vision = new(src)
	vision.Grant(jaunter)

/obj/effect/dummy/phased_mob/electricity/eject_jaunter(forced_out = FALSE)
	if(!forced_out)
		return ..()

	var/turf/dump_turf = get_turf(src)
	if(!istype(dump_turf))
		return ..()

	do_sparks(3, source = dump_turf)
	dump_turf.visible_message(span_boldwarning("[jaunter] reforms out of [dump_turf] in a violent shower of sparks!"), ignored_mobs = jaunter)

	var/obj/structure/cable/jaunting_in_currently = locate() in dump_turf
	if(jaunting_in_currently?.powernet?.avail > 0)
		to_chat(jaunter, span_userdanger("[jaunting_in_currently] suddenly loses power, ejecting you from the powernet!"))
	else
		to_chat(jaunter, span_userdanger("You suddenly find yourself disconnected from the powernet!"))

	if(isliving(jaunter))
		var/mob/living/living_jaunter = jaunter
		living_jaunter.Paralyze(12 SECONDS)
		living_jaunter.flash_act(10, length = 4 SECONDS)

	return ..()

// Simple subtype of nightvision action granted to mobs in the electric phase jaunt
/datum/action/adjust_vision/electric_jaunt
	desc = "Improve your vision of the darkness."
	background_icon_state = "bg_ecult"

/datum/action/adjust_vision/electric_jaunt/IsAvailable()
	return ..() && istype(owner.loc, /obj/effect/dummy/phased_mob/electricity)

/datum/action/adjust_vision/electric_jaunt/Grant(mob/living/grant_to)
	grant_to.sight |= (SEE_OBJS|SEE_TURFS)
	return ..()

/datum/action/adjust_vision/electric_jaunt/Remove(mob/living/remove_from)
	remove_from.sight ^= (SEE_OBJS|SEE_TURFS) // Yeah this fucks with mesons but too bad
	return ..()

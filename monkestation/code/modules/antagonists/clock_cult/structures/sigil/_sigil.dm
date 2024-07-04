#define SIGIL_INVOCATION_ALPHA 120
#define SIGIL_INVOKED_ALPHA 200
#define SIGIL_MATRIX_SCALE 1.2

//Sigil base
/obj/structure/destructible/clockwork/sigil
	name = "sigil"
	desc = "It's a sigil that does something."
	max_integrity = 10
	break_sound = null
	debris = null
	break_message = "The sigil is dispelled."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_effects.dmi'
	icon_state = "sigilvitality"
	density = FALSE
	alpha = 90
	/// How long you stand on the sigil before affect is applied
	var/effect_stand_time = 0
	/// The atom/movable that this is currently affecting
	var/currently_affecting
	/// Color while not used
	var/idle_color = "#FFFFFF"
	/// Color faded to while someone stands on top
	var/invocation_color = "#F1A03B"
	/// Color pulsed when effect applied
	var/pulse_color = "#EBC670"
	/// Color pulsed when effect fails
	var/fail_color = "#d47433"
	/// Ref to the current timer
	var/active_timer
	/// TRUE if the affect repeatedly applied an affect to the thing above it
	var/looping = FALSE
	/// FALSE if the rune can affect non-living atoms
	var/living_only = TRUE

/obj/structure/destructible/clockwork/sigil/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	color = idle_color

/obj/structure/destructible/clockwork/sigil/Destroy()
	currently_affecting = null

	if(active_timer)
		deltimer(active_timer)
		active_timer = null

	return ..()

/obj/structure/destructible/clockwork/sigil/attack_hand(mob/user)
	. = ..()
	if(dispel_check(user))
		dispel()


/// For trap sigils and similar; applies effects when someone/something walks over
/obj/structure/destructible/clockwork/sigil/proc/on_entered(datum/source, atom/movable/entered_movable)
	SIGNAL_HANDLER

	if((!isliving(entered_movable) && living_only) || currently_affecting || active_timer)
		return

	currently_affecting = entered_movable
	if(!effect_stand_time)
		apply_effects(entered_movable)
		return

	do_sparks(5, TRUE, src)
	animate(src, color = invocation_color, alpha = SIGIL_INVOCATION_ALPHA, effect_stand_time)
	active_timer = addtimer(CALLBACK(src, PROC_REF(apply_effects), entered_movable), effect_stand_time, TIMER_UNIQUE | TIMER_STOPPABLE)


/// For when someone/something leaves the sigil's turf
/obj/structure/destructible/clockwork/sigil/proc/on_exited(datum/source, atom/movable/exited_movable)
	SIGNAL_HANDLER

	if(currently_affecting != exited_movable)
		return

	currently_affecting = null
	animate(src, color = idle_color, alpha = initial(alpha), time = 0.5 SECONDS)

	if(active_timer)
		deltimer(active_timer)
		active_timer = null


/// If the sigil does not affect living, do not inherit this
/obj/structure/destructible/clockwork/sigil/proc/can_affect(atom/movable/movable_apply)

	var/mob/living/living_mob = movable_apply
	if(!istype(living_mob))
		return FALSE

	if(living_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return FALSE

	return TRUE


/// What happens when the sigil fails to invoke
/obj/structure/destructible/clockwork/sigil/proc/fail_invocation()
	active_timer = null
	currently_affecting = null
	color = fail_color
	transform = matrix() * SIGIL_MATRIX_SCALE
	alpha = 140
	animate(src, transform = matrix(), color = idle_color, alpha = initial(alpha), time = 0.5 SECONDS)


/// Apply the effects to an atom/movable
/obj/structure/destructible/clockwork/sigil/proc/apply_effects(atom/movable/movable_apply)

	if(!can_affect(movable_apply))
		fail_invocation()
		return FALSE

	color = pulse_color
	transform = matrix() * SIGIL_MATRIX_SCALE
	alpha = SIGIL_INVOKED_ALPHA

	if(looping)
		animate(src, transform = matrix(), color = invocation_color, alpha = SIGIL_INVOCATION_ALPHA, effect_stand_time)
		active_timer = addtimer(CALLBACK(src, PROC_REF(apply_effects), movable_apply), effect_stand_time, TIMER_UNIQUE | TIMER_STOPPABLE)

	else
		active_timer = null
		currently_affecting = null
		animate(src, transform = matrix(), color = idle_color, alpha = initial(alpha), time = 0.5 SECONDS)

	return TRUE


/// Dispel the sigil and delete itself
/obj/structure/destructible/clockwork/sigil/proc/dispel()
	animate(src, transform = matrix() * 1.5, alpha = 0, time = 3)
	QDEL_IN(src, 0.3 SECONDS)

/// Put any addtional checks you want to do before dispelling here
/obj/structure/destructible/clockwork/sigil/proc/dispel_check(mob/user)
	. = TRUE

#undef SIGIL_INVOCATION_ALPHA
#undef SIGIL_INVOKED_ALPHA
#undef SIGIL_MATRIX_SCALE

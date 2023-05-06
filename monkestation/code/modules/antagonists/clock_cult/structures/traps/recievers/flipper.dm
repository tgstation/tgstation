#define FLIP_DISTANCE 6
#define FLIP_SPEED 3

/obj/item/clockwork/trap_placer/flipper
	name = "flipper"
	desc = "A steam powered rotating floor panel. When input is received it will fling anyone on top of it."
	icon_state = "pressure_sensor"
	result_path = /obj/structure/destructible/clockwork/trap/flipper
	clockwork_desc = "A floor panel capable of flinging anyone back when triggered."

/obj/structure/destructible/clockwork/trap/flipper
	name = "flipper"
	desc = "A steam powered rotating floor panel. When input is received it will fling anyone on top of it."
	icon_state = "flipper"
	component_datum = /datum/component/clockwork_trap/flipper
	unwrench_path = /obj/item/clockwork/trap_placer/flipper
	clockwork_desc = "A floor panel capable of flinging anyone back when triggered. However, it does have a cooldown between uses."
	COOLDOWN_DECLARE(flip_cooldown)
	/// Time between possible flips
	var/cooldown_flip = 10 SECONDS

/obj/structure/destructible/clockwork/trap/flipper/examine(mob/user)
	. = ..()

	if(!COOLDOWN_FINISHED(src, flip_cooldown) && IS_CLOCK(user))
		. += span_brass("It's not ready to activate again yet!")

/// Send all `atom/movable`s flying in the set direction for a decent distance
/obj/structure/destructible/clockwork/trap/flipper/proc/flip()
	if(!COOLDOWN_FINISHED(src, flip_cooldown))
		return

	COOLDOWN_START(src, flip_cooldown, cooldown_flip)
	addtimer(CALLBACK(src, PROC_REF(cooldown_done)), cooldown_flip)

	flick("flipping", src)

	for(var/atom/movable/movable_atom in get_turf(src))

		if(movable_atom.anchored)
			continue

		movable_atom.throw_at(get_edge_target_turf(src, dir), FLIP_DISTANCE, FLIP_SPEED)

/// Visual update when the cooldown's finished
/obj/structure/destructible/clockwork/trap/flipper/proc/cooldown_done()
	visible_message(span_brass("[src] whirrs with a loud *CLANK* as it resets."))

/datum/component/clockwork_trap/flipper
	takes_input = TRUE

/datum/component/clockwork_trap/flipper/trigger()
	if(!..())
		return

	var/obj/structure/destructible/clockwork/trap/flipper/flipper_parent = parent
	flipper_parent.flip()

#undef FLIP_DISTANCE
#undef FLIP_SPEED

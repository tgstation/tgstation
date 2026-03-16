/// Science object that behaves similairly to to strange objects/relics, but is activated by cracking wire sequences and other functions
/obj/machinery/gizmo
	name = "gizmo"
	desc = "Does a function when you put the jigger at the other ends thing."
	icon = 'icons/obj/devices/gizmos.dmi'

	panel_open = TRUE
	density = TRUE
	anchored = FALSE

	var/list/icon_states = list("gizmo_0", "gizmo_1", "gizmo_2", "gizmo_3", "gizmo_4", "gizmo_5")
	var/datum/gizmo_interface/interface = /datum/gizmo_interface

	var/do_voice_instead = FALSE

/obj/machinery/gizmo/Initialize(mapload)
	. = ..()

	if(icon_states)
		base_icon_state = pick(icon_states)
		icon_state = base_icon_state

	var/list/trigger_callbacks = list()
	interface = new interface(src, trigger_callbacks)

	if(do_voice_instead)
		AddComponent(/datum/component/gizmo_voice, interface.puzzles[1])
	else
		set_wires(new /datum/wires/gizmo(src, interface.puzzles[1]))

	RegisterSignal(src, COMSIG_GIZMO_START_MOVING, PROC_REF(start_moving))
	RegisterSignal(src, COMSIG_GIZMO_STOP_MOVING, PROC_REF(stop_moving))

/obj/machinery/gizmo/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)

	if(is_wire_tool(item))
		attempt_wire_interaction(user)
		return

/obj/machinery/gizmo/proc/start_moving(datum/gizpulse/pulse)
	SIGNAL_HANDLER

	on_start_moving(pulse)

/obj/machinery/gizmo/proc/stop_moving(datum/gizpulse/pulse)
	SIGNAL_HANDLER

	on_stop_moving(pulse)

/obj/machinery/gizmo/proc/on_start_moving(datum/gizpulse/pulse)
	return

/obj/machinery/gizmo/proc/on_stop_moving(datum/gizpulse/pulse)
	return

/obj/machinery/gizmo/beyblade

	icon_state = "beyblade"

	interface = /datum/gizmo_interface/beyblade

	var/moving = FALSE


/obj/machinery/gizmo/beyblade/update_icon(updates)
	. = ..()

	icon_state = base_icon_state + (moving ? "_spinning" : "")

/obj/machinery/gizmo/beyblade/on_start_moving(datum/gizpulse/pulse)
	AddElement(/datum/element/moving_randomly)
	density = TRUE

	moving = TRUE
	update_icon()


/obj/machinery/gizmo/beyblade/on_stop_moving(datum/gizpulse/pulse)
	RemoveElement(/datum/element/moving_randomly)
	density = FALSE

	moving = FALSE
	update_icon()

/// A gizmo with some sort of "on" state. Really only for visuals
/obj/machinery/gizmo/toggle

	icon_state = "gizmo_light"

	interface = /datum/gizmo_interface/toggle

	icon_states = list("gizmo_active_0", "gizmo_active_1", "gizmo_active_2", "gizmo_active_3", "gizmo_active_4")

	do_voice_instead = TRUE

	var/on_state = FALSE

/obj/machinery/gizmo/toggle/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_GIZMO_ON_STATE, PROC_REF(on_state))
	RegisterSignal(src, COMSIG_GIZMO_OFF_STATE, PROC_REF(off_state))

/obj/machinery/gizmo/toggle/update_icon(updates)
	. = ..()

	icon_state = base_icon_state + (on_state ? "_on" : "")

/obj/machinery/gizmo/toggle/proc/on_state(datum/gizpulse/pulse)
	SIGNAL_HANDLER

	on_state = TRUE
	update_icon()

/obj/machinery/gizmo/toggle/proc/off_state(datum/gizpulse/pulse)
	SIGNAL_HANDLER

	on_state = FALSE
	update_icon()

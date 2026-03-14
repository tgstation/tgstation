/// Science object that behaves similairly to to strange objects/relics, but is activated by cracking wire sequences and other functions
/obj/machinery/gizmo
	name = "gizmo"
	desc = "Does a function when you put the jigger at the other ends thing."
	icon = 'icons/obj/devices/artefacts.dmi'
	icon_state = "debug_artefact"

	panel_open = TRUE
	density = TRUE
	anchored = FALSE

	var/datum/gizmo_interface/interface

/obj/machinery/gizmo/Initialize(mapload)
	. = ..()

	var/list/trigger_callbacks = list()
	interface = new (src, trigger_callbacks)

	set_wires(new /datum/wires/gizmo(src, interface.puzzles[1]))

/obj/machinery/gizmo/proc/activate_gizmo(code_sequence_number)
	to_chat(world, "WOOOOOOO, its sequence numba [code_sequence_number]")

/obj/machinery/gizmo/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	add_fingerprint(user)

	if(is_wire_tool(item))
		attempt_wire_interaction(user)
		return

/datum/wires/gizmo
	randomize = TRUE

	/// Might as well keep it broad, it's all signals anyway
	holder_type = /obj

	/// The wires we need to pulse for cracking the code
	var/list/cryptic_wires = list(
		CRYPTIC_WIRE_1,
		CRYPTIC_WIRE_2,
		CRYPTIC_WIRE_3,
		CRYPTIC_WIRE_4,
		CRYPTIC_WIRE_5,
		CRYPTIC_WIRE_6,
		CRYPTIC_WIRE_7,
		CRYPTIC_WIRE_8,
	)

	var/datum/gizmo_puzzle/puzzle

/datum/wires/gizmo/New(atom/holder, datum/gizmo_puzzle/_puzzle)
	wires = cryptic_wires
	puzzle = _puzzle

	..()

/datum/wires/gizmo/on_pulse(wire, mob/living/user)
	puzzle.on_pulse(cryptic_wires.Find(wire), user, holder)

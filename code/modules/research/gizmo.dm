/// Science object that behaves similairly to to strange objects/relics, but is activated by cracking wire sequences and other functions
/obj/machinery/gizmo
	name = "gizmo"
	desc = "Does a function when you put the jigger at the other ends thing."
	icon = 'icons/obj/devices/artefacts.dmi'
	icon_state = "debug_artefact"

	panel_open = TRUE
	density = TRUE
	anchored = FALSE

/obj/machinery/gizmo/Initialize(mapload)
	. = ..()

	var/datum/callback/callback_1 = CALLBACK(src, PROC_REF(activate_gizmo), 1)
	var/datum/callback/callback_2 = CALLBACK(src, PROC_REF(activate_gizmo), 2)

	set_wires(new /datum/wires/gizmo(src, list(callback_1, callback_2)))

/obj/machinery/gizmo/proc/activate_gizmo(code_sequence_number)
	to_chat(world, "WOOOOOOO, its sequence numba [code_sequence_number]")

/obj/machinery/gizmo/moody

/obj/machinery/gizmo/storage

/obj/machinery/gizmo/moisturizer

/obj/machinery/gizmo/proc/positive_mood_pulse(range)
	mood_pulse(range, /datum/mood_event/gizmo_positive)
	new /obj/effect/temp_visual/circle_wave(get_turf(src), COLOR_GREEN)

/obj/machinery/gizmo/proc/negative_mood_pulse(range)
	mood_pulse(range, /datum/mood_event/gizmo_negative)
	new /obj/effect/temp_visual/circle_wave(get_turf(src), COLOR_RED)

/obj/machinery/gizmo/proc/mood_pulse(range, datum/mood_event/event)
	for(var/mob/living/carbon/human/human in orange(range, src))
		human.add_mood_event("gizmo_mood_pulse", event)

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

	/// How long a code sequence can be
	var/code_length = 3
	/// The codes that got generated, formatted as (1 = list(CRYPTIC_WIRE_5, CRYPTIC_WIRE_3, CRYPTIC_WIRE_7, 2 = list(...)))
	var/list/code_sequences
	/// The current sequence we're on. Will reset if it doesn't match anything
	var/list/current_sequence = list()
	/// List of callbacks that the solutions will call on succes
	var/list/callbacks

/datum/wires/gizmo/New(atom/holder, list/_callbacks)
	wires = cryptic_wires

	callbacks = _callbacks

	generate_code_sequences()

	..()

/datum/wires/gizmo/proc/generate_code_sequences()
	code_sequences = list()

	for(var/i in 1 to callbacks.len)
		code_sequences += list(list())
		for(var/j in 1 to code_length)
			code_sequences[i] += pick(cryptic_wires)

/datum/wires/gizmo/on_pulse(wire, mob/living/user)
	current_sequence += wire

	var/succeeded = FALSE

	for(var/i in 1 to code_sequences.len)
		var/list/a = code_sequences[i]
		for(var/j in 1 to current_sequence.len)
			if(current_sequence[j] != a[j])
				break
			if(current_sequence.len == j)
				succeeded = TRUE
			if(j == a.len)
				var/datum/callback/callback = callbacks[i]
				callback.Invoke()
				current_sequence.Cut()
				break

	if(succeeded)
		holder.balloon_alert(user, "ping")
		playsound(holder, 'sound/machines/ping.ogg', 30, FALSE)

	else
		holder.balloon_alert(user, "buzz")
		playsound(holder, 'sound/machines/buzz/buzz-sigh.ogg', 30, FALSE)
		current_sequence.Cut()

/area/station/bitminer_den
	name = "Bitmining: Den"
	desc = "Office of bitminers, houses their equipment."
	icon_state = "bit_den"

/area/station/bitminer_den/receive
	name = "Bitmining: Receiving"
	desc = "Receives shipments from the virtual domain."
	icon_state = "bit_receive"

/area/station/virtual_domain
	name = "Virtual Domain"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED
	has_gravity = STANDARD_GRAVITY
	static_lighting = TRUE

/area/station/virtual_domain/bottom_left
	icon_state = "bit_gen_map"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain: Ruins"
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED

/area/icemoon/underground/explored/virtual_domain
	name = "Virtual Domain: Ice Ruins"
	icon_state = "bit_ice"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED

/// Using this to get turfs on the z-level then deleting contents
/area/station/virtual_domain/to_delete
	icon_state = "bit_gen_del"

/area/station/virtual_domain/safehouse
	name = "Virtual Domain: Safehouse"
	requires_power = FALSE
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/virtual_domain/safehouse/bottom_left
	icon_state = "bit_gen_safe"

/area/station/virtual_domain/safehouse/exit
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED
	icon_state = "bit_exit"

/area/station/virtual_domain/safehouse/send
	icon_state = "bit_send"

/area/station/virtual_domain/safehouse/send/LateInitialize()
	. = ..()

	for(var/turf/tile in get_area_turfs(type, z))
		RegisterSignal(tile, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/// Handles examining the server. Shows cooldown time and efficiency.
/area/station/virtual_domain/safehouse/send/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_info("Beneath your gaze, the floor pulses subtly with streams of encoded data.")
	examine_text += span_info("It seems to be part of the location designated for retrieving encrypted payloads.")

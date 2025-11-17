/obj/docking_port/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, dheight)
	. += NAMEOF(src, dwidth)
	. += NAMEOF(src, height)
	. += NAMEOF(src, shuttle_id)
	. += NAMEOF(src, width)
	return .

/obj/docking_port/stationary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, roundstart_template)
	return .

// The tram is a little tricky to save because all the [/obj/structure/transport/linear] get deleted except for the one at the bottom left of the tram. These all get used during Init to determine the size and shape of the tram.
// Next problem is the landmark [/obj/effect/landmark/transport/transport_id] gets attatched to the /datum/transport_controller/ and then deleted.
// To resolve these we are going to insert a transport structure on the same turf as any tram wall/floors.
// Then we lookup the landmark from the datum and insert it on the same turf that has the bottom left transport structure
// Without these fixes the tram will runtime on any map or ruins that has it setup

/obj/structure/transport/linear/tram/is_saveable(turf/current_loc, list/obj_blacklist)
	return TRUE // skip multi-tile object checks

// these are for public elevators
/obj/structure/transport/linear/public/on_object_saved(map_string, turf/current_loc)
	var/datum/transport_controller/linear/transport = transport_controller_datum

	if(!transport || !transport.specific_transport_id || !length(transport.transport_modules))
		return

	var/total_elevator_turfs = length(transport.transport_modules)
	var/middle_section = ceil(total_elevator_turfs / 2) // 2x3 elevators do not play nice with this calculation
	if(transport.transport_modules[middle_section] != src)
		return

	var/obj/effect/landmark/transport/transport_id/landmark_typepath = /obj/effect/landmark/transport/transport_id
	var/list/landmark_variables = list()
	TGM_ADD_TYPEPATH_VAR(landmark_variables, landmark_typepath, specific_transport_id, transport.specific_transport_id)
	TGM_MAP_BLOCK(map_string, landmark_typepath, generate_tgm_typepath_metadata(landmark_variables))

	var/obj/effect/abstract/elevator_music_zone/elevator_music_path = /obj/effect/abstract/elevator_music_zone
	var/list/elevator_variables = list()
	TGM_ADD_TYPEPATH_VAR(elevator_variables, elevator_music_path, linked_elevator_id, transport.specific_transport_id)
	TGM_MAP_BLOCK(map_string, elevator_music_path, generate_tgm_typepath_metadata(elevator_variables))

// these are for the tram
/obj/structure/transport/linear/tram/on_object_saved(map_string, turf/current_loc)
	// only save the landmark to the bottom left turf of the bounding box since
	// the tram is considered a multi-tile object
	if(src.loc != current_loc)
		return

	var/datum/transport_controller/linear/transport = transport_controller_datum
	if(transport?.specific_transport_id)
		var/obj/effect/landmark/transport/transport_id/landmark_typepath = /obj/effect/landmark/transport/transport_id
		var/list/landmark_variables = list()
		TGM_ADD_TYPEPATH_VAR(landmark_variables, landmark_typepath, specific_transport_id, transport.specific_transport_id)
		TGM_MAP_BLOCK(map_string, landmark_typepath, generate_tgm_typepath_metadata(landmark_variables))

/obj/machinery/elevator_control_panel/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, linked_elevator_id)
	. += NAMEOF(src, preset_destination_names)
	return .

/obj/machinery/lift_indicator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, linked_elevator_id)
	. += NAMEOF(src, current_lift_floor)
	return .

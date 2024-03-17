/datum/forklift_module/airlocks
	name = "Airlocks"
	current_selected_typepath = /obj/machinery/door/airlock
	available_builds = list(
		/obj/machinery/door/airlock,
		/obj/machinery/door/airlock/glass,
		/obj/machinery/door/airlock/maintenance,
		/obj/machinery/door/airlock/public,
		/obj/machinery/door/airlock/public/glass,
		/obj/machinery/door/airlock/science,
		/obj/machinery/door/airlock/science/glass,
		/obj/machinery/door/airlock/security,
		/obj/machinery/door/airlock/security/glass,
		/obj/machinery/door/airlock/engineering,
		/obj/machinery/door/airlock/engineering/glass,
		/obj/machinery/door/airlock/hydroponics,
		/obj/machinery/door/airlock/hydroponics/glass,
		/obj/machinery/door/airlock/medical,
		/obj/machinery/door/airlock/medical/glass,
		/obj/machinery/door/airlock/command,
		/obj/machinery/door/airlock/command/glass,

	)
	resource_price = list(
		/obj/machinery/door/airlock = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/maintenance = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/public = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/public/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/science = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/science/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/security = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/security/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/engineering = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/engineering/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/hydroponics = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/hydroponics/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/medical = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/medical/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
		/obj/machinery/door/airlock/command = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/machinery/door/airlock/command/glass = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
			/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		),
	)
	build_length = 10 SECONDS
	hologram_path = /obj/structure/building_hologram/airlock
	///What accesses do we have?
	var/list/available_accesses = list("None")
	///What access did we select?
	var/selected_access = "None"

/datum/forklift_module/airlocks/New()
	. = ..()
	available_accesses = list("None") + REGION_ACCESS_ALL_STATION

/// Ideally, you rotate here or cycle through a setting.
/datum/forklift_module/airlocks/on_ctrl_scrollwheel(mob/source, atom/A, scrolled_up)
	if(scrolled_up)
		selected_access = next_list_item(selected_access, available_accesses)
	else
		selected_access = previous_list_item(selected_access, available_accesses)
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	if(selected_access == "None")
		my_forklift.balloon_alert(source, "Public Access")
	else
		my_forklift.balloon_alert(source, SSid_access.desc_by_access[selected_access])

/datum/forklift_module/airlocks/after_build(atom/built_atom)
	built_atom.dir = direction
	if(selected_access != "None")
		var/obj/machinery/door/airlock/airlock = built_atom
		airlock.req_access += list(selected_access)

/datum/forklift_module/airlocks/valid_placement_location(location)
	if(locate(/obj/machinery/door/airlock) in location) // cant stack airlocks
		return FALSE
	if(istype(location, /turf/open/floor))
		return TRUE
	else
		return FALSE

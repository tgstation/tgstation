/datum/forklift_module/department_machinery
	name = "Departmental Machinery"
	current_selected_typepath = /obj/structure/frame/machine
	available_builds = list(
		/obj/structure/frame/machine,
		/obj/structure/frame/computer,
	) // Populated on New
	resource_price = list(
		/obj/structure/frame/machine = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
		/obj/structure/frame/computer = list(
			/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		),
	) // Populated on New
	build_length = 5 SECONDS
	turf_place_on_top = TRUE
	show_name_on_change = TRUE
	deconstruction_cooldown = 5 SECONDS
	var/bitflag_to_use = DEPARTMENT_BITFLAG_ENGINEERING
	var/list/machinery_price = list(
		/datum/material/iron = (SHEET_MATERIAL_AMOUNT * 5) + 50, // 5x cable coils + 5 sheets of metal
		/datum/material/glass = 25, // 5x cable coils
	)
	var/list/computer_price = list(
		/datum/material/iron = (SHEET_MATERIAL_AMOUNT * 5) + 50, // 5x cable coils + 5 sheets of metal
		/datum/material/glass = 25, // 5x cable coils
	)

/datum/forklift_module/department_machinery/New()
	. = ..()
	for(var/typepath in subtypesof(/datum/design/board))
		var/datum/design/board/checked_path = typepath
		var/obj/item/circuitboard/board_checked = initial(checked_path.build_path)
		if(initial(checked_path.departmental_flags) & bitflag_to_use)
			available_builds += initial(board_checked.build_path)
			if(ispath(initial(board_checked.build_path), /obj/machinery/computer))
				resource_price[initial(board_checked.build_path)] = computer_price
			else
				resource_price[initial(board_checked.build_path)] = machinery_price
		continue

/datum/forklift_module/department_machinery/on_scrollwheel(mob/source, atom/A, scrolled_up)
	var/list/available_paths_real = list(
		/obj/structure/frame/machine,
		/obj/structure/frame/computer,
	)
	var/datum/techweb/station_techweb = SSresearch.techwebs_assoc_lookup[TECHWEB_STATION]
	for(var/i in station_techweb.researched_designs)
		var/datum/design/board/circuit_board = SSresearch.techweb_design_by_id(i)
		if(!istype(circuit_board)) // not a machine
			continue
		if(!(initial(circuit_board.departmental_flags) & bitflag_to_use)) // not in our department
			continue
		var/obj/item/circuitboard/board_checked = initial(circuit_board.build_path)
		available_paths_real += initial(board_checked.build_path)
	if(scrolled_up)
		current_selected_typepath = next_list_item(current_selected_typepath, available_paths_real)
	else
		current_selected_typepath = previous_list_item(current_selected_typepath, available_paths_real)
	LAZYREMOVE(source.client.images, preview_image)
	qdel(preview_image)
	update_preview_icon()
	preview_image.loc = last_turf_moused_over
	LAZYOR(source.client.images, preview_image)
	var/atom/current_atom = current_selected_typepath
	if(show_name_on_change)
		my_forklift.balloon_alert(source, initial(current_atom.name))
	playsound(my_forklift, 'sound/effects/pop.ogg', 50, FALSE)

/datum/forklift_module/department_machinery/valid_placement_location(location)
	if(istype(location, /turf/open/floor))
		return TRUE
	else
		return FALSE

/datum/forklift_module/department_machinery/medical
	name = "Medical Machinery"
	bitflag_to_use = DEPARTMENT_BITFLAG_MEDICAL

/datum/forklift_module/department_machinery/engineering
	name = "Engineering Machinery"
	bitflag_to_use = DEPARTMENT_BITFLAG_ENGINEERING

/datum/forklift_module/department_machinery/service
	name = "Service Machinery"
	bitflag_to_use = DEPARTMENT_BITFLAG_SERVICE

/datum/forklift_module/department_machinery/cargo
	name = "Cargo Machinery"
	bitflag_to_use = DEPARTMENT_BITFLAG_CARGO

/datum/forklift_module/department_machinery/security
	name = "Security Machinery"
	bitflag_to_use = DEPARTMENT_BITFLAG_SECURITY

/datum/forklift_module/department_machinery/science
	name = "Science Machinery"
	bitflag_to_use = DEPARTMENT_BITFLAG_SCIENCE

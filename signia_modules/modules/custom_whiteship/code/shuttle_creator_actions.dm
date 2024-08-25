//============ Actions ============
/datum/action/innate/shuttle_creator
	button_icon = 'signia_modules/modules/custom_whiteship/icons/actions_shuttle.dmi'
	var/mob/living/C
	var/mob/camera/ai_eye/remote/shuttle_creation/remote_eye
	var/obj/item/shuttle_creator/shuttle_creator

/datum/action/innate/shuttle_creator/Activate()
	if(!target)
		return TRUE
	C = owner
	remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/shuttle_creator/internal_console = target
	shuttle_creator = internal_console.owner_rsd

//Add an area
/datum/action/innate/shuttle_creator/designate_area
	name = "Designate Room"
	button_icon_state = "designate_area"

/datum/action/innate/shuttle_creator/designate_area/Activate()
	if(..())
		return
	shuttle_creator.add_saved_area(remote_eye)

//Add a single turf
/datum/action/innate/shuttle_creator/designate_turf
	name = "Designate Turf"
	button_icon_state = "designate_turf"

/datum/action/innate/shuttle_creator/designate_turf/Activate()
	if(..())
		return
	var/turf/T = get_turf(remote_eye)
	if(istype(T, /turf/open/space))
		var/connectors_exist = FALSE
		for(var/obj/structure/lattice/lattice in T)
			connectors_exist = TRUE
			break
		if(!connectors_exist)
			to_chat(usr, "<span class='warning'>This turf requires support, build some catwalks or lattices.</span>")
			return
	if(!shuttle_creator.check_area(list(T)))
		return
	if(shuttle_creator.turf_in_list(T))
		return
	shuttle_creator.add_single_turf(T)

//Clear a single entire area
/datum/action/innate/shuttle_creator/clear_turf
	name = "Clear Turf"
	button_icon_state = "clear_turf"

/datum/action/innate/shuttle_creator/clear_turf/Activate()
	if(..())
		return
	shuttle_creator.remove_single_turf(get_turf(remote_eye))

//Clear the entire area
/datum/action/innate/shuttle_creator/reset
	name = "Reset Buffer"
	button_icon_state = "clear_area"

/datum/action/innate/shuttle_creator/reset/Activate()
	if(..())
		return
	shuttle_creator.reset_saved_area()

//Finish the shuttle
/datum/action/innate/shuttle_creator/airlock
	name = "Select Docking Airlock"
	button_icon_state = "select_airlock"

/datum/action/innate/shuttle_creator/airlock/Activate()
	if(..())
		return
	var/turf/T = get_turf(remote_eye)
	for(var/obj/machinery/door/airlock/A in T)
		if(get_area(A) != shuttle_creator.loggedOldArea)
			to_chat(C, "<span class='warning'>Caution, airlock must be on the shuttle to function as a dock.</span>")
			return
		if(shuttle_creator.linkedShuttleId)
			return
		if(GLOB.custom_shuttle_count > CUSTOM_SHUTTLE_LIMIT)
			to_chat(C, "<span class='warning'>Shuttle limit reached, sorry.</span>")
			return
		if(shuttle_creator.loggedTurfs.len > SHUTTLE_CREATOR_MAX_SIZE)
			to_chat(C, "<span class='warning'>This shuttle is too large!</span>")
			return
		if(!shuttle_creator.getNonShuttleDirection(T))
			to_chat(C, "<span class='warning'>Docking port must be on an external wall, with only 1 side exposed to space.</span>")
			return
		if(!shuttle_creator.create_shuttle_area(C))
			return
		if(shuttle_creator.shuttle_create_docking_port(A, C))
			to_chat(C, "<span class='notice'>Shuttle created!</span>")
		//Remove eye control
		var/obj/machinery/computer/camera_advanced/shuttle_creator/internal_console = target
		internal_console.remove_eye_control()
		qdel(internal_console)
		return

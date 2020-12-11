/obj/machinery/computer/camera_advanced/base_construction/aux
	name = "aux base construction console"
	structures = list("fans" = 0, "turrets" = 0)
	allowed_area = /area/shuttle/auxiliary_base

/obj/machinery/computer/camera_advanced/base_construction/aux/refill_special_structures()
	RCD.matter = RCD.max_matter
	structures["fans"] = 4
	structures["turrets"] = 4

/obj/machinery/computer/camera_advanced/base_construction/aux/populate_actions_list()
	construction_actions = list()
	construction_actions.Add(new /datum/action/innate/construction/switch_mode())//Action for switching the RCD's build modes
	construction_actions.Add(new /datum/action/innate/construction/build()) //Action for using the RCD
	construction_actions.Add(new /datum/action/innate/construction/airlock_type()) //Action for setting the airlock type
	construction_actions.Add(new /datum/action/innate/construction/window_type()) //Action for setting the window type
	construction_actions.Add(new /datum/action/innate/construction/place_structure/fan()) //Action for spawning fans
	construction_actions.Add(new /datum/action/innate/construction/place_structure/turret()) //Action for spawning turrets

/obj/machinery/computer/camera_advanced/base_construction/aux/find_spawn_spot()
	for(var/obj/machinery/computer/auxiliary_base/ABC in GLOB.machines)
		if(istype(get_area(ABC), allowed_area))
			found_aux_console = ABC
			break
	if(!found_aux_console)
		say("ERROR: Unable to locate auxiliary base controller!")
		return null
	return found_aux_console

//*******************FUNCTIONS*******************

/datum/action/innate/construction/build
	name = "Build"
	button_icon_state = "build"

/datum/action/innate/construction/build/Activate()
	if(..())
		return
	if(!check_spot())
		return
	var/turf/target_turf = get_turf(remote_eye)
	var/atom/rcd_target = target_turf

	//Find airlocks and other shite
	for(var/obj/S in target_turf)
		if(LAZYLEN(S.rcd_vals(owner,B.RCD)))
			rcd_target = S //If we don't break out of this loop we'll get the last placed thing
	owner.changeNext_move(CLICK_CD_RANGE)
	B.RCD.afterattack(rcd_target, owner, TRUE) //Activate the RCD and force it to work remotely!
	playsound(target_turf, 'sound/items/deconstruct.ogg', 60, TRUE)

/datum/action/innate/construction/switch_mode
	name = "Switch Mode"
	button_icon_state = "builder_mode"

/datum/action/innate/construction/switch_mode/Activate()
	if(..())
		return
	var/list/buildlist = list("Walls and Floors" = 1,"Airlocks" = 2,"Deconstruction" = 3,"Windows and Grilles" = 4)
	var/buildmode = input("Set construction mode.", "Base Console", null) in buildlist
	B.RCD.mode = buildlist[buildmode]
	to_chat(owner, "Build mode is now [buildmode].")

/datum/action/innate/construction/airlock_type
	name = "Select Airlock Type"
	button_icon_state = "airlock_select"

/datum/action/innate/construction/airlock_type/Activate()
	if(..())
		return
	B.RCD.change_airlock_setting()

/datum/action/innate/construction/window_type
	name = "Select Window Glass"
	button_icon_state = "window_select"

/datum/action/innate/construction/window_type/Activate()
	if(..())
		return
	B.RCD.toggle_window_glass()

/datum/action/innate/construction/place_structure
	name = "Place Generic Structure"
	var/structure_name
	var/obj/structure_path
	var/place_sound

/datum/action/innate/construction/place_structure/Activate()
	if(..())
		return
	var/turf/place_turf = get_turf(remote_eye)
	if(!B.structures[structure_name])
		to_chat(owner, "<span class='warning'>[B] is out of [structure_name]!</span>")
		return
	if(!check_spot())
		return
	if(place_turf.density)
		to_chat(owner, "<span class='warning'>[structure_name] may only be placed on a floor.</span>")
		return
	if(initial(structure_path.density) && place_turf.is_blocked_turf())
		to_chat(owner, "<span class='warning'>Location is obstructed by something. Please clear the location and try again.</span>")
		return
	var/obj/placed_structure = new structure_path(place_turf)
	B.structures[structure_name]--
	var/rem_fans = B.structures[structure_name]
	to_chat(owner, "<span class='notice'>Structure placed. [rem_fans] remaining.</span>")
	playsound(place_turf, place_sound, 50, TRUE)
	after_place(placed_structure)

/datum/action/innate/construction/place_structure/proc/after_place()
	return

/datum/action/innate/construction/place_structure/fan
	name = "Place Tiny Fan"
	button_icon_state = "build_fan"
	structure_name = "fans"
	structure_path = /obj/structure/fans/tiny
	place_sound =  'sound/machines/click.ogg'

/datum/action/innate/construction/place_structure/turret
	name = "Install Plasma Anti-Wildlife Turret"
	button_icon_state = "build_turret"
	structure_name = "turrets"
	structure_path = /obj/structure/fans/tiny
	place_sound = 'sound/items/drill_use.ogg'

/datum/action/innate/construction/place_structure/turret/after_place(var/obj/placed_structure)
	if(B.found_aux_console)
		B.found_aux_console.turrets += placed_structure //Add new turret to the console's control

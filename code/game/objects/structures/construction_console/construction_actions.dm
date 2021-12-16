/datum/action/innate/camera_off/base_construction
	name = "Log out"

///Generic construction action for base [construction consoles][/obj/machinery/computer/camera_advanced/base_construction].
/datum/action/innate/construction
	icon_icon = 'icons/mob/actions/actions_construction.dmi'
	///Console's eye mob
	var/mob/camera/ai_eye/remote/base_construction/remote_eye
	///Console itself
	var/obj/machinery/computer/camera_advanced/base_construction/base_console
	///Is this used to build only on the station z level?
	var/only_station_z = TRUE

/datum/action/innate/construction/Activate()
	if(!target)
		return TRUE
	remote_eye = owner.remote_control
	base_console = target

///Sanity check for any construction action that relies on an RCD being in the base console
/datum/action/innate/construction/proc/check_rcd()
	//The console must always have an RCD.
	if(!base_console.internal_rcd)
		CRASH("Base console is somehow missing an internal RCD!")

///Check a loction to see if it is inside the aux base at the station. Camera visbility checks omitted so as to not hinder construction.
/datum/action/innate/construction/proc/check_spot()
	var/turf/build_target = get_turf(remote_eye)
	var/area/build_area = get_area(build_target)
	var/area/area_constraint = base_console.allowed_area
	//If the console has no allowed_area var, then we're free to build wherever
	if (!area_constraint)
		return TRUE
	if(!istype(build_area, area_constraint))
		to_chat(owner, span_warning("You can only build within [area_constraint]!"))
		return FALSE
	if(only_station_z && !is_station_level(build_target.z))
		to_chat(owner, span_warning("[area_constraint] has launched and can no longer be modified."))
		return FALSE
	return TRUE

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
		if(LAZYLEN(S.rcd_vals(owner,base_console.internal_rcd)))
			rcd_target = S //If we don't break out of this loop we'll get the last placed thing
	owner.changeNext_move(CLICK_CD_RANGE)
	check_rcd()
	base_console.internal_rcd.pre_attack(rcd_target, owner, TRUE) //Activate the RCD and force it to work remotely!
	playsound(target_turf, 'sound/items/deconstruct.ogg', 60, TRUE)

/datum/action/innate/construction/switch_mode
	name = "Switch Mode"
	button_icon_state = "builder_mode"

/datum/action/innate/construction/switch_mode/Activate()
	if(..())
		return
	var/list/buildlist = list("Walls and Floors" = RCD_FLOORWALL, "Airlocks" = RCD_AIRLOCK, "Deconstruction" = RCD_DECONSTRUCT, "Windows and Grilles" = RCD_WINDOWGRILLE)
	var/buildmode = input(owner, "Set construction mode.", "Base Console", null) in buildlist
	check_rcd()
	base_console.internal_rcd.construction_mode = buildlist[buildmode]
	to_chat(owner, "Build mode is now [buildmode].")

/datum/action/innate/construction/airlock_type
	name = "Select Airlock Type"
	button_icon_state = "airlock_select"

/datum/action/innate/construction/airlock_type/Activate()
	if(..())
		return
	check_rcd()
	base_console.internal_rcd.change_airlock_setting(owner, remote_eye)

/datum/action/innate/construction/window_type
	name = "Select Window Glass"
	button_icon_state = "window_select"

/datum/action/innate/construction/window_type/Activate()
	if(..())
		return
	check_rcd()
	base_console.internal_rcd.toggle_window_glass(owner)

///Generic action used with base construction consoles to build anything that can't be built with an RCD
/datum/action/innate/construction/place_structure
	name = "Place Generic Structure"
	var/obj/structure_path
	var/structure_name
	var/place_sound

/datum/action/innate/construction/place_structure/Activate()
	if(..())
		return
	var/turf/place_turf = get_turf(remote_eye)
	if(!base_console.structures[structure_name])
		to_chat(owner, span_warning("[base_console] is out of [structure_name]!"))
		return
	if(!check_spot())
		return
	//Can't place inside a closed turf
	if(place_turf.density)
		to_chat(owner, span_warning("[structure_name] may only be placed on a floor."))
		return
	//Can't place two dense objects inside eachother
	if(initial(structure_path.density) && place_turf.is_blocked_turf())
		to_chat(owner, span_warning("Location is obstructed by something. Please clear the location and try again."))
		return
	var/obj/placed_structure = new structure_path(place_turf)
	base_console.structures[structure_name]--
	var/remaining = base_console.structures[structure_name]
	playsound(place_turf, place_sound, 50, TRUE)
	after_place(placed_structure, remaining)

///Proc to handle additional behavior after placing an object
/datum/action/innate/construction/place_structure/proc/after_place()
	return

/datum/action/innate/construction/place_structure/fan
	name = "Place Tiny Fan"
	button_icon_state = "build_fan"
	structure_name = "fans"
	structure_path = /obj/structure/fans/tiny
	place_sound = 'sound/machines/click.ogg'

/datum/action/innate/construction/place_structure/fan/after_place(obj/placed_structure, remaining)
	to_chat(owner, span_notice("Tiny fan placed. [remaining] fans remaining."))

/datum/action/innate/construction/place_structure/turret
	name = "Install Plasma Anti-Wildlife Turret"
	button_icon_state = "build_turret"
	structure_name = "turrets"
	structure_path = /obj/machinery/porta_turret/aux_base
	place_sound = 'sound/items/drill_use.ogg'

/datum/action/innate/construction/place_structure/turret/after_place(obj/placed_structure, remaining)
	var/obj/machinery/computer/auxiliary_base/turret_controller = locate() in get_area(placed_structure)
	if(!turret_controller)
		to_chat(owner, span_notice("<b>Warning:</b> Aux base controller not found. Turrets might not work properly."))
		return

	LAZYADD(turret_controller.turrets, WEAKREF(placed_structure))
	to_chat(owner, span_notice("You've constructed an additional turret. [remaining] turrets remaining."))

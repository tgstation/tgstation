///Amount of drained power per tile
#define TILE_POWER_CONSUMPTION 3500
///What the shields will set the turf conductivity to
#define SHIELDED_CONDUCTIVITY 0

/obj/machinery/power/proto_sh_emitter
	name = "Prototype Shield Emitter"
	desc = "This is a Prototype Shield Emitter that create in front of it a box made of shielding elements to protect the station from heat and pressure"
	icon = 'icons/obj/power.dmi'
	icon_state = "proto_sh_emitter"
	anchored = FALSE
	density = TRUE
	max_integrity = 350
	integrity_failure = 0.2
	circuit = /obj/item/circuitboard/machine/proto_sh_emitter
	///Store the powered shields placed in the world, used when turned off to removed them
	var/list/shields
	///Check if the machine is turned on or off
	var/is_on = FALSE
	///Used to check if the machine is placed inside the borders of the map
	var/borders = TRUE
	///Is the machines currently projecting a barrier?
	var/has_barrier = FALSE
	///Vars used in the GUI to be able to setup a size, their name is referred to the machine facing NORTH
	var/south_west_internal_corner = 1
	var/south_east_internal_corner = 1
	var/north_internal_edge = 2
	var/south_west_outer_corner = 2
	var/south_east_outer_corner = 2
	var/north_outer_edge = 3

/obj/machinery/power/proto_sh_emitter/anchored
	anchored = TRUE

/obj/machinery/power/proto_sh_emitter/Initialize()
	. = ..()
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, .proc/check_power)

/obj/machinery/power/proto_sh_emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		stack_trace("Prototype Shield Emitter deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("Prototype Shield Emitter deleted at [AREACOORD(T)]")
	QDEL_LAZYLIST(shields)
	return ..()

/obj/machinery/power/proto_sh_emitter/update_icon_state()
	. = ..()
	if(has_barrier)
		icon_state = "proto_sh_emitter_on"
	else
		icon_state = "proto_sh_emitter"

/obj/machinery/power/proto_sh_emitter/attackby(obj/item/I, mob/user, params)
	if(!is_on)
		if(default_deconstruction_screwdriver(user, "proto_sh_emitter_open", "proto_sh_emitter", I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/power/proto_sh_emitter/attackby_secondary(obj/item/item, mob/user, params)
	. = ..()
	if(panel_open && item.tool_behaviour == TOOL_WRENCH)
		if(default_unfasten_wrench(user, item))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/power/proto_sh_emitter/process()
	if(!is_on)
		return
	var/power_use = idle_power_usage
	use_power(power_use)

/obj/machinery/power/proto_sh_emitter/proc/check_power()
	if(is_operational)
		return
	var/turf/loc_turf = get_turf(src)
	is_on = FALSE
	has_barrier = FALSE
	QDEL_LAZYLIST(shields)
	update_icon_state()
	message_admins("[src] turned off at [ADMIN_VERBOSEJMP(loc_turf)]")
	log_game("[src] turned off at [AREACOORD(loc_turf)]")

/** The vars you'll see in the proc() are referred to the machine looking north. This way of naming the vars
 * won't have much sense for the other directions, so always refer to the north direction when making changes as all other are already properly setup
 * This proc builds the barriers
**/
/obj/machinery/power/proto_sh_emitter/proc/build_barrier(\
	south_west_internal_x_axis,\
	south_west_internal_y_axis,\
	north_east_internal_x_axis,\
	north_east_internal_y_axis,\
	south_west_outer_x_axis,\
	south_west_outer_y_axis,\
	north_east_outer_x_axis,\
	north_east_outer_y_axis,\
	mob/user\
	)

	to_chat(user, "<span class='warning'>You start to turn on the [src] and the generated shields!</span>")
	if(!do_after(user, 1.5 SECONDS, target = src))
		return
	to_chat(user, "<span class='warning'>You turn on the [src] and the generated shields!</span>")
	//Stores the outline of the room to generate
	var/list/outline = list()
	//Stores the internal turfs of the room to generate
	var/list/internal = list()
	var/turf/emitter_turf = get_turf(src)
	message_admins("[src] turned on at [ADMIN_VERBOSEJMP(emitter_turf)] by [ADMIN_LOOKUPFLW(user)]")
	log_game("[src] turned on at [AREACOORD(emitter_turf)] by [key_name(user)]")
	is_on = TRUE
	switch(dir) //this part check the direction of the machine and create the block in front of it
		if(NORTH)
			internal.Add(block(locate(x - south_west_internal_x_axis, y + south_west_internal_y_axis, z), locate(x + north_east_internal_x_axis, y + north_east_internal_y_axis, z)))
			outline.Add(block(locate(x - south_west_outer_x_axis, y + south_west_outer_y_axis, z), locate(x + north_east_outer_x_axis, y + north_east_outer_y_axis, z)) - internal)
		if(SOUTH)
			internal.Add(block(locate(x - north_east_internal_x_axis, y - south_west_internal_y_axis, z), locate(x + south_west_internal_x_axis, y - north_east_internal_y_axis, z)))
			outline.Add(block(locate(x - north_east_outer_x_axis, y - south_west_outer_y_axis, z), locate(x + south_west_outer_x_axis, y - north_east_outer_y_axis, z)) - internal)
		if(EAST)
			internal.Add(block(locate(x + south_west_internal_y_axis, y - north_east_internal_x_axis, z), locate(x + north_east_internal_y_axis, y + south_west_internal_x_axis, z)))
			outline.Add(block(locate(x + south_west_outer_y_axis, y - north_east_outer_x_axis, z), locate(x + north_east_outer_y_axis, y + south_west_outer_x_axis, z)) - internal)
		if(WEST)
			internal.Add(block(locate(x - south_west_internal_y_axis, y - south_west_internal_x_axis, z), locate(x - north_east_internal_y_axis, y + north_east_internal_x_axis, z)))
			outline.Add(block(locate(x - south_west_outer_y_axis, y - south_west_outer_x_axis, z), locate(x - north_east_outer_y_axis, y + north_east_outer_x_axis, z)) - internal)
	for(var/turf in outline)
		new /obj/machinery/holosign/barrier/power_shield/wall(turf, src)
	for(var/turf in internal)
		new /obj/machinery/holosign/barrier/power_shield/floor(turf, src)

///This proc removes the barriers
/obj/machinery/power/proto_sh_emitter/proc/remove_barrier(mob/user)
	var/turf/emitter_turf = get_turf(src)
	to_chat(user, "<span class='warning'>You start to turn off the [src] and the generated shields!</span>")
	if(!do_after(user, 3.5 SECONDS, target = src))
		return
	to_chat(user, "<span class='warning'>You turn off the [src] and the generated shields!</span>")
	message_admins("[src] turned off at [ADMIN_VERBOSEJMP(emitter_turf)] by [ADMIN_LOOKUPFLW(user)]")
	log_game("[src] turned off at [AREACOORD(emitter_turf)] by [key_name(user)]")
	QDEL_LAZYLIST(shields)

/** The vars you'll see in the proc() are referred to the machine looking north and they define an EDGE. This way of naming the vars
 * won't have much sense for the other directions, so always refer to the north direction when making changes as all other are already properly setup
 * This proc check if the machine is generating the barriers inside the map borders
**/
/obj/machinery/power/proto_sh_emitter/proc/check_map_borders(
	north_west_x_axis,\
	north_west_y_axis,\
	north_east_x_axis,\
	north_east_y_axis\
	)

	switch(dir) //Check for map limits.
		if(NORTH)
			if(!locate(x - north_west_x_axis, y + north_west_y_axis, z) || !locate(x + north_east_x_axis, y + north_east_y_axis, z))
				return FALSE
		if(SOUTH)
			if(!locate(x - north_east_x_axis, y - north_west_y_axis, z) || !locate(x + north_west_x_axis, y - north_east_y_axis, z))
				return FALSE
		if(EAST)
			if(!locate(x + north_west_y_axis, y -north_east_x_axis, z) || !locate(x + north_east_y_axis, y + north_west_x_axis, z))
				return FALSE
		if(WEST)
			if(!locate(x - north_west_y_axis, y - north_west_x_axis, z) || !locate(x - north_east_y_axis, y + north_east_x_axis, z))
				return FALSE

	return TRUE

/obj/machinery/power/proto_sh_emitter/ui_interact(mob/user, datum/tgui/ui)
	add_fingerprint(user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You need to close the panel first!</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>You need to anchor the [src] first!</span>")
		return
	if(!is_operational)
		to_chat(user, "<span class='warning'>There is no power in this area!!</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrototypeShieldEmitter", name)
		ui.open()

/obj/machinery/power/proto_sh_emitter/ui_data(mob/user)
	var/list/data = list()
	data["on"] = is_on
	data["powered"] = is_operational
	data["has_barrier"] = has_barrier

	data["width"] = south_west_outer_corner + south_east_outer_corner + 1
	data["height"] = north_outer_edge

	return data

/obj/machinery/power/proto_sh_emitter/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("on")
			is_on = !is_on
			. = TRUE
		if("emit")
			if(is_on && !has_barrier && check_map_borders(south_west_outer_corner, north_outer_edge, south_east_outer_corner, north_outer_edge))
				build_barrier(south_west_internal_corner, 2, south_east_internal_corner, north_internal_edge, south_west_outer_corner, 1, south_east_outer_corner, north_outer_edge, usr)
				has_barrier = TRUE
			. = TRUE
		if("disable")
			if(has_barrier)
				remove_barrier(usr)
				has_barrier = FALSE
			. = TRUE
		if("increase_left")
			south_west_internal_corner++
			south_west_outer_corner++
			south_west_internal_corner = clamp(south_west_internal_corner, 0, 1)
			south_west_outer_corner = clamp(south_west_outer_corner, 1, 2)
			. = TRUE
		if("decrease_left")
			south_west_internal_corner--
			south_west_outer_corner--
			south_west_internal_corner = clamp(south_west_internal_corner, 0, 1)
			south_west_outer_corner = clamp(south_west_outer_corner, 1, 2)
			. = TRUE
		if("increase_right")
			south_east_internal_corner++
			south_east_outer_corner++
			south_east_internal_corner = clamp(south_east_internal_corner, 0, 1)
			south_east_outer_corner = clamp(south_east_outer_corner, 1, 2)
			. = TRUE
		if("decrease_right")
			south_east_internal_corner--
			south_east_outer_corner--
			south_east_internal_corner = clamp(south_east_internal_corner, 0, 1)
			south_east_outer_corner = clamp(south_east_outer_corner, 1, 2)
			. = TRUE
		if("increase_up")
			north_internal_edge++
			north_outer_edge++
			north_internal_edge = clamp(north_internal_edge, 2, 4)
			north_outer_edge = clamp(north_outer_edge, 3, 5)
			. = TRUE
		if("decrease_up")
			north_internal_edge--
			north_outer_edge--
			north_internal_edge = clamp(north_internal_edge, 2, 4)
			north_outer_edge = clamp(north_outer_edge, 3, 5)
			. = TRUE
	update_appearance()

/obj/machinery/holosign/barrier/power_shield
	name = "powered shield"
	desc = "A shield to prevent changes of atmospheric and heat transfer"
	icon = 'icons/effects/effects.dmi'
	density = FALSE
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	///store the conductivity value of the turf is applyed so that it can be restored on removal
	var/stored_conductivity = 0
	///power drain from the apc, in W (so 5000 is 5 kW), per each holosign placed
	var/power_consumption = TILE_POWER_CONSUMPTION
	///store the reference to the shield projector
	var/obj/machinery/power/proto_sh_emitter/shield_projector

/obj/machinery/holosign/barrier/power_shield/Initialize(loc, source_projector)
	. = ..()
	shield_turf(TRUE)
	air_update_turf(TRUE)
	if(source_projector)
		shield_projector = source_projector
		LAZYADD(shield_projector.shields, src)
		shield_projector.idle_power_usage += power_consumption

/obj/machinery/holosign/barrier/power_shield/Destroy()
	shield_turf(FALSE)
	air_update_turf(TRUE)
	if(shield_projector)
		LAZYREMOVE(shield_projector.shields, src)
		shield_projector.idle_power_usage -= power_consumption
		shield_projector = null
	return ..()

///Proc that takes the thermal conductivity of the turf its on and store it inside a variable
/obj/machinery/holosign/barrier/power_shield/proc/shield_turf(shielding = TRUE)
	var/turf/current_turf = loc
	if(shielding)
		stored_conductivity = current_turf.thermal_conductivity
		current_turf.thermal_conductivity = SHIELDED_CONDUCTIVITY
		return
	current_turf.thermal_conductivity = stored_conductivity

/obj/machinery/holosign/barrier/power_shield/wall
	name = "Shield Wall"
	desc = "A powered wall to stop changes in atmospheric and the spread of heat"
	icon_state = "powershield_wall"
	layer = ABOVE_MOB_LAYER
	CanAtmosPass = ATMOS_PASS_NO

/obj/machinery/holosign/barrier/power_shield/floor
	name = "Shield Floor"
	desc = "A powered floor to stop the heat from melting the floors under it"
	icon_state = "powershield_floor"
	CanAtmosPass = ATMOS_PASS_YES
	layer = TURF_PLATING_DECAL_LAYER
	plane = FLOOR_PLANE

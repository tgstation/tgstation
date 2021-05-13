/mob/lavaland_drone
	name = "updated mining drone"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "mining_drone"
	density = FALSE
	see_in_dark = 7
	sight = SEE_TURFS | SEE_BLACKNESS
	layer = BELOW_MOB_LAYER
	var/obj/machinery/origin
	var/mob/living/drone_user = null
	var/move_delay = 20
	var/cooldown = 0
	var/id_tag

/mob/lavaland_drone/Initialize()
	. = ..()
	if(!id_tag)
		id_tag = SSnetworks.assign_random_name()
	cooldown = world.timeofday

/mob/lavaland_drone/proc/setLoc(turf/moving_turf)
/* 	if(!is_mining_level(z)) //commented out for testing purposes
		return */
	if(drone_user)
		if (moving_turf)
			forceMove(moving_turf)
		else
			moveToNullspace()

/mob/lavaland_drone/relaymove(mob/living/user, direction)
	var/old_turf = get_turf(src)

	if(cooldown > world.timeofday)
		return

	cooldown = world.timeofday + 0.1 SECONDS

	var/turf/step = get_turf(get_step(src, direction))
	var/dense_turf = FALSE
	for(var/atom/considered_content as anything in step.contents)
		if(considered_content.density)
			dense_turf = TRUE
			break
	if(step && isopenturf(step) && !isspaceturf(step) && !dense_turf)
		setLoc(step)

	dir = get_dir(old_turf, step)

/obj/machinery/drone_controller
	name = "mining drones controller"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE
	var/list/drones = list()
	var/mob/living/current_user = null
	var/mob/lavaland_drone/current_drone = null
	var/datum/action/innate/drone_release/off_action = new
	var/list/actions = list()

/obj/machinery/drone_controller/LateInitialize()
	. = ..()
	var/list/drone_turfs = block(locate(x-1,y+2,z), locate(x+1,y+1,z))
	for(var/turf/checked_turf in drone_turfs)
		for(var/drone as anything in checked_turf.contents)
			if(!istype(drone, /mob/lavaland_drone))
				continue
			drones += drone

/obj/machinery/drone_controller/proc/give_eye_control(mob/user, mob/lavaland_drone/drone)
	GrantActions(user)
	drone.origin = src
	drones -= drone
	current_user = user
	drone.drone_user = user
	user.remote_control = drone
	user.reset_perspective(drone)

/obj/machinery/drone_controller/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	RegisterSignal(user, COMSIG_MOB_CTRL_CLICKED, .proc/on_ctrl_click)

/obj/machinery/drone_controller/proc/on_ctrl_click(datum/source, atom/clicked_atom)
	SIGNAL_HANDLER
	if(!is_mining_level(clicked_atom.z))
		return
	if(isopenturf(clicked_atom))
		turf_ctrl_click(source, clicked_atom)
	if(istype(clicked_atom, /obj/machinery/conveyor))
		delete_conveyor(clicked_atom)
	if(istype(clicked_atom, /obj/structure/ore_vein))
		place_drill(source, clicked_atom)

/obj/machinery/drone_controller/proc/turf_ctrl_click(mob/living/user, turf/open/considered_turf)
	var/mob/lavaland_drone/drone = user.remote_control
	if(!locate(/obj/machinery/conveyor) in considered_turf)
		new /obj/machinery/conveyor/auto(considered_turf, drone.dir)

/obj/machinery/drone_controller/proc/delete_conveyor(obj/machinery/conveyor/clicked_conveyor)
	if(!QDELETED(clicked_conveyor))
		qdel(clicked_conveyor)

/obj/machinery/drone_controller/proc/place_drill(mob/living/user, obj/structure/ore_vein/vein)
	var/turf/vein_location = get_turf(vein)
	if(locate(/obj/machinery/drill) in vein_location)
		to_chat(user, "<span class='warning'>A drill is already present!</span>")
		return
	if(!vein.discovered)
		vein.add_points(user)
	new/obj/machinery/drill(vein_location)

/obj/machinery/drone_controller/proc/remove_drone_control(mob/living/user, mob/lavaland_drone/drone)
	if(!user)
		return
	for(var/action in actions)
		var/datum/action/current_action = action
		current_action.Remove(user)
	if(user.client)
		user.reset_perspective(null)
		user.client.view_size.unsupress()
	UnregisterSignal(user, COMSIG_MOB_CTRL_CLICKED)
	drones += drone
	drone.drone_user = null
	user.remote_control = null
	current_user = null
	current_drone = null
	user.unset_machine()
	playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)

/obj/machinery/drone_controller/ui_interact(mob/user, datum/tgui/ui)
	if(panel_open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DronesController", name)
		ui.open()

/obj/machinery/drone_controller/ui_data()
	var/data = list()
	for(var/mob/lavaland_drone/drone in drones)
		data["drones"] += list(list(
			"name" = drone.name,
			"drone_id" = drone.id_tag,
			"coord" = "[drone.x], [drone.y], [drone.z]"
		))
	return data

/obj/machinery/drone_controller/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("connect")
			/* if(!is_mining_level(z))
				return */
			var/drone_id = params["drone_id"]
			var/connecting_drone
			for(var/mob/lavaland_drone/drone in drones)
				if(drone.id_tag != drone_id)
					continue
				connecting_drone = drone
			current_drone = connecting_drone
			if(!user.remote_control)
				give_eye_control(user, connecting_drone)
			. = TRUE

/obj/machinery/drone_controller/on_unset_machine(mob/M)
	if(M == current_user)
		remove_drone_control(M, current_drone)

/datum/action/innate/drone_release
	name = "Place Slimes"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/drone_release/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/user = target
	var/mob/lavaland_drone/remote_drone = user.remote_control
	var/obj/machinery/drone_controller/console = remote_drone.origin
	console.remove_drone_control(target, remote_drone)


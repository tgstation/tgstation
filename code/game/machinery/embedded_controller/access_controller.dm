/obj/machinery/door_buttons
	power_channel = AREA_USAGE_ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.04
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/idSelf

/obj/machinery/door_buttons/attackby(obj/O, mob/user)
	return attack_hand(user)

/obj/machinery/door_buttons/proc/find_objects_by_tag()
	return

/obj/machinery/door_buttons/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door_buttons/post_machine_initialize()
	. = ..()
	find_objects_by_tag()

/obj/machinery/door_buttons/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	req_access = list()
	req_one_access = list()
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "access controller shorted")
	return TRUE

/obj/machinery/door_buttons/access_button
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "access_button_standby"
	base_icon_state = "access_button"
	name = "access button"
	desc = "A button used for the explicit purpose of opening an airlock."
	var/idDoor
	var/obj/machinery/door/airlock/door
	var/obj/machinery/door_buttons/airlock_controller/controller
	var/busy

/obj/machinery/door_buttons/access_button/find_objects_by_tag()
	for(var/obj/machinery/door_buttons/airlock_controller/A as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door_buttons/airlock_controller))
		if(A.idSelf == idSelf)
			controller = A
			RegisterSignal(controller, COMSIG_PREQDELETED, PROC_REF(remove_object))
			break
	for(var/obj/machinery/door/airlock/I as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(I.id_tag == idDoor)
			door = I
			RegisterSignal(door, COMSIG_PREQDELETED, PROC_REF(remove_object))
			break

/obj/machinery/door_buttons/access_button/interact(mob/user)
	if(busy)
		return
	if(!allowed(user))
		to_chat(user, span_warning("Access denied."))
		return
	if(controller && !controller.busy && door)
		if(controller.machine_stat & NOPOWER)
			return
		busy = TRUE
		update_appearance()
		if(door.density)
			if(!controller.exterior_airlock || !controller.interior_airlock)
				controller.only_open(door)
			else
				if(controller.exterior_airlock.density && controller.interior_airlock.density)
					controller.only_open(door)
				else
					controller.cycle_close(door)
		else
			controller.only_close(door)
		use_energy(active_power_usage)
		addtimer(CALLBACK(src, PROC_REF(not_busy)), 2 SECONDS)

/obj/machinery/door_buttons/access_button/proc/not_busy()
	busy = FALSE
	update_appearance()

/obj/machinery/door_buttons/access_button/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]_[busy ? "cycle" : "standby"]"
	return ..()

/obj/machinery/door_buttons/access_button/proc/remove_object(datum/source)
	SIGNAL_HANDLER

	if(source == door)
		door = null
		return
	if(source == controller)
		controller = null

/obj/machinery/door_buttons/access_button/Destroy()
	door = null
	controller = null
	return ..()

/obj/machinery/door_buttons/airlock_controller
	name = "access console"
	desc = "A small console that can cycle opening between two airlocks."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "access_control_standby"
	base_icon_state = "access_control"
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN|INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_OPEN_SILICON
	///the id of the interior airlock
	var/idInterior
	///the id of the exterior airlock
	var/idExterior
	///are we currently in use?
	var/busy
	///our interior airlock
	var/obj/machinery/door/airlock/interior_airlock
	///our exterior airlock
	var/obj/machinery/door/airlock/exterior_airlock

///set our doors to null upon deletion
/obj/machinery/door_buttons/airlock_controller/proc/remove_door(datum/source)
	SIGNAL_HANDLER

	if(source == interior_airlock)
		interior_airlock = null
		return

	if(source == exterior_airlock)
		exterior_airlock = null

///proc called when we want to open doors without any cycling involved
/obj/machinery/door_buttons/airlock_controller/proc/only_open(obj/machinery/door/airlock/target_door)
	if(isnull(target_door))
		return
	busy = TRUE
	update_appearance()
	open_door(target_door)

///proc called when we want to close doors without any cycling involved
/obj/machinery/door_buttons/airlock_controller/proc/only_close(obj/machinery/door/airlock/target_door)
	if(isnull(target_door))
		return
	busy = TRUE
	close_door(target_door)

///proc that handles closing doors
/obj/machinery/door_buttons/airlock_controller/proc/close_door(obj/machinery/door/airlock/target_door, turn_idle_on_terminate = TRUE)
	busy = TRUE
	if(isnull(target_door) || target_door.density)
		go_idle()
		return FALSE
	update_appearance()
	target_door.safe = FALSE //Door crushies, manual door after all. Set every time in case someone changed it, safe doors can end up waiting forever.
	target_door.unbolt()
	if(!target_door.close() || (machine_stat & NOPOWER))
		go_idle()
		return FALSE
	target_door?.bolt()

	if(turn_idle_on_terminate)
		go_idle()

	return TRUE

///proc called when we want to close doors with cycling
/obj/machinery/door_buttons/airlock_controller/proc/cycle_close(obj/machinery/door/airlock/target_door)
	if(isnull(exterior_airlock) || isnull(interior_airlock))
		return
	if(exterior_airlock.density == interior_airlock.density || !target_door.density)
		return
	busy = TRUE
	update_appearance()
	var/obj/machinery/door/airlock/opposite_airlock = (target_door == exterior_airlock ? interior_airlock : exterior_airlock)

	if(!close_door(opposite_airlock, turn_idle_on_terminate = FALSE))
		return go_idle()

	addtimer(CALLBACK(src, PROC_REF(cycle_open), target_door), 2 SECONDS)

///proc called when we want to open doors with cycling
/obj/machinery/door_buttons/airlock_controller/proc/cycle_open(obj/machinery/door/airlock/target_door)
	if(isnull(target_door))
		return go_idle()
	var/obj/machinery/door/airlock/opposite_airlock = (target_door == exterior_airlock ? interior_airlock : exterior_airlock)
	if(isnull(opposite_airlock) || !opposite_airlock.density || !opposite_airlock.locked)
		return go_idle()
	busy = TRUE
	open_door(target_door)

///proc that handles opening and unbolting the door
/obj/machinery/door_buttons/airlock_controller/proc/open_door(obj/machinery/door/airlock/target_door)
	if(!target_door.density)
		return go_idle()

	target_door.unbolt()
	if(!target_door.open() || (machine_stat & NOPOWER))
		return go_idle()

	target_door?.bolt()
	return go_idle()


///unsets our busy state and update our appearance
/obj/machinery/door_buttons/airlock_controller/proc/go_idle()
	busy = FALSE
	update_appearance()

/obj/machinery/door_buttons/airlock_controller/find_objects_by_tag()
	for(var/obj/machinery/door/door as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door))
		if(isnull(idInterior) || isnull(idExterior))
			break
		if(door.id_tag == idInterior)
			interior_airlock = door
			RegisterSignal(interior_airlock, COMSIG_PREQDELETED, PROC_REF(remove_door))
		if(door.id_tag == idExterior)
			exterior_airlock = door
			RegisterSignal(exterior_airlock, COMSIG_PREQDELETED, PROC_REF(remove_door))

/obj/machinery/door_buttons/airlock_controller/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]_[(busy) ? "process" : "standby"]"
	return ..()

/obj/machinery/door_buttons/airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockButtonController", name)
		ui.open()

/obj/machinery/door_buttons/airlock_controller/ui_data(mob/user)
	var/list/data = list()
	data["interior_door"] = interior_airlock ? REF(interior_airlock) : null
	data["exterior_door"] = exterior_airlock ? REF(exterior_airlock) : null
	data["busy"] = busy
	data["interior_door_closed"] = interior_airlock?.density
	data["exterior_door_closed"] = exterior_airlock?.density
	return data

/obj/machinery/door_buttons/airlock_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || busy)
		return TRUE

	if(isnull(params["requested_door"]))
		return TRUE

	var/atom/requested_door
	var/atom/opposite_door

	if(REF(interior_airlock) == params["requested_door"])
		requested_door = interior_airlock
		opposite_door = exterior_airlock
	else
		requested_door = exterior_airlock
		opposite_door = interior_airlock

	switch(action)
		if("open")
			if(opposite_door && !opposite_door.density)
				cycle_close(requested_door)
			else
				only_open(requested_door)
		if("close")
			only_close(requested_door)

	return TRUE

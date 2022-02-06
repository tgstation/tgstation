/obj/machinery/computer/exodrone_control_console
	name = "exploration drone control console"
	desc = "control eploration drones from intersteller distances. Communication lag not included."
	//Currently controlled drone
	var/obj/item/exodrone/controlled_drone
	/// Have we lost contact with the drone without disconnecting. Unset on user confirmation.
	var/signal_lost = FALSE

/obj/machinery/computer/exodrone_control_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExodroneConsole", name)
		ui.open()

/obj/machinery/computer/exodrone_control_console/proc/start_drone_control(obj/item/exodrone/drone)
	if(!drone.controlled)//Only one controller per drone at once to make it saner
		///End control if we had previous drone
		end_drone_control()
		controlled_drone = drone
		controlled_drone.controlled = TRUE
		RegisterSignal(controlled_drone,COMSIG_PARENT_QDELETING,.proc/drone_destroyed)
		RegisterSignal(controlled_drone,COMSIG_EXODRONE_STATUS_CHANGED,.proc/on_exodrone_status_changed)
		update_icon()

/obj/machinery/computer/exodrone_control_console/proc/on_exodrone_status_changed()
	SIGNAL_HANDLER
	//Notify we need human action and switch screeb icon to alert.
	playsound(src,'sound/machines/ping.ogg',30,FALSE)
	update_icon()

/obj/machinery/computer/exodrone_control_console/proc/drone_destroyed()
	SIGNAL_HANDLER
	signal_lost = TRUE
	end_drone_control()

/obj/machinery/computer/exodrone_control_console/proc/end_drone_control()
	if(controlled_drone)
		controlled_drone.controlled = FALSE
		UnregisterSignal(controlled_drone,list(COMSIG_PARENT_QDELETING,COMSIG_EXODRONE_STATUS_CHANGED))
		controlled_drone = null
		update_icon()

/obj/machinery/computer/exodrone_control_console/Destroy()
	. = ..()
	end_drone_control()

/obj/machinery/computer/exodrone_control_console/ui_static_data(mob/user)
	. = ..()
	.["all_tools"] = GLOB.exodrone_tool_metadata
	.["all_bands"] = GLOB.exoscanner_bands

/obj/machinery/computer/exodrone_control_console/ui_data(mob/user)
	. = ..()
	.["signal_lost"] = signal_lost
	.["drone"] = controlled_drone
	if(controlled_drone)
		.["drone_status"] = controlled_drone.drone_status
		.["drone_name"] = controlled_drone.name
		.["drone_integrity"] = controlled_drone.get_integrity()
		.["drone_max_integrity"] = controlled_drone.max_integrity
		.["drone_log"] = controlled_drone.drone_log
		.["configurable"] = controlled_drone.drone_status == EXODRONE_IDLE
		.["cargo"] = controlled_drone.get_cargo_data()
		.["drone_travel_coefficent"] = controlled_drone.get_travel_coeff()
		var/travel_error = controlled_drone.travel_error()
		.["can_travel"] = !travel_error
		.["travel_error"] = travel_error ? travel_error : ""
		switch(controlled_drone.drone_status) //could move this down to drone.ui_data()
			if(EXODRONE_IDLE)
				.["sites"] = build_exploration_site_ui_data()
				.["site"] = null
			if(EXODRONE_TRAVEL)
				.["travel_time"] = controlled_drone.travel_time
				.["travel_time_left"] = timeleft(controlled_drone.travel_timer_id)
			if(EXODRONE_BUSY)
				.["wait_time_left"] = controlled_drone.busy_time_left()
				.["wait_message"] = controlled_drone.busy_message
			if(EXODRONE_EXPLORATION)
				.["sites"] = build_exploration_site_ui_data()
				.["site"] = controlled_drone.location.site_data(exploration=TRUE)
				.["event"] = controlled_drone.current_event_ui_data
			if(EXODRONE_ADVENTURE)
				.["adventure_data"] = controlled_drone.get_adventure_data()
	else
		var/list/exodrones = list()
		for(var/obj/item/exodrone/drone in GLOB.exodrones)
			exodrones += list(list("name"=drone.name,"controlled"=drone.controlled,"description"=drone.ui_description(),"ref"=ref(drone)))
		.["all_drones"] = exodrones

/obj/machinery/computer/exodrone_control_console/update_overlays()
	/// Show alert screen if the drone is in a mode that requires decisionmaking
	if(controlled_drone && (controlled_drone.drone_status == EXODRONE_IDLE || controlled_drone.drone_status == EXODRONE_EXPLORATION || controlled_drone.drone_status == EXODRONE_ADVENTURE))
		icon_screen = "alert:2"
	else
		icon_screen = initial(icon_screen)
	. = ..()

/obj/machinery/computer/exodrone_control_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select_drone")
			var/obj/item/exodrone/selected = locate(params["drone_ref"]) in GLOB.exodrones
			if(selected)
				start_drone_control(selected)
			return TRUE
		if("end_control")
			end_drone_control()
			return TRUE
		if("confirm_signal_lost")
			signal_lost = FALSE
			return TRUE
		if("self_destruct")
			qdel(controlled_drone) //var will be nulled in signal response
			return TRUE
		if("add_tool")
			if(controlled_drone && controlled_drone.drone_status == EXODRONE_IDLE)
				controlled_drone.add_tool(params["tool_type"])
			return TRUE
		if("remove_tool")
			if(controlled_drone && controlled_drone.drone_status == EXODRONE_IDLE)
				controlled_drone.remove_tool(params["tool_type"])
			return TRUE
		if("start_travel")
			if(controlled_drone && !controlled_drone.travel_error())
				var/datum/exploration_site/target_site
				if(params["target_site"])
					target_site = locate(params["target_site"]) in GLOB.exploration_sites
					if(!target_site)
						return TRUE
				controlled_drone.launch_for(target_site)
			return TRUE
		if("explore")
			if(controlled_drone && controlled_drone.drone_status == EXODRONE_EXPLORATION)
				controlled_drone.explore_site()
			return TRUE
		if("explore_event")
			if(controlled_drone && controlled_drone.drone_status == EXODRONE_EXPLORATION)
				var/datum/exploration_event/chosen_event = locate(params["target_event"]) in controlled_drone.location.events
				if(chosen_event)
					controlled_drone.explore_site(chosen_event)
		if("adventure_choice")
			if(controlled_drone && controlled_drone.drone_status == EXODRONE_ADVENTURE)
				controlled_drone.current_adventure?.select_choice(params["choice"])
			return TRUE
		if("start_event")
			if(controlled_drone && controlled_drone.current_event_ui_data)
				var/datum/exploration_event/simple/chosen_event = locate(controlled_drone.current_event_ui_data["ref"]) in controlled_drone.location.events
				if(chosen_event)
					chosen_event.fire(controlled_drone)
			return TRUE
		if("skip_event")
			if(controlled_drone && controlled_drone.current_event_ui_data)
				var/datum/exploration_event/simple/chosen_event = locate(controlled_drone.current_event_ui_data["ref"]) in controlled_drone.location.events
				if(chosen_event.skippable)
					chosen_event.end(controlled_drone)
			return TRUE
		if("jettison")
			if(controlled_drone)
				var/obj/thing_to_jettison = locate(params["target_ref"]) in controlled_drone.contents
				if(thing_to_jettison)
					controlled_drone.drone_log("Jettisoned [thing_to_jettison]")
					if(controlled_drone.drone_status == EXODRONE_IDLE)
						thing_to_jettison.forceMove(controlled_drone.drop_location())
					else
						qdel(thing_to_jettison) //this might need some limitations
			return TRUE

/obj/machinery/computer/exodrone_control_console/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/adventure)) //preset screens

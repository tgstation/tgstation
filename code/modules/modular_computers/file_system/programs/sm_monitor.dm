/datum/computer_file/program/supermatter_monitor
	filename = "ntcims"
	filedesc = "NT CIMS"
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "Crystal Integrity Monitoring System, connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CONSTRUCTION
	size = 5
	tgui_id = "NtosSupermatterMonitor"
	program_icon = "radiation"
	alert_able = TRUE
	var/last_status = SUPERMATTER_INACTIVE
	var/list/supermatters
	var/obj/machinery/power/supermatter_crystal/active		// Currently selected supermatter crystal.

/datum/computer_file/program/supermatter_monitor/process_tick()
	..()
	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_icon()

/datum/computer_file/program/supermatter_monitor/run_program(mob/living/user)
	. = ..(user)
	if(!(active in GLOB.machines))
		active = null
	refresh()

/datum/computer_file/program/supermatter_monitor/kill_program(forced = FALSE)
	supermatters = null
	..()

// Refreshes list of active supermatter crystals
/datum/computer_file/program/supermatter_monitor/proc/refresh()
	supermatters = list()
	var/turf/T = get_turf(ui_host())
	if(!T)
		return
	for(var/obj/machinery/power/supermatter_crystal/S in GLOB.machines)
		// Delaminating, not within coverage, not on a tile.
		if (!isturf(S.loc) || !(is_station_level(S.z) || is_mining_level(S.z) || S.z == T.z))
			continue
		supermatters.Add(S)

	if(!(active in supermatters))
		active = null

/datum/computer_file/program/supermatter_monitor/proc/get_status()
	. = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter_crystal/S in supermatters)
		. = max(., S.get_status())

/**
  * Sets up the signal listener for Supermatter delaminations.
  *
  * Unregisters any old listners for SM delams, and then registers one for the SM refered
  * to in the `active` variable. This proc is also used with no active SM to simply clear
  * the signal and exit.
 */
/datum/computer_file/program/supermatter_monitor/proc/set_signals()
//	UnregisterSignal(COMSIG_SUPERMATTER_DELAM_ALARM)
//	UnregisterSignal(COMSIG_SUPERMATTER_DELAM_START_ALARM)
	if(active)
		RegisterSignal(active, COMSIG_SUPERMATTER_DELAM_ALARM, .proc/send_alert, FALSE, override = TRUE)
		RegisterSignal(active, COMSIG_SUPERMATTER_DELAM_START_ALARM, .proc/send_alert, TRUE, override = TRUE)

/**
  * Sends an SM delam alert to the computer.
  *
  * Triggered by the signals from set_signals(), this proc will send an alert to the
  * computer. If the program is the active one on this device, all alerts are simply
  * ignored except the very first delam alarm; engineers fixing the SM probably don't
  * need constant notification beeps to distract them.
  *
  * Arguments:
  * a bool of whether this alert is the signal indicating the start of a delam state
 */
/datum/computer_file/program/supermatter_monitor/proc/send_alert(start_alarm)
	if(!active) //just in case
		set_signals() //If active is not set, clear out the forgotten listeners
		return

	if(computer.active_program == src)
		if(start_alarm) //Only the initial alarm will be sent as an alert if this app is the active one
			computer.alert_call(src, "Crystal delamination in progress!")
		return

	if(!start_alarm) //Avoid the start_alarm signal if we're not the active app, to avoid double alerts
		computer.alert_call(src, "Crystal delamination in progress!")
		alert_pending = !(computer.active_program == src)


/datum/computer_file/program/supermatter_monitor/ui_data()
	var/list/data = get_header_data()

	if(istype(active))
		var/turf/T = get_turf(active)
		if(!T)
			active = null
			refresh()
			return
		var/datum/gas_mixture/air = T.return_air()
		if(!air)
			active = null
			return

		data["active"] = TRUE
		data["SM_integrity"] = active.get_integrity()
		data["SM_power"] = active.power
		data["SM_ambienttemp"] = air.temperature
		data["SM_ambientpressure"] = air.return_pressure()
		//data["SM_EPR"] = round((air.total_moles / air.group_multiplier) / 23.1, 0.01)
		var/list/gasdata = list()


		if(air.total_moles())
			for(var/gasid in air.gases)
				gasdata.Add(list(list(
				"name"= air.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = round(100*air.gases[gasid][MOLES]/air.total_moles(),0.01))))

		else
			for(var/gasid in air.gases)
				gasdata.Add(list(list(
					"name"= air.gases[gasid][GAS_META][META_GAS_NAME],
					"amount" = 0)))

		data["gases"] = gasdata
	else
		var/list/SMS = list()
		for(var/obj/machinery/power/supermatter_crystal/S in supermatters)
			var/area/A = get_area(S)
			if(A)
				SMS.Add(list(list(
				"area_name" = A.name,
				"integrity" = S.get_integrity(),
				"uid" = S.uid
				)))

		data["active"] = FALSE
		data["supermatters"] = SMS

	return data

/datum/computer_file/program/supermatter_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("PRG_clear")
			active = null
			return TRUE
		if("PRG_refresh")
			refresh()
			return TRUE
		if("PRG_set")
			var/newuid = text2num(params["target"])
			for(var/obj/machinery/power/supermatter_crystal/S in supermatters)
				if(S.uid == newuid)
					active = S
					set_signals()
			return TRUE

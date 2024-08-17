

GLOBAL_DATUM_INIT(exoscanner_controller,/datum/scanner_controller,new)
/// List of scanned distances
GLOBAL_LIST_INIT(exoscanner_bands,list(EXOSCANNER_BAND_PLASMA=0,EXOSCANNER_BAND_LIFE=0,EXOSCANNER_BAND_TECH=0,EXOSCANNER_BAND_RADIATION=0,EXOSCANNER_BAND_DENSITY=0))
/// Scan condition instances
GLOBAL_LIST_INIT(scan_conditions,init_scan_conditions())


/proc/init_scan_conditions()
	. = list()
	for(var/type in subtypesof(/datum/scan_condition))
		. += new type

#define MAX_SCAN_DISTANCE 10

#define WIDE_SCAN_COST(BAND, SCAN_POWER) (min(((BAND*BAND)/(SCAN_POWER))*2*60*10, 10 MINUTES))
#define BASE_POINT_SCAN_TIME (2 MINUTES)
#define BASE_DEEP_SCAN_TIME (3 MINUTES)

/// Represents scan in progress, only one globally for now, todo later split per z or allow partial dish swarm usage
/datum/exoscan
	/// Scan type wide/point/deep
	var/scan_type
	/// The scan power this scan was started with, if scanner swarm power falls below this value it will be interrupted
	var/scan_power = 0
	/// Target site for point/band scans
	var/datum/exploration_site/target
	/// End of scan timer id
	var/scan_timer

/datum/exoscan/New(scan_type,datum/exploration_site/target)
	src.scan_type = scan_type
	src.target = target
	var/scan_time = 0
	switch(scan_type)
		if(EXOSCAN_WIDE)
			scan_power = GLOB.exoscanner_controller.calculate_scan_power()
			scan_time = WIDE_SCAN_COST(GLOB.exoscanner_controller.wide_scan_band,scan_power)
		if(EXOSCAN_POINT)
			scan_power = GLOB.exoscanner_controller.get_scan_power(target)
			scan_time = BASE_POINT_SCAN_TIME/scan_power
		if(EXOSCAN_DEEP)
			scan_power = GLOB.exoscanner_controller.get_scan_power(target)
			scan_time = (BASE_DEEP_SCAN_TIME*target.distance)/scan_power
	scan_timer = addtimer(CALLBACK(src, PROC_REF(resolve_scan)),scan_time,TIMER_STOPPABLE)

/// Short description for in progress scan
/datum/exoscan/proc/ui_description()
	switch(scan_type)
		if(EXOSCAN_WIDE)
			return "Wide: Scanning sphere starting 1 AU from the station."
		if(EXOSCAN_POINT)
			return "Point scan of [target.display_name()]"
		if(EXOSCAN_DEEP)
			return "Deep scan of [target.display_name()]"

/datum/exoscan/proc/resolve_scan()
	switch(scan_type)
		if(EXOSCAN_WIDE)
			generate_exploration_sites()
		if(EXOSCAN_POINT)
			target.reveal()
			target.point_scan_complete = TRUE
		if(EXOSCAN_DEEP)
			target.reveal()
			target.deep_scan_complete = TRUE
	qdel(src)

/datum/exoscan/proc/stop()
	SEND_SIGNAL(src,COMSIG_EXOSCAN_INTERRUPTED)
	qdel(src)

/datum/exoscan/Destroy(force)
	. = ..()
	deltimer(scan_timer)

/obj/machinery/computer/exoscanner_control
	name = "scanner array control console"
	desc = "Controls scanner arrays to initiate scans for exodrones."
	circuit = /obj/item/circuitboard/computer/exoscanner_console
	/// If scan was interrupted show a popup until dismissed.
	var/failed_popup = FALSE
	/// Site we're configuring targeted scans for.
	var/datum/exploration_site/selected_site

/obj/machinery/computer/exoscanner_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExoscannerConsole", name)
		ui.open()

/obj/machinery/computer/exoscanner_control/ui_data(mob/user)
	. = ..()
	.["failed"] = failed_popup
	.["selected_site"] = selected_site && ref(selected_site)
	var/scan_power = 0
	if(selected_site)
		.["site_data"] = selected_site.site_data()
		.["scan_power"] = scan_power = GLOB.exoscanner_controller.get_scan_power(selected_site)
		.["point_scan_eta"] = scan_power > 0 ? BASE_POINT_SCAN_TIME/scan_power : 0
		.["deep_scan_eta"] = scan_power > 0 ? (BASE_DEEP_SCAN_TIME*selected_site.distance)/scan_power : 0
		var/list/condition_descriptions = list()
		for(var/datum/scan_condition/condition in selected_site.scan_conditions)
			condition_descriptions += condition.description
		.["scan_conditions"] = condition_descriptions
	else
		.["scan_power"] = scan_power = GLOB.exoscanner_controller.calculate_scan_power()
		.["wide_scan_eta"] = scan_power > 0 ? WIDE_SCAN_COST(GLOB.exoscanner_controller.wide_scan_band,scan_power) : 0
		.["possible_sites"] = build_exploration_site_ui_data()
		.["scan_conditions"] = null

	.["scan_in_progress"] = !!GLOB.exoscanner_controller.current_scan
	if(GLOB.exoscanner_controller.current_scan) //Display scan in progress info
		.["scan_time"] = timeleft(GLOB.exoscanner_controller.current_scan.scan_timer)
		.["current_scan_power"] = GLOB.exoscanner_controller.current_scan.scan_power
		.["scan_description"] = GLOB.exoscanner_controller.current_scan.ui_description()

/obj/machinery/computer/exoscanner_control/ui_static_data(mob/user)
	. = ..()
	.["all_bands"] = GLOB.exoscanner_bands

/obj/machinery/computer/exoscanner_control/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select_site")
			if(params["site_ref"])
				var/datum/exploration_site/site = locate(params["site_ref"]) in GLOB.exploration_sites
				if(site)
					selected_site = site
			else
				selected_site = null
			return TRUE
		if("stop_scan")
			stop_current_scan()
			return TRUE
		if("start_wide_scan")
			start_wide_scan()
			return TRUE
		if("start_point_scan")
			start_point_scan()
			return TRUE
		if("start_deep_scan")
			start_deep_scan()
			return TRUE
		if("confirm_fail")
			failed_popup = FALSE
			return TRUE

/obj/machinery/computer/exoscanner_control/proc/stop_current_scan()
	if(GLOB.exoscanner_controller.current_scan)
		GLOB.exoscanner_controller.current_scan.stop()

/obj/machinery/computer/exoscanner_control/proc/start_wide_scan(radius)
	if(GLOB.exoscanner_controller.current_scan)
		return
	if(GLOB.exoscanner_controller.wide_scan_band > MAX_SCAN_DISTANCE)
		return
	create_scan(EXOSCAN_WIDE)

/obj/machinery/computer/exoscanner_control/proc/start_point_scan()
	if(GLOB.exoscanner_controller.current_scan || !selected_site || selected_site.point_scan_complete)
		return
	create_scan(EXOSCAN_POINT,selected_site)

/obj/machinery/computer/exoscanner_control/proc/start_deep_scan()
	if(GLOB.exoscanner_controller.current_scan || !selected_site || selected_site.deep_scan_complete)
		return
	create_scan(EXOSCAN_DEEP,selected_site)

/obj/machinery/computer/exoscanner_control/proc/create_scan(scan_type,target)
	var/datum/exoscan/scan = GLOB.exoscanner_controller.create_scan(scan_type,target)
	if(scan)
		RegisterSignal(scan, COMSIG_EXOSCAN_INTERRUPTED, PROC_REF(scan_failed))

/obj/machinery/computer/exoscanner_control/proc/scan_failed()
	SIGNAL_HANDLER
	failed_popup = TRUE
	SStgui.update_uis(src)

/obj/machinery/computer/exoscanner_control/post_machine_initialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/exploration_scan), \
		config_mode = EXPERIMENT_CONFIG_UI, \
		config_flags = EXPERIMENT_CONFIG_ALWAYS_ACTIVE)

/obj/machinery/exoscanner
	name = "Scanner array"
	icon = 'icons/obj/exploration.dmi'
	icon_state = "scanner_off"
	desc = "A sophisticated scanning array. Easily influenced by its environment."
	circuit = /obj/item/circuitboard/machine/exoscanner
	///the scan power of this array to supply to scanner_controller
	var/scan_power = 1

/obj/machinery/exoscanner/Initialize(mapload)
	. = ..()
	RegisterSignals(GLOB.exoscanner_controller,list(COMSIG_EXOSCAN_STARTED,COMSIG_EXOSCAN_FINISHED), PROC_REF(scan_change))
	update_readiness()
	RefreshParts()

/obj/machinery/exoscanner/RefreshParts()
	. = ..()
	var/power = 1

	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		power += (scanning_module.tier - 1) / 12
	scan_power = power
	GLOB.exoscanner_controller.update_scan_power()

/obj/machinery/exoscanner/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(!.)
		. = default_deconstruction_screwdriver(user, "scanner_open", "scanner_off", tool)
		update_readiness()

/obj/machinery/exoscanner/crowbar_act(mob/user, obj/item/tool)
	..()
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/exoscanner/proc/scan_change()
	SIGNAL_HANDLER
	if(GLOB.exoscanner_controller.current_scan)
		update_use_power(ACTIVE_POWER_USE)
	else
		update_use_power(IDLE_POWER_USE)
	update_icon_state()

/obj/machinery/exoscanner/Destroy()
	. = ..()
	GLOB.exoscanner_controller.deactivate_scanner(src)

/obj/machinery/exoscanner/proc/is_ready()
	return anchored && is_operational && !panel_open

/obj/machinery/exoscanner/proc/update_readiness()
	if(is_ready())
		GLOB.exoscanner_controller.activate_scanner(src)
	else
		GLOB.exoscanner_controller.deactivate_scanner(src)
	update_icon_state()

/obj/machinery/exoscanner/update_icon_state()
	. = ..()
	if(is_ready())
		if(GLOB.exoscanner_controller.current_scan)
			icon_state = "scanner_on"
		else
			icon_state = "scanner_ready"
	else
		icon_state = "scanner_off"

/obj/machinery/exoscanner/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/exoscanner/set_anchored(anchorvalue)
	. = ..()
	update_readiness()

/obj/machinery/exoscanner/on_set_is_operational(old_value)
	. = ..()
	update_readiness()

///Helper datum to calculate and store scanning power and track in progress scans
/datum/scanner_controller
	/// List of dishes in working condition.
	var/list/tracked_dishes = list()
	/// Scan currently in progress if any.
	var/datum/exoscan/current_scan
	/// Band for the next wide scan. Increased after successful completion of wide scan.
	var/wide_scan_band = 1
	/// Current scan power keyed by site
	var/list/scan_power_cache = list()

/datum/scanner_controller/proc/create_scan(scan_type,datum/exploration_site/target)
	if(current_scan)
		return
	if(length(GLOB.exoscanner_controller.tracked_dishes) <= 0 || (target && GLOB.exoscanner_controller.get_scan_power(target) <= 0))
		return
	current_scan = new(scan_type,target)
	RegisterSignal(current_scan,COMSIG_QDELETING, PROC_REF(cleanup_current_scan))
	SEND_SIGNAL(src,COMSIG_EXOSCAN_STARTED,current_scan)
	return current_scan

/datum/scanner_controller/proc/cleanup_current_scan()
	SIGNAL_HANDLER
	current_scan = null
	SEND_SIGNAL(src,COMSIG_EXOSCAN_FINISHED,current_scan)

/datum/scanner_controller/proc/activate_scanner(obj/machinery/exoscanner/scanner)
	if(scanner in tracked_dishes)
		return
	tracked_dishes += scanner
	update_scan_power()

/datum/scanner_controller/proc/deactivate_scanner(obj/machinery/exoscanner/scanner)
	if(!(scanner in tracked_dishes))
		return
	tracked_dishes -= scanner
	update_scan_power()

/datum/scanner_controller/proc/update_scan_power()
	scan_power_cache = list()
	if(current_scan) //Check if we need to interrupt current scan.
		var/current_power = length(tracked_dishes)
		if(current_scan.target)
			current_power = get_scan_power(current_scan.target)
		if(current_scan.scan_power > current_power)
			current_scan.stop("Scan swarm power reduced")

/datum/scanner_controller/proc/get_scan_power(datum/exploration_site/target)
	if(!scan_power_cache[target])
		scan_power_cache[target] = calculate_scan_power(target.scan_conditions)
	return scan_power_cache[target]

/datum/scanner_controller/proc/calculate_scan_power(conditions)
	. = 0
	for(var/obj/machinery/exoscanner/dish in tracked_dishes)
		var/effective_power = dish.scan_power
		for(var/datum/scan_condition/condition in conditions)
			effective_power *= condition.check_dish(dish)
			if(!effective_power) //Don't bother continuing if it's zero
				break
		. += effective_power

/// Scan condition, these require some specific setup for the dish to count for the scan power for the given site
/datum/scan_condition
	var/name
	var/description

/// Returns power multiplier of the dish depending on condition.
/datum/scan_condition/proc/check_dish(obj/machinery/exoscanner/dish)
	return 1

/datum/scan_condition/nebula
	name = "Nebula"
	description = "Site is within an unusually dense nebula. To reduce scanner noise, position dishes at least 15 tiles apart."
	var/distance = 15

/datum/scan_condition/nebula/check_dish(obj/machinery/exoscanner/dish)
	for(var/obj/machinery/exoscanner/other_dish in GLOB.exoscanner_controller.tracked_dishes)
		if(dish != other_dish && dish.z == other_dish.z && get_dist(dish,other_dish) < distance)
			return 0
	return 1

/datum/scan_condition/pulsar
	name = "Pulsar"
	description = "A pulsar near the site requires dishes to be shielded from electomagnetic noise. Ensure no other machines are working near the dish."
	var/distance = 2

/datum/scan_condition/pulsar/check_dish(obj/machinery/exoscanner/dish)
	for(var/obj/machinery/some_machine in range(distance,dish))
		if(some_machine != dish && some_machine.is_operational)
			return 0
	return 1

/datum/scan_condition/asteroid_belt
	name = "Asteroid Belt"
	description = "An asteroid belt is obscuring the direct line of sight from the station to the site. Ensure the dishes are placed outside of the station z level."

/datum/scan_condition/asteroid_belt/check_dish(obj/machinery/exoscanner/dish)
	var/turf/dish_turf = get_turf(dish)
	return is_station_level(dish_turf.z) ? 0 : 1

/datum/scan_condition/black_hole
	name = "Black Hole"
	description = "A background black hole requires you to focus the scan point precisely. Ensure the dishes are isolated from rest of the station with at least 6 walls around them."

/datum/scan_condition/black_hole/check_dish(obj/machinery/exoscanner/dish)
	var/wall_count = 0
	for(var/turf/turf_in_dish_range in range(1,get_turf(dish)))
		if(turf_in_dish_range.density)
			wall_count += 1
	return wall_count > 6 ? 1 : 0

/datum/scan_condition/easy
	name = "Easy Scan"
	description = "This site is very easy to scan, all dish power is doubled."

/datum/scan_condition/easy/check_dish(obj/machinery/exoscanner/dish)
	return 2

#undef MAX_SCAN_DISTANCE
#undef WIDE_SCAN_COST
#undef BASE_POINT_SCAN_TIME
#undef BASE_DEEP_SCAN_TIME

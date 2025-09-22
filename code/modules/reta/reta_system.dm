/**
 * Request Emergency Temporary Access - RETA System
 * Provides temporary department access when Requests Console emergency calls are made.
 */

/// Helper function for RETA-specific logging
/proc/log_reta(text)
	WRITE_LOG(GLOB.reta_log, "[time_stamp()] RETA: [text]")
	log_game("RETA: [text]")

/proc/initialize_reta_system()
	// Define which access flags are granted for each department
	GLOB.reta_dept_grants = list(
		"Medical" = list(ACCESS_MEDICAL, ACCESS_SURGERY),
		"Security" = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_BRIG_ENTRANCE),
		"Engineering" = list(ACCESS_ENGINEERING, ACCESS_ATMOSPHERICS),
		"Science" = list(ACCESS_SCIENCE, ACCESS_RESEARCH),
		"Service" = list(ACCESS_SERVICE, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS),
		"Cargo" = list(ACCESS_CARGO),
		"Mining" = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_CARGO),
		"Command" = list(ACCESS_COMMAND), // Admin-only, not available through request consoles
	)

/// Checks if an origin department is on cooldown for calling a target department
/proc/reta_on_cooldown(origin, target)
	var/list/by_target = GLOB.reta_cooldown[origin]
	if(!by_target)
		return FALSE
	var/next_ok = by_target[target] || 0
	return world.time < next_ok

/// Sets a cooldown for an origin department calling a target department
/proc/reta_set_cooldown(origin, target, cd_ds)
	if(!GLOB.reta_cooldown[origin])
		GLOB.reta_cooldown[origin] = list()
	GLOB.reta_cooldown[origin][target] = world.time + cd_ds

/// Tracks recent emergency calls for multiple department analysis
/proc/reta_track_call(origin, target)
	var/list/call_info = list(
		"time" = world.time,
		"origin" = origin
	)

	if(!GLOB.reta_recent_calls[target])
		GLOB.reta_recent_calls[target] = list()
	GLOB.reta_recent_calls[target] += list(call_info)

	// Clean old calls (older than 10 minutes)
	var/cutoff_time = world.time - 6000 // 10 minutes
	if(GLOB.reta_recent_calls[target])
		var/list/recent_calls = GLOB.reta_recent_calls[target]
		GLOB.reta_recent_calls[target] = recent_calls.Copy()
		for(var/list/old_call in GLOB.reta_recent_calls[target])
			if(old_call["time"] < cutoff_time)
				GLOB.reta_recent_calls[target] -= list(old_call)

	// Check for multiple calls scenario
	if(LAZYLEN(GLOB.reta_recent_calls[target]) >= 3)
		var/list/origins = list()
		for(var/list/call_data in GLOB.reta_recent_calls[target])
			origins |= call_data["origin"]

		if(LAZYLEN(origins) >= 3)
			message_admins("RETA: Multiple emergency scenario detected! [target] has been called by [english_list(origins)] in the last 10 minutes. Consider station-wide emergency protocols.")
			log_game("RETA: Multiple department emergency - [target] called by [english_list(origins)]")

/// Finds eligible responders and grants them temporary access
/proc/reta_find_and_grant_access(target_dept, origin_dept, duration_ds)
	. = 0

	var/list/job_trims = GLOB.reta_job_trims[target_dept]
	if(!LAZYLEN(job_trims))
		log_reta("No job trims defined for department '[target_dept]'")
		return FALSE

	var/granted_count = 0
	var/total_players_checked = 0
	var/matching_trim_players = 0

	// Check ID cards being carried by living players (fast and efficient)
	for(var/mob/living/carbon/human/human_player as anything in GLOB.human_list)
		// Only check players who are alive and have clients (actively playing)
		if(!human_player.client || human_player.stat == DEAD)
			continue

		total_players_checked++

		// Get their ID card (worn_id, hands, or belt)
		var/obj/item/card/id/id_card = human_player.get_idcard(hand_first = FALSE)
		if(!id_card || !id_card.trim)
			continue

		// Check if this card's trim matches the target department
		if(!is_type_in_list(id_card.trim, job_trims))
			continue

		matching_trim_players++

		if(id_card.grant_reta_access(origin_dept, duration_ds))
			granted_count++

	if(granted_count > 0)
		// Register this as an active RETA grant for new cards
		if(!GLOB.reta_active_grants[target_dept])
			GLOB.reta_active_grants[target_dept] = list()
		GLOB.reta_active_grants[target_dept][origin_dept] = world.time + duration_ds

		// Set up automatic cleanup when the grant expires
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(cleanup_expired_reta_grant), target_dept, origin_dept), duration_ds)

		// Update all doors to show RETA lights for newly activated grants
		update_all_doors_reta_lights()

		log_reta("Granted temporary [origin_dept] access to [granted_count] [target_dept] department ID cards from a call by [origin_dept].")
		. = TRUE
	else
		log_reta("No [target_dept] personnel found who needed [origin_dept] access from a call by [origin_dept]. (Checked [total_players_checked] living players, [matching_trim_players] had matching trims)")

	return .

/// Populates the job trims list for RETA system
/proc/populate_reta_job_trims()
	GLOB.reta_job_trims = list(
		"Medical" = list(),
		"Security" = list(),
		"Engineering" = list(),
		"Science" = list(),
		"Service" = list(),
		"Command" = list(),
		"Cargo" = list(),
		"Mining" = list()
	)

	log_game("RETA: Starting job trim population...")
	var/total_trims = 0
	for(var/job_trim_path in subtypesof(/datum/id_trim/job))
		var/datum/id_trim/job/trim = new job_trim_path()
		total_trims++

		if(!trim.job)
			log_game("RETA: Trim [job_trim_path] has no job")
			continue
		if(!trim.job.departments_bitflags)
			log_game("RETA: Trim [job_trim_path] job [trim.job] has no departments_bitflags")
			continue

		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
			GLOB.reta_job_trims["Medical"] += job_trim_path
		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			GLOB.reta_job_trims["Security"] += job_trim_path
		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)
			GLOB.reta_job_trims["Engineering"] += job_trim_path
		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_SCIENCE)
			GLOB.reta_job_trims["Science"] += job_trim_path
		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_SERVICE)
			GLOB.reta_job_trims["Service"] += job_trim_path
		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			GLOB.reta_job_trims["Command"] += job_trim_path
		if(trim.job.departments_bitflags & DEPARTMENT_BITFLAG_CARGO)
			GLOB.reta_job_trims["Cargo"] += job_trim_path
			GLOB.reta_job_trims["Mining"] += job_trim_path  // Mining uses CARGO bitflag

	log_game("RETA: Processed [total_trims] trims. Final counts: Medical=[LAZYLEN(GLOB.reta_job_trims["Medical"])], Security=[LAZYLEN(GLOB.reta_job_trims["Security"])], Engineering=[LAZYLEN(GLOB.reta_job_trims["Engineering"])], Science=[LAZYLEN(GLOB.reta_job_trims["Science"])], Service=[LAZYLEN(GLOB.reta_job_trims["Service"])], Command=[LAZYLEN(GLOB.reta_job_trims["Command"])], Cargo=[LAZYLEN(GLOB.reta_job_trims["Cargo"])], Mining=[LAZYLEN(GLOB.reta_job_trims["Mining"])]")

/// Pushes UI updates to all consoles in the same origin department
/proc/reta_push_ui_updates(origin, target)
	for(var/obj/machinery/requests_console/console in GLOB.reta_consoles_by_origin[origin])
		console.ui_update()

/// Gets the department string for a user based on their job
/proc/reta_get_user_department(mob/user)
	if(!user?.mind?.assigned_role)
		return null

	var/datum/job/job = user.mind.assigned_role
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)
		return "Engineering"
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_SCIENCE)
		return "Science"
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_CARGO)
		return "Cargo"
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_SERVICE)
		return "Service"
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
		return "Medical"
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
		return "Security"
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		return "Command"

	return null

/// Gets the standardized department string from a console department name
/proc/reta_get_user_department_by_name(dept_name)
	if(!dept_name)
		return null

	var/dept_lower = LOWER_TEXT(dept_name)

	// Check for partial matches to handle variations in console naming
	if(findtext(dept_lower, "engineering") || findtext(dept_lower, "engine"))
		return "Engineering"
	if(findtext(dept_lower, "science") || findtext(dept_lower, "research"))
		return "Science"
	if(findtext(dept_lower, "cargo") || findtext(dept_lower, "supply"))
		return "Cargo"
	if(findtext(dept_lower, "mining") || findtext(dept_lower, "mine"))
		return "Mining"
	if(findtext(dept_lower, "service") || findtext(dept_lower, "civilian"))
		return "Service"
	if(findtext(dept_lower, "medical") || findtext(dept_lower, "medbay"))
		return "Medical"
	if(findtext(dept_lower, "security") || findtext(dept_lower, "sec"))
		return "Security"
	if(findtext(dept_lower, "command") || findtext(dept_lower, "bridge"))
		return "Command"

	// Autonamed areas that belong to service department
	if(findtext(dept_lower, "kitchen") || findtext(dept_lower, "bar") || findtext(dept_lower, "cafeteria") || findtext(dept_lower, "diner"))
		return "Service"
	if(findtext(dept_lower, "hydroponics") || findtext(dept_lower, "botany"))
		return "Service"
	if(findtext(dept_lower, "janitor") || findtext(dept_lower, "custodial"))
		return "Service"

	// Autonamed areas for medical
	if(findtext(dept_lower, "pharmacy") || findtext(dept_lower, "chemistry") || findtext(dept_lower, "chem"))
		return "Medical"
	if(findtext(dept_lower, "morgue") || findtext(dept_lower, "virology"))
		return "Medical"
	if(findtext(dept_lower, "surgery") || findtext(dept_lower, "operating") || findtext(dept_lower, "cryo"))
		return "Medical"
	if(findtext(dept_lower, "patients") || findtext(dept_lower, "exam"))
		return "Medical"

	// Autonamed areas for engineering
	if(findtext(dept_lower, "atmospherics") || findtext(dept_lower, "atmos"))
		return "Engineering"
	if(findtext(dept_lower, "supermatter") || findtext(dept_lower, "engine"))
		return "Engineering"
	if(findtext(dept_lower, "gravity") || findtext(dept_lower, "telecomm") || findtext(dept_lower, "tcomm"))
		return "Engineering"

	// Autonamed areas for science department
	if(findtext(dept_lower, "xenobiology") || findtext(dept_lower, "xenobio"))
		return "Science"
	if(findtext(dept_lower, "robotics") || findtext(dept_lower, "genetics"))
		return "Science"
	if(findtext(dept_lower, "ordnance") || findtext(dept_lower, "cytology"))
		return "Science"

	// Handle specific autonamed areas that belong to security department
	if(findtext(dept_lower, "brig") || findtext(dept_lower, "holding"))
		return "Security"
	if(findtext(dept_lower, "armory") || findtext(dept_lower, "checkpoint"))
		return "Security"

	return null

/// Cleans up an expired RETA grant from the active grants registry
/proc/cleanup_expired_reta_grant(target_dept, origin_dept)
	if(!GLOB.reta_active_grants[target_dept])
		return
	GLOB.reta_active_grants[target_dept] -= origin_dept
	if(!length(GLOB.reta_active_grants[target_dept]))
		GLOB.reta_active_grants -= target_dept
	log_reta("Cleaned up expired [origin_dept] grant for [target_dept] department")

	// Update all doors to remove RETA lights for expired grants
	update_all_doors_reta_lights()

/// Updates RETA lighting for all doors in the game
/proc/update_all_doors_reta_lights()
	for(var/obj/machinery/door/airlock/door as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		door.update_appearance(UPDATE_OVERLAYS)

/// Applies any currently active RETA grants to a newly created/spawned ID card
/// This should be called when ID cards are created, spawned, or have their trim changed
/proc/apply_active_reta_grants_to_card(obj/item/card/id/id_card)
	if(!id_card || !id_card.trim)
		return

	// If no active grants, nothing to do (prevents spam during round start)
	if(!LAZYLEN(GLOB.reta_active_grants))
		return

	// Check if this card's department has any active incoming RETA grants
	for(var/target_dept in GLOB.reta_active_grants)
		var/list/job_trims = GLOB.reta_job_trims[target_dept]
		if(!LAZYLEN(job_trims))
			continue

		// Check if this card's trim matches the target department
		if(!is_type_in_list(id_card.trim, job_trims))
			continue

		log_reta("Card trim [id_card.trim] matches [target_dept] department - applying active grants")

		// Apply all active grants for this department
		for(var/origin_dept in GLOB.reta_active_grants[target_dept])
			var/expiry_time = GLOB.reta_active_grants[target_dept][origin_dept]
			if(world.time >= expiry_time)
				continue // Grant expired, skip it

			var/remaining_time = expiry_time - world.time
			if(id_card.grant_reta_access(origin_dept, remaining_time))
				log_reta("Auto-granted [origin_dept] access to newly created [id_card] ([target_dept] department)")

// Default config values
#define RETA_DEFAULT_DURATION_DS 3000  // 5 minutes
#define RETA_DEFAULT_COOLDOWN_DS 150   // 15 seconds

/// Initialize RETA config values
/proc/reta_init_config()
	log_world("RETA: System initialized with duration=[CONFIG_GET(number/reta_duration_ds)]ds, cooldown=[CONFIG_GET(number/reta_dept_cooldown_ds)]ds, enabled=[CONFIG_GET(flag/reta_enabled)]")

#undef RETA_DEFAULT_DURATION_DS
#undef RETA_DEFAULT_COOLDOWN_DS

/// How many lines of log we keep
#define EXODRONE_LOG_SIZE 15
/// Size of drone storage shared between loot and tools.
#define EXODRONE_CARGO_SLOTS 6

// Fuel types and travel time per unit of distance on that fuel.
#define FUEL_BASIC "basic"
#define BASIC_FUEL_TIME_COST 300

#define FUEL_ADVANCED "advanced"
#define ADVANCED_FUEL_TIME_COST 200

#define FUEL_EXOTIC "exotic"
#define EXOTIC_FUEL_TIME_COST 100

/// All exodrones.
GLOBAL_LIST_EMPTY(exodrones)
/// All exodrone launchers.
GLOBAL_LIST_EMPTY(exodrone_launchers)

/// Exploration drone
/obj/item/exodrone
	name = "exploration drone"
	desc = "long range semi-autonomous exploration drone"
	icon = 'icons/obj/exploration.dmi'
	icon_state = "drone"
	w_class = WEIGHT_CLASS_BULKY

	/// Current drone status, see code\__DEFINES\adventure.dm
	var/drone_status = EXODRONE_IDLE
	/// Are we currently controlled by remote terminal, blocks other terminals from interacting with this drone.
	var/controlled = FALSE
	/// Site we're currently at, null means station.
	var/datum/exploration_site/location
	/// Site we're currently travelling to, null means going back to station - check drone status if you want to check if traveling or idle
	var/datum/exploration_site/travel_target
	/// Total travel time to our current target
	var/travel_time
	/// Id of travel timer
	var/travel_timer_id
	/// Message that will show up on busy screen
	var/busy_message = "Doing something..."
	/// When we entered busy state
	var/busy_start_time
	/// How long will busy state last
	var/busy_duration
	// Our current adventure if any.
	var/datum/adventure/current_adventure
	// Our current simple event ui data if any
	var/list/current_event_ui_data
	/// Pad we've launched from, we'll try to land on this one first when coming back if it still exists.
	var/datum/weakref/last_pad
	/// Log of recent events
	var/list/drone_log = list()
	/// List of tools, EXODRONE_TOOL_WELDER etc
	var/list/tools = list()
	// Current travel cost per 1 distance in deciseconds
	var/travel_cost_coeff = BASIC_FUEL_TIME_COST
	/// Repeated drone name counter
	var/static/name_counter = list()
	/// Used to provide source to the regex replacement function. DO NOT MODIFY DIRECTLY
	var/static/obj/item/exodrone/_regex_context

/obj/item/exodrone/Initialize(mapload)
	. = ..()
	name = pick(strings(EXODRONE_FILE,"probe_names"))
	if(name_counter[name])
		name_counter[name]++
		name = "[name] \Roman[name_counter[name]]"
	else
		name_counter[name] = 1
	GLOB.exodrones += src
	/// Cargo storage
	var/datum/component/storage/storage = AddComponent(/datum/component/storage/concrete)
	storage.cant_hold = GLOB.blacklisted_cargo_types
	storage.max_w_class = WEIGHT_CLASS_NORMAL
	storage.max_items = EXODRONE_CARGO_SLOTS

/obj/item/exodrone/Destroy()
	. = ..()
	GLOB.exodrones -= src

/// Description for drone listing, describes location and current status
/obj/item/exodrone/proc/ui_description()
	if(location)
		switch(drone_status)
			if(EXODRONE_TRAVEL)
				return "Traveling back to station."
			else
				return "Exploring [location.display_name()]"
	else
		switch(drone_status)
			if(EXODRONE_TRAVEL)
				return "Traveling to exploration site."
			else
				return "Idle."

/// Starts travel for site, does not validate if it's possible
/obj/item/exodrone/proc/launch_for(datum/exploration_site/target_site)
	if(!location) //We're launching from station, fuel up
		var/obj/machinery/exodrone_launcher/pad = locate() in loc
		pad.fuel_up(src)
		pad.launch_effect()
		last_pad = WEAKREF(pad)
		drone_log("Launched from [pad.name] and set course for [target_site.display_name()]")
	else
		drone_log("Launched from [location.display_name()] and set course for [target_site ? target_site.display_name() : station_name()]")
	set_status(EXODRONE_TRAVEL)
	moveToNullspace()
	var/distance_to_travel = target_site ? target_site.distance : location.distance //If we're going home distance is distance of our current location
	if(location && target_site) //Traveling site to site is faster (don't think too hard on 3d space logistics here)
		distance_to_travel = max(abs(target_site.distance - location.distance),1)
	travel_target = target_site
	travel_time = travel_cost_coeff*distance_to_travel
	travel_timer_id = addtimer(CALLBACK(src,.proc/finish_travel),travel_time,TIMER_STOPPABLE)

/// Travel cleanup
/obj/item/exodrone/proc/finish_travel()
	location = travel_target
	travel_timer_id = null
	travel_time = null
	if(location)//We're arriving at exploration site
		location.on_drone_arrival(src)
		set_status(EXODRONE_EXPLORATION)
	else
		var/obj/machinery/exodrone_launcher = find_landing_pad()
		if(exodrone_launcher)
			forceMove(get_turf(exodrone_launcher))
			drone_log("Arrived at [station_name()]. Landing at [exodrone_launcher].")
		else
			var/turf/drop_zone = drop_somewhere_on_station()
			drone_log("Arrived at [station_name()]. Emergency landing at [drop_zone.loc.name].")
		set_status(EXODRONE_IDLE)

/obj/item/exodrone/proc/set_status(new_status)
	SEND_SIGNAL(src,COMSIG_EXODRONE_STATUS_CHANGED)
	drone_status = new_status

/// Cargo space left
/obj/item/exodrone/proc/space_left()
	return EXODRONE_CARGO_SLOTS - length(contents) - length(tools)

/// Adds drone tool and resizes storage.
/obj/item/exodrone/proc/add_tool(tool_type)
	if(space_left() > 0 && (tool_type in GLOB.exodrone_tool_metadata))
		tools += tool_type
		update_storage_size()

/// Removes drone tool and resizes storage.
/obj/item/exodrone/proc/remove_tool(tool_type)
	tools -= tool_type
	update_storage_size()

/// Resizes storage component depending on slots used by tools.
/obj/item/exodrone/proc/update_storage_size()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage/concrete)
	storage.max_items = EXODRONE_CARGO_SLOTS - length(tools)

/// Builds ui data for drone storage.
/obj/item/exodrone/proc/get_cargo_data()
	. = list()
	for(var/tool in tools)
		. += list(list("type"="tool","name"=tool))
	for(var/obj/cargo in contents)
		. += list(list("type"="cargo","name"=cargo.name, "ref"=ref(cargo)))
	for(var/_ in 1 to space_left())
		. += list(list("type"="empty","name"="Free space"))

/// Tries to add loot to drone cargo while respecting space left
/obj/item/exodrone/proc/try_transfer(obj/loot, delete_on_failure=TRUE)
	if(space_left() > 1)
		loot.forceMove(src)
		drone_log("Acquired [loot.name].")
	else
		drone_log("Abandoned [loot.name] due to lack of space.")
		if(delete_on_failure)
			qdel(loot)

/// Crashes the drone somewhere random if there's no launchpad to be found.
/obj/item/exodrone/proc/drop_somewhere_on_station()
	var/turf/random_spot = get_safe_random_station_turf()

	var/obj/structure/closet/supplypod/pod = podspawn(list(
		"target" = random_spot,
	))
	forceMove(pod)
	return random_spot

/// Tries to find landing pad, starting with the one we launched from.
/obj/item/exodrone/proc/find_landing_pad()
	var/obj/machinery/exodrone_launcher/landing_pad = last_pad?.resolve()
	if(landing_pad)
		return landing_pad
	for(var/obj/machinery/exodrone_launcher/other_pad in GLOB.exodrone_launchers)
		return other_pad

/// encounters random or specificed event for the current site.
/obj/item/exodrone/proc/explore_site(datum/exploration_event/specific_event)
	if(!specific_event) //encounter random event
		var/list/events_to_encounter = list()
		for(var/datum/exploration_event/event in location.events)
			if(event.visited)
				continue
			events_to_encounter += event
		if(!length(events_to_encounter))
			drone_log("It seems there's nothing interesting left around [location.name].")
			return
		var/datum/exploration_event/encountered_event = pick(events_to_encounter)
		encountered_event.encounter(src)
	else if(specific_event.is_targetable())
		specific_event.encounter(src)

/obj/item/exodrone/proc/get_adventure_data()
	var/list/data = current_adventure?.ui_data()
	data["description"] = updateKeywords(data["description"])
	var/list/choices = data["choices"]
	for(var/list/choice in choices)
		choice["text"] = updateKeywords(choice["text"])
	return data

///Replaces $$SITE_NAME with site name and $$QualityName with quality values
/obj/item/exodrone/proc/updateKeywords(text)
	_regex_context = src
	var/static/regex/keywordRegex = regex(@"\$\$(\S*)","g")
	. = keywordRegex.Replace(text,/obj/item/exodrone/proc/replace_keyword)
	_regex_context = null

/// This is called with src = regex datum, so don't try to access any instance variables directly here.
/obj/item/exodrone/proc/replace_keyword(match,g1)
	switch(g1)
		if("SITE_NAME")
			return _regex_context.location.display_name()
		else
			if(_regex_context.current_adventure.qualities[g1])
				return "[_regex_context.current_adventure.qualities[g1]]"
			else
				return ""

/obj/item/exodrone/proc/start_adventure(datum/adventure/adventure)
	current_adventure = adventure
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_FINISHED,.proc/resolve_adventure)
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_QUALITY_INIT,.proc/add_tool_qualities)
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_DELAY_START,.proc/adventure_delay_start)
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_DELAY_END,.proc/adventure_delay_end)
	set_status(EXODRONE_ADVENTURE)
	current_adventure.start_adventure()

/// Handles finishing adventure
/obj/item/exodrone/proc/resolve_adventure(datum/source,result)
	SIGNAL_HANDLER
	switch(result)
		if(ADVENTURE_RESULT_SUCCESS)
			award_adventure_loot()
			UnregisterSignal(current_adventure,list(COMSIG_ADVENTURE_FINISHED,COMSIG_ADVENTURE_QUALITY_INIT,COMSIG_ADVENTURE_DELAY_START,COMSIG_ADVENTURE_DELAY_END))
			current_adventure = null
			set_status(EXODRONE_EXPLORATION)
			return
		if(ADVENTURE_RESULT_DAMAGE)
			damage(max_integrity*0.5) //Half health lost
			if(!QDELETED(src)) // Don't bother if we just blown up from the damage
				UnregisterSignal(current_adventure,list(COMSIG_ADVENTURE_FINISHED,COMSIG_ADVENTURE_QUALITY_INIT,COMSIG_ADVENTURE_DELAY_START,COMSIG_ADVENTURE_DELAY_END))
				current_adventure = null
				set_status(EXODRONE_EXPLORATION)
			return
		if(ADVENTURE_RESULT_DEATH)
			qdel(src)

/// Adds loot from current adventure to the drone
/obj/item/exodrone/proc/award_adventure_loot()
	if(length(current_adventure.loot_categories))
		var/generator_type = GLOB.adventure_loot_generator_index[pick(current_adventure.loot_categories)]
		if(!generator_type)
			return //Could probably warn but i suppose this is up to adventure creator.
		var/datum/adventure_loot_generator/generator = new generator_type
		generator.transfer_loot(src)

/// Applies adventure qualities based on our tools
/obj/item/exodrone/proc/add_tool_qualities(datum/source,list/quality_list)
	SIGNAL_HANDLER
	for(var/tool in tools)
		quality_list[tool] = 1

/obj/item/exodrone/proc/adventure_delay_start(datum/source, delay_time,delay_message)
	SIGNAL_HANDLER
	set_busy(delay_message,delay_time)

/obj/item/exodrone/proc/adventure_delay_end(datum/source)
	SIGNAL_HANDLER
	unset_busy(EXODRONE_ADVENTURE)

/// Enters busy mode for a given duration.
/obj/item/exodrone/proc/set_busy(message,duration)
	if(message)
		busy_message = message
	busy_start_time = world.time
	busy_duration = duration
	set_status(EXODRONE_BUSY)

/// Resets busy status
/obj/item/exodrone/proc/unset_busy(new_status)
	busy_message = initial(busy_message)
	busy_start_time = null
	busy_duration = null
	set_status(new_status)

/obj/item/exodrone/proc/busy_time_left()
	return busy_duration - (world.time - busy_start_time)

/// Returns failure message or FALSE if we're ready to travel
/obj/item/exodrone/proc/travel_error()
	/// We're home and on ready pad or exploring and out of any events/adventures
	switch(drone_status)
		if(EXODRONE_IDLE)
			var/obj/machinery/exodrone_launcher/pad = locate() in loc
			if(!pad)
				return "No launcher"
			if(!pad.fuel_canister)
				return "No fuel in launcher"
			if(pad.fuel_canister.uses <= 0)
				return "Launcher fuel used up"
			return FALSE
		if(EXODRONE_EXPLORATION)
			if(current_event_ui_data)
				return "Busy"
			return FALSE
		else
			return ""

/// Deals damage in adventures/events.
/obj/item/exodrone/proc/damage(amount)
	take_damage(amount)
	drone_log("Sustained [amount] damage.")

/obj/item/exodrone/proc/drone_log(message)
	drone_log.Insert(1,message)
	if(length(drone_log) > EXODRONE_LOG_SIZE)
		drone_log.Cut(EXODRONE_LOG_SIZE)

/obj/item/exodrone/proc/has_tool(tool_type)
	return tools.Find(tool_type)

/// Exploration drone launcher
/obj/machinery/exodrone_launcher
	name = "exploration drone launcher"
	desc = "A launch pad designed to send exploration drones into the great beyond."
	icon = 'icons/obj/exploration.dmi'
	icon_state = "launcher"
	/// Loaded fuel pellet.
	var/obj/item/fuel_pellet/fuel_canister

/obj/machinery/exodrone_launcher/Initialize(mapload)
	. = ..()
	GLOB.exodrone_launchers += src

/obj/machinery/exodrone_launcher/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/fuel_pellet))
		if(fuel_canister)
			to_chat(user, span_warning("There's already fuel loaded inside [src]!"))
			return TRUE
		if(!user.transferItemToLoc(weapon, src))
			return
		fuel_canister = weapon
		update_icon()
		return TRUE

	if(istype(weapon, /obj/item/exodrone) && user.transferItemToLoc(weapon, drop_location()))
		return TRUE

	return ..()

/obj/machinery/exodrone_launcher/crowbar_act(mob/living/user, obj/item/crowbar)
	if(!fuel_canister)
		return

	to_chat(user, span_notice("You remove [fuel_canister] from [src]."))
	fuel_canister.forceMove(drop_location())
	fuel_canister = null
	update_icon()
	return TRUE

/obj/machinery/exodrone_launcher/Destroy()
	GLOB.exodrone_launchers -= src
	QDEL_NULL(fuel_canister)
	return ..()

/obj/machinery/exodrone_launcher/update_overlays()
	. = ..()
	if(fuel_canister && fuel_canister.uses > 0)
		switch(fuel_canister.fuel_type)
			if(FUEL_BASIC)
				. += "launchpad_fuel_basic"
			if(FUEL_ADVANCED)
				. += "launchpad_fuel_advanced"
			if(FUEL_EXOTIC)
				. += "launchpad_fuel_exotic"

/*
 * Gets the fuel travel coefficient for what type of fuel is within the launcher.
 */
/obj/machinery/exodrone_launcher/proc/get_fuel_coefficent()
	if(!fuel_canister)
		return
	switch(fuel_canister.fuel_type)
		if(FUEL_BASIC)
			return BASIC_FUEL_TIME_COST
		if(FUEL_ADVANCED)
			return ADVANCED_FUEL_TIME_COST
		if(FUEL_EXOTIC)
			return EXOTIC_FUEL_TIME_COST

/*
 * Use up some of the fuel within the launcher to power the drone.
 *
 * drone - the drone that's being fuelled by our launcher.
 */
/obj/machinery/exodrone_launcher/proc/fuel_up(obj/item/exodrone/drone)
	drone.travel_cost_coeff = get_fuel_coefficent()
	fuel_canister.use()
	update_icon()

/*
 * Plays an effect on the pad, with a sound effect to boot.
 */
/obj/machinery/exodrone_launcher/proc/launch_effect()
	playsound(src,'sound/effects/podwoosh.ogg',50, FALSE)
	do_smoke(1,get_turf(src))

/obj/machinery/exodrone_launcher/handle_atom_del(atom/A)
	if(A == fuel_canister)
		fuel_canister = null
		update_icon()

/obj/item/exodrone/proc/get_travel_coeff()
	switch(drone_status)
		if(EXODRONE_IDLE)
			var/obj/machinery/exodrone_launcher/pad = locate() in loc
			if(pad && pad.fuel_canister)
				return pad.get_fuel_coefficent()
			else
				return travel_cost_coeff
		else
			return travel_cost_coeff

/obj/item/fuel_pellet
	name = "standard fuel pellet"
	desc = "A compressed fuel pellet for long-distance drone flight."
	icon = 'icons/obj/exploration.dmi'
	icon_state = "fuel_basic"
	/// The type of fuel this pellet has within.
	var/fuel_type = FUEL_BASIC
	/// The amount of uses left in this fuel pellet.
	var/uses = 5

/obj/item/fuel_pellet/use()
	uses--
	if(uses <= 0)
		qdel(src)

/obj/item/fuel_pellet/advanced
	name = "advanced fuel pellet"
	fuel_type = FUEL_ADVANCED
	icon_state = "fuel_advanced"

/obj/item/fuel_pellet/exotic
	name = "exotic fuel pellet"
	fuel_type = FUEL_EXOTIC
	icon_state = "fuel_exotic"

#undef EXODRONE_LOG_SIZE
#undef EXODRONE_CARGO_SLOTS
#undef FUEL_BASIC
#undef BASIC_FUEL_TIME_COST
#undef FUEL_ADVANCED
#undef ADVANCED_FUEL_TIME_COST
#undef FUEL_EXOTIC
#undef EXOTIC_FUEL_TIME_COST

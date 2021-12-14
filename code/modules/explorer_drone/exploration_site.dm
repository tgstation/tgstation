/// All exploration site instances
GLOBAL_LIST_EMPTY(exploration_sites)

// Band is general distance group. Cost of scanning bands increasly exponentialy.
/proc/generate_exploration_sites()
	var/band = GLOB.exoscanner_controller.wide_scan_band
	var/site_count = 1+rand(band-1,band+1)
	var/site_types = subtypesof(/datum/exploration_site) //cache?
	for(var/i in 1 to site_count)
		var/site_type = pick(site_types)
		var/datum/exploration_site/fresh_site = new site_type(band)
		GLOB.exploration_sites += fresh_site
	GLOB.exoscanner_controller.wide_scan_band += 1

/// Exploration site, drone travel destination representing interesting zone for exploration.
/datum/exploration_site
	/// Name displayed after scanning/exploring
	var/name
	/// Description shown after scanning/exploring
	var/description
	/// How far is it, affects travel time/cost.
	var/distance = 1
	/// Coordinates in Station coordinate system - don't ask if station rotates
	var/coordinates
	/// Was the point scan done or a drone arrived on the site. Affects displayed name/description
	var/revealed = FALSE
	/// Was point scan of this site completed.
	var/point_scan_complete = FALSE
	/// Was deep scan of this site completed.
	var/deep_scan_complete = FALSE
	/// Contains baseline site bands at define time. Events bands will be added to this list as part of event generation.
	var/list/band_info = list()
	/// List of event instances represting thing to be found around this exploration site.
	var/list/events = list()
	/// These are used to determine events/adventures possible for this site
	var/site_traits = list()
	/// Key for strings file fluff events
	var/fluff_type = "fluff_generic"
	/// List of scan conditions for this site - scan conditions are singletons
	var/list/datum/scan_condition/scan_conditions

/datum/exploration_site/New(band)
	. = ..()
	distance = max(band+pick(-1,0,1,2),1)
	coordinates = "ℓ:[rand(0,360)]°,𝑏:[rand(0,90)]°" // ℓ and 𝑏 are symbols for longitude/inclination in made-up station centric coordinate system.
	generate_events()
	generate_scan_conditions()

/datum/exploration_site/proc/generate_events()
	/// Try to find aventure first since they're the meat of the system.
	var/datum/exploration_event/adventure = generate_adventure(site_traits)
	if(adventure)
		add_event(adventure)
	/// Fill other events
	/// Baseline weights for each event root type
	var/static/list/base_weights = list(
		/datum/exploration_event/fluff = 2,
		/datum/exploration_event/simple/danger = 2,
		/datum/exploration_event/simple/trader = 1,
		/datum/exploration_event/simple/resource = 1
	)
	/// Weight mods scaled by distance, resources are more easily found on farther sites
	var/static/list/distance_modifiers = list(
		/datum/exploration_event/simple/trader = 0.3,
		/datum/exploration_event/simple/resource = 0.3,
	)
	var/list/category_weights = base_weights.Copy()
	for(var/modifier in distance_modifiers)
		category_weights[modifier] += distance*distance_modifiers[modifier]
	var/min_events_amount = CEILING(0.4*distance+0.2,1)
	for(var/i in 1 to rand(min_events_amount,min_events_amount+2))
		var/chosen_category = pick_weight(category_weights)
		var/datum/exploration_event/event = generate_event(site_traits,chosen_category)
		if(event)
			add_event(event)

/datum/exploration_site/proc/generate_scan_conditions()
	var/condition_count = pick(3;0,2;1,1;2) //scale this with distance maybe ?
	var/list/possible_conditions = GLOB.scan_conditions.Copy()
	for(var/i in 1 to condition_count)
		LAZYADD(scan_conditions,pick_n_take(possible_conditions))

/datum/exploration_site/proc/generate_adventure(site_traits)
	var/list/possible_adventures = list()
	for(var/datum/adventure_db_entry/entry in GLOB.explorer_drone_adventure_db_entries)
		if(entry.valid_for_use(site_traits))
			possible_adventures += entry
	if(!length(possible_adventures))
		return
	var/datum/adventure_db_entry/chosen_db_entry = pick(possible_adventures)
	var/datum/adventure/chosen_adventure = chosen_db_entry.create_adventure()
	chosen_db_entry.placed = TRUE
	var/datum/exploration_event/adventure/adventure_event = new
	adventure_event.adventure = chosen_adventure
	adventure_event.band_values = chosen_adventure.band_modifiers
	return adventure_event

/datum/exploration_site/proc/generate_event(site_traits,event_root_type)
	/// List of exploration event requirements indexed by type, .[/datum/exploration_site/a] = list("required"=list(trait),"blacklisted"=list(other_trait))
	var/static/exploration_event_requirements_cache = list()
	if(!length(exploration_event_requirements_cache))
		exploration_event_requirements_cache = build_exploration_event_requirements_cache()
	var/list/viable_events = list()
	for(var/event_type in exploration_event_requirements_cache)
		var/list/required_traits = exploration_event_requirements_cache[event_type]["required"]
		var/list/blacklisted_traits = exploration_event_requirements_cache[event_type]["blacklisted"]
		if(!ispath(event_type,event_root_type))
			continue
		if(required_traits && length(required_traits - site_traits) != 0)
			continue
		if(blacklisted_traits && length(required_traits & blacklisted_traits) != 0)
			continue
		viable_events += event_type
	if(!length(viable_events))
		return
	var/chosen_type = pick(viable_events)
	return new chosen_type()

/datum/exploration_site/proc/build_exploration_event_requirements_cache()
	. = list()
	for(var/event_type in subtypesof(/datum/exploration_event))
		var/datum/exploration_event/event = event_type
		if(initial(event.root_abstract_type) == event_type)
			continue
		event = new event_type
		.[event_type] = list("required" = event.required_site_traits,"blacklisted" = event.blacklisted_site_traits)
		//Should be no event refs,GC'd naturally

/datum/exploration_site/proc/add_event(datum/exploration_event/event)
	events += event
	/// Add up event band values to ours
	for(var/band in event.band_values)
		if(band_info[band])
			band_info[band] += event.band_values[band]
		else
			band_info[band] = event.band_values[band]
	return

/datum/exploration_site/proc/on_drone_arrival(obj/item/exodrone/drone)
	var/was_known_before = revealed
	reveal()
	if(!was_known_before)
		drone.drone_log("Discovered [name] at [coordinates].")
	else
		drone.drone_log("Arrived at [display_name()].")

/datum/exploration_site/proc/reveal()
	revealed = TRUE

/datum/exploration_site/proc/display_name()
	return revealed ? name : "Anomaly"

/datum/exploration_site/proc/display_description()
	if(!revealed)
		return "No Data"
	var/list/descriptions = list(description)
	for(var/datum/exploration_event/event in events)
		if(deep_scan_complete && event.deep_scan_description)
			descriptions += event.deep_scan_description
		else if(point_scan_complete && event.point_scan_description)
			descriptions += event.point_scan_description
	return descriptions.Join("\n")

/// Data for ui_data, exploration
/datum/exploration_site/proc/site_data(exploration=FALSE)
	. = list()
	.["ref"] = ref(src)
	.["name"] = display_name()
	.["coordinates"] = coordinates
	.["description"] = display_description()
	.["distance"] = distance
	.["revealed"] = revealed
	.["point_scan_complete"] = point_scan_complete
	.["deep_scan_complete"] = deep_scan_complete
	.["band_info"] = point_scan_complete ? band_info : list() //This loses order so when you iterate bands ui side use all_bands
	if(exploration)
		var/list/event_data = list()
		for(var/datum/exploration_event/event in events)
			if(event.visited && event.is_targetable())
				event_data += list(list("name"=event.name,"ref"=ref(event)))
		.["events"] = event_data

/// Helper proc for exploration site listings in ui.
/proc/build_exploration_site_ui_data()
	. = list()
	for(var/datum/exploration_site/site in GLOB.exploration_sites)
		. += list(site.site_data())

/// Sites

/datum/exploration_site/abandoned_refueling_station
	name = "abandoned refueling station"
	description = "old shuttle refueling station drifting through the void."
	band_info = list(EXOSCANNER_BAND_TECH = 1)
	site_traits = list(EXPLORATION_SITE_RUINS,EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)

/datum/exploration_site/trader_post
	name = "unregistered trading station"
	description = "Weak radio transmission advertises this place as RANDOMIZED_NAME"
	band_info = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_LIFE = 1)
	site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION,EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	fluff_type = "fluff_trading"

/datum/exploration_site/trader_post/New(band)
	. = ..()
	var/chosen_name = pick_list(EXODRONE_FILE,"trading_station_names")
	name = "\"[chosen_name]\" trading station"
	description = replacetext(description,"RANDOMIZED_NAME",chosen_name)

/datum/exploration_site/cargo_wreck
	name = "interstellar cargo ship wreckage"
	description = "wreckage of long-range cargo shuttle"
	band_info = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_DENSITY = 1)
	site_traits = list(EXPLORATION_SITE_SHIP,EXPLORATION_SITE_TECHNOLOGY)

/datum/exploration_site/alien_spaceship
	name = "ancient alien spaceship"
	description = "a gigantic spaceship of unknown origin, it doesnt respond to your hails but does not prevent you boarding either"
	band_info = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_RADIATION = 1)
	site_traits = list(EXPLORATION_SITE_SHIP,EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_ALIEN)

/datum/exploration_site/uncharted_planet
	name = "uncharted planet"
	description = "planet missing from nanotrasen starcharts."
	band_info = list(EXOSCANNER_BAND_LIFE = 3)
	site_traits = list(EXPLORATION_SITE_SURFACE)

/datum/exploration_site/uncharted_planet/New(band)
	/// Planet Type, Atmosphere
	var/list/planet_info = pick_list(EXODRONE_FILE,"planet_types")
	name = planet_info["name"]
	description = planet_info["description"]
	if(planet_info["habitable"])
		site_traits += EXPLORATION_SITE_HABITABLE
	if(planet_info["civilized"])
		site_traits += EXPLORATION_SITE_CIVILIZED
	if(planet_info["tech"])
		site_traits += EXPLORATION_SITE_TECHNOLOGY
	. = ..()

/datum/exploration_site/alien_ruins
	name = "alien ruins"
	description = "alien ruins on small moon surface."
	site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE,EXPLORATION_SITE_ALIEN,EXPLORATION_SITE_RUINS)
	fluff_type = "fluff_ruins"

/datum/exploration_site/asteroid_belt
	name = "asteroid belt"
	description = "dense asteroid belt"
	site_traits = list(EXPLORATION_SITE_SURFACE)
	fluff_type = "fluff_space"

/datum/exploration_site/spacemine
	name = "mining facility"
	description = "abandoned mining facility attached to ore-heavy asteroid"
	band_info = list(EXOSCANNER_BAND_PLASMA = 3)
	site_traits = list(EXPLORATION_SITE_RUINS,EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE)
	fluff_type = "fluff_ruins"

/datum/exploration_site/junkyard
	name = "space junk field"
	description = "a giant cluster of space junk."
	band_info = list(EXOSCANNER_BAND_DENSITY = 3)
	site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_SPACE)
	fluff_type = "fluff_space"

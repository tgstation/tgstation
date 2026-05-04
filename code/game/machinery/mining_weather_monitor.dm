/// Wall mounted mining weather tracker
/obj/machinery/mining_weather_monitor
	name = "barometric monitor"
	desc = "A machine monitoring atmospheric data from mining environments. Provides warnings about incoming weather fronts."
	icon = 'icons/obj/devices/miningradio.dmi'
	icon_state = "wallmount"
	light_power = 1
	light_range = 1.6

/obj/machinery/mining_weather_monitor/Initialize(mapload, ndir, nbuild)
	. = ..()
	AddComponent( \
		/datum/component/weather_announcer, \
		state_normal = "wallgreen", \
		state_warning = "wallyellow", \
		state_danger = "wallred", \
		radar_z_trait = ZTRAIT_MINING, \
	)

/obj/machinery/mining_weather_monitor/update_overlays()
	. = ..()
	if((machine_stat & BROKEN) || !powered())
		return
	. += emissive_appearance(icon, "emissive", src)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/mining_weather_monitor, 28)

/datum/armor/weather_tower
	melee = 80
	bullet = 50
	laser = 50
	energy = 50
	fire = 100
	acid = 100
	bomb = 100

/datum/armor/weather_tower/constructed
	melee = 50
	bullet = 30
	laser = 30
	energy = 30

GLOBAL_LIST_EMPTY(weather_towers)

/obj/machinery/power/weather_tower
	name = "doppler radar tower"
	desc = "A tower that monitors atmospheric data from mining environments. Provides warnings about incoming weather fronts."
	icon = 'icons/obj/mining_zones/terrain.dmi'
	icon_state = "radar"
	base_icon_state = "radar"
	anchored = TRUE
	density = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	armor_type = /datum/armor/weather_tower
	max_integrity = 500
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	processing_flags = START_PROCESSING_MANUALLY
	custom_materials = list(/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 12)

	/// Whether the tower is active and functioning
	var/active = FALSE
	/// Reference to a core installed in the tower
	var/obj/item/assembly/signaler/anomaly/weather/core
	/// Cooldown between weather summons
	COOLDOWN_DECLARE(summon_weather_cd)
	/// Cooldown between weather clears
	COOLDOWN_DECLARE(clear_weather_cd)

/obj/machinery/power/weather_tower/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()
		update_appearance()
	SSmachines.processing_early += src
	LAZYADD(GLOB.weather_towers["[src.z]"], src)
	AddComponent(/datum/component/gps, "Radar Tower")

/obj/machinery/power/weather_tower/Destroy()
	LAZYREMOVE(GLOB.weather_towers["[src.z]"], src)
	QDEL_NULL(core)
	SSmachines.processing_early -= src
	return ..()

/obj/machinery/power/weather_tower/connect_to_network()
	return anchored && ..()

/obj/machinery/power/weather_tower/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/plasteel(loc, disassembled ? 12 : 4)

/obj/machinery/power/weather_tower/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == core)
		core = null
		if(!QDELING(src))
			update_appearance()

/obj/machinery/power/weather_tower/update_overlays()
	. = ..()
	if(active)
		. += mutable_appearance(icon, "[base_icon_state]_on", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]_em", src, alpha = src.alpha)
	else if(anchored)
		. += mutable_appearance(icon, "[base_icon_state]_off", alpha = src.alpha)

	if(core)
		. += mutable_appearance(icon, "[base_icon_state]_core", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]_core_em", src, alpha = src.alpha)

/obj/machinery/power/weather_tower/update_name(updates)
	. = ..()
	if(isnull(core))
		name = initial(name)
	else
		name = "anomalous [initial(name)]"

/obj/machinery/power/weather_tower/examine(mob/user)
	. = ..()
	if(isnull(core))
		. += span_info("It has a slot in which you could install a weather anomaly core.")
	else
		. += span_info("It has \a [core] installed, unlocking weather control.")

/obj/machinery/power/weather_tower/ui_interact(mob/user, datum/tgui/ui)
	if(isnull(core))
		return

	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalousWeatherTower")
		ui.open()

/obj/machinery/power/weather_tower/ui_status(mob/user, datum/ui_state/state)
	if(isnull(core))
		return UI_CLOSE
	if(!active)
		return UI_DISABLED
	return ..()

/obj/machinery/power/weather_tower/ui_data(mob/user)
	var/list/data = list()

	if(isnull(core))
		stack_trace("Tried to get weather tower UI data with no core installed!")

	data["core_charges"] = core?.charges
	data["can_summon_weather"] = COOLDOWN_FINISHED(src, summon_weather_cd)
	data["can_clear_weather"] = COOLDOWN_FINISHED(src, clear_weather_cd)
	data["active_weather_on_z"] = list()
	for(var/datum/weather/ongoing as anything in get_active_weather_on_z())
		data["active_weather_on_z"] += list(list(
			"id" = REF(ongoing),
			"name" = capitalize(ongoing.name),
			"desc" = ongoing.desc,
		))

	return data

/obj/machinery/power/weather_tower/ui_static_data(mob/user)
	var/list/data = list()
	var/list/summonable_weather_types = list()
	for(var/datum/weather/weather_type as anything in get_summonable_weather_types())
		summonable_weather_types += list(list(
			"id" = weather_type,
			"name" = capitalize(weather_type::name),
			"desc" = weather_type::desc,
		))

	data["summonable_weather_types"] = summonable_weather_types
	data["weather_charge_cost"] = weather_charge_cost()
	data["max_core_charge"] = /obj/item/assembly/signaler/anomaly/weather::charges
	return data

/obj/machinery/power/weather_tower/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("summon_weather")
			summon_weather(text2path(params["weather_type"]), ui.user) // sanity checks in proc
			return TRUE

		if("clear_weather")
			clear_weather(params["weather_ref"], ui.user) // sanity checks in proc
			return TRUE

/obj/machinery/power/weather_tower/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/assembly/signaler/anomaly))
		if(!isnull(core))
			to_chat(user, span_warning("The weather core slot is already occupied."))
			return ITEM_INTERACT_FAILURE

		if(!istype(tool, /obj/item/assembly/signaler/anomaly/weather))
			to_chat(user, span_warning("[tool] probably won't do anything useful within [src]."))
			return ITEM_INTERACT_FAILURE

		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("You can't seem to part ways with [tool]."))
			return ITEM_INTERACT_FAILURE

		core = tool
		update_appearance()
		to_chat(user, span_notice("You install [tool] into [src]."))
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/power/weather_tower/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return

	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/weather_tower/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(old_turf)
		LAZYREMOVE(GLOB.weather_towers["[old_turf.z]"], src)
	if(new_turf)
		LAZYADD(GLOB.weather_towers["[new_turf.z]"], src)

/obj/machinery/power/weather_tower/process_early()
	if(anchored && surplus() >= idle_power_usage)
		add_load(idle_power_usage)
		if(!active)
			active = TRUE
			update_appearance()

	else if(active)
		active = FALSE
		update_appearance()

/obj/machinery/power/weather_tower/process()
	return

/// Check whether this tower is on a station z-level or not
/obj/machinery/power/weather_tower/proc/is_on_station()
	return is_station_level(src.z) && !SSmapping.is_planetary()

/// Calculate the charge cost to summon weather based on whether the tower is on station or not
/obj/machinery/power/weather_tower/proc/weather_charge_cost()
	return is_on_station() ? /obj/item/assembly/signaler/anomaly/weather::charges * 0.5 : 1

/// Summon a weather event of the given type on this tower's z-level
/obj/machinery/power/weather_tower/proc/summon_weather(datum/weather/weather_type, mob/user)
	if(isnull(core) || !active)
		return FALSE
	if(!COOLDOWN_FINISHED(src, summon_weather_cd))
		return FALSE
	if(!(weather_type in get_summonable_weather_types()))
		return FALSE

	var/charge_amount = weather_charge_cost()
	if(core.charges < charge_amount)
		return FALSE

	var/used_flags = weather_type::weather_flags | WEATHER_THUNDER
	var/is_station = is_on_station()
	var/list/affected_zs = list(src.z)
	var/list/affected_areas
	if(is_station)
		var/list/storm_free_areas = typecacheof(list(
			/area/station/ai,
			/area/station/commons/storage/emergency,
			/area/station/maintenance,
			/area/station/security/prison/safe,
			/area/station/security/prison/toilet,
		))

		used_flags |= WEATHER_INDOORS
		affected_zs |= SSmapping.levels_by_trait(ZTRAIT_STATION)
		affected_areas = list()
		for(var/area/station/station_area in GLOB.areas)
			if(is_type_in_typecache(station_area, storm_free_areas))
				continue
			affected_areas += station_area
		// keep the summoner safe as well
		affected_areas -= get_area(src)

	var/datum/weather/weather = SSweather.run_weather(
		weather_datum_type = weather_type,
		z_levels = affected_zs,
		weather_data = list(
			WEATHER_FORCED_AREAS = affected_areas,
			WEATHER_FORCED_FLAGS = used_flags,
			WEATHER_FORCED_THUNDER = 0,
			WEATHER_FORCED_TELEGRAPH = 30 SECONDS,
			WEATHER_FORCED_END = 4 MINUTES,
			WEATHER_FORCED_DURATION = 30 SECONDS,
		)
	)

	var/success = !!weather
	if(success)
		visible_message(span_notice("The [src] hums as it summons a [weather]."))
		use_core_charge(charge_amount)
		COOLDOWN_START(src, summon_weather_cd, 8 MINUTES)
		COOLDOWN_START(src, clear_weather_cd, 4 MINUTES)
		if(is_station)
			notify_ghosts("Someone summoned weather on the station!", src)
			log_game("[user ? key_name(user) : "Unknown"] summoned [weather.name] weather on the station using [src] [AREACOORD(src)].")
			message_admins("[user ? ADMIN_LOOKUPFLW(user) : "Unknown"] summoned [weather.name] weather on the station using [src] [ADMIN_COORDJMP(src)].")
		else
			log_game("[user ? key_name(user) : "Unknown"] summoned [weather.name] weather using [src] [AREACOORD(src)].")
	else
		audible_message(span_warning("The [src] emits a frustrated buzz as nothing happens."))
		COOLDOWN_START(src, summon_weather_cd, 1 MINUTES)

	return success

/// Subtract a charge and handle core depletion
/obj/machinery/power/weather_tower/proc/use_core_charge(amount)
	if(isnull(core))
		CRASH("Tried to use weather core charge when no core is installed!")

	core.charges -= amount
	if(core.charges <= 0)
		visible_message(span_boldwarning("[core] expends all of its energy and disintegrates!"))
		new /obj/effect/decal/cleanable/ash/large(loc)
		QDEL_NULL(core)

/// Clears whatever weather datum is referenced with weather_ref
/obj/machinery/power/weather_tower/proc/clear_weather(weather_ref, mob/user)
	if(isnull(core) || !active)
		return FALSE
	if(!COOLDOWN_FINISHED(src, clear_weather_cd))
		return FALSE

	// clear weather on zlevel
	for(var/datum/weather/ongoing as anything in get_active_weather_on_z())
		if(REF(ongoing) == weather_ref)
			log_game("[user ? key_name(user) : "Unknown"] cleared [ongoing.name] using [src] [AREACOORD(src)].")
			ongoing.wind_down()
			COOLDOWN_START(src, clear_weather_cd, 2 MINUTES)
			COOLDOWN_START(src, summon_weather_cd, 1 MINUTES)
			use_core_charge(1)
			return TRUE

	return FALSE

/// Return a list of weather typepaths that this tower can summon when given a weather core.
/obj/machinery/power/weather_tower/proc/get_summonable_weather_types()
	. = list(
		/datum/weather/ash_storm,
		/datum/weather/rain_storm,
		/datum/weather/sand_storm,
		/datum/weather/snow_storm,
	)
	if(is_on_station())
		. += /datum/weather/rad_storm

/// Returns a list of active weather datums that are active on this tower's z-level.
/obj/machinery/power/weather_tower/proc/get_active_weather_on_z()
	. = list()
	for(var/datum/weather/ongoing as anything in SSweather.processing)
		if(ongoing.stage != MAIN_STAGE)
			continue
		if(src.z in ongoing.impacted_z_levels)
			. += ongoing

/obj/machinery/power/weather_tower/constructed
	max_integrity = 200
	armor_type = /datum/armor/weather_tower/constructed

/obj/machinery/power/weather_tower/core

/obj/machinery/power/weather_tower/core/Initialize(mapload)
	. = ..()
	core = new(src)
	update_appearance()

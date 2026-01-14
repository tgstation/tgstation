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

GLOBAL_LIST_EMPTY(weather_towers)

/obj/machinery/power/weather_tower
	name = "doppler radar tower"
	desc = "A tower that monitors atmospheric data from mining environments. Provides warnings about incoming weather fronts."

	var/active = FALSE

	var/obj/item/assembly/signaler/anomaly/weather/core

	COOLDOWN_DECLARE(summon_weather_cd)
	COOLDOWN_DECLARE(clear_weather_cd)

/obj/machinery/power/weather_tower/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()
	LAZYADD(GLOB.weather_towers["[src.z]"], src)

/obj/machinery/power/weather_tower/Destroy()
	LAZYREMOVE(GLOB.weather_towers["[src.z]"], src)
	QDEL_NULL(core)
	return ..()

/obj/machinery/power/weather_tower/connect_to_network()
	return anchored && ..()

/obj/machinery/power/weather_tower/dump_contents()
	. = ..()
	core?.forceMove(drop_location())
	if(!QDELING(src))
		update_appearance()

/obj/machinery/power/weather_tower/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == core)
		core = null
		if(!QDELING(src))
			update_appearance()

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
	return isnull(core) ? UI_CLOSE : ..()

/obj/machinery/power/weather_tower/ui_data(mob/user)
	var/list/data = list()

	if(isnull(core))
		stack_trace("Tried to get weather tower UI data with no core installed!")
		return data

	data["core_charges"] = core.charges
	data["can_summon_weather"] = COOLDOWN_FINISHED(src, summon_weather_cd)
	data["can_clear_weather"] = COOLDOWN_FINISHED(src, clear_weather_cd)
	data["active_weather_on_z"] = list()
	for(var/datum/weather/ongoing as anything in get_active_weather_on_z())
		data["active_weather_on_z"] += list(list(
			"id" = REF(ongoing),
			"name" = ongoing.name,
			"desc" = ongoing.desc,
		))

	return data

/obj/machinery/power/weather_tower/ui_static_data(mob/user)
	var/list/data = list()
	data["summonable_weather_types"] = get_summonable_weather_types()
	data["weather_charge_cost"] = weather_charge_cost()
	return data

/obj/machinery/power/weather_tower/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("summon_weather")
			summon_weather(params["weather_type"])
			return TRUE

		if("clear_weather")
			clear_weather(params["weather_ref"])
			return TRUE

/obj/machinery/power/weather_tower/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/assembly/signaler/anomaly))
		if(!isnull(core))
			to_chat(user, span_warning("The weather core slot is already occupied."))
			return ITEM_INTERACT_FAILURE

		if(!istype(tool, /obj/item/assembly/signaler/anomaly/weather))
			to_chat(user, span_warning("[tool] probably won't do anything useful within [src]."))
			return ITEM_INTERACT_FAILURE

		if(!user.transferItemToLoc(src, tool))
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
	LAZYREMOVE(GLOB.weather_towers["[old_turf.z]"], src)
	LAZYADD(GLOB.weather_towers["[new_turf.z]"], src)

/obj/machinery/power/weather_tower/process_early()
	if(anchored && surplus() >= active_power_usage)
		add_load(active_power_usage)
		active = TRUE
	else
		active = FALSE

/obj/machinery/power/weather_tower/proc/is_on_station()
	return is_station_level(src.z) && !SSmapping.is_planetary()

/obj/machinery/power/weather_tower/proc/weather_charge_cost()
	return is_on_station() ? /obj/item/assembly/signaler/anomaly/weather::charges * 0.5 : 1

/obj/machinery/power/weather_tower/proc/summon_weather(weather_type)
	if(isnull(core))
		return FALSE
	if(!COOLDOWN_FINISHED(src, summon_weather_cd))
		return FALSE
	if(!(weather_type in get_summonable_weather_types()))
		return FALSE
	if(core.charges < weather_charge_cost())
		return FALSE

	var/list/affected_zs = is_on_station() ? SSmapping.levels_by_trait(ZTRAIT_STATION) : list(src.z)
	var/weather = SSweather.run_weather(
		weather_datum_type = weather_type,
		z_levels = affected_zs,
		weather_data = list(
			WEATHER_FORCED_FLAGS = weather_type::weather_flags | WEATHER_INDOORS | WEATHER_THUNDER,
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
	else
		COOLDOWN_START(src, summon_weather_cd, 1 MINUTES)

	return success

/obj/machinery/power/weather_tower/proc/use_core_charge(amount)
	if(isnull(core))
		return

	core.charges -= amount
	if(core.charges <= 0)
		visible_message(span_boldwarning("[core] expends all of its energy and disintegrates!"))
		new /obj/effect/decal/cleanable/ash/large(loc)
		QDEL_NULL(core)

/obj/machinery/power/weather_tower/proc/clear_weather(weather_ref)
	if(isnull(core))
		return FALSE
	if(!COOLDOWN_FINISHED(src, clear_weather_cd))
		return FALSE

	// clear weather on zlevel
	for(var/datum/weather/ongoing as anything in get_active_weather_on_z())
		if(REF(ongoing) == weather_ref)
			ongoing.wind_down()
			COOLDOWN_START(src, clear_weather_cd, 2 MINUTES)
			use_core_charge(1)
			return TRUE

	return FALSE

/obj/machinery/power/weather_tower/proc/get_summonable_weather_types()
	. = list(
		/datum/weather/ash_storm,
		/datum/weather/rain_storm,
		/datum/weather/sand_storm,
		/datum/weather/snow_storm,
	)
	if(is_on_station())
		. += /datum/weather/rad_storm

/obj/machinery/power/weather_tower/proc/get_active_weather_on_z()
	. = list()
	for(var/datum/weather/ongoing as anything in SSweather.processing)
		if(src.z in ongoing.impacted_z_levels)
			. += ongoing

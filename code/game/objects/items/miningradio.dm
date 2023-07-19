#define WEATHER_ALERT_CLEAR 0
#define WEATHER_ALERT_INCOMING 1
#define WEATHER_ALERT_IMMINENT_OR_ACTIVE 2

/// Portable mining radio purchasable by miners
/obj/item/radio/weather_monitor
	icon = 'icons/obj/miningradio.dmi'
	name = "mining weather radio"
	icon_state = "miningradio"
	desc = "A weather radio designed for use in inhospitable environments. Gives audible warnings when storms approach. Has access to cargo channel."
	freqlock = RADIO_FREQENCY_LOCKED

/obj/item/radio/weather_monitor/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/weather_announcer, \
		state_normal = "weatherwarning", \
		state_warning = "urgentwarning", \
		state_danger = "direwarning", \
	)
	set_frequency(FREQ_SUPPLY)

/datum/orderable_item/mining/weather_radio
	item_path = /obj/item/radio/weather_monitor
	cost_per_order = 500

/// Wall mounted mining weather tracker
/obj/machinery/mining_weather_monitor
	name = "barometric monitor"
	desc = "A machine monitoring atmospheric data from mining environments. Provides warnings about incoming weather fronts."
	icon = 'icons/obj/miningradio.dmi'
	icon_state = "wallmount"

/obj/machinery/mining_weather_monitor/Initialize(mapload, ndir, nbuild)
	. = ..()
	AddComponent( \
		/datum/component/weather_announcer, \
		state_normal = "wallgreen", \
		state_warning = "wallyellow", \
		state_danger = "wallred", \
	)

/obj/machinery/mining_weather_monitor/update_overlays()
	. = ..()
	if((machine_stat & BROKEN) || !powered())
		return
	. += emissive_appearance(icon, "emissive", src)

/// Component which makes you yell about what the weather is
/datum/component/weather_announcer
	/// Currently displayed warning level
	var/warning_level = WEATHER_ALERT_CLEAR
	/// Whether the incoming weather is actually going to harm you
	var/is_weather_dangerous = TRUE
	/// Are we actually turned on right now?
	var/enabled = TRUE
	/// Overlay added when things are alright
	var/state_normal
	/// Overlay added when you should start looking for shelter
	var/state_warning
	/// Overlay added when you are in danger
	var/state_danger

/datum/component/weather_announcer/Initialize(
	state_normal,
	state_warning,
	state_danger,
)
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSprocessing, src)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_powered))
	RegisterSignal(parent, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_lost))

	src.state_normal = state_normal
	src.state_warning = state_warning
	src.state_danger = state_danger
	var/atom/speaker = parent
	speaker.update_appearance(UPDATE_ICON)

/datum/component/weather_announcer/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/// Add appropriate overlays
/datum/component/weather_announcer/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	if (!enabled || !state_normal || !state_warning || !state_danger)
		return

	switch (warning_level)
		if(WEATHER_ALERT_CLEAR)
			overlays += state_normal
		if(WEATHER_ALERT_INCOMING)
			overlays += state_warning
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			overlays += (is_weather_dangerous) ? state_danger : state_warning

/// If powered, receive updates
/datum/component/weather_announcer/proc/on_powered()
	SIGNAL_HANDLER
	enabled = TRUE
	var/atom/speaker = parent
	speaker.update_appearance(UPDATE_ICON)

/// If no power, don't receive updates
/datum/component/weather_announcer/proc/on_power_lost()
	SIGNAL_HANDLER
	enabled = FALSE
	var/atom/speaker = parent
	speaker.update_appearance(UPDATE_ICON)

/datum/component/weather_announcer/process(seconds_per_tick)
	if (!enabled)
		return

	var/previous_level = warning_level
	var/previous_danger = is_weather_dangerous
	set_current_alert_level()
	if(previous_level == warning_level && previous_danger == is_weather_dangerous)
		return // No change
	var/atom/movable/speaker = parent
	speaker.say(get_warning_message())
	speaker.update_appearance(UPDATE_ICON)

/// Returns a string we should display to communicate what you should be doing
/datum/component/weather_announcer/proc/get_warning_message()
	if (!is_weather_dangerous)
		return "No risk expected from incoming weather front."
	switch(warning_level)
		if(WEATHER_ALERT_CLEAR)
			return "All clear, no weather alerts to report."
		if(WEATHER_ALERT_INCOMING)
			return "Weather front incoming, begin to seek shelter."
		if(WEATHER_ALERT_IMMINENT_OR_ACTIVE)
			return "Weather front imminent, find shelter immediately."
	return "Error in meteorological calculation. Please report this deviation to a trained programmer."

/// Polls existing weather for what kind of warnings we should be displaying.
/datum/component/weather_announcer/proc/set_current_alert_level()
	var/list/mining_z_levels = SSmapping.levels_by_trait(ZTRAIT_MINING)
	if(!length(mining_z_levels))
		return // No problems if there are no mining z levels

	for(var/datum/weather/check_weather as anything in SSweather.processing)
		if(!check_weather.barometer_predictable || check_weather.stage == WIND_DOWN_STAGE || check_weather.stage == END_STAGE)
			continue
		for (var/mining_level in mining_z_levels)
			if(mining_level in check_weather.impacted_z_levels)
				is_weather_dangerous = !check_weather.aesthetic
				warning_level = WEATHER_ALERT_IMMINENT_OR_ACTIVE
				return

	is_weather_dangerous = TRUE // We don't actually know until it arrives so err with caution
	var/soonest_active_weather = INFINITY
	for(var/mining_level in mining_z_levels)
		var/next_time = timeleft(SSweather.next_hit_by_zlevel["[mining_level ]"]) || INFINITY
		if (next_time && next_time < soonest_active_weather)
			soonest_active_weather = next_time

	if(soonest_active_weather < 30 SECONDS)
		warning_level = WEATHER_ALERT_IMMINENT_OR_ACTIVE
		return

	if(soonest_active_weather < 2 MINUTES)
		warning_level = WEATHER_ALERT_INCOMING
		return

	warning_level = WEATHER_ALERT_CLEAR

#undef WEATHER_ALERT_CLEAR
#undef WEATHER_ALERT_INCOMING
#undef WEATHER_ALERT_IMMINENT_OR_ACTIVE

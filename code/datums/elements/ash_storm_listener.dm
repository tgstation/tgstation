///This element just handles creating and destroying an area sound manager that's hooked into ash storm stuff
/datum/element/ash_storm_listener
	element_flags = ELEMENT_DETACH
	//These will come from
	var/list/sound_change_signals
	var/list/fitting_z_levels = SSmapping.levels_by_trait(ZTRAIT_ASHSTORM)

/datum/element/ash_storm_listener/New()
	. = ..()
	sound_change_signals = list(
		COMSIG_WEATHER_TELEGRAPH(/datum/weather/ash_storm),
		COMSIG_WEATHER_START(/datum/weather/ash_storm),
		COMSIG_WEATHER_WINDDOWN(/datum/weather/ash_storm),
		COMSIG_WEATHER_END(/datum/weather/ash_storm)
	)

/datum/element/ash_storm_listener/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/handle_z_level_change)
	RegisterSignal(target, COMSIG_MOB_LOGOUT, .proc/handle_logout)

/datum/element/ash_storm_listener/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOB_LOGOUT)

/datum/element/ash_storm_listener/proc/handle_z_level_change(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	if(!(new_z in fitting_z_levels))
		return
	var/datum/component/our_comp = source.AddComponent(/datum/component/area_sound_manager, GLOB.ash_storm_sounds, list(), COMSIG_MOB_LOGOUT, fitting_z_levels)
	our_comp.RegisterSignal(SSdcs, sound_change_signals, /datum/component/area_sound_manager/proc/handle_change)

/datum/element/ash_storm_listener/proc/handle_logout(datum/source)
	SIGNAL_HANDLER
	source.RemoveElement(/datum/element/ash_storm_listener)


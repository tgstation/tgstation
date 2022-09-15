///This element just handles creating and destroying an area sound manager that's hooked into weather stuff
/datum/element/weather_listener
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/weather_type
	//What events to change the track on
	var/list/sound_change_signals
	//The weather type we're working with
	var/weather_trait
	//The playlist of sounds to draw from. Pass by ref
	var/list/playlist


/datum/element/weather_listener/Attach(datum/target, w_type, trait, weather_playlist)
	. = ..()
	if(!weather_type)
		weather_type = w_type
		sound_change_signals = list(
			COMSIG_WEATHER_TELEGRAPH(weather_type),
			COMSIG_WEATHER_START(weather_type),
			COMSIG_WEATHER_WINDDOWN(weather_type),
			COMSIG_WEATHER_END(weather_type)
		)
		weather_trait = trait
		playlist = weather_playlist

	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/handle_z_level_change, override = TRUE)
	RegisterSignal(target, COMSIG_MOB_LOGOUT, .proc/handle_logout, override = TRUE)

/datum/element/weather_listener/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOB_LOGOUT))

/datum/element/weather_listener/proc/handle_z_level_change(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	var/list/fitting_z_levels = SSmapping.levels_by_trait(weather_trait)
	if(!(new_z in fitting_z_levels))
		return
	var/datum/component/our_comp = source.AddComponent(/datum/component/area_sound_manager, playlist, list(), COMSIG_MOB_LOGOUT, fitting_z_levels)
	our_comp.RegisterSignal(SSdcs, sound_change_signals, /datum/component/area_sound_manager/proc/handle_change)

/datum/element/weather_listener/proc/handle_logout(datum/source)
	SIGNAL_HANDLER
	source.RemoveElement(/datum/element/weather_listener, weather_type, weather_trait, playlist)


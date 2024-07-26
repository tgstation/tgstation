/// Returns true if the map we're playing on is on a planet, but it DOES have space access.
/datum/controller/subsystem/mapping/proc/is_planetary_with_space()
	return config.planetary && config.allow_space_when_planetary


/datum/map_config
	/// Are we allowing space even if we're planetary?
	var/allow_space_when_planetary = FALSE

/datum/config_entry/flag/eclipse
	default = FALSE

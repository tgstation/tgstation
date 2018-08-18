// global datum that will preload variables on atoms instanciation
GLOBAL_VAR_INIT(use_preloader, FALSE)
GLOBAL_DATUM_INIT(_preloader, /datum/map_preloader, new)

/// Preloader datum
/datum/map_preloader
	parent_type = /datum
	var/list/attributes
	var/target_path

/datum/map_preloader/proc/setup(list/the_attributes, path)
	if(the_attributes.len)
		GLOB.use_preloader = TRUE
		attributes = the_attributes
		target_path = path

/datum/map_preloader/proc/load(atom/what)
	GLOB.use_preloader = FALSE
	for(var/attribute in attributes)
		var/value = attributes[attribute]
		if(islist(value))
			value = deepCopyList(value)
		what.vars[attribute] = value

/area/template_noop
	name = "Area Passthrough"

/turf/template_noop
	name = "Turf Passthrough"
	icon_state = "noop"
	bullet_bounce_sound = null

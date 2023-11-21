GLOBAL_VAR_INIT(light_debug_enabled, FALSE)

/// Global list of all light template types
GLOBAL_LIST_INIT_TYPED(light_types, /datum/light_template, generate_light_types())

/proc/generate_light_types()
	var/list/types = list()
	for(var/datum/light_template/template_path as anything in typesof(/datum/light_template))
		if(initial(template_path.ignore_type) == template_path)
			continue
		var/datum/light_template/template = new template_path()
		types[template.id] = template
	return types

/// Light templates. They describe how a light looks, and links that to names/icons that can be used when templating/debugging
/datum/light_template
	/// User friendly name, to display clientside
	var/name = ""
	/// Description to display to the client
	var/desc = ""
	/// Unique id for this template
	var/id = ""
	/// What category to put this template in
	var/category = "UNSORTED"
	/// Icon to use to display this clientside
	var/icon = ""
	/// Icon state to display clientside
	var/icon_state = ""
	/// The light range we use
	var/range = 0
	/// The light power we use
	var/power = 0
	/// The light color we use
	var/color = ""
	/// The light angle we use
	var/angle = 360
	/// The type to spawn off create()
	var/spawn_type = /obj
	/// Do not load this template if its type matches the ignore type
	/// This lets us do subtypes more nicely
	var/ignore_type = /datum/light_template

/datum/light_template/New()
	. = ..()
	id = replacetext("[type]", "/", "-")

/// Create an atom with our light details
/datum/light_template/proc/create(atom/location, direction)
	var/atom/lad = new spawn_type(location)
	lad.light_flags &= ~LIGHT_FROZEN
	lad.set_light(range, power, color, angle, l_on = TRUE)
	lad.setDir(direction)

	lad.light_flags |= LIGHT_FROZEN
	return lad

/// Template that reads info off a light subtype
/datum/light_template/read_light
	ignore_type = /datum/light_template/read_light
	/// Typepath to pull our icon/state and lighting details from
	var/obj/machinery/light/path_to_read

/datum/light_template/read_light/New()
	. = ..()
	desc ||= "[path_to_read]"
	icon ||= initial(path_to_read.icon)
	icon_state ||= initial(path_to_read.icon_state)
	range = initial(path_to_read.brightness)
	power = initial(path_to_read.bulb_power)
	color = initial(path_to_read.bulb_colour)
	angle = initial(path_to_read.light_angle)
	spawn_type = path_to_read

/datum/light_template/read_light/standard_bar
	name = "Light Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light

/datum/light_template/read_light/warm_bar
	name = "Warm Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/warm

/datum/light_template/read_light/dimwarm_bar
	name = "Dim Warm Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/warm/dim

/datum/light_template/read_light/cold_bar
	name = "Cold Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/cold

/datum/light_template/read_light/dimcold_bar
	name = "Dim Cold Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/cold/dim

/datum/light_template/read_light/red_bar
	name = "Red Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/red

/datum/light_template/read_light/dimred_bar
	name = "Dim Red Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/red/dim

/datum/light_template/read_light/blacklight_bar
	name = "Black Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/blacklight

/datum/light_template/read_light/dim_bar
	name = "Dim Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/dim

/datum/light_template/read_light/very_dim_bar
	name = "Very Dim Bar"
	category = "Bar"
	path_to_read = /obj/machinery/light/very_dim

/datum/light_template/read_light/standard_bulb
	name = "Light Bulb"
	category = "Bulb"
	path_to_read = /obj/machinery/light/small

/datum/light_template/read_light/dim_bulb
	name = "Dim Bulb"
	category = "Bulb"
	path_to_read = /obj/machinery/light/small/dim

/datum/light_template/read_light/red_bulb
	name = "Red Bulb"
	category = "Bulb"
	path_to_read = /obj/machinery/light/small/red

/datum/light_template/read_light/dimred_bulb
	name = "Dim-Red Bulb"
	category = "Bulb"
	path_to_read = /obj/machinery/light/small/red/dim

/datum/light_template/read_light/blacklight_bulb
	name = "Black Bulb"
	category = "Bulb"
	path_to_read = /obj/machinery/light/small/blacklight

/datum/light_template/read_light/standard_floor
	name = "Floor Light"
	category = "Misc"
	path_to_read = /obj/machinery/light/floor

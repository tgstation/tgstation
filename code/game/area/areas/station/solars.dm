/*
* External Solar Areas
*/

/area/station/solars
	icon_state = "panels"
	requires_power = FALSE
	area_flags = UNIQUE_AREA|NO_GRAVITY
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SPACE
	default_gravity = ZERO_GRAVITY

/area/station/solars/fore
	name = "\improper Fore Solar Array"
	icon_state = "panelsF"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/solars/aft
	name = "\improper Aft Solar Array"
	icon_state = "panelsAF"

/area/station/solars/aux/port
	name = "\improper Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/station/solars/aux/starboard
	name = "\improper Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/station/solars/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "panelsS"

/area/station/solars/starboard/aft
	name = "\improper Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/station/solars/starboard/fore
	name = "\improper Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/station/solars/starboard/fore/asteriod
	name = "\improper Starboard Bow Asteriod Solar Array"
	icon_state = "panelsFS"
	area_flags = UNIQUE_AREA // solar areas directly on asteriod have gravity

/area/station/solars/port
	name = "\improper Port Solar Array"
	icon_state = "panelsP"

/area/station/solars/port/asteriod
	name = "\improper Port Asteriod Solar Array"
	icon_state = "panelsP"
	area_flags = UNIQUE_AREA // solar areas directly on asteriod have gravity

/area/station/solars/port/aft
	name = "\improper Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/station/solars/port/fore
	name = "\improper Port Bow Solar Array"
	icon_state = "panelsFP"

/area/station/solars/aisat
	name = "\improper AI Satellite Solars"
	icon_state = "panelsAI"


/*
* Internal Solar Areas
* The rooms where the SMES and computer are
* Not in the maintenance file just so we can keep these organized with other the external solar areas
*/

/area/station/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"

/area/station/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/station/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "SolarcontrolAP"

/area/station/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "SolarcontrolFP"

/area/station/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/station/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "SolarcontrolAS"

/area/station/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "SolarcontrolFS"

/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME   (you can make as many subdivisions as you want)
	name = "NICE NAME" (not required but makes things really nice)
	icon = 'ICON FILENAME' (defaults to 'icons/area_misc.dmi')
	icon_state = "NAME OF ICON" (defaults to "unknown" (blank))
	requires_power = FALSE (defaults to true)
	ambience_index = AMBIENCE_GENERIC   (picks the ambience from an assoc list in ambience.dm)
	ambientsounds = list() (defaults to ambience_index's assoc on Initialize(). override it as "ambientsounds = list('sound/ambience/signal.ogg')" or by changing ambience_index)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

/area/ai_monitored //stub defined ai_monitored.dm

/area/ai_monitored/turret_protected

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE

	base_lighting_alpha = 255
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA | NO_ALERTS
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/space/nearstation
	icon_state = "space_near"
	area_flags = UNIQUE_AREA | NO_ALERTS | AREA_USES_STARLIGHT

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = STANDARD_GRAVITY


/area/testroom
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	name = "Test Room"
	icon_state = "test_room"

//EXTRA

/area/asteroid
	name = "\improper Asteroid"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "asteroid"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA
	ambience_index = AMBIENCE_MINING
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_ASTEROID
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/asteroid/nearstation
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED

/area/asteroid/nearstation/bomb_site
	name = "\improper Bomb Testing Asteroid"

//STATION13

//AI

/area/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ai_monitored/aisat/exterior
	name = "\improper AI Satellite Exterior"
	icon_state = "ai"
	airlock_wires = /datum/wires/airlock/ai

/area/ai_monitored/command/storage/satellite
	name = "\improper AI Satellite Maint"
	icon_state = "ai_storage"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/ai

//AI - Turret_protected

/area/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	///Some sounds (like the space jam) are terrible when on loop. We use this varaible to add it to other AI areas, but override it to keep it from the AI's core.
	var/ai_will_not_hear_this = list('sound/ambience/ambimalf.ogg')
	airlock_wires = /datum/wires/airlock/ai

/area/ai_monitored/turret_protected/Initialize(mapload)
	. = ..()
	if(ai_will_not_hear_this)
		ambientsounds += ai_will_not_hear_this

/area/ai_monitored/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai_upload_foyer
	name = "\improper AI Upload Access"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ai_will_not_hear_this = null

/area/ai_monitored/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/turret_protected/aisat/atmos
	name = "\improper AI Satellite Atmos"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/foyer
	name = "\improper AI Satellite Foyer"
	icon_state = "ai_foyer"

/area/ai_monitored/turret_protected/aisat/service
	name = "\improper AI Satellite Service"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/hallway
	name = "\improper AI Satellite Hallway"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/maint
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai_maint"

/area/ai_monitored/turret_protected/aisat_interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ai_monitored/turret_protected/ai_sat_ext_as
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_east"

/area/ai_monitored/turret_protected/ai_sat_ext_ap
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_west"


// Specfic AI monitored areas

// Stub defined ai_monitored.dm
/area/station/ai_monitored

/area/station/ai_monitored/turret_protected

// AI
/area/station/ai_monitored
	icon_state = "ai"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/ai_monitored/aisat/exterior
	name = "\improper AI Satellite Exterior"
	icon_state = "ai"
	airlock_wires = /datum/wires/airlock/ai

/area/station/ai_monitored/command/storage/satellite
	name = "\improper AI Satellite Maint"
	icon_state = "ai_storage"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/ai

// Turret protected
/area/station/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	///Some sounds (like the space jam) are terrible when on loop. We use this varaible to add it to other AI areas, but override it to keep it from the AI's core.
	var/ai_will_not_hear_this = list('sound/ambience/ambimalf.ogg')
	airlock_wires = /datum/wires/airlock/ai

/area/station/ai_monitored/turret_protected/Initialize(mapload)
	. = ..()
	if(ai_will_not_hear_this)
		ambientsounds += ai_will_not_hear_this

/area/station/ai_monitored/turret_protected/ai_upload
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai_monitored/turret_protected/ai_upload_foyer
	name = "\improper AI Upload Access"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai_monitored/turret_protected/ai
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	ai_will_not_hear_this = null

/area/station/ai_monitored/turret_protected/aisat
	name = "\improper AI Satellite"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/ai_monitored/turret_protected/aisat/atmos
	name = "\improper AI Satellite Atmos"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/foyer
	name = "\improper AI Satellite Foyer"
	icon_state = "ai_foyer"

/area/station/ai_monitored/turret_protected/aisat/service
	name = "\improper AI Satellite Service"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/hallway
	name = "\improper AI Satellite Hallway"
	icon_state = "ai"

/area/station/ai_monitored/turret_protected/aisat/maint
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai_maint"

/area/station/ai_monitored/turret_protected/aisat_interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/ai_monitored/turret_protected/ai_sat_ext_as
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_east"

/area/station/ai_monitored/turret_protected/ai_sat_ext_ap
	name = "\improper AI Sat Ext"
	icon_state = "ai_sat_west"

// Station specific ai monitored rooms, move here for consistenancy

//Command - AI Monitored
/area/station/ai_monitored/command/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER

/area/station/ai_monitored/command/storage/eva/upper
	name = "Upper EVA Storage"

/area/station/ai_monitored/command/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"
	airlock_wires = /datum/wires/airlock/command

//Security - AI Monitored
/area/station/ai_monitored/security/armory
	name = "\improper Armory"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	airlock_wires = /datum/wires/airlock/security

/area/station/ai_monitored/security/armory/upper
	name = "Upper Armory"

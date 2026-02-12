/area/station/ai
	icon_state = "ai"
	sound_environment = SOUND_AREA_STANDARD_STATION
	airlock_wires = /datum/wires/airlock/ai
	motion_monitored = TRUE

	ambientsounds = list('sound/ambience/engineering/ambitech.ogg', 'sound/ambience/engineering/ambitech2.ogg', 'sound/ambience/engineering/ambiatmos.ogg', 'sound/ambience/engineering/ambiatmos2.ogg')
	/// Disables ambientsounds if TRUE. Used for mundane AI locations like the exterior or storage room.
	var/secure = TRUE
	/// Some sounds (like the space jam) are terrible when on loop.
	/// We use this variable to add it to other AI areas, but override it to keep it from the AI's core.
	var/annoying_ambience = list('sound/ambience/misc/ambimalf.ogg')

/area/station/ai/Initialize(mapload)
	. = ..()
	if(!secure)
		ambientsounds = null
		return
	if(annoying_ambience)
		ambientsounds += annoying_ambience

/* --------- */

/area/station/ai/upload
	name = "\improper AI Upload Area"
	icon_state = "unknown" // this is supposed to be for sorting, but if you want to make an upload hallway you can change this
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/ai/upload/chamber
	name = "\improper AI Upload Chamber"
	icon_state = "ai_upload"

/area/station/ai/upload/foyer
	name = "\improper AI Upload Access"
	icon_state = "ai_upload_foyer"

/* SATELLITE */

/area/station/ai/satellite
	name = "\improper AI Satellite"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/station/ai/satellite/chamber
	name = "\improper AI Chamber"
	icon_state = "ai_chamber"
	annoying_ambience = null

/area/station/ai/satellite/exterior
	name = "\improper AI Satellite Exterior"
	secure = FALSE

/area/station/ai/satellite/maintenance
	name = "\improper AI Satellite Maintenance"
	icon_state = "ai_maint"

/area/station/ai/satellite/maintenance/storage
	name = "\improper AI Satellite Storage"
	icon_state = "ai_storage"
	ambience_index = AMBIENCE_DANGER

/* Interior */

/area/station/ai/satellite/interior
	name = "\improper AI Satellite Antechamber"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/ai/satellite/foyer
	name = "\improper AI Satellite Foyer"
	icon_state = "ai_foyer"

/area/station/ai/satellite/hallway
	name = "\improper AI Satellite Hallway"

/area/station/ai/satellite/uppernorth
	name = "\improper AI Satellite Upper Fore"

/area/station/ai/satellite/uppersouth
	name = "\improper AI Satellite Upper Aft"

/* Functions */

/area/station/ai/satellite/atmos
	name = "\improper AI Satellite Atmospherics"

/area/station/ai/satellite/service
	name = "\improper AI Satellite Service"

/area/station/ai/satellite/teleporter
	name ="\improper AI Satellite Teleporter"

/area/station/ai/satellite/equipment
	name ="\improper AI Satellite Equipment"

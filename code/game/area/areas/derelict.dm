//DERELICT

/area/derelict
	name = "Derelict Station"
	icon_state = "storage"
	blob_allowed = 0 //Nope, no winning on the derelict as a blob. Gotta eat the station.

/area/derelict/hallway/primary
	name = "Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "Derelict Solar Control"
	icon_state = "engine"

/area/derelict/se_solar
	name = "South East Solars"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "Derelict Morgue"
	icon_state = "morgue"

/area/derelict/medical/chapel
	name = "Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/derelict/ship
	name = "Abandoned Ship"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "Derelict Aft Solar Array"
	icon_state = "yellow"

/area/derelict/singularity_engine
	name = "Derelict Singularity Engine"
	icon_state = "engine"

/area/derelict/gravity_generator
	name = "Derelict Gravity Generator Room"
	icon_state = "red"

/area/derelict/atmospherics
	name = "Derelict Atmospherics"
	icon_state = "red"



//DJSTATION

/area/djstation
	name = "Ruskie DJ Station"
	icon_state = "DJ"
	has_gravity = 1
	blob_allowed = 0 //Nope, no winning on the DJ station as a blob. Gotta eat the main station.

/area/djstation/solars
	name = "DJ Station Solars"
	icon_state = "DJ"
	has_gravity = 1


//ABANDONED TELEPORTER

/area/AIsattele
	name = "Abandoned Teleporter"
	icon_state = "teleporter"
	music = "signal"
	ambientsounds = list('sound/ambience/ambimalf.ogg')

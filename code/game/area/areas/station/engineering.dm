/area/station/engineering
	icon_state = "engie"
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"

/area/station/engineering/main
	name = "Engineering"
	icon_state = "engine"

/area/station/engineering/hallway
	name = "Engineering Hallway"
	icon_state = "engine_hallway"

/area/station/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/station/engineering/atmos/upper
	name = "Upper Atmospherics"

/area/station/engineering/atmos/project
	name = "\improper Atmospherics Project Room"
	icon_state = "atmos_projectroom"

/area/station/engineering/atmos/pumproom
	name = "\improper Atmospherics Pumping Room"
	icon_state = "atmos_pump_room"

/area/station/engineering/atmos/mix
	name = "\improper Atmospherics Mixing Room"
	icon_state = "atmos_mix"

/area/station/engineering/atmos/storage
	name = "\improper Atmospherics Storage Room"
	icon_state = "atmos_storage"

/area/station/engineering/atmos/storage/gas
	name = "\improper Atmospherics Gas Storage"
	icon_state = "atmos_storage_gas"

/area/station/engineering/atmos/office
	name = "\improper Atmospherics Office"
	icon_state = "atmos_office"

/area/station/engineering/atmos/hfr_room
	name = "\improper Atmospherics HFR Room"
	icon_state = "atmos_HFR"

/area/station/engineering/atmospherics_engine
	name = "\improper Atmospherics Engine"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/engineering/lobby
	name = "\improper Engineering Lobby"
	icon_state = "engi_lobby"

/area/station/engineering/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine_sm"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/supermatter/waste
	name = "\improper Supermatter Waste Chamber"
	icon_state = "engine_sm_waste"

/area/station/engineering/supermatter/room
	name = "\improper Supermatter Engine Room"
	icon_state = "engine_sm_room"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/station/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_break"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/gravity_generator
	name = "\improper Gravity Generator Room"
	icon_state = "grav_gen"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/station/engineering/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engine_storage_shared"

/area/station/engineering/transit_tube
	name = "\improper Transit Tube"
	icon_state = "transit_tube"

/area/station/engineering/storage/tech
	name = "Technical Storage"
	icon_state = "tech_storage"

/area/station/engineering/storage/tcomms
	name = "Telecomms Storage"
	icon_state = "tcom_storage"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/*
* Construction Areas
*/

/area/station/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/construction/storage_wing
	name = "\improper Storage Wing"
	icon_state = "storage_wing"

// General types of Metro's area
// main type of metro is just like metro, for metro stations
// Control room area for maintainers\service rooms like a office or with cameras or something
// Substation - small engi rooms on every station with power stuff(smes, emergency generator maybe)
// Metro Train Tunnels - for tunnels, at which these rippers(trams) are moving
// Abandoned rooms - dangerous places of Metro
/area/station/metro
	name = "Generic Metro"
	icon_state = "hall"
	ambience_index = AMBIENCE_MAINT
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED | PERSISTENT_ENGRAVINGS
	airlock_wires = /datum/wires/airlock/maint
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	forced_ambience = TRUE
	ambient_buzz = 'sound/ambience/maintenance/source_corridor2.ogg'
	ambient_buzz_vol = 20

/area/station/metro/metro_control_room
	name = "Generic Metro"
	icon_state = "engie"

/area/station/metro/power_substation

	name = "Metro's substation"
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	icon_state = "engie"


/area/station/metro/arrivals_station

/area/station/metro/center_station

/area/station/metro/outrivals_station

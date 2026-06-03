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
	name = "Generic Metro control room"
	icon_state = "engie"
	sound_environment = SOUND_AREA_WOODFLOOR
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	ambient_buzz_vol = 5

/area/station/metro/power_substation

	name = "Metro's substation"
	icon_state = "engine"
	ambience_index = AMBIENCE_ENGI
	airlock_wires = /datum/wires/airlock/engineering
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	icon_state = "engie"

/area/station/metro/train_tunnels
	name = "Metro Train's tunnel"

/area/station/metro/abandoned
	name = "Abandoned Metro's part"
	ambient_buzz_vol = 30
	icon_state = "disposal"



// Actual areas, which are at use
// - - - - - - - - - - -
// Metro station's areas
// - - - - - - - - - - -


/area/station/metro/arrivals_station

/area/station/metro/center_station

/area/station/metro/outrivals_station

// - - - - - - - - - - -
// Metro power substation's areas
// - - - - - - - - - - -

/area/station/metro/power_substation/arrivals_metro_substation
	name = "Arrivals Metro Substation"

/area/station/metro/power_substation/center_metro_substation
	name = "Center Metro Substation"

/area/station/metro/power_substation/outrivals_metro_substation
	name = "Outrivals Metro Substation"

// - - - - - - - - - - -
// Metro train tunnels areas
// - - - - - - - - - - -

/area/station/metro/train_tunnels/north_tunnel
	name = "Metro's North tunnel"

/area/station/metro/train_tunnels/south_tunnel
	name = "Metro's South tunnel"

// - - - - - - - - - - -
// Metro control room areas
// - - - - - - - - - - -

/area/station/metro/metro_control_room/center_control_room
	name = "Metro's control room"

// - - - - - - - - - - -
// Metro abandoned part areas
// - - - - - - - - - - -

/area/station/metro/abandoned/garbage_corner
	name = "Abandoned Metro's part"

/area/station/metro/abandoned/abandoned_collector
	name = "Abandoned collector"

/area/station/metro/abandoned/abandoned_north_east_tunnel
	name = "Abandoned North-East Tunnel"

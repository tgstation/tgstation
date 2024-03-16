/area/station/command
	name = "Command"
	icon_state = "command"
	ambientsounds = list(
		'sound/ambience/signal.ogg',
		)
	airlock_wires = /datum/wires/airlock/command
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/station/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_showroom
	name = "\improper Corporate Showroom"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/command/corporate_suite
	name = "\improper Corporate Guest Suite"
	icon_state = "command"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/emergency_closet
	name = "\improper Corporate Emergency Closet"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/*
* Command Head Areas
*/

/area/station/command/heads_quarters
	icon_state = "heads_quarters"

/area/station/command/heads_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/station/command/heads_quarters/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"

/area/station/command/heads_quarters/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/station/command/heads_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"

/area/station/command/heads_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"

/area/station/command/heads_quarters/rd
	name = "\improper Research Director's Office"
	icon_state = "rd_office"

/area/station/command/heads_quarters/qm
	name = "\improper Quartermaster's Office"
	icon_state = "qm_office"

/*
* Command - Teleporter
*/

/area/station/command/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/station/command/gateway
	name = "\improper Gateway"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI

/*
* Command - Misc
*/

/area/station/command/corporate_dock
	name = "\improper Corporate Private Dock"
	icon_state = "command"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

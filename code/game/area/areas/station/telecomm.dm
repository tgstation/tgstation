/*
* Telecommunications Satellite Areas
*/

/area/station/tcommsat
	icon_state = "tcomsatcham"
	ambientsounds = list(
		'sound/ambience/engineering/ambisin2.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/general/ambigen9.ogg',
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambitech3.ogg',
		'sound/ambience/misc/ambimystery.ogg',
		)
	airlock_wires = /datum/wires/airlock/engineering

/area/station/tcommsat/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/tcommsat/server
	name = "\improper Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/station/tcommsat/server/upper
	name = "\improper Upper Telecomms Server Room"

/*
* On-Station Telecommunications Areas
*/

/area/station/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/server
	name = "\improper Messaging Server Room"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

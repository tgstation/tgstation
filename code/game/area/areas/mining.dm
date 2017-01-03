/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = 1

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	music = null
	always_unpowered = 1
	requires_power = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	outdoors = 1
	ambientsounds = list('sound/ambience/ambimine.ogg')
	flags = NONE

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	music = null
	always_unpowered = 1
	requires_power = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	outdoors = 1
	ambientsounds = list('sound/ambience/ambimine.ogg')
	flags = NONE

/area/mine/lobby
	name = "Mining Station"

/area/mine/storage
	name = "Mining Station Storage"

/area/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Abandoned Mining Station"

/area/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Mining Station Communications"

/area/mine/cafeteria
	name = "Mining station Cafeteria"

/area/mine/hydroponics
	name = "Mining station Hydroponics"

/area/mine/sleeper
	name = "Mining station Emergency Sleeper"

/area/mine/north_outpost
	name = "North Mining Outpost"

/area/mine/west_outpost
	name = "West Mining Outpost"

/area/mine/laborcamp
	name = "Labor Camp"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"




/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = 1

/area/lavaland/surface
	name = "Lavaland"
	icon_state = "explored"
	music = null
	always_unpowered = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	requires_power = 1
	ambientsounds = list('sound/ambience/ambilava.ogg')

/area/lavaland/underground
	name = "Lavaland Caves"
	icon_state = "unexplored"
	music = null
	always_unpowered = 1
	requires_power = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	ambientsounds = list('sound/ambience/ambilava.ogg')


/area/lavaland/surface/outdoors
	name = "Lavaland Wastes"
	outdoors = 1

/area/lavaland/surface/outdoors/explored
	name = "Lavaland Labor Camp"
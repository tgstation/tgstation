/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = 1

/area/lavaland/surface
	name = "Lavaland"
	icon_state = "explored"
	music = null
	requires_power = 1
	ambientsounds = list('sound/ambience/ambimine.ogg')

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
	ambientsounds = list('sound/ambience/ambimine.ogg')


/area/lavaland/surface/outdoors
	name = "Lavaland Wastes"
	outdoors = 1

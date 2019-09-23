//clown planet ruin code

//Areas
/area/ruin/powered/clownplanet/actual
	name = "Clown Planet"
	icon_state = "dk_yellow"
	dynamic_lighting = 0
	ambientsounds = list('sound/ambience/clown.ogg')

//Turfs

/turf/open/indestructible/sound/clownplanet
	name = "grass patch"
	icon_state = "grass"
	desc = "You can't tell if this is real grass or just cheap plastic imitation."
	sound = list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg','sound/items/bikehorn.ogg')

/turf/closed/mineral/clownplanet
	baseturfs = /turf/open/floor/plating/asteroid

/turf/closed/mineral/bananium/clownplanet
	baseturfs = /turf/open/floor/plating/asteroid
	mineralAmt = 1

/turf/closed/mineral/bananium/clownplanet/two
	mineralAmt = 2

/turf/closed/mineral/bananium/clownplanet/three
	mineralAmt = 3

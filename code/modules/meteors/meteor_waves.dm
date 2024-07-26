
GLOBAL_VAR_INIT(meteor_wave_delay, 625) //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round
// This spelling mistake? Name? is older then git, I'm scared to touch it

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
						  /obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=2, /obj/effect/meteor/carp=1, /obj/effect/meteor/bluespace=1, \
						  /obj/effect/meteor/banana=1, /obj/effect/meteor/emp = 1)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium=4, /obj/effect/meteor/big=8, /obj/effect/meteor/flaming=3, \
						  /obj/effect/meteor/irradiated=3, /obj/effect/meteor/cluster=1, /obj/effect/meteor/carp=1, /obj/effect/meteor/bluespace=2, /obj/effect/meteor/emp = 2)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium=5, /obj/effect/meteor/big=75, \
						  /obj/effect/meteor/flaming=10, /obj/effect/meteor/irradiated=8, /obj/effect/meteor/cluster=8, /obj/effect/meteor/tunguska=1, \
						  /obj/effect/meteor/carp=2, /obj/effect/meteor/bluespace=10, /obj/effect/meteor/emp = 8)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meateors, list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1)) //for meaty ore event

GLOBAL_LIST_INIT(meteors_dust, list(/obj/effect/meteor/dust=1)) //for space dust event

GLOBAL_LIST_INIT(meteors_stray, list(/obj/effect/meteor/medium=15, /obj/effect/meteor/big=10, \
						  /obj/effect/meteor/flaming=25, /obj/effect/meteor/irradiated=30, /obj/effect/meteor/carp=25, /obj/effect/meteor/bluespace=30, \
						  /obj/effect/meteor/banana=25, /obj/effect/meteor/meaty=10, /obj/effect/meteor/meaty/xeno=8, /obj/effect/meteor/emp = 30, \
						  /obj/effect/meteor/cluster=20, /obj/effect/meteor/tunguska=1)) //for stray meteor event (bigger numbers for a bit finer weighting)

GLOBAL_LIST_INIT(meteors_sandstorm, list(/obj/effect/meteor/sand=45, /obj/effect/meteor/dust=5)) //for sandstorm event

GLOBAL_LIST_INIT(meteorsSPOOKY, list(/obj/effect/meteor/pumpkin=1))

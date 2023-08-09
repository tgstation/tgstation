/area/station/science
	name = "\improper Science Division"
	icon_state = "science"
	airlock_wires = /datum/wires/airlock/science
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/station/science/lobby
	name = "\improper Science Lobby"
	icon_state = "science_lobby"

/area/station/science/lower
	name = "\improper Lower Science Division"
	icon_state = "lower_science"

/area/station/science/breakroom
	name = "\improper Science Break Room"
	icon_state = "science_breakroom"

/area/station/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/station/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/station/science/xenobiology/hallway
	name = "\improper Xenobiology Hallway"
	icon_state = "xenobio_hall"

/area/station/science/cytology
	name = "\improper Cytology Lab"
	icon_state = "cytology"

/area/station/science/cubicle
	name = "\improper Science Cubicles"
	icon_state = "science"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/station/science/genetics
	name = "\improper Genetics Lab"
	icon_state = "geneticssci"

/area/station/science/server
	name = "\improper Research Division Server Room"
	icon_state = "server"

/area/station/science/circuits
	name = "\improper Circuit Lab"
	icon_state = "cir_lab"

/area/station/science/explab
	name = "\improper Experimentation Lab"
	icon_state = "exp_lab"

/area/station/science/auxlab
	name = "\improper Auxiliary Lab"
	icon_state = "aux_lab"

/area/station/science/auxlab/firing_range
	name = "\improper Research Firing Range"

/area/station/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/station/science/robotics/mechbay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/station/science/robotics/lab
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/station/science/robotics/augments
	name = "improper Augmentation Theater"
	icon_state = "robotics"
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/station/science/research
	name = "\improper Research Division"
	icon_state = "science"

/area/station/science/research/abandoned
	name = "\improper Abandoned Research Lab"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/*
* Ordnance Areas
*/

// Use this for the main lab. If test equipment, storage, etc is also present use this one too.
/area/station/science/ordnance
	name = "\improper Ordnance Lab"
	icon_state = "ord_main"

/area/station/science/ordnance/office
	name = "\improper Ordnance Office"
	icon_state = "ord_office"

/area/station/science/ordnance/storage
	name = "\improper Ordnance Storage"
	icon_state = "ord_storage"

/area/station/science/ordnance/burnchamber
	name = "\improper Ordnance Burn Chamber"
	icon_state = "ord_burn"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/ordnance/freezerchamber
	name = "\improper Ordnance Freezer Chamber"
	icon_state = "ord_freeze"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

// Room for equipments and such
/area/station/science/ordnance/testlab
	name = "\improper Ordnance Testing Lab"
	icon_state = "ord_test"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

/area/station/science/ordnance/bomb
	name = "\improper Ordnance Bomb Site"
	icon_state = "ord_boom"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA | CULT_PERMITTED

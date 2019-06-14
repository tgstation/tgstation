/obj/mecha/working/cleaner
	desc = "CLEAN CLEAN CLEAN"
	name = "\improper Cleaner"
	icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	step_in = 1.8
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/ripley
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	max_equip = 3
	internals_req_access = list(ACCESS_JANITOR, ACCESS_MECH_SCIENCE)
	enclosed = FALSE // you don't need to clean space

/obj/mecha/working/cleaner/Initialize()
	. = ..()
	AddComponent(/datum/component/cleaning, 1)
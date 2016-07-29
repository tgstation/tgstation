/datum/rcd_schematic/test
	category = "test"

/datum/rcd_schematic/test/attack(var/atom/A, var/mob/user)
	to_chat(user, "WHOMP")
	A.color = "#FFFF00"

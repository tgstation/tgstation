/obj/spell/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	charge_max = 400
	clothes_req = 1
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	var/emp_heavy_radius = 5
	var/emp_light_radius = 7

/obj/spell/disable_tech/Click()
	..()

	if(!cast_check())
		return

	invocation()

	empulse(usr.loc, src.emp_heavy_radius, src.emp_light_radius)
	return
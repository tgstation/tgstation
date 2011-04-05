/obj/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1 //originates from the user and I don't give a shit atm
	var/smoke_amount = 10 //above 10 gets reduced to 10 anyway by the set_up proc

/obj/spell/smoke/Click()
	..()

	if(!cast_check())
		return

	invocation()

	var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
	smoke.set_up(smoke_amount, 0, usr.loc)
	smoke.start()
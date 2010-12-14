/client/proc/smokecloud()

	set category = "Spells"
	set name = "Smoke"
	set desc = "Creates a cloud of smoke"
//	if(!usr.casting()) return
	usr.verbs -= /client/proc/smokecloud
	spawn(120)
		usr.verbs += /client/proc/smokecloud
	var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()


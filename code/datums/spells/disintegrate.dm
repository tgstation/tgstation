/obj/spell/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	recharge = 600
	clothes_req = 1
	invocation = "EI NATH"
	invocation_type = "shout"
	range = 1
	var/sparks_spread = 1 //if set to 0, no sparks spread when disintegrating
	var/kill_type = "disintegrate" //"disintegrate" leaves a pile of ash and bones (remains), "gib" gibs, "kill" adds damage_amount of damage_type
	var/damage_amount = 2000 //only used if kill_type = "damage"
	var/damage_type = "brute" //can be "brute", "fire", "toxin" or "oxygen"

/obj/spell/disintegrate/Click()
	..()

	if(!cast_check())
		return

	var/mob/M = input("Choose whom to [kill_type]", "ABRAKADABRA") as mob in oview(usr,range)

	invocation()

	if(sparks_spread)
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(4, 1, M)
		s.start()

	switch(kill_type)
		if("disintegrate")
			M.dust()
		if("gib")
			M.gib()
		if("kill")
			for(var/i=0,i<damage_amount,i++)
				sleep(0) //to avoid troubles with instantly applying lots of damage, it seems to be buggy
				switch(damage_type)
					if("brute")
						M.bruteloss++
					if("toxin")
						M.toxloss++
					if("oxygen")
						M.oxyloss++
					if("fire")
						M.fireloss++
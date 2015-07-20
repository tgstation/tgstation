/mob/living/simple_animal/corgi/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Corgi"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/simple_animal/corgi/verb/chasetail()  called tick#: [world.time]")
	src << text("[pick("You dance around","You chase your tail")].")
	for(var/mob/O in oviewers(src, null))
		if ((O.client && !( O.blinded )))
			O << text("[] [pick("dances around","chases its tail")].", src)
	for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
		dir = i
		sleep(1)

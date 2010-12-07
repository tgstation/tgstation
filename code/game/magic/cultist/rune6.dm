/obj/rune/proc/drain()
	var/drain = 0
	for(var/obj/rune/R in world)
		if(R.word1==wordtravel && R.word2==wordblood && R.word3==wordself)
			for(var/mob/living/carbon/D in R.loc)
				if(D.health>=-100)
					var/bdrain = rand(1,25)
					D << "\red You feel weakened."
					D.bruteloss += bdrain
					drain += bdrain
	if(!drain)
		return fizzle()
	usr.say ("Yu'gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	usr << "\red The blood starts flowing from the rune and into your frail mortal body. You feel... empowered."
	for (var/mob/V in viewers(src))
		if(V!=usr)
			V.show_message("\red Blood flows from the rune into [usr]!", 3, "\red You hear a liquid flowing.", 2)
	if(usr.bhunger)
		usr.bhunger -= 2*drain
	if(drain>=50)
		usr << "\red ...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within."
		usr.bhunger += drain
		for (,usr.bhunger,usr.bhunger--)
			sleep(50)
			usr.bruteloss += 3
	usr.bruteloss -= drain
	return

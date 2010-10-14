/obj/rune/proc/manifest()
	if(usr.loc==src.loc)
		for(var/mob/dead/observer/O in src.loc)
			usr.say("Gal'h'rfikk harfrandid mud'gib!")
			var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(src.loc)
			for (var/mob/V in viewers(D))
				V.show_message("\red A shape forms in the center of the rune. A shape of... a man.", 3, "", 2)
			D.real_name = "Unknown"
			for(var/obj/item/weapon/paper/P in src.loc)
				if(length(P.info)<=24)
					D.real_name = P.info
			D.universal_speak = 1
			D.nodamage = 0
			D.key = O.key
			del(O)
			for(,usr.loc==src.loc)
				sleep(30)
				if(usr.health>-100)
					usr.bruteloss++
				else
					break
			D.gib(1)
			for (var/mob/V in viewers(D))
				V.show_message("\red [D] explodes in a pile of gore.", 3, "\red \b SPLORCH", 2)
			return
	return fizzle()
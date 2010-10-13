/obj/rune/proc/ajourney() //some bits copypastaed from admin tools - Urist
	if(usr.loc==src.loc)
		var/mob/living/carbon/human/L = usr
		usr.say("Fwe'sh mah erl nyag r'ya!")
		usr.ghostize()
		usr << "\red The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this it's a great sight, being here strains your mind and body. Hurry."
		for (var/mob/V in viewers(src))
			V.show_message("\red [usr]'s eyes glow blue as \he freezes in place, absolutely motionless.", 3, "\red You hear only complete silence for a moment.", 2)
		for(L.ajourn=1,L.ajourn)
			sleep(10)
			if(L.key)
				L.ajourn=0
				return
			else
				L.bruteloss++
	return fizzle()
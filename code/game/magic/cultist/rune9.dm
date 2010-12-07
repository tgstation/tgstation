/obj/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/rune/R in orange(rad,src))
		if(R!=src)
			R.visibility=0
		S=1
	if(S)
		if(istype(src,/obj/rune))
			usr.say("Kla'atu barada nikt'o!")
			for (var/mob/V in viewers(src))
				V.show_message("\red The rune turns into gray dust, veiling the surrounding runes.", 3)
			del(src)
		else
			usr.whisper("Kla'atu barada nikt'o!")
			usr << "\red Your talisman turns into gray dust, veiling the surrounding runes."
			for (var/mob/V in viewers(src))
				if(V!=usr)
					V.show_message("\red Dust emanates from [usr]'s hands for a moment.", 3)

		return
	if(istype(src,/obj/rune))
		return	fizzle()
	else
		call(/obj/rune/proc/fizzle)()
		return
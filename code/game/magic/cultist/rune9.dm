/obj/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/rune/R in orange(rad,src))
		if(R!=src)
			R.visibility=0
		S=1
	if(S)
		if(istype(src,/obj/rune))
			usr.say("Kla'atu barada nikt'o!")
		else
			usr.whisper("Kla'atu barada nikt'o!")
		return
	if(istype(src,/obj/rune))
		return	fizzle()
	else
		call(/obj/rune/proc/fizzle)()
		return
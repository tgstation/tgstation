/obj/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/rune/R in orange(rad,src))
		if(R!=src)
			R.visibility=0
		S=1
	if(S)
		usr.say("Kla'atu barada nikt'o!")
		return
	if(istype(src,/obj/rune))
		return	fizzle()
	else
		call(/obj/rune/proc/fizzle)()
		return
/obj/rune/proc/revealrunes(var/obj/W as obj)
	var/go=0
	var/rad
	var/S=0
	if(istype(W,/obj/rune))
		rad = 6
		go = 1
	if (istype(W,/obj/item/weapon/paper/talisman))
		rad = 4
		go = 1
	if (istype(W,/obj/item/weapon/storage/bible))
		rad = 1
		go = 1
	if(go)
		for(var/obj/rune/R in orange(rad,src))
			if(R!=src)
				R.visibility=15
			S=1
	if(S)
		if(istype(W,/obj/item/weapon/storage/bible))
			usr << "\red Arcane markings suddenly glow from underneath a thin layer of dust!"
			return
		if(istype(W,/obj/rune))
			usr.say("Nikt'o barada kla'atu!")
			for (var/mob/V in viewers(src))
				V.show_message("\red The rune turns into red dust, reveaing the surrounding runes.", 3)
			del(src)
			return
		if(istype(W,/obj/item/weapon/paper/talisman))
			usr.whisper("Nikt'o barada kla'atu!")
			usr << "\red Your talisman turns into red dust, revealing the surrounding runes."
			for (var/mob/V in orange(1,usr.loc))
				if(V!=usr)
					V.show_message("\red Red dust emanates from [usr]'s hands for a moment.", 3)
			return
		return
	if(istype(W,/obj/rune))
		return	fizzle()
	if(istype(W,/obj/item/weapon/paper/talisman))
		call(/obj/rune/proc/fizzle)()
		return
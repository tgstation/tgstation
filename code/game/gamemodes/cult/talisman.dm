/obj/item/weapon/paper/talisman
	icon_state = "paper_talisman"
	var/imbue = null
	var/uses = 0
	var/nullblock = 0

/obj/item/weapon/paper/talisman/proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.nullding()
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0


/obj/item/weapon/paper/talisman/examine()
	set src in view(2)
	..()
	return

/obj/item/weapon/paper/talisman/New()
	..()
	pixel_x=0
	pixel_y=0


/obj/item/weapon/paper/talisman/attack_self(mob/living/user as mob)
	if(iscultist(user))
		var/delete = 1
		switch(imbue)
			if("newtome")
				call(/obj/effect/rune/proc/tomesummon)()
			if("armor") //Fuck off with your shit /tg/. This isn't Edgy Rev+
				call(/obj/effect/rune/proc/armor)()
			if("emp")
				call(/obj/effect/rune/proc/emp)(usr.loc,3)
			if("conceal")
				call(/obj/effect/rune/proc/obscure)(2)
			if("revealrunes")
				call(/obj/effect/rune/proc/revealrunes)(src)
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				var/turf/T1 = get_turf(user)
				call(/obj/effect/rune/proc/teleport)(imbue)
				var/turf/T2 = get_turf(user)
				if(T1!=T2)
					T1.invocanimation("rune_teleport")
			if("communicate")
				//If the user cancels the talisman this var will be set to 0
				delete = call(/obj/effect/rune/proc/communicate)()
			if("deafen")
				deafen()
				del(src)
			if("blind")
				blind()
				del(src)
			if("runestun")
				user << "\red To use this talisman, attack your target directly."
				return
			if("supply")
				supply()
		user.take_organ_damage(5, 0)
		if(src && src.imbue!="supply" && src.imbue!="runestun")
			if(delete)
				del(src)
		return
	else
		user << "You see strange symbols on the paper. Are they supposed to mean something?"
		return


/obj/item/weapon/paper/talisman/attack(mob/living/carbon/T as mob, mob/living/user as mob)
	if(iscultist(user))
		if(imbue == "runestun")
			user.take_organ_damage(5, 0)
			runestun(T)
			del(src)
		else
			..()   ///If its some other talisman, use the generic attack code, is this supposed to work this way?
	else
		..()

/obj/item/weapon/paper/talisman/attack_animal(var/mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/construct/harvester))
		attack_self(M)

/obj/item/weapon/paper/talisman/proc/supply(var/key)
	if (!src.uses)
		del(src)
		return

	var/dat = {"<B>There are [src.uses] bloody runes on the parchment.</B>
<BR>Please choose the chant to be imbued into the fabric of reality.<BR>
<HR>
<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon a new arcane tome.<BR>
<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>
<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>
<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor.<BR>
<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult.<BR>
<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>
<A href='?src=\ref[src];rune=soulstone'>Kal om neth</A> - Summons a soul stone<BR>
<A href='?src=\ref[src];rune=construct'>Da A'ig Osk</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"}
//<A href='?src=\ref[src];rune=armor'>Sa tatha najin</A> - Allows you to summon armoured robes and an unholy blade<BR> //Kept for reference
	// END AUTOFIX
	usr << browse(dat, "window=id_com;size=350x200")
	return


/obj/item/weapon/paper/talisman/Topic(href, href_list)
	if(!src)	return
	if (usr.stat || usr.restrained() || !in_range(src, usr))	return

	if (href_list["rune"])
		switch(href_list["rune"])
			if("newtome")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "newtome"
			if("teleport")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")
				T.imbue = input("Write your teleport destination rune:", "Rune Scribing") in words
			if("emp")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "emp"
			if("conceal")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "conceal"
			if("communicate")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "communicate"
			if("runestun")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "runestun"
			//if("armor")
				//var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				//T.imbue = "armor"
			if("soulstone")
				new /obj/item/device/soulstone(get_turf(usr))
			if("construct")
				new /obj/structure/constructshell/cult(get_turf(usr))
		src.uses--
		supply()
	return


/obj/item/weapon/paper/talisman/supply
	imbue = "supply"
	uses = 5


//imbued talismans invocation for a few runes, since calling the proc causes a runtime error due to src = null
/obj/item/weapon/paper/talisman/proc/runestun(var/mob/living/T as mob)//When invoked as talisman, stun and mute the target mob.
	usr.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
	nullblock = 0
	for(var/turf/TU in range(T,1))
		findNullRod(TU)
	if(nullblock)
		usr.visible_message("<span class='danger'>[usr] invokes a talisman at [T], but they are unaffected!</span>")
	else
		usr.visible_message("<span class='danger'>[usr] invokes a talisman at [T]</span>")

		if(issilicon(T))
			T.Weaken(15)

		else if(iscarbon(T))
			var/mob/living/carbon/C = T
			flick("e_flash", C.flash)
			if (!(M_HULK in C.mutations))
				C.silent += 15
			C.Weaken(25)
			C.Stun(25)
	return

/obj/item/weapon/paper/talisman/proc/blind()
	var/affected = 0
	for(var/mob/living/carbon/C in view(2,usr))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.eye_blurry += 30
		C.eye_blind += 10
		//talismans is weaker.
		affected++
		C << "<span class='warning'>You feel a sharp pain in your eyes, and the world disappears into darkness..</span>"
	if(affected)
		usr.whisper("Sti[pick("'","`")] kaliesin!")
		usr << "<span class='warning'>Your talisman turns into gray dust, blinding those who not follow the Nar-Sie.</span>"


/obj/item/weapon/paper/talisman/proc/deafen()
	var/affected = 0
	for(var/mob/living/carbon/C in range(7,usr))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.ear_deaf += 30
		//talismans is weaker.
		C.show_message("\<span class='warning'>The world around you suddenly becomes quiet.</span>", 3)
		affected++
	if(affected)
		usr.whisper("Sti[pick("'","`")] kaliedir!")
		usr << "<span class='warning'>Your talisman turns into gray dust, deafening everyone around.</span>"
		for (var/mob/V in orange(1,src))
			if(!(iscultist(V)))
				V.show_message("<span class='warning'>Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..</span>", 3)
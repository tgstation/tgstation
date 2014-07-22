/obj/item/weapon/storage/book
	name = "hollowed book"
	desc = "I guess someone didn't like it."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/title = "book"
	hitsound = "punch"

/obj/item/weapon/storage/book/attack_self(mob/user)
		user << "<span class='notice'>The pages of [title] have been cut out!</span>"

/obj/item/weapon/storage/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage.dmi'
	icon_state ="bible"
	var/mob/affecting = null
	
	var/global/current_user

	var/global/religion_name
	var/global/deity_name
	var/global/bible_name
	var/global/bible_icon_state
	var/global/bible_item_state

	//Pretty bible names
	var/global/list/biblenames =		list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light", "The God Delusion", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon")

	//Bible iconstates
	var/global/list/biblestates =		list("bible", "koran", "scrapbook", "burning", "honk1", "honk2", "creeper", "white", "holylight", "atheist", "tome", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon")

	//Bible itemstates
	var/global/list/bibleitemstates =	list("bible", "koran", "scrapbook", "bible", "bible", "bible", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon")

/obj/item/weapon/storage/book/bible/New()
	..()
	setup_name_icon()

/obj/item/weapon/storage/book/bible/proc/setup_name_icon(var/mob/living/carbon/human/H)
	if(bible_name && bible_icon_state && bible_item_state)
		if(H && src.name != bible_name)
			H << "\red The book glows in your hands."

		src.name = bible_name
		src.icon_state = bible_icon_state
		src.item_state = bible_item_state
		if(bible_icon_state == "honk1")
			hitsound = 'sound/items/bikehorn.ogg'
	else
		src.name = "Choose Your Own Religion"

/obj/item/weapon/storage/book/bible/attack_self(mob/user)
	if(!istype(user, /mob/living/carbon/human))
		return
	
	var/mob/living/carbon/human/H = user

	if(!H)
		return //How?!
	
	var/default_religion_name = "Christianity"

	if(!H.mind && (H.mind.assigned_role == "Chaplain"))
		H << "\red The book sizzles in your hands."
		H.take_organ_damage(0,10)
		return

	if(!religion_name)	
		//Prevent input box spam.
			
		// Hacks. Abusing a login event to prevent spammed text boxes
		if(current_user == H.hud_used)
			return
		current_user = H.hud_used

		var/new_religion = copytext(sanitize(input(H, "You are the Chaplain. Would you like to change your religion? Default is Christianity, in SPACE.", "Name change", default_religion_name)),1,MAX_NAME_LEN)

		current_user = null

		if(!H)
			return

		// Additional checks against setting values more than once
		if(!religion_name)
			religion_name = new_religion ? new_religion : default_religion_name
			
			switch(lowertext(religion_name))
				if("christianity")
					bible_name = pick("The Holy Bible","The Dead Sea Scrolls")
				if("satanism")
					bible_name = "The Unholy Bible"
				if("cthulu")
					bible_name = "The Necronomicon"
				if("islam")
					bible_name = "Quran"
				if("scientology")
					bible_name = pick("The Biography of L. Ron Hubbard","Dianetics")
				if("chaos")
					bible_name = "The Book of Lorgar"
				if("imperium")
					bible_name = "Uplifting Primer"
				if("toolboxia")
					bible_name = "Toolbox Manifesto"
				if("homosexuality")
					bible_name = "Guys Gone Wild"
				if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks")
					bible_name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition")
					H.setBrainLoss(100) // starts off retarded as fuck
				if("science")
					bible_name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
				else
					bible_name = "The Holy Book of [religion_name]"

			feedback_set_details("religion_name","[religion_name]")

	if(!deity_name)
		var/default_deity_name = "Space Jesus"
					
		// Hacks. Abusing a login event to prevent spammed text boxes
		if(current_user == H.hud_used)
			return
		current_user = H.hud_used

		var/new_deity = copytext(sanitize(input(H, "Would you like to change your deity? Default is Space Jesus.", "Name change", default_deity_name)),1,MAX_NAME_LEN)
		
		current_user = null

		// User could be gone
		if(!H)
			return		
		
		// Additional checks against setting values more than once
		if(!deity_name)
			deity_name = new_deity ? new_deity : default_deity_name

		feedback_set_details("religion_deity","[deity_name]")

	if(!bible_icon_state)

		// Hacks. Abusing a login event to prevent spammed web pages
		if(current_user == H.hud_used)
			return
		current_user = H.hud_used

		//Open bible selection
		var/dat = "<html><head><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"

		var/i
		for(i = 1, i < biblestates.len, i++)
			var/icon/bibleicon = icon('icons/obj/storage.dmi', biblestates[i])

			var/nicename = biblenames[i]
			H << browse_rsc(bibleicon, nicename)
			dat += {"<tr><td><img src="[nicename]"></td><td><a href="?src=\ref[src];seticon=[i];bible=\ref[src]">[nicename]</a></td></tr>"}

		dat += "</table></body></html>"

		H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")

/obj/item/weapon/storage/book/bible/Topic(href, href_list)
	//JUST A NOTE: IF YOU GET GIBBED WITH THIS OPEN IT WONT EVER GO AWAY :D
	if(href_list["seticon"])
		current_user = null

		if(!bible_icon_state)
			var/iconi = text2num(href_list["seticon"])

			var/biblename = biblenames[iconi]
			feedback_set_details("religion_book","[biblename]")
			
			bible_icon_state = biblestates[iconi]
			bible_item_state = bibleitemstates[iconi]
			
			setup_name_icon(usr)

			//Set biblespecific chapels
			setupbiblespecifics(usr)

		usr << browse(null, "window=editicon") // Close window

/obj/item/weapon/storage/book/bible/proc/setupbiblespecifics(var/mob/living/carbon/human/H)
	if(!H)
		return

	switch(icon_state)
		if("honk1","honk2")
			new /obj/item/weapon/grown/bananapeel(src)
			new /obj/item/weapon/grown/bananapeel(src)

			if(icon_state == "honk1")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)

		if("bible")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 2
		if("koran")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 4
		if("scientology")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 8
		if("athiest")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 10

/obj/item/weapon/storage/book/bible/attack(mob/living/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1

	add_logs(user, M, "attacked", object="[src.name]")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return

	if(!chaplain)
		user << "\red The book sizzles in your hands."
		user.take_organ_damage(0,10)
		return

	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if(M.mind && (M.mind.assigned_role == "Chaplain"))
			user << "\red You can't heal yourself!"
			return
		/*if((M.mind in ticker.mode.cult) && (prob(20)))
			M << "\red The power of [src.deity_name] clears your mind of heresy!"
			user << "\red You see how [M]'s eyes become clear, the cult no longer holds control over him!"
			ticker.mode.remove_cultist(M.mind)*/
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/message_halt = 0
				for(var/obj/item/organ/limb/affecting in H.organs)
					if(affecting.status == ORGAN_ORGANIC)
						if(message_halt == 0)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] heals [] with the power of [src.deity_name]!</B>", user, M), 1)
							M << "\red May the power of [src.deity_name] compel you to be healed!"
							playsound(src.loc, hitsound, 25, 1, -1)
							message_halt = 1
					else
						src << "<span class='warning'>[src.deity_name] refuses to heal this metallic taint!</span>"
						return
		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				M << "\red You feel dumber."
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] beats [] over the head with []!</B>", user, M, src), 1)
			playsound(src.loc, hitsound, 25, 1, -1)

	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] smacks []'s lifeless corpse with [].</B>", user, M, src), 1)
		playsound(src.loc, hitsound, 25, 1, -1)
	return

/obj/item/weapon/storage/book/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/obj/item/organ/limb/affecting in H.organs)
			if(affecting.status == ORGAN_ORGANIC) //No Bible can heal a robotic arm!
				if(affecting.heal_damage(heal_amt, heal_amt, 0))
					H.update_damage_overlays(0)
	return

/obj/item/weapon/storage/book/bible/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(A, /turf/simulated/floor))
		user << "\blue You hit the floor with the bible."
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			user << "\blue You bless [A]."
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)
			return
		if(A.reagents && A.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
			user << "\blue You purify [A]."
			var/unholy2clean = A.reagents.get_reagent_amount("unholywater")
			A.reagents.del_reagent("unholywater")
			A.reagents.add_reagent("cleaner",unholy2clean)		//it cleans their soul, get it? I'll get my coat...
			return

/obj/item/weapon/storage/book/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	..()

	/obj/item/weapon/storage/book/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/book/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
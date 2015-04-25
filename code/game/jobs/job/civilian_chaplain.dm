//Due to how large this one is it gets its own file
/*
Chaplain
*/
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	default_pda = /obj/item/device/pda/chaplain

	access = list(access_morgue, access_chapel_office, access_crematorium)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)

	//Pretty bible names
	var/global/list/biblenames =		list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light", "The God Delusion", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon")

	//Bible iconstates
	var/global/list/biblestates =		list("bible", "koran", "scrapbook", "burning", "honk1", "honk2", "creeper", "white", "holylight", "atheist", "tome", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon")

	//Bible itemstates
	var/global/list/bibleitemstates =	list("bible", "koran", "scrapbook", "bible", "bible", "bible", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon")

/datum/job/chaplain/proc/setupbiblespecifics(var/obj/item/weapon/storage/book/bible/B, var/mob/living/carbon/human/H)
	switch(B.icon_state)
		if("honk1","honk2")
			new /obj/item/weapon/grown/bananapeel(B)
			new /obj/item/weapon/grown/bananapeel(B)

			if(B.icon_state == "honk1")
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

/datum/job/chaplain/Topic(href, href_list)
	if(href_list["seticon"])
		var/iconi = text2num(href_list["seticon"])

		var/biblename = biblenames[iconi]
		var/obj/item/weapon/storage/book/bible/B = locate(href_list["bible"])

		B.icon_state = biblestates[iconi]
		B.item_state = bibleitemstates[iconi]

		//Set biblespecific chapels
		setupbiblespecifics(B, usr)

		usr.put_in_hands(B) // Update inhand icon

		if(ticker)
			ticker.Bible_icon_state = B.icon_state
			ticker.Bible_item_state = B.item_state
			ticker.Bible_name = B.name
		feedback_set_details("religion_book","[biblename]")

		usr << browse(null, "window=editicon") // Close window

/datum/job/chaplain/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)

	var/obj/item/weapon/storage/book/bible/B = new /obj/item/weapon/storage/book/bible/booze(H)
	var/new_religion = "Christianity"
	if(H.client && H.client.prefs.custom_names["religion"])
		new_religion = H.client.prefs.custom_names["religion"]

	switch(lowertext(new_religion))
		if("christianity")
			B.name = pick("The Holy Bible","The Dead Sea Scrolls")
		if("satanism")
			B.name = "The Unholy Bible"
		if("cthulu")
			B.name = "The Necronomicon"
		if("islam")
			B.name = "Quran"
		if("scientology")
			B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
		if("chaos")
			B.name = "The Book of Lorgar"
		if("imperium")
			B.name = "Uplifting Primer"
		if("toolboxia")
			B.name = "Toolbox Manifesto"
		if("homosexuality")
			B.name = "Guys Gone Wild"
		if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks")
			B.name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition")
			H.setBrainLoss(100) // starts off retarded as fuck
		if("science")
			B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		else
			B.name = "The Holy Book of [new_religion]"
	feedback_set_details("religion_name","[new_religion]")

	var/new_deity = "Space Jesus"
	if(H.client && H.client.prefs.custom_names["deity"])
		new_deity = H.client.prefs.custom_names["deity"]
	B.deity_name = new_deity

	if(ticker)
		ticker.Bible_deity_name = B.deity_name
	feedback_set_details("religion_deity","[new_deity]")

	//Open bible selection
	var/dat = "<html><head><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"

	var/i
	for(i = 1, i < biblestates.len, i++)
		var/icon/bibleicon = icon('icons/obj/storage.dmi', biblestates[i])

		var/nicename = biblenames[i]
		H << browse_rsc(bibleicon, nicename)
		dat += {"<tr><td><img src="[nicename]"></td><td><a href="?src=\ref[src];seticon=[i];bible=\ref[B]">[nicename]</a></td></tr>"}

	dat += "</table></body></html>"

	H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")
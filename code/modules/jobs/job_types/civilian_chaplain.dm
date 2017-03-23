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

	outfit = /datum/outfit/job/chaplain

	access = list(access_morgue, access_chapel_office, access_crematorium, access_theatre)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium, access_theatre)

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	belt = /obj/item/device/pda/chaplain
	uniform = /obj/item/clothing/under/rank/chaplain
	backpack_contents = list(/obj/item/device/camera/spooky = 1)
	backpack = /obj/item/weapon/storage/backpack/cultpack
	satchel = /obj/item/weapon/storage/backpack/cultpack


/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.isholy = TRUE

	var/obj/item/weapon/storage/book/bible/B = new /obj/item/weapon/storage/book/bible/booze(H)

	if(SSreligion.Bible_deity_name)
		B.deity_name = SSreligion.Bible_deity_name
		B.name = SSreligion.Bible_name
		B.icon_state = SSreligion.Bible_icon_state
		B.item_state = SSreligion.Bible_item_state
		to_chat(H, "There is already an established religion onboard the station. You are an acolyte of [SSreligion.Bible_deity_name]. Defer to the Chaplain.")
		H.equip_to_slot_or_del(B, slot_in_backpack)
		var/obj/item/weapon/nullrod/N = new(H)
		H.equip_to_slot_or_del(N, slot_in_backpack)
		return

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
		if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks", "meme", "memes")
			B.name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition")
			H.setBrainLoss(100) // starts off retarded as fuck
		if("science")
			B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		else
			B.name = "The Holy Book of [new_religion]"
	feedback_set_details("religion_name","[new_religion]")
	SSreligion.Bible_name = B.name

	var/new_deity = "Space Jesus"
	if(H.client && H.client.prefs.custom_names["deity"])
		new_deity = H.client.prefs.custom_names["deity"]
	B.deity_name = new_deity

	SSreligion.Bible_deity_name = B.deity_name
	feedback_set_details("religion_deity","[new_deity]")
	H.equip_to_slot_or_del(B, slot_in_backpack)

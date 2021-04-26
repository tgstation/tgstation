/datum/job/chaplain
	title = "Chaplain"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/chaplain
	plasmaman_outfit = /datum/outfit/plasmaman/chaplain

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_CHAPLAIN
	departments = DEPARTMENT_SERVICE

	family_heirlooms = list(/obj/item/toy/windup_toolbox, /obj/item/reagent_containers/food/drinks/bottle/holywater)

	mail_goodies = list(
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 30,
		/obj/item/toy/plush/awakenedplushie = 10,
		/obj/item/grenade/chem_grenade/holy = 5,
		/obj/item/toy/plush/narplush = 2,
		/obj/item/toy/plush/ratplush = 1
	)

/datum/job/chaplain/after_spawn(mob/living/H, mob/M)
	. = ..()

	var/obj/item/storage/book/bible/booze/B = new

	if(GLOB.religion)
		if(H.mind)
			H.mind.holy_role = HOLY_ROLE_PRIEST
		B.deity_name = GLOB.deity
		B.name = GLOB.bible_name
		// These checks are important as there's no guarantee the "HOLY_ROLE_HIGHPRIEST" chaplain has selected a bible skin.
		if(GLOB.bible_icon_state)
			B.icon_state = GLOB.bible_icon_state
		if(GLOB.bible_inhand_icon_state)
			B.inhand_icon_state = GLOB.bible_inhand_icon_state
		to_chat(H, "<span class='boldnotice'>There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.</span>")
		H.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)
		var/nrt = GLOB.holy_weapon_type || /obj/item/nullrod
		var/obj/item/nullrod/N = new nrt(H)
		H.put_in_hands(N)
		if(GLOB.religious_sect)
			GLOB.religious_sect.on_conversion(H)
		return
	if(H.mind)
		H.mind.holy_role = HOLY_ROLE_HIGHPRIEST

	var/new_religion = DEFAULT_RELIGION
	if(M.client && M.client.prefs.custom_names["religion"])
		new_religion = M.client.prefs.custom_names["religion"]

	var/new_deity = DEFAULT_DEITY
	if(M.client && M.client.prefs.custom_names["deity"])
		new_deity = M.client.prefs.custom_names["deity"]

	B.deity_name = new_deity

	var/new_bible = DEFAULT_BIBLE
	if(M.client && M.client.prefs.custom_names["bible"])
		new_bible = M.client.prefs.custom_names["bible"]

	switch(lowertext(new_religion))
		if("christianity") // DEFAULT_RELIGION
			new_bible = pick("The Holy Bible","The Dead Sea Scrolls")
		if("buddhism")
			new_bible = "The Sutras"
		if("clownism","honkmother","honk","honkism","comedy")
			new_bible = pick("The Holy Joke Book", "Just a Prank", "Hymns to the Honkmother")
		if("chaos")
			new_bible = "The Book of Lorgar"
		if("cthulhu")
			new_bible = "The Necronomicon"
		if("hinduism")
			new_bible = "The Vedas"
		if("homosexuality")
			new_bible = pick("Guys Gone Wild","Coming Out of The Closet")
		if("imperium")
			new_bible = "Uplifting Primer"
		if("islam")
			new_bible = "Quran"
		if("judaism")
			new_bible = "The Torah"
		if("lampism")
			new_bible = "Fluorescent Incandescence"
		if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks", "meme", "memes")
			new_bible = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition","F.A.T.A.L. Rulebook")
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100) // starts off brain damaged as fuck
		if("monkeyism","apism","gorillism","primatism")
			new_bible = pick("Going Bananas", "Bananas Out For Harambe")
		if("mormonism")
			new_bible = "The Book of Mormon"
		if("pastafarianism")
			new_bible = "The Gospel of the Flying Spaghetti Monster"
		if("rastafarianism","rasta")
			new_bible = "The Holy Piby"
		if("satanism")
			new_bible = "The Unholy Bible"
		if("sikhism")
			new_bible = "Guru Granth Sahib"
		if("science")
			new_bible = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		if("scientology")
			new_bible = pick("The Biography of L. Ron Hubbard","Dianetics")
		if("servicianism", "partying")
			new_bible = "The Tenets of Servicia"
			B.deity_name = pick("Servicia", "Space Bacchus", "Space Dionysus")
			B.desc = "Happy, Full, Clean. Live it and give it."
		if("subgenius")
			new_bible = "Book of the SubGenius"
		if("toolboxia","greytide")
			new_bible = pick("Toolbox Manifesto","iGlove Assistants")
		if("weeaboo","kawaii")
			new_bible = pick("Fanfiction Compendium","Japanese for Dummies","The Manganomicon","Establishing Your O.T.P")
		else
			if(new_bible == DEFAULT_BIBLE)
				new_bible = "The Holy Book of [new_religion]"

	B.name = new_bible

	GLOB.religion = new_religion
	GLOB.bible_name = new_bible
	GLOB.deity = B.deity_name

	H.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)

	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)
	SSblackbox.record_feedback("text", "religion_bible", 1, "[new_bible]", 1)

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	belt = /obj/item/pda/chaplain
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	backpack_contents = list(
		/obj/item/stamp/chap = 1,
		/obj/item/camera/spooky = 1
		)

	skillchips = list(/obj/item/skillchip/entrails_reader)

	backpack = /obj/item/storage/backpack/cultpack
	satchel = /obj/item/storage/backpack/cultpack

	chameleon_extras = /obj/item/stamp/chap

	id_trim = /datum/id_trim/job/chaplain

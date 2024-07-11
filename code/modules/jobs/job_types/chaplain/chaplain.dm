/datum/job/chaplain
	title = JOB_CHAPLAIN
	description = "Hold services and funerals, cremate people, preach your \
		religion, protect the crew against cults."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CHAPLAIN"

	outfit = /datum/outfit/job/chaplain
	plasmaman_outfit = /datum/outfit/plasmaman/chaplain

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_CHAPLAIN
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/toy/windup_toolbox, /obj/item/reagent_containers/cup/glass/bottle/holywater)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 30,
		/obj/item/grenade/chem_grenade/holy = 5,
		/obj/item/toy/plush/narplush = 2,
		/obj/item/toy/plush/ratplush = 1
	)
	rpg_title = "Paladin"
	job_flags = STATION_JOB_FLAGS

	voice_of_god_power = 2 //Chaplains are very good at speaking with the voice of god

	job_tone = "holy"


/datum/job/chaplain/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/human_spawned = spawned
	var/obj/item/book/bible/booze/holy_bible = new
	if(GLOB.religion)
		if(human_spawned.mind)
			human_spawned.mind.holy_role = HOLY_ROLE_PRIEST
		holy_bible.deity_name = GLOB.deity
		holy_bible.name = GLOB.bible_name
		// These checks are important as there's no guarantee the "HOLY_ROLE_HIGHPRIEST" chaplain has selected a bible skin.
		if(GLOB.bible_icon_state)
			holy_bible.icon_state = GLOB.bible_icon_state
		if(GLOB.bible_inhand_icon_state)
			holy_bible.inhand_icon_state = GLOB.bible_inhand_icon_state
		to_chat(human_spawned, span_boldnotice("There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain."))
		human_spawned.equip_to_slot_or_del(holy_bible, ITEM_SLOT_BACKPACK, indirect_action = TRUE)
		var/nrt = GLOB.holy_weapon_type || /obj/item/nullrod
		var/obj/item/nullrod/nullrod = new nrt(human_spawned)
		human_spawned.put_in_hands(nullrod)
		if(GLOB.religious_sect)
			GLOB.religious_sect.on_conversion(human_spawned)
		return
	if(human_spawned.mind)
		human_spawned.mind.holy_role = HOLY_ROLE_HIGHPRIEST

	var/new_religion = player_client?.prefs?.read_preference(/datum/preference/name/religion) || DEFAULT_RELIGION
	var/new_deity = player_client?.prefs?.read_preference(/datum/preference/name/deity) || DEFAULT_DEITY
	var/new_bible = player_client?.prefs?.read_preference(/datum/preference/name/bible) || DEFAULT_BIBLE

	holy_bible.deity_name = new_deity
	switch(LOWER_TEXT(new_religion))
		if("homosexuality", "gay", "penis", "ass", "cock", "cocks")
			new_bible = pick("Guys Gone Wild","Coming Out of The Closet","War of Cocks")
			switch(new_bible)
				if("War of Cocks")
					holy_bible.deity_name = pick("Dick Powers", "King Cock")
				else
					holy_bible.deity_name = pick("Gay Space Jesus", "Gandalf", "Dumbledore")
			human_spawned.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100) // starts off brain damaged as fuck
		if("lol", "wtf", "poo", "badmin", "shitmin", "deadmin", "meme", "memes", "skibidi")
			new_bible = pick("Woody's Got Wood: The Aftermath", "Sweet Bro and Hella Jeff: Expanded Edition","F.A.T.A.L. Rulebook", "Toilet Humor")
			switch(new_bible)
				if("Woody's Got Wood: The Aftermath")
					holy_bible.deity_name = pick("Woody", "Andy", "Cherry Flavored Lube")
				if("Sweet Bro and Hella Jeff: Expanded Edition")
					holy_bible.deity_name = pick("Sweet Bro", "Hella Jeff", "Stairs", "AH")
				if("F.A.T.A.L. Rulebook")
					holy_bible.deity_name = "Twenty Ten-Sided Dice"
				if("Toilet Humor")
					holy_bible.deity_name = pick("Skibidi Toilet", "Skibidi Wizard", "Skibidi Bathtub", "John Skibidi", "Skibidi Skibidi", "G-Toilet 1.0", "John Freeman")
			human_spawned.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100) // also starts off brain damaged as fuck
		if("servicianism", "partying")
			holy_bible.desc = "Happy, Full, Clean. Live it and give it."
		if("weeaboo","kawaii")
			new_bible = pick("Fanfiction Compendium","Japanese for Dummies","The Manganomicon","Establishing Your O.T.P")
			holy_bible.deity_name = "Anime"
		else
			if(new_bible == DEFAULT_BIBLE)
				new_bible = DEFAULT_BIBLE_REPLACE(new_bible)

	holy_bible.name = new_bible

	GLOB.religion = new_religion
	GLOB.bible_name = new_bible
	GLOB.deity = holy_bible.deity_name

	human_spawned.equip_to_slot_or_del(holy_bible, ITEM_SLOT_BACKPACK, indirect_action = TRUE)

	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)
	SSblackbox.record_feedback("text", "religion_bible", 1, "[new_bible]", 1)

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	id_trim = /datum/id_trim/job/chaplain
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	backpack_contents = list(
		/obj/item/camera/spooky = 1,
		/obj/item/stamp/chap = 1,
		)
	belt = /obj/item/modular_computer/pda/chaplain
	ears = /obj/item/radio/headset/headset_srv

	backpack = /obj/item/storage/backpack/cultpack
	satchel = /obj/item/storage/backpack/cultpack

	chameleon_extras = /obj/item/stamp/chap
	skillchips = list(/obj/item/skillchip/entrails_reader)

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
		if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks", "meme", "memes")
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100) // starts off brain damaged as fuck
		if("servicianism", "partying")
			B.desc = "Happy, Full, Clean. Live it and give it."

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

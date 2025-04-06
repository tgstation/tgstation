/datum/job/curator
	title = JOB_CURATOR
	description = "Read and write books and hand them to people, stock \
		bookshelves, report on station news."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	config_tag = "CURATOR"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/curator
	plasmaman_outfit = /datum/outfit/plasmaman/curator

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	mind_traits = list(TRAIT_TOWER_OF_BABEL)

	display_order = JOB_DISPLAY_ORDER_CURATOR
	departments_list = list(
		/datum/job_department/service,
		)

	mail_goodies = list(
		/obj/item/book/random = 44,
		/obj/item/book/manual/random = 5,
		/obj/item/book/granter/action/spell/blind/wgw = 1,
	)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/storage/dice)

	job_flags = STATION_JOB_FLAGS

	voice_of_god_silence_power = 3
	rpg_title = "Veteran Adventurer"

/datum/outfit/job/curator
	name = "Curator"
	jobtype = /datum/job/curator

	id_trim = /datum/id_trim/job/curator
	uniform = /obj/item/clothing/under/rank/civilian/curator
	backpack_contents = list(
		/obj/item/barcodescanner = 1,
		/obj/item/choice_beacon/hero = 1,
	)
	belt = /obj/item/modular_computer/pda/curator
	ears = /obj/item/radio/headset/headset_srvent
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/laser_pointer/green
	r_pocket = /obj/item/key/displaycase
	l_hand = /obj/item/storage/bag/books

	accessory = /obj/item/clothing/accessory/pocketprotector/full

/datum/outfit/job/curator/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return ..()

	/// There can be only one cameraman on this station, and no, not that kind
	var/static/cameraman_choosen = FALSE
	if(!cameraman_choosen)
		backpack_contents[/obj/item/broadcast_camera] = 1
		cameraman_choosen = TRUE
	return ..()


/datum/outfit/job/curator/post_equip(mob/living/carbon/human/translator, visuals_only = FALSE)
	..()

	if(visuals_only)
		return

	translator.grant_all_languages(source = LANGUAGE_CURATOR)
	translator.remove_blocked_language(GLOB.all_languages, source=LANGUAGE_ALL)

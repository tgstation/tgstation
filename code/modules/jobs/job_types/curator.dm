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

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

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
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/laser_pointer/green
	r_pocket = /obj/item/key/displaycase
	l_hand = /obj/item/storage/bag/books

	accessory = /obj/item/clothing/accessory/pocketprotector/full

/datum/outfit/job/curator/post_equip(mob/living/carbon/human/translator, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	translator.grant_all_languages(source=LANGUAGE_CURATOR)
	translator.remove_blocked_language(GLOB.all_languages, source=LANGUAGE_ALL)

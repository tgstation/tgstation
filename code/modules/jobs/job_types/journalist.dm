/datum/job/journalist
	title = JOB_JOURNALIST
	description = "Ünlü bir gazetecisin, Haber yaparak insanlara ve Centcom'a istasyonda ne olduğunu göster. Unutma, sözlerin altın değerinde, sen ne söylersen inanacaklar."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	selection_color = "#bbe291"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/journalist
	plasmaman_outfit = /datum/outfit/plasmaman/curator

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_CURATOR
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/storage/dice)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	voice_of_god_silence_power = 3
	rpg_title = "Veteran Adventurer"

/datum/outfit/job/journalist
	name = "Journalist"
	jobtype = /datum/job/journalist

	id_trim = /datum/id_trim/job/journalist
	uniform = /obj/item/clothing/under/rank/civilian/curator
	backpack_contents = list(
		/obj/item/announcer = 1,
		/obj/item/megaphone = 1,
	)
	belt = /obj/item/modular_computer/tablet/pda/curator
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/laser_pointer

	accessory = /obj/item/clothing/accessory/pocketprotector/full

/datum/outfit/job/journalist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_CURATOR)
	ADD_TRAIT(H, TRAIT_JOURNALIST, JOB_TRAIT)

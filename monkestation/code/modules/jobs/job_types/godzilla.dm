/datum/job/godzilla
	title = JOB_SPOOKTOBER_GODZILLA
	description = "Film a monster movie. Blend in with the lizards. Get arrested for roaring at the crew."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	supervisors = JOB_HEAD_OF_PERSONNEL
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/godzilla
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_LOWER
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	departments_list = list(
		 /datum/job_department/spooktober,
		)

	family_heirlooms = list(/obj/item/megaphone, /obj/item/clothing/head/lizard, /obj/item/clothing/suit/hooded/dinojammies)

	mail_goodies = list(
		/obj/item/megaphone,
		/obj/item/food/fried_blood_sausage,
		/obj/item/food/bread/root,
		/obj/item/food/lizard_fries
	)

	rpg_title = "Lizardman"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER

/datum/outfit/job/godzilla
	name = "Discount Godzilla"
	jobtype = /datum/job/godzilla

	head = /obj/item/clothing/head/lizard
	r_pocket = /obj/item/megaphone
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant

/datum/outfit/job/godzilla/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/dinojammies(H), ITEM_SLOT_OCLOTHING)

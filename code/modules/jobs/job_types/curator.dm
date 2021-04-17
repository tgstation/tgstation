/datum/job/curator
	title = "Curator"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/curator
	plasmaman_outfit = /datum/outfit/plasmaman/curator

	departments = DEPARTMENT_SERVICE
	display_order = JOB_DISPLAY_ORDER_CURATOR
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	family_heirlooms = list(
		/obj/item/pen/fountain,
		/obj/item/storage/pill_bottle/dice,
		)

/datum/outfit/job/curator
	name = "Curator"
	jobtype = /datum/job/curator

	id_trim = /datum/id_trim/job/curator
	uniform = /obj/item/clothing/under/rank/civilian/curator
	backpack_contents = list(
		/obj/item/barcodescanner = 1,
		/obj/item/choice_beacon/hero = 1,
		/obj/item/soapstone = 1,
	)
	belt = /obj/item/pda/curator
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/key/displaycase
	l_hand = /obj/item/storage/bag/books

	accessory = /obj/item/clothing/accessory/pocketprotector/full

/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_CURATOR)

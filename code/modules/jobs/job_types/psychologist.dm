/datum/job/psychologist
	title = "Psychologist"
	flag = PSYCHOLOGIST
	department_head = list("Head of Personnel","Chief Medical Officer")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel and the chief medical officer"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/psychologist

	access = list(ACCESS_MEDICAL, ACCESS_PSYCHOLOGY)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHOLOGY)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_PSYCHOLOGIST

/datum/outfit/job/psychologist
	name = "Psychologist"
	jobtype = /datum/job/psychologist

	ears = /obj/item/radio/headset/headset_srvmed
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id
	belt = /obj/item/pda/medical
	pda_slot = ITEM_SLOT_BELT
	l_hand = /obj/item/clipboard

	backpack_contents = list(/obj/item/storage/pill_bottle/mannitol, /obj/item/storage/pill_bottle/psicodine, /obj/item/storage/pill_bottle/paxpsych, /obj/item/storage/pill_bottle/happinesspsych, /obj/item/storage/pill_bottle/lsdpsych)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

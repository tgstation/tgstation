/datum/job/vip
	title = "Donator"
	flag = VIP
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 200
	spawn_positions = 200
	supervisors = "the gods"
	selection_color = "#FFD700"

	outfit = /datum/outfit/job/vip

	access = list(ACCESS_LIBRARY, ACCESS_CONSTRUCTION, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_CONSTRUCTION, ACCESS_MINING_STATION)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_CURATOR

/datum/outfit/job/vip
	name = "Donator"
	jobtype = /datum/job/vip
	box = /obj/item/storage/box/tournament/vip

	shoes = /obj/item/clothing/shoes/laceup
	belt = /obj/item/pda/curator
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/curator
	l_hand = /obj/item/storage/bag/books
	r_pocket = /obj/item/key/displaycase
	l_pocket = /obj/item/laser_pointer
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack_contents = list(/obj/item/choice_beacon/hero = 1, /obj/item/soapstone = 1, /obj/item/barcodescanner = 1)
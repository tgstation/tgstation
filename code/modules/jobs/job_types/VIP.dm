/datum/job/vip
	title = "Vip"
	flag = VIP
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 200
	spawn_positions = 200
	supervisors = "the gods"
	selection_color = "#ffd700"

	outfit = /datum/outfit/job/vip

	access = list(ACCESS_LIBRARY, ACCESS_CONSTRUCTION, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_CONSTRUCTION, ACCESS_MINING_STATION)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_VIP

/datum/outfit/job/vip
	name = "Donator"
	jobtype = /datum/job/vip
	box = /obj/item/storage/box/tournament/vip

	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowler
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/suit/black_really
	l_pocket = /obj/item/laser_pointer
	glasses = /obj/item/clothing/glasses/hud/health
	gloves = /obj/item/clothing/gloves/color/white

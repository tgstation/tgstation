/datum/job/head_of_service
	title = "Head of Service"
	flag = HOSER
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = CIVILIAN
	head_announce = list(RADIO_CHANNEL_SERVICE)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#bbe291"
	outfit = /datum/outfit/job/head_of_service

	access = list(ACCESS_HOSE, ACCESS_HYDROPONICS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE,
					ACCESS_MINERAL_STOREROOM, ACCESS_HEADS, ACCESS_JANITOR, ACCESS_THEATRE)
	minimal_access = list(ACCESS_KITCHEN, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE,
							ACCESS_MINERAL_STOREROOM, ACCESS_JANITOR, ACCESS_THEATRE)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_SERVICE

/datum/outfit/job/head_of_service
	name = "Head of Service"
	jobtype = /datum/job/head_of_service

	id = /obj/item/card/id/silver
	belt = /obj/item/pda/heads/hoser
	ears = /obj/item/radio/headset/heads/hoser
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/toggle/chef
	backpack_contents = list(/obj/item/sharpener = 1, /obj/item/kitchen/knife/combat/ezel = 1)

/datum/outfit/job/head_of_service/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	var/list/possible_boxes = subtypesof(/obj/item/storage/box/ingredients)
	var/chosen_box = pick(possible_boxes)
	var/obj/item/storage/box/I = new chosen_box(src)
	H.equip_to_slot_or_del(I,ITEM_SLOT_BACKPACK)
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H)

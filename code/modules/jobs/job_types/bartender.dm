/datum/job/bartender
	title = "Bartender"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/bartender
	plasmaman_outfit = /datum/outfit/plasmaman/bar

	bounty_types = CIV_JOB_DRINK
	departments = DEPARTMENT_SERVICE
	display_order = JOB_DISPLAY_ORDER_BARTENDER
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	family_heirlooms = list(
		/obj/item/clothing/head/that,
		/obj/item/reagent_containers/food/drinks/shaker,
		/obj/item/reagent_containers/glass/rag,
	)

	mail_goodies = list(
		/obj/item/storage/box/rubbershot = 30,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/datum/reagent/consumable/clownstears = 10,
	)

/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender

	id_trim = /datum/id_trim/job/bartender
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	backpack_contents = list(
		/obj/item/storage/box/beanbag = 1,
		)
	belt = /obj/item/pda/bar
	ears = /obj/item/radio/headset/headset_srv
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	var/obj/item/card/id/W = H.wear_id
	if(H.age < AGE_MINOR)
		W.registered_age = AGE_MINOR
		to_chat(H, "<span class='notice'>You're not technically old enough to access or serve alcohol, but your ID has been discreetly modified to display your age as [AGE_MINOR]. Try to keep that a secret!</span>")

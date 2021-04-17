/datum/job/lawyer
	title = "Lawyer"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	var/lawyers = 0 //Counts lawyer amount

	outfit = /datum/outfit/job/lawyer
	plasmaman_outfit = /datum/outfit/plasmaman/bar

	departments = DEPARTMENT_SERVICE
	display_order = JOB_DISPLAY_ORDER_LAWYER
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	family_heirlooms = list(
		/obj/item/book/manual/wiki/security_space_law,
		/obj/item/gavelhammer,
		)
	liver_traits = list(
		TRAIT_LAW_ENFORCEMENT_METABOLISM,
		)
	mind_traits = list(
		TRAIT_DONUT_LOVER,
		)

/datum/outfit/job/lawyer
	name = "Lawyer"
	jobtype = /datum/job/lawyer

	id_trim = /datum/id_trim/job/lawyer
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	suit = /obj/item/clothing/suit/toggle/lawyer
	belt = /obj/item/pda/lawyer
	ears = /obj/item/radio/headset/headset_srvsec
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	l_hand = /obj/item/storage/briefcase/lawyer

	chameleon_extras = /obj/item/stamp/law

/datum/outfit/job/lawyer/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return ..()

	var/static/use_purple_suit = FALSE //If there is one lawyer, they get the default blue suit. If another lawyer joins the round, they start with a purple suit.
	if(use_purple_suit)
		uniform = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit
		suit = /obj/item/clothing/suit/toggle/lawyer/purple
	else
		use_purple_suit = TRUE
	..()

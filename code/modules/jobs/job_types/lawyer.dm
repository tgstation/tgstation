/datum/job/lawyer
	title = "Lawyer"
	flag = LAWYER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	var/lawyers = 0 //Counts lawyer amount

	outfit = /datum/outfit/job/lawyer

	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_LAWYER

/datum/outfit/job/lawyer
	name = "Lawyer"
	jobtype = /datum/job/lawyer

	belt = /obj/item/pda/lawyer
	ears = /obj/item/radio/headset/headset_srvsec
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge

	chameleon_extras = /obj/item/stamp/law


/datum/outfit/job/lawyer/pre_equip(mob/living/carbon/human/H)
	..()
	//visuals only was fucking things up so now it's just this
	var/datum/job/lawyer/J = SSjob.GetJobType(jobtype)
	J.lawyers++
	if(J.lawyers>1)
		if(H.jumps == SUIT)
			uniform = /obj/item/clothing/under/lawyer/purpsuit
		else
			uniform = /obj/item/clothing/under/lawyer/purpsuit/skirt
			suit = /obj/item/clothing/suit/toggle/lawyer/purple
	else if(H.jumps == SUIT)
		uniform = /obj/item/clothing/under/lawyer/bluesuit
	else if(H.jumps == SKIRT)
		uniform = /obj/item/clothing/under/lawyer/bluesuit/skirt
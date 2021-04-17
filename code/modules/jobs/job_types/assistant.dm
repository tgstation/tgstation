/datum/job/assistant
	title = "Assistant"
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	antag_rep = 7

	outfit = /datum/outfit/job/assistant
	plasmaman_outfit = /datum/outfit/plasmaman

	departments = DEPARTMENT_SERVICE
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV

	family_heirlooms = list(
		/obj/item/clothing/gloves/cut/heirloom,
		/obj/item/storage/toolbox/mechanical/old/heirloom,
		)
	liver_traits = list(
		TRAIT_GREYTIDE_METABOLISM,
		)

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant

	id_trim = /datum/id_trim/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/grey
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/grey
	else
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/random

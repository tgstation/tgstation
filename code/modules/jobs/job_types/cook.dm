/datum/job/cook
	title = "Cook"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	var/cooks = 0 //Counts cooks amount
	/// List of areas that are counted as the kitchen for the purposes of CQC. Defaults to just the kitchen. Mapping configs can and should override this.
	var/list/kitchen_areas = list(/area/service/kitchen)

	outfit = /datum/outfit/job/cook

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	liver_traits = list(TRAIT_CULINARY_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_COOK
	bounty_types = CIV_JOB_CHEF
	departments = DEPARTMENT_SERVICE

	family_heirlooms = list(/obj/item/reagent_containers/food/condiment/saltshaker, /obj/item/kitchen/rollingpin, /obj/item/clothing/head/chefhat)

/datum/job/cook/New()
	. = ..()
	SSmapping.HACK_LoadMapConfig()
	var/list/job_changes = SSmapping.config.job_changes

	if(!length(job_changes))
		return

	var/list/cook_changes = job_changes["cook"]

	if(!length(cook_changes))
		return

	var/list/additional_cqc_areas = cook_changes["additional_cqc_areas"]

	if(!additional_cqc_areas)
		return

	if(!islist(additional_cqc_areas))
		stack_trace("Incorrect CQC area format from mapping configs. Expected /list, got: \[[additional_cqc_areas.type]\]")
		return

	for(var/path_as_text in additional_cqc_areas)
		var/path = text2path(path_as_text)
		if(!ispath(path, /area))
			stack_trace("Invalid path in mapping config for chef CQC: \[[path_as_text]\]")
			continue

		kitchen_areas |= path

/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	belt = /obj/item/pda/cook
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian
	backpack_contents = list(
		/obj/item/sharpener = 1,
		/obj/item/choice_beacon/ingredient = 1
	)
	skillchips = list(/obj/item/skillchip/job/chef)

	id_trim = /datum/id_trim/job/cook

/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/datum/job/cook/J = SSjob.GetJobType(jobtype)
	if(J) // Fix for runtime caused by invalid job being passed
		if(J.cooks>0)//Cooks
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft/mime
		if(!visualsOnly)
			J.cooks++

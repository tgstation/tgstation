/datum/job/cook
	title = JOB_COOK
	description = "Serve food, cook meat, keep the crew fed."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "COOK"
	var/cooks = 0 //Counts cooks amount

	outfit = /datum/outfit/job/cook
	plasmaman_outfit = /datum/outfit/plasmaman/chef

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	liver_traits = list(TRAIT_CULINARY_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_COOK
	bounty_types = CIV_JOB_CHEF
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(
		/obj/item/reagent_containers/condiment/saltshaker,
		/obj/item/kitchen/rollingpin,
		/obj/item/clothing/head/utility/chefhat,
	)

	mail_goodies = list(
		/obj/item/storage/box/ingredients/random = 80,
		/obj/item/reagent_containers/cup/bottle/caramel = 20,
		/obj/item/reagent_containers/condiment/flour = 20,
		/obj/item/reagent_containers/condiment/rice = 20,
		/obj/item/reagent_containers/condiment/ketchup = 20,
		/obj/item/reagent_containers/condiment/enzyme = 15,
		/obj/item/reagent_containers/condiment/soymilk = 15,
		/obj/item/knife/kitchen = 4,
		/obj/item/knife/butcher = 2
	)

	rpg_title = "Tavern Chef"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

/datum/job/cook/award_service(client/winner, award)
	winner.give_award(award, winner.mob)

	var/datum/venue/restaurant = SSrestaurant.all_venues[/datum/venue/restaurant]
	var/award_score = restaurant.total_income
	var/award_status = winner.get_award_status(/datum/award/score/chef_tourist_score)
	if(award_score > award_status)
		award_score -= award_status
	winner.give_award(/datum/award/score/chef_tourist_score, winner.mob, award_score)


/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	id_trim = /datum/id_trim/job/cook/chef
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/toggle/chef
	backpack_contents = list(
		/obj/item/choice_beacon/ingredient = 1,
		/obj/item/sharpener = 1,
	)
	belt = /obj/item/modular_computer/pda/cook
	ears = /obj/item/radio/headset/headset_srv
	head = /obj/item/clothing/head/utility/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian

	skillchips = list(/obj/item/skillchip/job/chef)

/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/datum/job/cook/other_chefs = SSjob.GetJobType(jobtype)
	if(other_chefs) // If there's other Chefs, you're a Cook
		if(other_chefs.cooks > 0)//Cooks
			id_trim = /datum/id_trim/job/cook
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft/mime
		if(!visualsOnly)
			other_chefs.cooks++

/datum/outfit/job/cook/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/suit/apron/chef
	. += /obj/item/clothing/head/soft/mime

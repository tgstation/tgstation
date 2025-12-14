/datum/job/head_of_personnel
	title = JOB_HEAD_OF_PERSONNEL
	description = "Alter access on ID cards, manage the service department, \
		protect Ian, run the station when the captain dies."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_CAPTAIN)
	head_announce = list(RADIO_CHANNEL_SERVICE)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CAPTAIN
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SERVICE
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "HEAD_OF_PERSONNEL"

	outfit = /datum/outfit/job/hop
	plasmaman_outfit = /datum/outfit/plasmaman/head_of_personnel
	departments_list = list(
		/datum/job_department/service,
		/datum/job_department/command,
		)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SRV
	bounty_types = CIV_JOB_RANDOM

	mind_traits = list(HEAD_OF_STAFF_MIND_TRAITS)
	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL

	mail_goodies = list(
		/obj/item/card/id/advanced/silver = 10,
		/obj/item/stack/sheet/bone = 5
	)

	family_heirlooms = list(/obj/item/reagent_containers/cup/glass/trophy/silver_cup)
	rpg_title = "Guild Questgiver"
	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS

	human_authority = JOB_AUTHORITY_HUMANS_ONLY

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/head_of_personnel/get_captaincy_announcement(mob/living/captain)
	return "Due to staffing shortages, newly promoted Acting Captain [captain.real_name] on deck!"

/datum/job/head_of_personnel/generate_traitor_objective()
	var/datum/objective/assassinate/captain_replacement/promotion = new()
	promotion.target = promotion.find_target()
	if(isnull(promotion.target))
		qdel(promotion)
		return null

	promotion.update_explanation_text()
	return promotion

/// Special assassination objective to kill the cap, take their id, and become the new captain
/datum/objective/assassinate/captain_replacement
	name = "replace the captain"
	admin_grantable = FALSE

/datum/objective/assassinate/captain_replacement/update_explanation_text()
	. = ..()
	explanation_text = "Assassinate [target.name], the Captain, and steal [target.p_their()] ID card."

/datum/objective/assassinate/captain_replacement/check_completion()
	if(completed)
		return TRUE
	if(!..())
		return FALSE

	for(var/datum/mind/hop as anything in get_owners())
		if(!isliving(hop.current))
			continue

		if(locate(/obj/item/card/id/advanced/gold) in hop.current.get_all_contents())
			return TRUE

	return FALSE

/datum/objective/assassinate/captain_replacement/find_target(dupe_search_range, list/blacklist)
	for(var/datum/mind/fellow_head as anything in SSjob.get_all_heads() - blacklist)
		if(is_captain_job(fellow_head.assigned_role))
			return fellow_head
	return null

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/head_of_personnel

	id = /obj/item/card/id/advanced/platinum
	id_trim = /datum/id_trim/job/head_of_personnel
	uniform = /obj/item/clothing/under/rank/civilian/head_of_personnel
	backpack_contents = list(
		/obj/item/melee/baton/telescopic/silver = 1,
		)
	belt = /obj/item/modular_computer/pda/heads/hop
	ears = /obj/item/radio/headset/heads/hop
	head = /obj/item/clothing/head/hats/hopcap
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/armor/vest/hop

	chameleon_extras = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/stamp/head/hop,
		)

/datum/outfit/job/hop/pre_equip(mob/living/carbon/human/H)
	..()
	if(check_holidays(IAN_HOLIDAY))
		undershirt = /datum/sprite_accessory/undershirt/ian

//only pet worth reviving
/datum/job/head_of_personnel/get_mail_goodies(mob/recipient)
	. = ..()
	// Strange Reagent if the pet is dead.
	for(var/mob/living/basic/pet/dog/corgi/ian/staff_pet in GLOB.dead_mob_list)
		. += list(/datum/reagent/medicine/strange_reagent = 20)
		break

/datum/job/veteran_advisor
	title = JOB_VETERAN_ADVISOR
	description = "Advise HoS, and Captain on matters of Security. Train green Officers. \
		Lay back in your wheelchair and say \"I told you\" to the HoS when all of the station collapses."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = SUPERVISOR_HOS
	minimal_player_age = 7
	exp_requirements = 6000 //100 HOURS! We want really hard boiled people
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SECURITY
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "VETERAN_ADVISOR"

	outfit = /datum/outfit/job/veteran_advisor
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_VETERAN_ADVISOR
	departments_list = list(/datum/job_department/security)

	family_heirlooms = list(/obj/item/plaque)

	mail_goodies = list(
		/obj/item/clothing/accessory/medal/conduct = 1,
		/obj/item/instrument/trumpet = 5,
		/obj/item/storage/fancy/cigarettes/cigars = 10,
	)
	rpg_title = "Royal Advisor"
	allow_bureaucratic_error = FALSE
	job_flags = STATION_JOB_FLAGS | STATION_TRAIT_JOB_FLAGS

/datum/job/veteran_advisor/get_default_roundstart_spawn_point()
	for(var/obj/effect/landmark/start/spawn_point as anything in GLOB.start_landmarks_list)
		if(spawn_point.name != "Security Officer")
			continue
		. = spawn_point
		if(spawn_point.used) //so we can revert to spawning them on top of eachother if something goes wrong
			continue
		spawn_point.used = TRUE
		break
	if(!.) // Try to fall back to "our" landmark
		. = ..()
	if(!.)
		log_mapping("Job [title] ([type]) couldn't find a round start spawn point.")

/datum/job/veteran_advisor/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/mob/living/carbon/veteran = spawned
	spawned.add_quirk(/datum/quirk/paraplegic) //Even in 2300s veterans are getting it bad
	if(veteran)
		veteran.gain_trauma(/datum/brain_trauma/special/ptsd) //War, war never changes...

/datum/outfit/job/veteran_advisor
	name = "Veteran Security Advisor"
	jobtype = /datum/job/veteran_advisor

	id_trim = /datum/id_trim/job/veteran_advisor
	backpack_contents = list(
		/obj/item/modular_computer/pda/veteran_advisor = 1,
		/obj/item/storage/fancy/cigarettes/cigars = 1,
		/obj/item/lighter = 1,
		/obj/item/clothing/accessory/medal/bronze_heart = 1,
	)

	uniform = /obj/item/clothing/under/rank/security/officer/formal
	head = /obj/item/clothing/head/soft/veteran
	mask = /obj/item/cigarette/cigar
	suit = /obj/item/clothing/suit/jacket/trenchcoat
	belt = /obj/item/storage/belt/holster/detective/full/ert //M1911 pistol
	ears = /obj/item/radio/headset/heads/hos/advisor
	glasses = /obj/item/clothing/glasses/eyepatch
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/coin/antagtoken
	r_pocket = /obj/item/melee/baton/telescopic
	r_hand = /obj/item/cane

	implants = list(/obj/item/implant/mindshield)

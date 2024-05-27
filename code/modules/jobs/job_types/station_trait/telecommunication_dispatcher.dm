/datum/job/telecommunication_dispatcher
	title = JOB_TELECOMMUNICATION_DISPATCHER
	description = "Coordinate interdepartmental communication and emergency response, maintain extremely confusing telecommunication systems."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = "the Head of Personnel and the Chief Engineer"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "TELECOMMUNICATION_DISPATCHER"

	outfit = /datum/outfit/job/telecommunication_dispatcher
	plasmaman_outfit = /datum/outfit/plasmaman/telecommunication_dispatcher

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_TELECOMMUNICATION_DISPATCHER
	department_for_prefs = /datum/job_department/service
	departments_list = list(
		/datum/job_department/service,
		/datum/job_department/engineering,
	)

	family_heirlooms = list(/obj/item/phone)

	mail_goodies = list(
		/obj/item/radio/off = 1,
		/obj/item/binoculars = 1,
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/megaphone = 1,
	)
	rpg_title = "Messenger"
	allow_bureaucratic_error = FALSE
	job_flags = STATION_JOB_FLAGS | STATION_TRAIT_JOB_FLAGS

/datum/job/interdepartmental_dispatcher/get_roundstart_spawn_point() //taken from Bridge Assistant
	var/list/chair_turfs = list()
	var/list/possible_turfs = list()
	var/area/tcomms = GLOB.areas_by_type[/area/station/tcommsat/computer]
	if(isnull(tcomms))
		return ..() //if no tcomms control room, spawn on the arrivals shuttle
	for (var/list/zlevel_turfs as anything in tcomms.get_zlevel_turf_lists())
		for (var/turf/possible_turf as anything in zlevel_turfs)
			if(possible_turf.is_blocked_turf())
				continue
			if(locate(/obj/structure/chair) in possible_turf)
				chair_turfs += possible_turf
				continue
			possible_turfs += possible_turf
	if(length(chair_turfs))
		return pick(chair_turfs) //prioritize turfs with a chair
	if(length(possible_turfs))
		return pick(possible_turfs) //if none, just pick a random turf in the control room
	return ..() //if the control room has no turfs, spawn on the arrivals shuttle

/datum/outfit/job/telecommunication_dispatcher
	name = "Telecommunication Dispatcher"
	jobtype = /datum/job/telecommunication_dispatcher

	id_trim = /datum/id_trim/job/telecommunication_dispatcher
	backpack_contents = list(
		/obj/item/clothing/neck/link_scryer/loaded = 1,
		/obj/item/chair/plastic = 1,
	)

	uniform = /obj/item/clothing/under/costume/buttondown/slacks/dispatcher
	suit = /obj/item/clothing/suit/hazardvest/blue
	head = /obj/item/clothing/head/soft/blue
	neck = /obj/item/clothing/neck/tie/blue
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/dispatcher
	glasses = /obj/item/clothing/glasses/welding/up
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/modular_computer/pda/dispatcher
	r_pocket = /obj/item/radio/dispatcher
	r_hand = /obj/item/modular_computer/laptop/preset/dispatcher

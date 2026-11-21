/datum/job/security_officer
	title = JOB_SECURITY_OFFICER
	description = "Protect company assets, follow the Standard Operating \
		Procedure, eat donuts."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	faction = FACTION_STATION
	total_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	spawn_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	supervisors = "the Head of Security, and the head of your assigned department (if applicable)"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SECURITY_OFFICER"

	outfit = /datum/outfit/job/security
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	desensitized_base = DESENSITIZED_THRESHOLD
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)
	rpg_title = "Guard"
	alternate_titles = list(
		JOB_SECURITY_OFFICER_MEDICAL,
		JOB_SECURITY_OFFICER_ENGINEERING,
		JOB_SECURITY_OFFICER_SUPPLY,
		JOB_SECURITY_OFFICER_SCIENCE,
	)
	job_flags = STATION_JOB_FLAGS | JOB_ANTAG_PROTECTED
	tgui_icon = FA_ICON_SHIELD_HALVED


GLOBAL_LIST_INIT(available_depts, list(SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY))

/**
 * The department distribution of the security officers.
 *
 * Keys are refs of the security officer mobs. This is to preserve the list's structure even if the
 * mob gets deleted. This is also safe, as mobs are guaranteed to have a unique ref, as per /mob/GenerateTag().
 */
GLOBAL_LIST_EMPTY(security_officer_distribution)

/datum/job/security_officer/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!prob(PIG_COP_PROBABILITY))
		return
	for (var/obj/item/bodypart/ham as anything in spawned.get_bodyparts())
		ham.butcher_drops_override = list(/obj/item/food/meat/slab/pig = ham.base_meat_amount)

/datum/job/security_officer/after_roundstart_spawn(mob/living/spawning, client/player_client)
	. = ..()
	if(ishuman(spawning))
		setup_department(spawning, player_client, move_to = TRUE)


/datum/job/security_officer/after_latejoin_spawn(mob/living/spawning)
	. = ..()
	if(ishuman(spawning))
		var/department = setup_department(spawning, spawning.client)
		if(department)
			announce_latejoin(spawning, department, GLOB.security_officer_distribution)


/// Returns the department this mob was assigned to, if any.
/datum/job/security_officer/proc/setup_department(mob/living/carbon/human/spawning, client/player_client, move_to = FALSE)
	var/department = player_client?.prefs?.read_preference(/datum/preference/choiced/security_department)
	if (!isnull(department))
		department = get_my_department(spawning, department)
		GLOB.security_officer_distribution[REF(spawning)] = department

	var/ears = null
	var/accessory = null
	var/datum/id_trim/dep_trim = null
	var/destination = null

	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_sec/alt/department/supply
			dep_trim = /datum/id_trim/job/security_officer/supply
			destination = /area/station/security/checkpoint/supply
			accessory = /obj/item/clothing/accessory/armband/cargo
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_sec/alt/department/engi
			dep_trim = /datum/id_trim/job/security_officer/engineering
			destination = /area/station/security/checkpoint/engineering
			accessory = /obj/item/clothing/accessory/armband/engine
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_sec/alt/department/med
			dep_trim = /datum/id_trim/job/security_officer/medical
			destination = /area/station/security/checkpoint/medical
			accessory = /obj/item/clothing/accessory/armband/medblue
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sec/alt/department/sci
			dep_trim = /datum/id_trim/job/security_officer/science
			destination = /area/station/security/checkpoint/science
			accessory = /obj/item/clothing/accessory/armband/science

	if(accessory)
		var/obj/item/clothing/under/worn_under = spawning.w_uniform
		worn_under.attach_accessory(new accessory)

	if(ears)
		if(spawning.ears)
			qdel(spawning.ears)
		spawning.equip_to_slot_or_del(new ears(spawning),ITEM_SLOT_EARS)

	// If there's a departmental sec trim to apply to the card, overwrite.
	if(dep_trim)
		var/obj/item/card/id/worn_id = spawning.get_idcard(hand_first = FALSE)
		SSid_access.apply_trim_to_card(worn_id, dep_trim)
		spawning.update_ID_card()

		// Update PDA to match new trim.
		var/obj/item/modular_computer/pda/pda = spawning.get_item_by_slot(ITEM_SLOT_BELT)
		var/assignment = worn_id.get_trim_assignment()
		if(istype(pda) && !isnull(assignment))
			pda.imprint_id(spawning.real_name, assignment)

	var/spawn_point = pick(LAZYACCESS(GLOB.department_security_spawns, department))

	if(!CONFIG_GET(flag/sec_start_brig) && move_to && (destination || spawn_point))
		if(spawn_point)
			spawning.forceMove(get_turf(spawn_point))
		else
			var/list/possible_turfs = get_area_turfs(destination)
			while (length(possible_turfs))
				var/random_index = rand(1, length(possible_turfs))
				var/turf/target = possible_turfs[random_index]
				if (isopenturf(target) && spawning.forceMove(target))
					break
				possible_turfs.Cut(random_index, random_index + 1)

	if(player_client)
		if(department)
			to_chat(player_client, "<b>You have been assigned to [department]!</b>")
		else
			to_chat(player_client, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")

	return department


/datum/job/security_officer/proc/announce_latejoin(
	mob/officer,
	department,
	distribution,
)
	var/obj/machinery/announcement_system/announcement_system = get_announcement_system(/datum/aas_config_entry/announce_officer, null, list(RADIO_CHANNEL_SECURITY))
	if (isnull(announcement_system))
		return

	announcement_system.announce(/datum/aas_config_entry/announce_officer, list(
		"OFFICER" = officer.real_name,
		"DEPARTMENT" = department,
	), list(RADIO_CHANNEL_SECURITY))

	var/list/targets = list()

	var/list/partners = list()
	for (var/officer_ref in distribution)
		var/mob/partner = locate(officer_ref)
		if (!istype(partner) || distribution[officer_ref] != department)
			continue
		partners += partner.real_name

	if (partners.len)
		for(var/messenger_ref in GLOB.pda_messengers)
			var/datum/computer_file/program/messenger/messenger = GLOB.pda_messengers[messenger_ref]
			if(!(messenger.computer?.saved_identification in partners))
				continue
			targets += messenger

	if (!targets.len)
		return

	// I thought it would be great, if AAS also modifies PDA messages. Especially because it's AASs message.
	var/datum/signal/subspace/messaging/tablet_message/signal = new(announcement_system, list(
		"fakename" = "Security Department Update",
		"fakejob" = "Automated Announcement System",
		"message" = announcement_system.compile_config_message(/datum/aas_config_entry/announce_officer, list(
			"OFFICER" = officer.real_name,
			"DEPARTMENT" = department,
		)),
		"targets" = targets,
		"automated" = TRUE,
	))

	signal.send_to_receivers()

/datum/job/security_officer/proc/get_my_department(mob/character, preferred_department)
	return GLOB.security_officer_distribution[REF(character)] || get_officer_department(
		preferred_department,
		shuffle(GLOB.available_depts),
		GLOB.security_officer_distribution,
	)

/datum/outfit/job/security
	name = "Security Officer"
	jobtype = /datum/job/security_officer

	id_trim = /datum/id_trim/job/security_officer
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest/alt/sec
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/evidencebag = 1,
		)
	belt = /obj/item/modular_computer/pda/crew/security
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black/security
	head = /obj/item/clothing/head/helmet/sec
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	messenger = /obj/item/storage/backpack/messenger/sec

	box = /obj/item/storage/box/survival/security
	chameleon_extras = list(
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/gun/energy/disabler,
		)
		//The helmet is necessary because /obj/item/clothing/head/helmet/sec is overwritten in the chameleon list by the standard helmet, which has the same name and icon state
	implants = list(/obj/item/implant/mindshield)

	wintercoat = /obj/item/clothing/suit/hooded/wintercoat/security

/datum/outfit/job/security/mod
	name = "Security Officer (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/security
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	internals_slot = ITEM_SLOT_SUITSTORE

/obj/item/radio/headset/headset_sec/alt/department/Initialize(mapload)
	. = ..()
	set_wires(new/datum/wires/radio(src))

/obj/item/radio/headset/headset_sec/alt/department/engi
	keyslot = /obj/item/encryptionkey/headset_sec
	keyslot2 = /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_sec/alt/department/supply
	keyslot = /obj/item/encryptionkey/headset_sec
	keyslot2 = /obj/item/encryptionkey/headset_cargo
/obj/item/radio/headset/headset_sec/alt/department/med
	keyslot = /obj/item/encryptionkey/headset_sec
	keyslot2 = /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sec/alt/department/sci
	keyslot = /obj/item/encryptionkey/headset_sec
	keyslot2 = /obj/item/encryptionkey/headset_sci

/// Returns the department a new officer should go to: the least populated one, favoring their preference on ties.
/proc/get_officer_department(
	preference,
	list/departments,
	list/distribution,
)
	var/list/amount_in_departments = list()

	for (var/department in departments)
		amount_in_departments[department] = 0

	for (var/officer in distribution)
		var/department = distribution[officer]
		if (!isnull(department))
			amount_in_departments[department] += 1

	var/list/lowest_departments = list(departments[1])
	var/lowest_amount = INFINITY

	for (var/department in amount_in_departments)
		var/amount = amount_in_departments[department]

		if (lowest_amount > amount)
			lowest_departments = list(department)
			lowest_amount = amount
		else if (lowest_amount == amount)
			lowest_departments += department

	return (preference in lowest_departments) ? preference : lowest_departments[1]

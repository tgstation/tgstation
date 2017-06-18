//Warden and regular officers add this result to their get_access()
/datum/job/proc/check_config_for_sec_maint()
	if(config.jobs_have_maint_access & SECURITY_HAS_MAINT_ACCESS)
		return list(GLOB.access_maint_tunnels)
	return list()

/*
Head of Security
*/
/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_head = list("Captain")
	department_flag = ENGSEC
	head_announce = list("Security")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	req_admin_notify = 1
	minimal_player_age = 14

	outfit = /datum/outfit/job/hos

	access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_weapons,
			            GLOB.access_forensics_lockers, GLOB.access_morgue, GLOB.access_maint_tunnels, GLOB.access_all_personal_lockers,
			            GLOB.access_research, GLOB.access_engine, GLOB.access_mining, GLOB.access_medical, GLOB.access_construction, GLOB.access_mailsorting,
			            GLOB.access_heads, GLOB.access_hos, GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_gateway, GLOB.access_maint_tunnels)
	minimal_access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_weapons,
			            GLOB.access_forensics_lockers, GLOB.access_morgue, GLOB.access_maint_tunnels, GLOB.access_all_personal_lockers,
			            GLOB.access_research, GLOB.access_engine, GLOB.access_mining, GLOB.access_medical, GLOB.access_construction, GLOB.access_mailsorting,
			            GLOB.access_heads, GLOB.access_hos, GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_gateway, GLOB.access_maint_tunnels)

/datum/outfit/job/hos
	name = "Head of Security"
	jobtype = /datum/job/hos

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hos
	ears = /obj/item/device/radio/headset/heads/hos/alt
	uniform = /obj/item/clothing/under/rank/head_of_security
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/hos/trenchcoat
	gloves = /obj/item/clothing/gloves/color/black/hos
	head = /obj/item/clothing/head/HoS/beret
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	suit_store = /obj/item/weapon/gun/energy/e_gun
	r_pocket = /obj/item/device/assembly/flash/handheld
	l_pocket = /obj/item/weapon/restraints/handcuffs
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel/sec
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/sec
	box = /obj/item/weapon/storage/box/security

	implants = list(/obj/item/weapon/implant/mindshield)

/*
Warden
*/
/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	outfit = /datum/outfit/job/warden

	access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_weapons, GLOB.access_forensics_lockers)
	minimal_access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_court, GLOB.access_weapons) //See /datum/job/warden/get_access()

/datum/job/warden/get_access()
	var/list/L = list()
	L = ..() | check_config_for_sec_maint()
	return L

/datum/outfit/job/warden
	name = "Warden"
	jobtype = /datum/job/warden

	belt = /obj/item/device/pda/warden
	ears = /obj/item/device/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/warden
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/warden
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/device/assembly/flash/handheld
	l_pocket = /obj/item/weapon/restraints/handcuffs
	suit_store = /obj/item/weapon/gun/energy/e_gun/advtaser
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel/sec
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/sec
	box = /obj/item/weapon/storage/box/security

	implants = list(/obj/item/weapon/implant/mindshield)


/*
Detective
*/
/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	outfit = /datum/outfit/job/detective

	access = list(GLOB.access_sec_doors, GLOB.access_forensics_lockers, GLOB.access_morgue, GLOB.access_maint_tunnels, GLOB.access_court, GLOB.access_brig, GLOB.access_weapons)
	minimal_access = list(GLOB.access_sec_doors, GLOB.access_forensics_lockers, GLOB.access_morgue, GLOB.access_maint_tunnels, GLOB.access_court, GLOB.access_brig, GLOB.access_weapons)

/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	belt = /obj/item/device/pda/detective
	ears = /obj/item/device/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/det
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/weapon/lighter
	backpack_contents = list(/obj/item/weapon/storage/box/evidence=1,\
		/obj/item/device/detective_scanner=1,\
		/obj/item/weapon/melee/classic_baton=1)
	mask = /obj/item/clothing/mask/cigarette

	implants = list(/obj/item/weapon/implant/mindshield)

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
	cig.light("")

	if(visualsOnly)
		return

/*
Security Officer
*/
/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	spawn_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	outfit = /datum/outfit/job/security

	access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_court, GLOB.access_maint_tunnels, GLOB.access_morgue, GLOB.access_weapons, GLOB.access_forensics_lockers)
	minimal_access = list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_court, GLOB.access_weapons) //But see /datum/job/warden/get_access()


/datum/job/officer/get_access()
	var/list/L = list()
	L |= ..() | check_config_for_sec_maint()
	return L

GLOBAL_LIST_INIT(available_depts, list(SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY))

/datum/job/officer/after_spawn(mob/living/carbon/human/H, mob/M)
	// Assign department security
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client.prefs.prefered_security_department
		if(!LAZYLEN(GLOB.available_depts) || department == "None")
			return
		else if(department in GLOB.available_depts)
			LAZYREMOVE(GLOB.available_depts, department)
		else
			department = pick_n_take(GLOB.available_depts)
	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/device/radio/headset/headset_sec/alt/department/supply
			dep_access = list(GLOB.access_mailsorting, GLOB.access_mining, GLOB.access_mining_station)
			destination = /area/security/checkpoint/supply
			spawn_point = locate(/obj/effect/landmark/start/depsec/supply) in GLOB.department_security_spawns
			accessory = /obj/item/clothing/accessory/armband/cargo
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/device/radio/headset/headset_sec/alt/department/engi
			dep_access = list(GLOB.access_construction, GLOB.access_engine)
			destination = /area/security/checkpoint/engineering
			spawn_point = locate(/obj/effect/landmark/start/depsec/engineering) in GLOB.department_security_spawns
			accessory = /obj/item/clothing/accessory/armband/engine
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/device/radio/headset/headset_sec/alt/department/med
			dep_access = list(GLOB.access_medical)
			destination = /area/security/checkpoint/medical
			spawn_point = locate(/obj/effect/landmark/start/depsec/medical) in GLOB.department_security_spawns
			accessory =  /obj/item/clothing/accessory/armband/medblue
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/device/radio/headset/headset_sec/alt/department/sci
			dep_access = list(GLOB.access_research)
			destination = /area/security/checkpoint/science
			spawn_point = locate(/obj/effect/landmark/start/depsec/science) in GLOB.department_security_spawns
			accessory = /obj/item/clothing/accessory/armband/science

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		U.attach_accessory(new accessory)
	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),slot_ears)

	var/obj/item/weapon/card/id/W = H.wear_id
	W.access |= dep_access

	var/teleport = 0
	if(!config.sec_start_brig)
		if(destination || spawn_point)
			teleport = 1
	if(teleport)
		var/turf/T
		if(spawn_point)
			T = get_turf(spawn_point)
			H.Move(T)
		else
			var/safety = 0
			while(safety < 25)
				T = safepick(get_area_turfs(destination))
				if(T && !H.Move(T))
					safety += 1
					continue
				else
					break
	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")



/datum/outfit/job/security
	name = "Security Officer"
	jobtype = /datum/job/officer

	belt = /obj/item/device/pda/security
	ears = /obj/item/device/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/weapon/restraints/handcuffs
	r_pocket = /obj/item/device/assembly/flash/handheld
	suit_store = /obj/item/weapon/gun/energy/e_gun/advtaser
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel/sec
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/sec
	box = /obj/item/weapon/storage/box/security

	implants = list(/obj/item/weapon/implant/mindshield)


/obj/item/device/radio/headset/headset_sec/alt/department/Initialize()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = new
	recalculateChannels()
	..()

/obj/item/device/radio/headset/headset_sec/alt/department/engi
	keyslot = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_sec/alt/department/supply
	keyslot = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/headset_sec/alt/department/med
	keyslot = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sec/alt/department/sci
	keyslot = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_sci

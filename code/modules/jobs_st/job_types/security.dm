//Warden and regular officers add this result to their get_access()
/datum/job/proc/check_config_for_sec_maint()
	if(config.jobs_have_maint_access & SECURITY_HAS_MAINT_ACCESS)
		return list(access_maint_tunnels)
	return list()

/*
Chief Security Officer
*/
/datum/job/cso
	title = "Chief Security Officer"
	flag = CSO
	department_head = list("Commanding Officer")
	department_flag = SECJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commanding Officer"
	selection_color = "#ffdddd"
	req_admin_notify = 1
	minimal_player_age = 14

	outfit = /datum/outfit/job/cso

	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_weapons,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_weapons,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)

/datum/outfit/job/cso
	name = "Chief of Security"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hos
	ears = /obj/item/device/radio/headset/heads/hos/alt
	uniform = /obj/item/clothing/under/rank/head_of_security
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/hos/trenchcoat
	gloves = /obj/item/clothing/gloves/color/black/hos
	head = /obj/item/clothing/head/HoS/beret
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	suit_store = /obj/item/weapon/gun/energy/gun
	r_pocket = /obj/item/device/assembly/flash/handheld
	l_pocket = /obj/item/weapon/restraints/handcuffs
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/sec
	box = /obj/item/weapon/storage/box/security

/datum/outfit/job/cso/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	H.sec_hud_set_implants()

	announce_head(H, list("Security")) //tell underlings (security radio) they have a head

/*
Tactical Officer
*/
/datum/job/tacofficer
	title = "Tactical Officer"
	flag = TACOFFICER
	department_head = list("Chief Security Officer")
	department_flag = SECJOBS
	faction = "Federation"
	total_positions = 25 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	spawn_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	supervisors = "the Chief Security Officer, or your Away Team Officer"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	outfit = /datum/outfit/job/tacofficer

	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue, access_weapons, access_forensics_lockers)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons) //But see /datum/job/warden/get_access()

/datum/job/tacofficer/get_access()
	var/list/L = list()
	L |= ..() | check_config_for_sec_maint()
	return L

/datum/outfit/job/tacofficer
	name = "Tactical Officer"

	belt = /obj/item/device/pda/security
	ears = /obj/item/device/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/security
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/weapon/restraints/handcuffs
	r_pocket = /obj/item/device/assembly/flash/handheld
	suit_store = /obj/item/weapon/gun/energy/gun/advtaser
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/sec
	box = /obj/item/weapon/storage/box/security

/datum/outfit/job/tacofficer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H) //These aren't really necessary
	L.imp_in = H
	L.implanted = 1
	H.sec_hud_set_implants()

/*
Security Officer
*/
/datum/job/officer
	title = "Security Officer"
	flag = SECOFFICER
	department_head = list("Chief of Security")
	department_flag = SECJOBS
	faction = "Federation"
	total_positions = 10 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	spawn_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	outfit = /datum/outfit/job/security

	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue, access_weapons, access_forensics_lockers)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons) //But see /datum/job/warden/get_access()

/datum/job/officer/get_access()
	var/list/L = list()
	L |= ..() | check_config_for_sec_maint()
	return L

var/list/sec_departments = list("engineering", "medical", "science", "the bridge")

/datum/outfit/job/security
	name = "Security Officer"

	belt = /obj/item/device/pda/security
	ears = /obj/item/device/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/weapon/restraints/handcuffs
	r_pocket = /obj/item/device/assembly/flash/handheld
	suit_store = /obj/item/weapon/gun/energy/gun/advtaser
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/sec
	box = /obj/item/weapon/storage/box/security

	var/department = null
	var/tie = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null

/datum/outfit/job/security/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(sec_departments.len)
		department = pick(sec_departments)
		if(!visualsOnly)
			sec_departments -= department
		switch(department)
			if("the bridge")  //Change thissssssss stuff
				ears = /obj/item/device/radio/headset/headset_sec/alt/department/supply
				dep_access = list(access_mailsorting, access_mining, access_mining_station)
				destination = /area/security/checkpoint/supply
				spawn_point = locate(/obj/effect/landmark/start/depsec/supply) in department_security_spawns
				tie = /obj/item/clothing/tie/armband/cargo
			if("engineering")
				ears = /obj/item/device/radio/headset/headset_sec/alt/department/engi
				dep_access = list(access_construction, access_engine)
				destination = /area/security/checkpoint/engineering
				spawn_point = locate(/obj/effect/landmark/start/depsec/engineering) in department_security_spawns
				tie = /obj/item/clothing/tie/armband/engine
			if("medical")
				ears = /obj/item/device/radio/headset/headset_sec/alt/department/med
				dep_access = list(access_medical)
				destination = /area/security/checkpoint/medical
				spawn_point = locate(/obj/effect/landmark/start/depsec/medical) in department_security_spawns
				tie =  /obj/item/clothing/tie/armband/medblue
			if("science")
				ears = /obj/item/device/radio/headset/headset_sec/alt/department/sci
				dep_access = list(access_research)
				destination = /area/security/checkpoint/science
				spawn_point = locate(/obj/effect/landmark/start/depsec/science) in department_security_spawns
				tie = /obj/item/clothing/tie/armband/science

/datum/outfit/job/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	var/obj/item/clothing/under/U = H.w_uniform
	if(tie)
		U.attachTie(new tie)

	if(visualsOnly)
		return

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	H.sec_hud_set_implants()

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
		H << "<b>You have been assigned to [department]!</b>"
	else
		H << "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>"

/obj/item/device/radio/headset/headset_sec/department/New()
	wires = new(src)
	secure_radio_connections = new

	initialize()
	recalculateChannels()

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



/*
AO
*/
/datum/job/armofficer
	title = "Armory Officer"
	flag = ARMORYOFFICER
	department_head = list("Chief Security Officer")
	department_flag = SECJOBS
	faction = "Federation"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Chief Security Officer"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	outfit = /datum/outfit/job/armofficer

	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels, access_morgue, access_weapons, access_forensics_lockers)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_weapons) //See /datum/job/warden/get_access()

/datum/job/armofficer/get_access()
	var/list/L = list()
	L = ..() | check_config_for_sec_maint()
	return L

/datum/outfit/job/armofficer
	name = "Armory Officer"

	belt = /obj/item/device/pda/warden
	ears = /obj/item/device/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/warden
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/warden
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/beret/sec/navywarden
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/device/assembly/flash/handheld
	l_pocket = /obj/item/weapon/restraints/handcuffs
	suit_store = /obj/item/weapon/gun/energy/gun/advtaser
	backpack_contents = list(/obj/item/weapon/melee/baton/loaded=1)

	backpack = /obj/item/weapon/storage/backpack/security
	satchel = /obj/item/weapon/storage/backpack/satchel_sec
	dufflebag = /obj/item/weapon/storage/backpack/dufflebag/sec
	box = /obj/item/weapon/storage/box/security


/datum/outfit/job/armofficer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1
	H.sec_hud_set_implants()
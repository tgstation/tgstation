/datum/job/deputy
	title = "Deputy"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security")
	faction = "Station"
	total_positions = 4 //Kept in for posterity
	spawn_positions = 4 //ditto
	supervisors = "the head of security, and the head of your assigned department"
	selection_color = "#ffeeee"
	minimal_player_age = 1
	exp_requirements = 50
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/deputy

	access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_SEC_DOORS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER

	// FULP Integration Vars
	id_icon = 'icons/fulpicons/cards.dmi'	// Overlay on your ID
	hud_icon = 'icons/fulpicons/fulphud.dmi'		 	// Sec Huds see this


/obj/item/clothing/under/rank/security/mallcop
	name = "deputy shirt"
	desc = "An awe-inspiring tactical shirt-and-pants combo; because safety never takes a holiday."
	worn_icon = 'icons/fulpicons/mith_stash/clothing/under_worn.dmi' //will be sharing a DMI with digisuits
	icon = 'icons/fulpicons/mith_stash/clothing/under_icons.dmi'
	icon_state = "mallcop"
	strip_delay = 50
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	fulp_item = TRUE
	mutantrace_variation = MUTANTRACE_VARIATION
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/mallcop/skirt
	name = "deputy skirt"
	desc = "An awe-inspiring tactical shirt-and-skirt combo; perfectly tailored for segway-riding."
	icon_state = "mallcop_skirt"
	mutantrace_variation = NO_MUTANTRACE_VARIATION
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/head/beret/sec/engineering
	name = "engineering deputy beret"
	desc = "Perhaps the only thing standing between the supermatter and a station-wide explosive sabotage."
	worn_icon = 'icons/fulpicons/mith_stash/clothing/head_worn.dmi'
	icon = 'icons/fulpicons/mith_stash/clothing/head_icons.dmi'
	icon_state = "beret_engi"
	fulp_item = TRUE

/obj/item/clothing/head/beret/sec/medical
	name = "medical deputy beret"
	desc = "This proud white-blue beret is a welcome sight when the greytide descends on chemistry."
	worn_icon = 'icons/fulpicons/mith_stash/clothing/head_worn.dmi'
	icon = 'icons/fulpicons/mith_stash/clothing/head_icons.dmi'
	icon_state = "beret_medbay"
	fulp_item = TRUE

/obj/item/clothing/head/beret/sec/science
	name = "science deputy beret"
	desc = "This loud purple beret screams 'Dont mess with his matter manipulator!'"
	worn_icon = 'icons/fulpicons/mith_stash/clothing/head_worn.dmi'
	icon = 'icons/fulpicons/mith_stash/clothing/head_icons.dmi'
	icon_state = "beret_science"
	fulp_item = TRUE

/obj/item/clothing/head/beret/sec/supply
	name = "supply deputy beret"
	desc = "The headwear for only the most eagle-eyed Deputy, able to watch both Cargo and Mining."
	worn_icon = 'icons/fulpicons/mith_stash/clothing/head_worn.dmi'
	icon = 'icons/fulpicons/mith_stash/clothing/head_icons.dmi'
	icon_state = "beret_supply"
	fulp_item = TRUE

/datum/outfit/job/deputy
	name = "Deputy"
	jobtype = /datum/job/deputy

	head = /obj/item/clothing/head/beret/sec
	belt = /obj/item/storage/belt/security/fulp_starter_full
	ears = /obj/item/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/rank/security/mallcop
	accessory = /obj/item/clothing/accessory/armband/deputy
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs/cable/zipties
	r_pocket = /obj/item/pda/security

	glasses = /obj/item/clothing/glasses/hud/security

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival

	implants = list(/obj/item/implant/mindshield)


/datum/job/deputy/get_access()
	var/list/L = list()
	L |= ..()
	return L

GLOBAL_LIST_INIT(available_deputy_depts, list(SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY))

/datum/job/deputy/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign dept
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client.prefs.prefered_security_department
		if(!LAZYLEN(GLOB.available_deputy_depts)) //shouldn't ever get called, unless the HoP/admins bump the numbers up: 4 depts, 4 deputies
			return
		else if(department in GLOB.available_deputy_depts)
			LAZYREMOVE(GLOB.available_deputy_depts, department)
		else
			department = pick_n_take(GLOB.available_deputy_depts)
	var/ears = null
	var/head = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null
	var/head_p
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_sec/department/supply
			head = /obj/item/clothing/head/beret/sec/supply
			head_p = /obj/item/clothing/head/helmet/space/plasmaman/cargo
			dep_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION)
			destination = /area/security/checkpoint/supply
			spawn_point = get_fulp_spawn(destination)
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_sec/department/engi
			head = /obj/item/clothing/head/beret/sec/engineering
			head_p = /obj/item/clothing/head/helmet/space/plasmaman/engineering
			dep_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)
			destination = /area/security/checkpoint/engineering
			spawn_point = get_fulp_spawn(destination)
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_sec/department/med
			head = /obj/item/clothing/head/beret/sec/medical
			head_p = /obj/item/clothing/head/helmet/space/plasmaman/medical
			dep_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_MECH_MEDICAL, ACCESS_GENETICS, ACCESS_CHEMISTRY) // ACCESS_CLONING
			destination = /area/security/checkpoint/medical
			spawn_point = get_fulp_spawn(destination)
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sec/department/sci
			head = /obj/item/clothing/head/beret/sec/science
			head_p = /obj/item/clothing/head/helmet/space/plasmaman/science
			dep_access = list(ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MECH_SCIENCE)
			destination = /area/security/checkpoint/science
			spawn_point = get_fulp_spawn(destination)

	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),ITEM_SLOT_EARS)
	if(head)
		if(isplasmaman(H))
			head = head_p
		if(H.head)
			qdel(H.head)
		H.equip_to_slot_or_del(new head(H),ITEM_SLOT_HEAD)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access
	// SWAIN: Cards now link to their job, which contains id_icon and hud_icon (see above in Deputy's vars). We don't have to assign it here anymore <3
	//W.job_icon = 'icons/fulpicons/cards.dmi'
	//W.update_icon()

	var/teleport = 0
	if(!CONFIG_GET(flag/sec_start_brig))
		if(destination || spawn_point)
			teleport = 1
	if(teleport)
		var/turf/T
		if(spawn_point)
			T = get_turf(spawn_point)
			H.Move(T)
		else
			var/list/possible_turfs = get_area_turfs(destination)
			while (length(possible_turfs))
				var/I = rand(1, possible_turfs.len)
				var/turf/target = possible_turfs[I]
				if (H.Move(target))
					break
				possible_turfs.Cut(I,I+1)
	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")




/obj/item/radio/headset/headset_sec/department/Initialize()
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = new
	recalculateChannels()

/obj/item/radio/headset/headset_sec/department/engi
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_sec/department/supply
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_sec/department/med
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sec/department/sci
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_sci


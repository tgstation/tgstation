/obj/item/clothing/under/rank/security/officer/blueshirt/orderly
	name = "orderly uniform"
	icon_state = "orderly_uniform"
	worn_icon_state = "orderly_uniform"

/obj/item/clothing/under/rank/security/officer/blueshirt/engineering_guard
	name = "engineering guard uniform"
	icon_state = "engineering_guard_uniform"
	worn_icon_state = "engineering_guard_uniform"

/obj/item/clothing/under/rank/security/officer/blueshirt/customs_agent
	name = "customs agent uniform"
	icon_state = "customs_uniform"
	worn_icon_state = "customs_uniform"

/obj/item/clothing/suit/armor/vest/blueshirt
	icon_state = "barney_armor_symbol"
	worn_icon_state = "barney_armor_symbol"
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/blueshirt/guard
	icon_state = "barney_armor"
	worn_icon_state = "barney_armor"

/obj/item/clothing/suit/armor/vest/blueshirt/orderly
	name = "armored orderly coat"
	desc = "An armored coat, to keep you safe from unruly patients."
	icon_state = "medical_coat"
	worn_icon_state = "medical_coat"

/obj/item/clothing/suit/armor/vest/blueshirt/engineering_guard
	name = "armored engineering guard coat"
	desc = "An armored coat, to keep you safe from unruly patients."
	icon_state = "engineering_coat"
	worn_icon_state = "engineering_coat"

/obj/item/clothing/suit/armor/vest/blueshirt/customs_agent
	name = "armored customs agent coat"
	desc = "An armored coat, to keep you safe from unruly customers."
	icon_state = "customs_coat"
	worn_icon_state = "customs_coat"

/obj/item/clothing/head/helmet/blueshirt/guard
	icon_state = "mallcop_helm"
	worn_icon_state = "mallcop_helm"

/obj/effect/landmark/start/orderly
	name = "Orderly"
	icon_state = "Orderly"

/datum/job/orderly
	title = JOB_ORDERLY
	description = "Defend the medical department, hold down idiots who refuse the vaccine, flex your muscles at people who fuck with medical."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	config_tag = "ORDERLY"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer, <b>NOT SECURITY</b>"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/orderly
	plasmaman_outfit = /datum/outfit/plasmaman/medical

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_ORDERLY
	bounty_types = CIV_JOB_MED
	departments_list = list(
		/datum/job_department/medical,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/orderly
	name = "Orderly" // You forgot your vaccine *flexes muscles*
	jobtype = /datum/job/orderly

	belt = /obj/item/modular_computer/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt/orderly
	shoes = /obj/item/clothing/shoes/sneakers/white
	head =  /obj/item/clothing/head/helmet/blueshirt/guard
	suit = /obj/item/clothing/suit/armor/vest/blueshirt/orderly
	l_hand = /obj/item/melee/baton/security/loaded/departmental/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/medical

	id_trim = /datum/id_trim/job/orderly

/datum/id_trim/job/orderly
	assignment = "Orderly"
	trim_state = "trim_orderly"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_ORDERLY
	extra_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_PLUMBING,
		ACCESS_SECURITY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_WEAPONS,
	)
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_PLUMBING,
		ACCESS_SECURITY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_WEAPONS,
	)
	template_access = list(ACCESS_CAPTAIN, ACCESS_CMO, ACCESS_CHANGE_IDS)
	job = /datum/job/orderly

/obj/effect/landmark/start/science_guard
	name = "Science Guard"
	icon_state = "Science Guard"

/datum/job/science_guard
	title = JOB_SCIENCE_GUARD // I'm a little busy here, Calhoun.
	description = "Figure out why the emails aren't working, keep an eye on those eggheads, keep them safe from their mistakes."
	department_head = list(JOB_RESEARCH_DIRECTOR)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director, <b>NOT SECURITY</b>"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SCIENCE_GUARD"

	outfit = /datum/outfit/job/science_guard
	plasmaman_outfit = /datum/outfit/plasmaman/science

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_SCIENCE_GUARD
	bounty_types = CIV_JOB_SCI
	departments_list = list(
		/datum/job_department/science,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/science_guard
	name = "Science Guard"
	jobtype = /datum/job/science_guard

	belt = /obj/item/modular_computer/pda/science
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	shoes = /obj/item/clothing/shoes/sneakers/black
	head =  /obj/item/clothing/head/helmet/blueshirt
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	l_hand = /obj/item/melee/baton/security/loaded/departmental/science

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/science
	duffelbag = /obj/item/storage/backpack/duffelbag/science
	box = /obj/item/storage/box/survival/medical

	id_trim = /datum/id_trim/job/science_guard

/datum/id_trim/job/science_guard
	assignment = "Science Guard"
	trim_state = "trim_calhoun"
	department_color = COLOR_SCIENCE_PINK
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_SCIENCE_GUARD
	extra_access = list(
		ACCESS_AUX_BASE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_GENETICS,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS,
		ACCESS_SCIENCE,
		ACCESS_SECURITY,
		ACCESS_TECH_STORAGE,
		ACCESS_WEAPONS,
		ACCESS_XENOBIOLOGY,
	)
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_GENETICS,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_ORDNANCE,
		ACCESS_ORDNANCE_STORAGE,
		ACCESS_RESEARCH,
		ACCESS_ROBOTICS,
		ACCESS_SCIENCE,
		ACCESS_SECURITY,
		ACCESS_TECH_STORAGE,
		ACCESS_WEAPONS,
		ACCESS_XENOBIOLOGY,
	)
	template_access = list(ACCESS_CAPTAIN, ACCESS_RD, ACCESS_CHANGE_IDS)
	job = /datum/job/science_guard

/obj/effect/landmark/start/bouncer
	name = "Bouncer"
	icon_state = "Bouncer"

/datum/job/bouncer
	title = JOB_BOUNCER
	description = "Tell people they aren't on the list. Check people's IDs. Tell them to fuck off and get real ID."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel, <b>NOT SECURITY</b>"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BOUNCER"
	outfit = /datum/outfit/job/bouncer
	plasmaman_outfit = /datum/outfit/plasmaman/party_bouncer

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_BOUNCER
	bounty_types = CIV_JOB_DRINK
	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/bouncer
	name = "Bouncer" // That ID looks a little suspect, pal. You ain't on the list, beat it.
	jobtype = /datum/job/bouncer

	belt = /obj/item/modular_computer/pda/bar
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/misc/bouncer
	shoes = /obj/item/clothing/shoes/sneakers/black
	head =  /obj/item/clothing/head/helmet/blueshirt/guard
	suit = /obj/item/clothing/suit/armor/vest/blueshirt/guard
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/departmental/service = 1,
		)
	glasses = /obj/item/clothing/glasses/sunglasses

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival

	id_trim = /datum/id_trim/job/bouncer

/datum/id_trim/job/bouncer
	assignment = "Bouncer"
	trim_state = "trim_bouncer"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_BOUNCER
	extra_access = list(
		ACCESS_BAR,
		ACCESS_SERVICE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_HYDROPONICS,
		ACCESS_KITCHEN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SECURITY,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
	)
	minimal_access = list(
		ACCESS_BAR,
		ACCESS_SERVICE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_HYDROPONICS,
		ACCESS_KITCHEN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SECURITY,
		ACCESS_THEATRE,
		ACCESS_WEAPONS,
	)
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/bouncer

/obj/effect/landmark/start/customs_agent
	name = "Customs Agent"
	icon_state = "Customs Agent"

/datum/job/customs_agent
	title = JOB_CUSTOMS_AGENT // No, you don't get to ship ten kilograms of cocaine to the Spinward Stellar Coalition.
	description = "Inspect the packages coming to and from the station, protect the cargo department, beat the shit out of people trying to ship Cocaine to the Spinward Stellar Coalition."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster, <b>NOT SECURITY</b>"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CUSTOMS_AGENT"

	outfit = /datum/outfit/job/customs_agent
	plasmaman_outfit = /datum/outfit/plasmaman/cargo

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_CUSTOMS_AGENT
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/cargo,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/customs_agent
	name = "Customs Agent"
	jobtype = /datum/job/customs_agent

	belt = /obj/item/modular_computer/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo
	shoes = /obj/item/clothing/shoes/sneakers/black
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt/customs_agent
	head =  /obj/item/clothing/head/helmet/blueshirt/guard
	suit = /obj/item/clothing/suit/armor/vest/blueshirt/customs_agent
	l_hand = /obj/item/melee/baton/security/loaded/departmental/cargo

	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival

	id_trim = /datum/id_trim/job/customs_agent

/datum/id_trim/job/customs_agent
	assignment = "Customs Agent"
	trim_state = "trim_customs"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_CARGO_BROWN
	sechud_icon_state = SECHUD_CUSTOMS_AGENT
	extra_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_SECURITY,
		ACCESS_SHIPPING,
		ACCESS_QM,
		ACCESS_WEAPONS,
	)
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_SECURITY,
		ACCESS_SHIPPING,
		ACCESS_QM,
		ACCESS_WEAPONS,
	)
	template_access = list(ACCESS_CAPTAIN, ACCESS_QM, ACCESS_CHANGE_IDS)
	job = /datum/job/customs_agent

/obj/effect/landmark/start/engineering_guard
	name = "Engineering Guard"
	icon_state = "Engineering Guard"

/datum/job/engineering_guard
	title = JOB_ENGINEERING_GUARD // Listen here, this engine is a restricted area. Please leave if you aren't wearing a radioactive suit.
	description = "Spy on the supermatter, keep an eye on atmospherics, fall asleep at your desk."
	department_head = list(JOB_CHIEF_ENGINEER)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief engineer, <b>NOT SECURITY</b>"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "ENGINEERING_GUARD"

	outfit = /datum/outfit/job/engineering_guard
	plasmaman_outfit = /datum/outfit/plasmaman/engineering

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_ENG

	display_order = JOB_DISPLAY_ORDER_ENGINEER_GUARD
	bounty_types = CIV_JOB_ENG
	departments_list = list(
		/datum/job_department/engineering,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)

	mail_goodies = list(
		/obj/item/food/donut/caramel = 10,
		/obj/item/food/donut/matcha = 10,
		/obj/item/food/donut/blumpkin = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/melee/baton/security/boomerang/loaded = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

/datum/outfit/job/engineering_guard
	name = "Engineering Guard"
	jobtype = /datum/job/engineering_guard

	belt = /obj/item/modular_computer/pda/engineering
	ears = /obj/item/radio/headset/headset_eng
	shoes = /obj/item/clothing/shoes/workboots
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt/engineering_guard
	head =  /obj/item/clothing/head/helmet/blueshirt/guard
	suit = /obj/item/clothing/suit/armor/vest/blueshirt/engineering_guard
	l_hand = /obj/item/melee/baton/security/loaded/departmental/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

	id_trim = /datum/id_trim/job/engineering_guard

/datum/id_trim/job/engineering_guard
	assignment = "Engineering Guard"
	trim_state = "trim_engiguard"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_ENGINEERING_GUARD
	extra_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_AUX_BASE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MECH_ENGINE,
		ACCESS_SECURITY,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		ACCESS_WEAPONS,
	)
	minimal_access = list(
		ACCESS_ATMOSPHERICS,
		ACCESS_AUX_BASE,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MECH_ENGINE,
		ACCESS_SECURITY,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		ACCESS_WEAPONS,
	)
	template_access = list(ACCESS_CAPTAIN, ACCESS_CE, ACCESS_CHANGE_IDS)
	job = /datum/job/engineering_guard

/obj/item/melee/baton/security/loaded/departmental
	name = "departmental stun baton"
	desc = "A stun baton fitted with a departmental area-lock, based off the station's blueprint layout - outside of its department, it only has three uses."
	icon_state = "prison_baton"
	var/list/valid_areas = list()
	var/emagged = FALSE
	var/non_departmental_uses_left = 4

/obj/item/melee/baton/security/loaded/departmental/baton_attack(mob/living/target, mob/living/user, modifiers)
	if(active && !emagged && cooldown_check <= world.time)
		var/area/current_area = get_area(user)
		if(!is_type_in_list(current_area, valid_areas))
			if(non_departmental_uses_left)
				non_departmental_uses_left--
				if(non_departmental_uses_left)
					say("[non_departmental_uses_left] non-departmental uses left!")
				else
					say("[src] is out of non-departmental uses! Return to your department and reactivate the baton to refresh it!")
			else
				target.visible_message(span_warning("[user] prods [target] with [src]. Luckily, it shut off due to being in the wrong area."), \
					span_warning("[user] prods you with [src]. Luckily, it shut off due to being in the wrong area."))
				active = FALSE
				balloon_alert(user, "wrong department")
				playsound(src, SFX_SPARKS, 75, TRUE, -1)
				update_appearance()
				return BATON_ATTACK_DONE
	. = ..()

/obj/item/melee/baton/security/loaded/departmental/attack_self(mob/user)
	. = ..()
	if(active) // just turned on
		var/area/current_area = get_area(user)
		if(!is_type_in_list(current_area, valid_areas))
			return
		if(non_departmental_uses_left < 4)
			say("Non-departmental uses refreshed!")
			non_departmental_uses_left = 4

/obj/item/melee/baton/security/loaded/departmental/emag_act(mob/user)
	if(!emagged)
		if(user)
			user.visible_message(span_warning("Sparks fly from [src]!"),
							span_warning("You scramble [src]'s departmental lock, allowing it to be used freely!"),
							span_hear("You hear a faint electrical spark."))
		balloon_alert(user, "emagged")
		playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		emagged = TRUE

/obj/item/melee/baton/security/loaded/departmental/medical
	name = "medical stun baton"
	desc = "A stun baton that doesn't operate outside of the Medical department, based off the station's blueprint layout. Can be used outside of Medical up to three times before needing to return!"
	icon_state = "medical_baton"
	valid_areas = list(/area/station/medical, /area/station/maintenance/department/medical, /area/shuttle/escape)

/obj/item/melee/baton/security/loaded/departmental/engineering
	name = "engineering stun baton"
	desc = "A stun baton that doesn't operate outside of the Engineering department, based off the station's blueprint layout. Can be used outside of Engineering up to three times before needing to return!"
	icon_state = "engineering_baton"
	valid_areas = list(/area/station/engineering, /area/station/maintenance/department/engine, /area/shuttle/escape)

/obj/item/melee/baton/security/loaded/departmental/science
	name = "science stun baton"
	desc = "A stun baton that doesn't operate outside of the Science department, based off the station's blueprint layout. Can be used outside of Science up to three times before needing to return!"
	icon_state = "science_baton"
	valid_areas = list(/area/station/science, /area/station/maintenance/department/science, /area/shuttle/escape)

/obj/item/melee/baton/security/loaded/departmental/cargo
	name = "cargo stun baton"
	desc = "A stun baton that doesn't operate outside of the Cargo department, based off the station's blueprint layout. Can be used outside of Cargo up to three times before needing to return!"
	icon_state = "cargo_baton"
	valid_areas = list(/area/station/cargo, /area/station/maintenance/department/cargo, /area/shuttle/escape)

/obj/item/melee/baton/security/loaded/departmental/service
	name = "service stun baton"
	desc = "A stun baton that doesn't operate outside of the Service department, based off the station's blueprint layout. Can be used outside of Service up to three times before needing to return!"
	icon_state = "service_baton"
	valid_areas = list(/area/station/service, /area/station/maintenance/department/chapel, /area/station/maintenance/department/crew_quarters, /area/shuttle/escape)

/obj/item/melee/baton/security/loaded/departmental/prison
	name = "prison stun baton"
	desc = "A stun baton that doesn't operate outside of the Prison, based off the station's blueprint layout. Can be used outside of the Prison up to three times before needing to return!"
	icon_state = "prison_baton"
	valid_areas = list(/area/station/security/prison, /area/station/security/processing, /area/shuttle/escape)

/datum/supply_pack/security/baton_prison
	name = "Prison Baton Crate"
	desc = "Contains an extra baton for Corrections Officers. \
		Just in case you hated the idea of a normal baton in their hands."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	access = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded/departmental/prison)

/datum/supply_pack/service/baton_service
	name = "Service Baton Crate"
	desc = "Contains an extra baton for Service Guards."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	access = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded/departmental/service)

/datum/supply_pack/medical/baton_medical
	name = "Medical Baton Crate"
	desc = "Contains an extra baton for Orderlies."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	access = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded/departmental/medical)

/datum/supply_pack/engineering/baton_engineering
	name = "Engineering Baton Crate"
	desc = "Contains an extra baton for Engineering Guards."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	access = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded/departmental/engineering)

/datum/supply_pack/science/baton_science
	name = "Science Baton Crate"
	desc = "Contains an extra baton for Science Guards."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	access = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded/departmental/science)

/datum/supply_pack/misc/baton_cargo
	name = "Cargo Baton Crate"
	desc = "Contains an extra baton for Customs Agents."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	access = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded/departmental/cargo)

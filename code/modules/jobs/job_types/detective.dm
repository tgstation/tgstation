/datum/job/detective
	title = JOB_DETECTIVE
	description = "Investigate crimes, gather evidence, perform interrogations, \
		run the brig and armory, look badass, smoke cigarettes."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	faction = FACTION_STATION
	// Lowpop: absorbs Warden, Security Officer and Head of Security.
	total_positions = 8
	spawn_positions = 8
	supervisors = SUPERVISOR_CAPTAIN
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "DETECTIVE"

	outfit = /datum/outfit/job/detective
	plasmaman_outfit = /datum/outfit/plasmaman/detective
	departments_list = list(
		/datum/job_department/security,
		)

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	desensitized_base = DESENSITIZED_THRESHOLD
	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DETECTIVE

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 25,
		/obj/item/ammo_box/speedloader/c38 = 20,
		/obj/item/ammo_box/speedloader/c38/dumdum = 5,
		/obj/item/ammo_box/speedloader/c38/hotshot = 5,
		/obj/item/ammo_box/speedloader/c38/iceblox = 5,
		/obj/item/ammo_box/speedloader/c38/match = 5,
		/obj/item/ammo_box/speedloader/c38/trac = 5,
		/obj/item/card/id/advanced/plainclothes = 5,
		/obj/item/storage/belt/holster/detective/full = 1,
	)

	family_heirlooms = list(/obj/item/reagent_containers/cup/glass/bottle/whiskey)
	rpg_title = "Thiefcatcher" //I guess they caught them all rip thief...
	job_flags = STATION_JOB_FLAGS | JOB_ANTAG_PROTECTED
	job_tone = "objection"
	tgui_icon = FA_ICON_USER_SECRET


/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	id = /obj/item/card/id/advanced/plainclothes

	id_trim = /datum/id_trim/job/detective
	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/toggle/jacket/det_trench
	// Lowpop: patrol gear from Security Officer, Warden and Head of Security.
	suit_store = /obj/item/gun/energy/disabler
	backpack_contents = list(
		/obj/item/detective_scanner = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/evidence = 1,
		/obj/item/lighter = 1,
		/obj/item/toy/crayon/white = 1,
		)
	belt = /obj/item/modular_computer/pda/crew/detective
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/black/security
	head = /obj/item/clothing/head/fedora/det_hat
	mask = /obj/item/cigarette
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	messenger = /obj/item/storage/backpack/messenger/sec

	box = /obj/item/storage/box/survival/security

	chameleon_extras = list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/gun/ballistic/revolver/c38/detective,
		)
	implants = list(/obj/item/implant/mindshield)

	skillchips = list(/obj/item/skillchip/job/detectives_taste)

	wintercoat = /obj/item/clothing/suit/hooded/wintercoat/security

/datum/outfit/job/detective/pre_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if (human.age < AGE_MINOR)
		mask = /obj/item/cigarette/candy
		head = /obj/item/clothing/head/fedora/det_hat/minor

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	..()
	var/obj/item/cigarette/cig = H.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light()

	if(visuals_only)
		return

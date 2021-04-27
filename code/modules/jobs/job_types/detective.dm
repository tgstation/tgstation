/datum/job/detective
	title = "Detective"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/detective
	plasmaman_outfit = /datum/outfit/plasmaman/detective

	departments = DEPARTMENT_SECURITY
	display_order = JOB_DISPLAY_ORDER_DETECTIVE
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC

	family_heirlooms = list(
		/obj/item/reagent_containers/food/drinks/bottle/whiskey,
	)
  
	liver_traits = list(
		TRAIT_LAW_ENFORCEMENT_METABOLISM,
	)
  
	mail_goodies = list(
		/obj/item/ammo_box/c38 = 25,
		/obj/item/ammo_box/c38/dumdum = 5,
		/obj/item/ammo_box/c38/hotshot = 5,
		/obj/item/ammo_box/c38/iceblox = 5,
		/obj/item/ammo_box/c38/match = 5,
		/obj/item/ammo_box/c38/trac = 5,
		/obj/item/storage/belt/holster/detective/full = 1,
		/obj/item/storage/fancy/cigarettes = 25,
	)    
  
	mind_traits = list(
		TRAIT_DONUT_LOVER,
	)

/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	id_trim = /datum/id_trim/job/detective
	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/det_suit
	backpack_contents = list(
		/obj/item/detective_scanner = 1,
		/obj/item/melee/classic_baton = 1,
		/obj/item/storage/box/evidence = 1,
		)
	belt = /obj/item/pda/detective
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	mask = /obj/item/clothing/mask/cigarette
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter

	chameleon_extras = list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/gun/ballistic/revolver/detective,
		)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light("")

	if(visualsOnly)
		return

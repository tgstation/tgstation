/datum/job/captain
	title = "Captain"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list("CentCom")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space law"
	selection_color = "#ccccff"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/captain
	plasmaman_outfit = /datum/outfit/plasmaman/captain

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	departments_list = list(
		/datum/job_department/command,
		)

	family_heirlooms = list(/obj/item/reagent_containers/food/drinks/flask/gold)

	mail_goodies = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 10
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_BOLD_SELECT_TEXT | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/captain/get_captaincy_announcement(mob/living/captain)
	return "Captain [captain.real_name] on deck!"


/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain

	id = /obj/item/card/id/advanced/gold
	belt = /obj/item/pda/captain
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/heads/captain/alt
	gloves = /obj/item/clothing/gloves/color/captain
	uniform =  /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/caphat
	backpack_contents = list(/obj/item/melee/baton/telescopic=1, /obj/item/station_charter=1)

	skillchips = list(/obj/item/skillchip/disk_verifier)

	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain

	implants = list(/obj/item/implant/mindshield)
	accessory = /obj/item/clothing/accessory/medal/gold/captain

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/captain)

	id_trim = /datum/id_trim/job/captain
	var/special_charter

/datum/outfit/job/captain/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/list/job_changes = SSmapping.config.job_changes
	if(!length(job_changes))
		return
	var/list/captain_changes = job_changes["captain"]
	if(!length(captain_changes))
		return
	special_charter = captain_changes["special_charter"]
	if(!special_charter)
		return
	backpack_contents.Remove(/obj/item/station_charter)
	l_hand = /obj/item/station_charter/banner

/datum/outfit/job/captain/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()
	var/obj/item/station_charter/banner/celestial_charter = equipped.held_items[LEFT_HANDS]
	if(!celestial_charter)
		return
	celestial_charter.name_type = special_charter

/datum/outfit/job/captain/hardsuit
	name = "Captain (Hardsuit)"

	mask = /obj/item/clothing/mask/gas/atmos/captain
	suit = /obj/item/clothing/suit/space/hardsuit/swat/captain
	suit_store = /obj/item/tank/internals/oxygen

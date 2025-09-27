/datum/job/captain
	title = JOB_CAPTAIN
	description = "Be responsible for the station, manage your Heads of Staff, \
		keep the crew alive, be prepared to do anything and everything or die \
		horribly trying."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list("CentCom")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Space Law"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CAPTAIN"

	outfit = /datum/outfit/job/captain
	plasmaman_outfit = /datum/outfit/plasmaman/captain

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(HEAD_OF_STAFF_MIND_TRAITS)
	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	department_for_prefs = /datum/job_department/captain
	departments_list = list(
		/datum/job_department/command,
	)

	family_heirlooms = list(/obj/item/reagent_containers/cup/glass/flask/gold, /obj/item/toy/captainsaid/collector)

	mail_goodies = list(
		/obj/item/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 5,
		/obj/item/reagent_containers/cup/glass/bottle/champagne/cursed = 5,
		/obj/item/toy/captainsaid/collector = 20,
		/obj/item/skillchip/sabrage = 5,
	)

	job_flags = STATION_JOB_FLAGS | HEAD_OF_STAFF_JOB_FLAGS | JOB_ANTAG_PROTECTED
	rpg_title = "Star Duke"

	human_authority = JOB_AUTHORITY_HUMANS_ONLY

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/captain/get_captaincy_announcement(mob/living/captain)
	return "Captain [captain.real_name] on deck!"

/datum/job/captain/get_radio_information()
	. = ..()
	. += "\nYou have access to all radio channels, but they are not automatically tuned. Check your radio for more information."

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain

	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/captain
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	backpack_contents = list(
		/obj/item/melee/baton/telescopic/gold = 1,
		/obj/item/station_charter = 1,
		)
	belt = /obj/item/modular_computer/pda/heads/captain
	ears = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/captain
	head = /obj/item/clothing/head/hats/caphat
	shoes = /obj/item/clothing/shoes/laceup


	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain
	messenger = /obj/item/storage/backpack/messenger/cap

	accessory = /obj/item/clothing/accessory/medal/gold/captain
	chameleon_extras = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/stamp/head/captain,
		)
	implants = list(/obj/item/implant/mindshield)
	skillchips = list(/obj/item/skillchip/disk_verifier)

	var/special_charter

/datum/outfit/job/captain/pre_equip(mob/living/carbon/human/H, visuals_only)
	. = ..()
	special_charter = CHECK_MAP_JOB_CHANGE(JOB_CAPTAIN, "special_charter")
	if(!special_charter)
		return

	backpack_contents -= /obj/item/station_charter

	if(!l_hand)
		l_hand = /obj/item/station_charter/banner
	else if(!r_hand)
		r_hand = /obj/item/station_charter/banner

/datum/outfit/job/captain/post_equip(mob/living/carbon/human/equipped, visuals_only)
	. = ..()
	if(visuals_only || !special_charter)
		return

	var/obj/item/station_charter/banner/celestial_charter = locate() in equipped.held_items
	if(isnull(celestial_charter))
		// failed to give out the unique charter, plop on the ground
		celestial_charter = new(get_turf(equipped))

	celestial_charter.name_type = special_charter

/datum/outfit/job/captain/mod
	name = "Captain (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/magnate
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/atmos/captain
	internals_slot = ITEM_SLOT_SUITSTORE

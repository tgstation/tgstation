// MARK: Trans-Solar Federation //

// TSF default
/datum/outfit/tsf
	name = "TSF Base"

/datum/outfit/tsf/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/obj/item/card/id/advanced/tsf
	name = "\improper TSF ID"
	desc = "An ID straight from TSF."
	icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	icon_state = "card_tsf"
	assigned_icon_state = "assigned_faction"
	trim = /datum/id_trim/tsf
	wildcard_slots = WILDCARD_LIMIT_CENTCOM

/datum/id_trim/tsf
	access = list(ACCESS_CENT_GENERAL)
	assignment = "TSF"
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_tsf"
	sechud_icon_state = SECHUD_TSF
	department_color = COLOR_MODERATE_BLUE
	subdepartment_color = COLOR_MODERATE_BLUE
	big_pointer = TRUE
	pointer_color = COLOR_UNION_JACK_BLUE

// TSF Commander
/datum/outfit/tsf/commander
	name = "TSF - Commander"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/commander
	uniform = /obj/item/clothing/under/rank/tsf/commander
	suit = /obj/item/clothing/suit/armor/centcom_formal/tsf_commander
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/reagent_containers/hypospray/combat/nanites,
		/obj/item/storage/fancy/cigarettes/cigars/havana,
		/obj/item/reagent_containers/cup/glass/bottle/whiskey,
		/obj/item/stamp/tsf
	)
	accessory = /obj/item/clothing/accessory/holster/tacticool/tsf_commander
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/beret/tsf_commander
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/thermal/eyepatch/tsf_commander
	r_pocket = /obj/item/lighter/skull

/datum/id_trim/tsf/commander
	assignment = "TSF - Commanding Officer"
	trim_state = "trim_tsf_rank3"

/datum/id_trim/tsf/commander/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)) + ACCESS_COMMAND)

// TSF Marine (Unarmed)
/datum/outfit/tsf/marine_unarmed
	name = "TSF - Marine (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine
	uniform = /obj/item/clothing/under/rank/tsf/marine
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
	)
	head = /obj/item/clothing/head/beret/tsf_marine
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/sunglasses

/datum/id_trim/tsf/marine
	assignment = "TSF - Marine"
	big_pointer = FALSE
	trim_state = "trim_tsf_rank1"

/datum/id_trim/tsf/marine/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)))

// TSF Marine Officer (Unarmed)
/datum/outfit/tsf/marine_officer
	name = "TSF - Marine Officer (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/officer
	uniform = /obj/item/clothing/under/rank/tsf/marine_officer
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/lighter/greyscale,
	)
	head = /obj/item/clothing/head/beret/tsf_marine_officer
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	belt = /obj/item/storage/belt/military/army/tsf/full_pistol
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf

/datum/id_trim/tsf/marine/officer
	assignment = "TSF - Marine Officer"
	trim_state = "trim_tsf_rank2"
	big_pointer = TRUE

// TSF Marine
// Rifleman
/datum/outfit/tsf/marine
	name = "TSF - Marine Rifleman"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine
	uniform = /obj/item/clothing/under/rank/tsf/marine
	suit = /obj/item/clothing/suit/armor/vest/marine/security
	suit_store = /obj/item/gun/ballistic/automatic/carwo/auto
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/regular,
		/obj/item/grenade/frag,
		/obj/item/clothing/head/beret/tsf_marine,
	)
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	mask = /obj/item/clothing/mask/gas/sechailer
	head = /obj/item/clothing/head/helmet/marine/security
	belt = /obj/item/storage/belt/military/army/tsf/full_autorifle_carwo
	l_pocket = /obj/item/knife/combat

// Officer
/datum/outfit/tsf/marine/officer
	name = "TSF - Marine Officer"
	id_trim = /datum/id_trim/tsf/marine/officer
	uniform = /obj/item/clothing/under/rank/tsf/marine_officer
	suit = /obj/item/clothing/suit/armor/vest/marine
	suit_store = /obj/item/gun/ballistic/automatic/carwo/auto/black
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/storage/box/zipties,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/clothing/head/beret/tsf_marine_officer,
	)
	belt = /obj/item/storage/belt/military/army/tsf/full_autorifle_carwo_officer
	glasses = /obj/item/clothing/glasses/hud/security/night
	neck = /obj/item/binoculars
	head = /obj/item/clothing/head/helmet/marine

// Medic
/datum/outfit/tsf/marine/medic
	name = "TSF - Marine Corpsman"
	id_trim = /datum/id_trim/tsf/marine/corpsman
	suit = /obj/item/clothing/suit/armor/vest/marine/medic
	suit_store = /obj/item/gun/ballistic/automatic/sindano
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/o2,
		/obj/item/storage/medkit/toxin,
		/obj/item/storage/medkit/tactical,
		/obj/item/defibrillator/compact/loaded,
		/obj/item/clothing/head/beret/tsf_marine,
	)
	belt = /obj/item/storage/belt/military/army/tsf/full_smg_sindano
	head = /obj/item/clothing/head/helmet/marine/medic
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses

	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/id_trim/tsf/marine/corpsman
	assignment = "TSF - Marine Corpsman"

// Engineer
/datum/outfit/tsf/marine/engineer
	name = "TSF - Marine Combat Technician"
	id_trim = /datum/id_trim/tsf/marine/engineer
	suit = /obj/item/clothing/suit/armor/vest/marine/engineer
	suit_store = /obj/item/gun/ballistic/shotgun/riot/renoster
	back = /obj/item/mounted_machine_gun_folded
	backpack_contents = null
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	head = /obj/item/clothing/head/helmet/marine/engineer
	belt = /obj/item/storage/belt/military/army/tsf/full_engineer
	l_pocket = /obj/item/wrench
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

/datum/id_trim/tsf/marine/engineer
	assignment = "TSF - Marine Combat Technician"

// Grenadier
/datum/outfit/tsf/marine/grenadier
	name = "TSF - Marine Grenadier"
	id_trim = /datum/id_trim/tsf/marine/grenadier
	suit = /obj/item/clothing/suit/armor/vest/marine/engineer
	suit_store = /obj/item/gun/ballistic/rocketlauncher/unrestricted
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/regular,
		/obj/item/ammo_box/rocket = 2,
		/obj/item/ammo_casing/rocket/weak = 2,
		/obj/item/clothing/head/beret/tsf_marine,
	)
	belt = /obj/item/storage/belt/military/army/tsf/full_rpg

/datum/id_trim/tsf/marine/grenadier
	assignment = "TSF - Marine Grenadier"

// Snipers
/datum/outfit/tsf/marine/sniper
	name = "TSF - Marine Marksman"
	id_trim = /datum/id_trim/tsf/marine/sniper
	suit_store = /obj/item/gun/ballistic/automatic/carwo/marksman
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/regular,
		/obj/item/clothing/head/beret/tsf_marine,
	)
	belt = /obj/item/storage/belt/military/army/tsf/full_sniper_carwo
	glasses = /obj/item/clothing/glasses/hud/security/night
	neck = /obj/item/binoculars

/datum/id_trim/tsf/marine/sniper
	assignment = "TSF - Marine Marksman"

// Riot
/datum/outfit/tsf/marine/riot
	name = "TSF - Riot Specialist"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/riot
	uniform = /obj/item/clothing/under/rank/tsf/marine
	suit = /obj/item/clothing/suit/armor/riot
	suit_store = /obj/item/gun/ballistic/shotgun/automatic/combat/compact
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/megaphone/sec,
		/obj/item/storage/medkit/regular,
		/obj/item/storage/box/zipties,
		/obj/item/ammo_box/c12ga/rubbershot,
		/obj/item/ammo_box/c12ga/beanbag,
	)
	head = /obj/item/clothing/head/helmet/toggleable/riot
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	belt = /obj/item/storage/belt/security/full
	l_hand = /obj/item/melee/baton/security/loaded/ert
	r_hand = /obj/item/shield/riot/flash
	l_pocket = /obj/item/assembly/flash
	r_pocket = /obj/item/grenade/flashbang

/datum/id_trim/tsf/marine/riot
	assignment = "TSF - Riot Specialist"

// TSF Heavy Troopers
/datum/outfit/tsf/marine/machinegunner
	name = "TSF - Marine Machinegunner"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marine/machinegunner
	uniform = /obj/item/clothing/under/rank/tsf/marine
	suit = /obj/item/clothing/suit/armor/swat/tsf_heavy
	suit_store = /obj/item/gun/ballistic/automatic/carwo/auto/machinegun
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/smokebomb = 2,
	)
	belt = /obj/item/storage/belt/military/army/tsf/full_machinegun
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	head = /obj/item/clothing/head/helmet/marine/security/tsf_heavy

/datum/id_trim/tsf/marine/machinegunner
	assignment = "TSF - Marine Machinegunner"

// TSF MARSOC (Unarmed)
/datum/outfit/tsf/marsoc_unarmed
	name = "TSF - MARSOC (Unarmed)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc
	uniform = /obj/item/clothing/under/rank/tsf/marsoc
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
	)
	head = /obj/item/clothing/head/beret/tsf_marsoc
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	belt = /obj/item/storage/belt/military/army/tsf/full_pistol

/datum/id_trim/tsf/marsoc
	assignment = "TSF - MARSOC"

/datum/id_trim/tsf/marsoc/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_GENERAL)) + ACCESS_COMMAND)

// TSF MARSOC Officer (Unarmed)
/datum/outfit/tsf/marsoc_unarmed/officer
	name = "TSF - MARSOC Officer (Unarmed)"
	id_trim = /datum/id_trim/tsf/marsoc/officer
	uniform = /obj/item/clothing/under/rank/tsf/marsoc_officer
	head = /obj/item/clothing/head/beret/tsf_marsoc_officer
	belt = /obj/item/storage/belt/military/army/tsf/full_pistol

/datum/id_trim/tsf/marsoc/officer
	assignment = "TSF - MARSOC Officer"
	trim_state = "trim_tsf_rank2"

// TSF MARSOC (MOD)
/datum/outfit/tsf/marsoc
	name = "TSF - MARSOC"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc/breacher
	uniform = /obj/item/clothing/under/rank/tsf/marsoc
	suit_store = /obj/item/gun/ballistic/automatic/carwo/auto/black/suppressed
	back = /obj/item/mod/control/pre_equipped/tsf_standart
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4 = 2,
		/obj/item/clothing/head/beret/tsf_marsoc,
	)
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/night
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	belt = /obj/item/storage/belt/military/army/tsf/full_autorifle_carwo_marsok
	l_pocket = /obj/item/knife/combat

/datum/outfit/tsf/marsoc/breacher
	name = "TSF - MARSOC (Breacher)"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/marsoc/breacher
	uniform = /obj/item/clothing/under/rank/tsf/marsoc
	suit_store = /obj/item/gun/ballistic/shotgun/riot/renoster/black/sawoff
	back = /obj/item/mod/control/pre_equipped/tsf_standart
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4/x4 = 2,
		/obj/item/clothing/head/beret/tsf_marsoc,
	)
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/night
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	belt = /obj/item/storage/belt/military/army/tsf/full_engineer

/datum/id_trim/tsf/marsoc/breacher
	assignment = "TSF - MARSOC Breaching Specialist"

// TSF MARSOC Officer (MOD)
/datum/outfit/tsf/marsoc/officer
	name = "TSF - MARSOC Officer"
	id_trim = /datum/id_trim/tsf/marsoc/officer
	uniform = /obj/item/clothing/under/rank/tsf/marsoc_officer
	back = /obj/item/mod/control/pre_equipped/tsf_elite
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/c4 = 2,
	)
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer
	glasses = /obj/item/clothing/glasses/hud/security/night
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	belt = /obj/item/storage/belt/military/army/tsf/full_autorifle_carwo_marsok
	neck = /obj/item/binoculars

/datum/outfit/tsf/marsoc/officer/post_equip(mob/living/carbon/human/squaddie, visuals_only = FALSE)
	. = ..()
	var/obj/item/mod/control/mod = squaddie.back
	if(!istype(mod))
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/head/beret/tsf_marsoc_officer/beret = new(helmet)
	var/datum/component/hat_stabilizer/component = helmet.GetComponent(/datum/component/hat_stabilizer)
	component.attach_hat(beret)
	squaddie.update_clothing(helmet.slot_flags)

// TSF infiltrator
/datum/outfit/tsf/infiltrator
	name = "TSF - Infiltrator"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/infiltrator
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/hooded/stealth_cloak/black
	suit_store = /obj/item/gun/ballistic/automatic/carwo/auto/black/suppressed
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/c4 = 2,
		/obj/item/clothing/head/beret/tsf_infiltrator
	)
	implants = list(/obj/item/implant/emp, /obj/item/implant/cqc)
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/meson/night
	mask = /obj/item/clothing/mask/breath/breathscarf/tsf_infiltrator
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	neck = /obj/item/binoculars
	belt = /obj/item/storage/belt/military/army/tsf/full_infiltrator
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/knife/combat

/datum/id_trim/tsf/infiltrator
	assignment = "TSF - Infiltrator"
	trim_state = "trim_tsf_rank2"
	big_pointer = FALSE

/datum/id_trim/tsf/infiltrator/New()
	. = ..()
	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

// TSF representative
/datum/outfit/tsf/representative
	name = "TSF - Representative"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/representative
	uniform = /obj/item/clothing/under/rank/tsf/representative
	suit = /obj/item/clothing/suit/armor/vest/tsf_overcoat
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/lighter/greyscale,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba,
		/obj/item/stamp/tsf,
		/obj/item/folder/blue,
		/obj/item/pen/fourcolor,
	)
	head = /obj/item/clothing/head/hats/fedora/tsf
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/stack/spacecash/c1000

/datum/id_trim/tsf/representative
	assignment = "Trans-Solar Federation Representative"

/datum/id_trim/tsf/representative/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_SECURITY - ACCESS_CAPTAIN - ACCESS_AI_UPLOAD)

// TSF diplomat
/datum/outfit/tsf/diplomat
	name = "TSF - Diplomat"
	id = /obj/item/card/id/advanced/tsf
	id_trim = /datum/id_trim/tsf/diplomat
	uniform = /obj/item/clothing/under/rank/tsf/formal
	suit = /obj/item/clothing/suit/tsf_suitjacket
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba,
		/obj/item/stamp/tsf,
		/obj/item/folder/blue,
		/obj/item/pen/fourcolor,
	)
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/beret/tsf_diplomat
	ears = /obj/item/radio/headset/heads/captain/alt/tsf
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase
	neck = /obj/item/clothing/neck/tsf_fancy_cloak
	l_pocket = /obj/item/stack/spacecash/c1000
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf

/datum/id_trim/tsf/diplomat
	assignment = "Trans-Solar Federation Diplomat"
	trim_state = "trim_tsf_rank3"

/datum/id_trim/tsf/diplomat/New()
	. = ..()
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_SECURITY - ACCESS_CAPTAIN - ACCESS_AI_UPLOAD)

/obj/item/storage/box/survival/tsf
	mask_type = /obj/item/clothing/mask/gas/sechailer
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/tsf/PopulateContents()
	. = ..()
	new /obj/item/crowbar(src)
	new /obj/item/food/rationpack(src)
	new /obj/item/radio/off(src)
	new /obj/item/flashlight/seclite(src)

/obj/item/storage/box/survival/tsf/officer
	medipen_type =  /obj/item/reagent_containers/hypospray/medipen/atropine
	internal_type = /obj/item/tank/internals/emergency_oxygen/double

/datum/outfit/tsf/post_equip(mob/living/carbon/human/translator, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		return
	translator.grant_language(/datum/language/uncommon)
	translator.grant_language(/datum/language/common)
	translator.remove_blocked_language(/datum/language/uncommon)
	translator.set_active_language(/datum/language/uncommon)

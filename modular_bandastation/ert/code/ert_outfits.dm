/datum/outfit/centcom/ert
	uniform = /obj/item/clothing/under/rank/centcom/military/ert
	mask = /obj/item/clothing/mask/gas/sechailer/swat

// MARK: SECURITY
/datum/outfit/centcom/ert/security
	name = "ERT Security - Base"
	id = /obj/item/card/id/advanced/centcom/ert/security
	back = /obj/item/storage/backpack/ert/security
	box = /obj/item/storage/box/survival/centcom
	l_hand = null
	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
	)
	belt = /obj/item/storage/belt/security/full
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	additional_radio = /obj/item/encryptionkey/heads/hos

/datum/outfit/centcom/ert/security/amber
	name = "ERT Security - Amber"
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/webbing/ert/full
	suit = /obj/item/clothing/suit/armor/swat/ert
	suit_store = /obj/item/gun/energy/e_gun
	head = /obj/item/clothing/head/helmet/swat/nanotrasen

/datum/outfit/centcom/ert/security/red
	name = "ERT Security - Red"
	suit = /obj/item/clothing/suit/armor/vest/marine/security
	belt = /obj/item/storage/belt/military/assault/ert/full_red_security
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/hos = 1,
		/obj/item/storage/box/handcuffs = 1,
	)
	head = /obj/item/clothing/head/helmet/marine/security
	suit_store = /obj/item/gun/ballistic/automatic/laser

/datum/outfit/centcom/ert/security/gamma
	name = "ERT Security - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/security
	belt = /obj/item/storage/belt/military/ert/full_gamma_security
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/storage/box/handcuffs = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/flash = 1,
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
	)
	suit_store = /obj/item/gun/energy/e_gun/stun
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated

/datum/outfit/centcom/ert/security/inquisitor
	name = "ERT Security - Inquisition"
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/security
	belt = /obj/item/storage/belt/military/ert/full_gamma_security
	backpack_contents = list(
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/flash = 1,
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
	)
	suit_store = /obj/item/gun/energy/e_gun/stun
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated

// MARK: COMMANDER
/datum/outfit/centcom/ert/commander
	name = "ERT Commander - Base"
	id = /obj/item/card/id/advanced/centcom/ert
	back = /obj/item/storage/backpack/ert
	l_hand = null
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/storage/box/zipties = 1,
	)
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/headset_cent/alt/leader
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/switchblade
	additional_radio = /obj/item/encryptionkey/heads/captain

/datum/outfit/centcom/ert/commander/amber
	name = "ERT Commander - Amber"
	belt = /obj/item/storage/belt/security/webbing/ert/full
	suit = /obj/item/clothing/suit/armor/swat/ert
	head = /obj/item/clothing/head/helmet/marine
	backpack_contents = list(
		/obj/item/clothing/head/beret/ert/amber = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/flash
	)
	accessory = /obj/item/clothing/accessory/holster/tacticool/ert_gp93r
	l_pocket = /obj/item/melee/baton/telescopic/bronze
	r_pocket = /obj/item/switchblade

/datum/outfit/centcom/ert/commander/red
	name = "ERT Commander - Red"
	suit = /obj/item/clothing/suit/armor/vest/marine
	belt = /obj/item/storage/belt/military/assault/ert/full_red_commander
	head = /obj/item/clothing/head/helmet/marine
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/hos = 1,
		/obj/item/clothing/head/beret/ert/red = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/baton
	)
	suit_store = /obj/item/gun/energy/e_gun/nuclear
	l_pocket = /obj/item/melee/baton/telescopic/silver
	r_pocket = /obj/item/knife/combat

/datum/outfit/centcom/ert/commander/gamma
	name = "ERT Commander - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/commander
	accessory = /obj/item/clothing/accessory/holster/tacticool/ert_gammacom
	belt = /obj/item/storage/belt/military/ert/full_gamma_commander
	l_pocket = /obj/item/melee/baton/telescopic/gold
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/esword = 1,
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
	)

/datum/outfit/centcom/ert/commander/gamma/post_equip(mob/living/carbon/human/squaddie, visuals_only = FALSE)
	. = ..()
	var/obj/item/mod/control/mod = squaddie.back
	if(!istype(mod))
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	var/obj/item/clothing/head/beret/ert/gamma/beret = new(helmet)
	var/datum/component/hat_stabilizer/component = helmet.GetComponent(/datum/component/hat_stabilizer)
	component.attach_hat(beret)
	squaddie.update_clothing(helmet.slot_flags)

/datum/outfit/centcom/ert/commander/inquisitor
	name = "ERT Commander - Inquisition"
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/commander
	accessory = /obj/item/clothing/accessory/holster/tacticool/ert_gammacom
	belt = /obj/item/nullrod/claymore/talking/chainsword
	l_pocket = /obj/item/melee/baton/telescopic/gold
	backpack_contents = list(
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/esword = 1,
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
	)
	r_hand = null

// MARK: MEDIC
/datum/outfit/centcom/ert/medic
	name = "ERT Medic - Base"
	id = /obj/item/card/id/advanced/centcom/ert/medical
	back = /obj/item/storage/backpack/ert/medical
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/storage/box/hug/plushes = 1,
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/medkit/regular = 1,
	)
	belt = /obj/item/storage/belt/medical/ert
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_hand = null
	r_hand = null
	l_pocket = null
	additional_radio = /obj/item/encryptionkey/heads/cmo
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/outfit/centcom/ert/medic/amber
	name = "ERT Medic - Amber"
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit = /obj/item/clothing/suit/armor/swat/ert
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	suit_store = /obj/item/gun/energy/disabler
	belt = /obj/item/storage/belt/medical/paramedic

/datum/outfit/centcom/ert/medic/red
	name = "ERT Medic - Red"
	suit = /obj/item/clothing/suit/armor/vest/marine/medic
	accessory = /obj/item/clothing/accessory/holster/tacticool/ert_gp93r
	back = /obj/item/storage/backpack/ert/medical
	head = /obj/item/clothing/head/helmet/marine/medic
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/hos = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/storage/medkit/tactical_lite = 1,
		/obj/item/storage/medkit/advanced = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/eyes/hud/medical
	)

/datum/outfit/centcom/ert/medic/gamma
	name = "ERT Medic - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/medic
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/storage/medkit/tactical = 1,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/storage/box/hug/plushes = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/surgery = 1,
		/obj/item/organ/cyberimp/eyes/hud/medical = 1,
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
	)
	suit_store = /obj/item/gun/energy/e_gun/nuclear

/datum/outfit/centcom/ert/medic/inquisitor
	name = "ERT Medic - Inquisition"
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/medic
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/storage/medkit/tactical = 1,
		/obj/item/storage/box/hug/plushes = 1,
		/obj/item/reagent_containers/hypospray/combat/nanites = 1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge = 1,
		/obj/item/book/bible = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/arm/toolkit/surgery = 1,
		/obj/item/organ/cyberimp/eyes/hud/medical = 1,
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
	)
	suit_store = /obj/item/gun/energy/e_gun/nuclear

// MARK: ENGINEER
/datum/outfit/centcom/ert/engineer
	name = "ERT Engineer - Base"
	uniform = /obj/item/clothing/under/rank/centcom/military/eng/ert
	id = /obj/item/card/id/advanced/centcom/ert/engineer
	back = /obj/item/storage/backpack/ert/engineer
	l_hand = null
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/rcd_ammo/large = 1,
	)
	belt = /obj/item/storage/belt/utility/full/powertools
	glasses = /obj/item/clothing/glasses/meson/sunglasses
	l_pocket = /obj/item/rcd_ammo/large
	additional_radio = /obj/item/encryptionkey/heads/ce
	skillchips = list(/obj/item/skillchip/job/engineer)

/datum/outfit/centcom/ert/engineer/amber
	name = "ERT Engineer - Amber"
	suit = /obj/item/clothing/suit/armor/swat/ert
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	suit_store = /obj/item/gun/energy/disabler/smg

/datum/outfit/centcom/ert/engineer/red
	name = "ERT Engineer - Red"
	suit = /obj/item/clothing/suit/armor/vest/marine/engineer
	head = /obj/item/clothing/head/helmet/marine/engineer
	backpack_contents = list(
		/obj/item/construction/rcd/ce = 1,
		/obj/item/melee/baton/security/loaded/hos = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/rcd_ammo/large = 1,
		/obj/item/storage/box/breacherslug = 1,
		/obj/item/storage/box/beanbag = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/eyes/hud/diagnostic
	)
	suit_store = /obj/item/gun/ballistic/shotgun/riot

/datum/outfit/centcom/ert/engineer/gamma
	name = "ERT Engineer - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/engineer
	backpack_contents = list(
		/obj/item/construction/rcd/combat = 1,
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/rcd_ammo/large = 1,
		/obj/item/storage/box/breacherslug = 1,
		/obj/item/storage/box/lethalshot = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
		/obj/item/organ/cyberimp/eyes/hud/diagnostic = 1,
		/obj/item/organ/cyberimp/arm/toolkit/toolset = 1,
	)
	belt = /obj/item/storage/belt/utility/chief/full
	suit_store = /obj/item/gun/ballistic/shotgun/automatic/combat/compact

// MARK: CHAPLAIN
/datum/outfit/centcom/ert/chaplain
	name = "ERT Chaplain - Base"
	id = /obj/item/card/id/advanced/centcom/ert/chaplain
	back = /obj/item/storage/backpack/cultpack
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)
	l_hand = null
	belt = /obj/item/storage/belt/soulstone/full/chappy
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	box = /obj/item/storage/box/survival/centcom
	additional_radio = /obj/item/encryptionkey/heads/hop
	l_pocket = /obj/item/nullrod

/datum/outfit/centcom/ert/chaplain/amber
	name = "ERT Chaplain - Amber"
	suit = /obj/item/clothing/suit/chaplainsuit/armor/templar
	head = /obj/item/clothing/head/helmet/chaplain
	gloves = /obj/item/clothing/gloves/plate
	shoes = /obj/item/clothing/shoes/plate
	belt = /obj/item/nullrod/claymore
	r_pocket = /obj/item/flashlight/lantern
	l_hand = /obj/item/gun/energy/disabler/smoothbore/prime

/datum/outfit/centcom/ert/chaplain/red
	name = "ERT Chaplain - Red"
	suit = /obj/item/clothing/suit/chaplainsuit/armor/crusader/ert
	head = /obj/item/clothing/head/helmet/plate/crusader/ert
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/hos = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/eyes/hud/security
	)
	belt = /obj/item/claymore/weak
	r_pocket = /obj/item/flashlight/lantern
	suit_store = /obj/item/gun/energy/e_gun

/datum/outfit/centcom/ert/chaplain/gamma
	name = "ERT Chaplain - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/chaplain
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
		/obj/item/organ/cyberimp/eyes/hud/security = 1,
	)
	belt = /obj/item/claymore
	suit_store = /obj/item/gun/energy/e_gun/nuclear

/datum/outfit/centcom/ert/chaplain/inquisitor
	name = "ERT Chaplain - Inquisition"
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/holy = 1,
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/hypospray/combat/heresypurge = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/brain/anti_stun = 1,
		/obj/item/organ/cyberimp/eyes/hud/security = 1,
	)
	belt = /obj/item/storage/belt/soulstone/full/chappy
	suit_store = /obj/item/gun/energy/e_gun/nuclear

// MARK: JANITOR
/datum/outfit/centcom/ert/janitor
	name = "ERT Janitor - Base"
	id = /obj/item/card/id/advanced/centcom/ert/janitor
	back = /obj/item/storage/backpack/ert/janitor
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/storage/box/lights/mixed = 1,
	)
	belt = /obj/item/storage/belt/janitor/full
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_hand = /obj/item/storage/bag/trash/bluespace
	additional_radio = /obj/item/encryptionkey/heads/hop

/datum/outfit/centcom/ert/janitor/amber
	name = "ERT Janitor - Amber"
	suit = /obj/item/clothing/suit/apron/ert
	head = /obj/item/clothing/head/beret/ert/janitor

/datum/outfit/centcom/ert/janitor/red
	name = "ERT Janitor - Red"
	suit = /obj/item/clothing/suit/armor/vest/marine
	head = /obj/item/clothing/head/helmet/marine/security
	backpack_contents = list(
		/obj/item/grenade/clusterbuster/cleaner = 1,
		/obj/item/melee/baton/security/loaded/hos = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/clothing/head/beret/ert/janitor = 1,
	)
	r_hand = /obj/item/reagent_containers/spray/cleaner

/datum/outfit/centcom/ert/janitor/gamma
	name = "ERT Janitor - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/janitor
	backpack_contents = list(
		/obj/item/grenade/clusterbuster/cleaner = 3,
		/obj/item/melee/baton/security/loaded/ert = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/clothing/head/beret/ert/janitor = 1,
	)
	organs = list(
		/obj/item/organ/cyberimp/brain/anti_stun
	)
	r_hand = /obj/item/reagent_containers/spray/chemsprayer/janitor

// MARK: CLOWN
/datum/outfit/centcom/ert/clown
	name = "ERT Clown - Base"
	id = /obj/item/card/id/advanced/centcom/ert/clown
	back = /obj/item/storage/backpack/ert/clown
	box = /obj/item/storage/box/survival/centcom
	backpack_contents = list(
		/obj/item/toy/gun = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/food/pie/cream = 2,
		/obj/item/bikehorn/airhorn = 1,
	)
	belt = /obj/item/storage/belt/champion
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	mask = /obj/item/clothing/mask/gas/clown_hat
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	l_pocket = /obj/item/food/grown/banana
	r_pocket = /obj/item/bikehorn/golden
	additional_radio = /obj/item/encryptionkey/heads/hop

/datum/outfit/centcom/ert/clown/amber
	name = "ERT Clown - Amber"
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/sec
	glasses = /obj/item/clothing/glasses/trickblindfold

/datum/outfit/centcom/ert/clown/red
	name = "ERT Clown - Red"
	suit = /obj/item/clothing/suit/armor/vest/marine
	head = /obj/item/clothing/head/helmet/marine
	backpack_contents = list(
		/obj/item/toy/gun = 1,
		/obj/item/reagent_containers/spray/waterflower/superlube = 1,
		/obj/item/food/pie/cream = 2,
		/obj/item/bikehorn/airhorn = 1,
		/obj/item/stack/sheet/mineral/bananium = 10,
	)
	belt = /obj/item/storage/belt/military/assault/ert/full_red_clown
	shoes = /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat

/datum/outfit/centcom/ert/clown/gamma
	name = "ERT Clown - Gamma"
	back = /obj/item/mod/control/pre_equipped/responsory/clown
	backpack_contents = list(
		/obj/item/gun/ballistic/revolver/reverse = 1,
		/obj/item/melee/energy/sword/bananium = 1,
		/obj/item/shield/energy/bananium = 1,
		/obj/item/reagent_containers/spray/waterflower/superlube = 1,
		/obj/item/food/pie/cream = 2,
		/obj/item/bikehorn/airhorn = 1,
		/obj/item/stack/sheet/mineral/bananium = 15,
	)
	organs = list(
		/obj/item/organ/cyberimp/brain/anti_stun
	)
	belt = /obj/item/storage/belt/military/assault/ert/full_gamma_clown
	shoes = /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	l_pocket = /obj/item/food/grown/banana/bunch
	l_hand = /obj/item/pneumatic_cannon/pie/selfcharge

// MARK: OLD PRESETS
// TODO220: Don't change TG ert teams modularly, need to create our own
/datum/outfit/centcom/ert/security/alert
	name = "(OLD OUTFIT) ERT Security - High Alert"
	back = /obj/item/mod/control/pre_equipped/responsory/security

/datum/outfit/centcom/ert/medic/alert
	name = "(OLD OUTFIT) ERT Medic - High Alert"
	back = /obj/item/mod/control/pre_equipped/responsory/medic

/datum/outfit/centcom/ert/engineer/alert
	name = "(OLD OUTFIT) ERT Engineer - High Alert"
	back = /obj/item/mod/control/pre_equipped/responsory/engineer

/datum/outfit/centcom/ert/commander/alert
	name = "(OLD OUTFIT) ERT Commander - High Alert"
	back = /obj/item/mod/control/pre_equipped/responsory/commander

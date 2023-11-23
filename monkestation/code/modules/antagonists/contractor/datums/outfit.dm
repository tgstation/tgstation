/datum/outfit/contractor
	name = "Syndicate Contractor - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/mod/control/pre_equipped/contractor/upgraded
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/storage/belt/military

	uniform = /obj/item/clothing/under/syndicate/coldres
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/modular_computer/tablet/syndicate_contract_uplink
	id = /obj/item/card/id/advanced/chameleon
	backpack_contents = list(
		/obj/item/storage/box/survival/syndie,
		/obj/item/storage/box/syndie_kit/contract_kit,
		/obj/item/knife/combat/survival,
		/obj/item/pinpointer/crew/contractor
	)

	implants = list(
		/obj/item/implant/uplink/precharged,
		/obj/item/implant/explosive,
	)

	id_trim = /datum/id_trim/chameleon/contractor

/datum/outfit/contractor_preview
	name = "Syndicate Contractor (Preview only)"

	back = /obj/item/mod/control/pre_equipped/syndicate_empty/contractor
	uniform = /obj/item/clothing/under/syndicate
	glasses = /obj/item/clothing/glasses/night

/datum/outfit/contractor/fully_upgraded
	name = "Syndicate Contractor - Fully Upgraded"
	back = /obj/item/mod/control/pre_equipped/contractor/upgraded/adminbus

/datum/id_trim/chameleon/contractor
	assignment = "Syndicate Contractor"
	trim_state = "trim_contractor"

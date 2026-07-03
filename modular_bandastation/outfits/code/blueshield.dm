/datum/outfit/job/blueshield
	name = "Blueshield"

	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield_jacket
	suit_store = /obj/item/gun/energy/eg_14
	gloves = /obj/item/clothing/gloves/tackler/combat
	id = /obj/item/card/id/advanced/nanotrasen_official
	id_trim = /datum/id_trim/job/blueshield
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/blueshield/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	implants = list(/obj/item/implant/mindshield)

	backpack = /obj/item/storage/backpack/blueshield
	backpack_contents = list(
		/obj/item/storage/box/deathimp
	)
	satchel = /obj/item/storage/backpack/satchel/blueshield
	duffelbag = /obj/item/storage/backpack/duffelbag/blueshield

	head = /obj/item/clothing/head/beret/blueshield
	box = /obj/item/storage/box/survival/security
	belt = /obj/item/modular_computer/pda/heads/blueshield

/datum/outfit/plasmaman/blueshield
	name = "Blueshield Plasmaman"
	head = /obj/item/clothing/head/helmet/space/plasmaman/blueshield
	uniform = /obj/item/clothing/under/plasmaman/blueshield

/datum/outfit/job/blueshield/mod
	name = "Blueshield (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/praetorian
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas
	internals_slot = ITEM_SLOT_SUITSTORE

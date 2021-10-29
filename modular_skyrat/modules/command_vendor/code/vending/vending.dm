/obj/machinery/vending/access/command
	name = "\improper Command Outfitting Station"
	desc = "A vending machine for specialised clothing for members of Command."
	product_ads = "File paperwork in style!;It's red so you can't see the blood!;You have the right to be fashionable!;Now you can be the fashion police you always wanted to be!"
	icon = 'modular_skyrat/modules/command_vendor/icons/vending/vending.dmi'
	icon_state = "commdrobe"
	light_mask = "wardrobe-light-mask"
	vend_reply = "Thank you for using the CommDrobe!"
	auto_build_products = TRUE
	payment_department = ACCOUNT_CMD

/obj/machinery/vending/access/command/build_access_list(list/access_lists)
	access_lists["[ACCESS_CAPTAIN]"] = list(
		// CAPTAIN
		/obj/item/clothing/head/caphat = 1,
		/obj/item/clothing/head/caphat/beret = 1,
		/obj/item/clothing/head/caphat/beret/alt = 1,
		/obj/item/clothing/under/rank/captain = 1,
		/obj/item/clothing/under/rank/captain/skirt = 1,
		/obj/item/clothing/under/rank/captain/humble = 1,
		/obj/item/clothing/under/rank/captain/dress = 1,
		/obj/item/clothing/under/rank/captain/kilt = 1,
		/obj/item/clothing/under/rank/captain/imperial = 1,
		/obj/item/clothing/head/caphat/parade = 1,
		/obj/item/clothing/under/rank/captain/parade = 1,
		/obj/item/clothing/under/rank/captain/kilt = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal = 1,
		/obj/item/clothing/suit/captunic = 1,
		/obj/item/clothing/neck/mantle/capmantle = 1,
		/obj/item/storage/backpack/captain = 1,
		/obj/item/storage/backpack/satchel/cap = 1,
		/obj/item/storage/backpack/duffelbag/captain = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,

		// BLUESHIELD
		/obj/item/clothing/head/beret/blueshield = 1,
		/obj/item/clothing/head/beret/blueshield/navy = 1,
		/obj/item/clothing/under/rank/security/blueshield = 1,
		/obj/item/clothing/under/rank/security/blueshieldturtleneck = 1,
		/obj/item/clothing/under/rank/security/blueshieldskirt = 1,
		/obj/item/clothing/suit/armor/vest/blueshield = 1,
		/obj/item/clothing/suit/armor/vest/blueshieldarmor = 1,
		/obj/item/clothing/neck/mantle/bsmantle = 1,
		/obj/item/storage/backpack/blueshield = 1,
		/obj/item/storage/backpack/satchel/blueshield = 1,
		/obj/item/storage/backpack/duffel/blueshield = 1,
		/obj/item/clothing/shoes/laceup = 1
		)
	access_lists["[ACCESS_HOP]"] = list( // Best head btw
		/obj/item/clothing/head/hopcap = 1,
		/obj/item/clothing/head/hopcap/beret = 1,
		/obj/item/clothing/head/hopcap/beret/alt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/turtleneck = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/turtleneck/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/parade = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/parade/female = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/imperial = 1,
		/obj/item/clothing/suit/toggle/hop_parade = 1,
		/obj/item/clothing/neck/mantle/hopmantle = 1,
		/obj/item/storage/backpack/head_of_personnel = 1,
		/obj/item/storage/backpack/satchel/head_of_personnel = 1,
		/obj/item/storage/backpack/duffel/head_of_personnel = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1
		)
	access_lists["[ACCESS_CMO]"] = list(
		/obj/item/clothing/head/beret/medical/cmo = 1,
		/obj/item/clothing/head/beret/medical/cmo/alt = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/imperial = 1,
		/obj/item/clothing/neck/mantle/cmomantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1
		)
	access_lists["[ACCESS_RD]"] = list(
		/obj/item/clothing/head/beret/science/fancy/rd = 1,
		/obj/item/clothing/head/beret/science/fancy/rd/alt = 1,
		/obj/item/clothing/under/rank/rnd/research_director = 1,
		/obj/item/clothing/under/rank/rnd/research_director/skirt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/alt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/alt/skirt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck = 1,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/imperial = 1,
		/obj/item/clothing/neck/mantle/rdmantle = 1,
		/obj/item/clothing/suit/toggle/labcoat = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1
		)
	access_lists["[ACCESS_CE]"] = list(
		/obj/item/clothing/head/beret/engi/ce = 1,
		/obj/item/clothing/head/beret/engi/ce/alt = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer/skirt = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer/imperial = 1,
		/obj/item/clothing/neck/mantle/cemantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1
		)
	access_lists["[ACCESS_HOS]"] = list(
		/obj/item/clothing/head/hos = 1,
		/obj/item/clothing/head/hos/beret/navyhos = 1,
		/obj/item/clothing/head/hos/peacekeeper/sol = 1,
		/obj/item/clothing/under/rank/security/head_of_security/peacekeeper = 1,
		/obj/item/clothing/under/rank/security/head_of_security/peacekeeper/sol = 1,
		/obj/item/clothing/under/rank/security/head_of_security/skirt = 1,
		/obj/item/clothing/under/rank/security/head_of_security/grey = 1,
		/obj/item/clothing/under/rank/security/head_of_security/alt = 1,
		/obj/item/clothing/under/rank/security/head_of_security/alt/skirt = 1,
		/obj/item/clothing/under/rank/security/head_of_security/imperial = 1,
		/obj/item/clothing/suit/armor/hos/navyblue = 1,
		/obj/item/clothing/under/rank/security/head_of_security/parade = 1,
		/obj/item/clothing/suit/armor/hos/parade = 1,
		/obj/item/clothing/suit/armor/hos/parade/female = 1,
		/obj/item/clothing/suit/armor/hos/hos_formal = 1,
		/obj/item/clothing/neck/mantle/hosmantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1
		)
	access_lists["[ACCESS_QM]"] = list(
		/obj/item/clothing/head/beret/cargo/qm = 1,
		/obj/item/clothing/head/beret/cargo/qm/alt = 1,
		/obj/item/clothing/under/rank/cargo/qm = 1,
		/obj/item/clothing/under/rank/cargo/qm/skirt = 1,
		/obj/item/clothing/under/utility/cargo/gorka/head = 1,
		/obj/item/clothing/under/utility/cargo/turtleneck/head = 1,
		/obj/item/clothing/suit/brownfurrich = 1,
		/obj/item/clothing/under/rank/cargo/qm/casual = 1,
		/obj/item/clothing/suit/toggle/jacket/supply/head = 1,
        /obj/item/clothing/under/rank/cargo/qm/formal = 1,
		/obj/item/clothing/under/rank/cargo/qm/formal/skirt = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1
		)

	access_lists["[ACCESS_CENT_GENERAL]"] = list( // CC Rep Shiz
		/obj/item/clothing/head/nanotrasen_representative = 1,
		/obj/item/clothing/head/nanotrasen_representative/beret = 1,
		/obj/item/clothing/head/beret/centcom_formal/ntrep = 1,
		/obj/item/clothing/under/rank/nanotrasen_representative = 1,
		/obj/item/clothing/under/rank/nanotrasen_representative/skirt = 1,
		/obj/item/clothing/head/centhat = 1,
		/obj/item/clothing/head/centcom_cap = 1,
		/obj/item/clothing/suit/toggle/armor/vest/centcom_formal/ntrep = 1
		)

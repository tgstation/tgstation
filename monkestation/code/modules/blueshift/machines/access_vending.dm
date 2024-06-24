/**
 * This vending machine supports a list of items that changes based on the user/card's access.
 */
/obj/machinery/vending/access
	name = "access-based vending machine"
	/// Internal variable to store our access list
	var/list/access_lists
	/// Should we auto build our product list? 0 means no
	var/auto_build_products = 0

/**
 * This is where you generate the list to store what items each access grants.
 * Should be an assosciative list where the key is the access as a string and the value is the items typepath.
 * You can also set it to TRUE instead of a list to allow them to purchase anything.
 */
/obj/machinery/vending/access/proc/build_access_list(list/access_lists)
	return

/obj/machinery/vending/access/Initialize(mapload)
	var/list/_list = new
	build_access_list(_list)
	access_lists = _list
	if(auto_build_products)
		products = list()
		for(var/access in access_lists)
			for(var/item in (access_lists[access]))
				if(!ispath(item))
					continue
				if(item in products)
					continue
				products[item] = auto_build_products
	return ..()

/obj/machinery/vending/access/ui_static_data(mob/user)
	. = ..()
	if(issilicon(user))
		return // Silicons get to view all items regardless

	.["product_records"] = list() // Vending machine code is bad; I hate it
	if(!iscarbon(user))
		return

	var/mob/living/carbon/carbon_user = user
	var/obj/item/card/id/user_id = carbon_user.get_idcard(TRUE)
	if(onstation && !user_id && !(obj_flags & EMAGGED))
		return

	// Alright so, this is the EXACT SAME LOOP as our base proc; however we check to see if the user is allowed to purchase it first.
	for (var/datum/data/vending_product/record in product_records)
		if(!allow_purchase(user_id, record.product_path))
			continue
		var/list/data = list(
			path = replacetext(replacetext("[record.product_path]", "/obj/item/", ""), "/", "-"),
			name = record.name,
			price = record.custom_price || default_price,
			max_amount = record.max_amount,
			ref = REF(record)
		)
		.["product_records"] += list(data)

/// Check if the list of given access is allowed to purchase the given product
/obj/machinery/vending/access/proc/allow_purchase(var/obj/item/card/id/user_id, product_path)
	if(obj_flags & EMAGGED || !onstation)
		return TRUE
	. = FALSE
	var/list/access = user_id.access
	for(var/acc in access)
		acc = "[acc]" // U G L Y
		if(!((acc) in access_lists))
			continue

		if(isnum(access_lists[acc]) && access_lists[acc])
			return access_lists[acc]

		if(product_path in (access_lists[acc]))
			return TRUE

/// Debug version to verify access checking is working and functional
/obj/machinery/vending/access/debug
	auto_build_products = TRUE

/obj/machinery/vending/access/debug/build_access_list(list/access_lists)
	access_lists["[ACCESS_ENGINEERING]"] = TRUE
	access_lists["[ACCESS_EVA]"] = list(/obj/item/crowbar)
	access_lists["[ACCESS_SECURITY]"] = list(/obj/item/wrench, /obj/item/gun/ballistic/revolver/mateba)

/obj/machinery/vending/access/command
	name = "\improper Command Outfitting Station"
	desc = "A vending machine for specialised clothing for members of Command."
	product_ads = "File paperwork in style!;It's red so you can't see the blood!;You have the right to be fashionable!;Now you can be the fashion police you always wanted to be!"
	icon = 'monkestation/code/modules/blueshift/icons/vending.dmi'
	icon_state = "commdrobe"
	light_mask = "wardrobe-light-mask"
	vend_reply = "Thank you for using the CommDrobe!"
	auto_build_products = TRUE
	payment_department = ACCOUNT_CMD

	refill_canister = /obj/item/vending_refill/wardrobe/comm_wardrobe
	payment_department = ACCOUNT_CMD
	light_color = COLOR_COMMAND_BLUE

/obj/item/vending_refill/wardrobe/comm_wardrobe
	machine_name = "CommDrobe"

/obj/machinery/vending/access/command/build_access_list(list/access_lists)
	access_lists["[ACCESS_CAPTAIN]"] = list(
		// CAPTAIN
		/obj/item/clothing/head/hats/caphat = 1,
		/obj/item/clothing/head/caphat/beret = 1,
		/obj/item/clothing/head/caphat/beret/alt = 1,
		/obj/item/clothing/head/hats/imperial/cap = 1,
		/obj/item/clothing/under/rank/captain = 1,
		/obj/item/clothing/under/rank/captain/skirt = 1,
		/obj/item/clothing/under/rank/captain/dress = 1,
		/obj/item/clothing/under/rank/captain/nova/kilt = 1,
		/obj/item/clothing/under/rank/captain/nova/imperial = 1,
		/obj/item/clothing/head/hats/caphat/parade = 1,
		/obj/item/clothing/under/rank/captain/parade = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/jacket = 1,
		/obj/item/clothing/suit/jacket/capjacket = 1,
		/obj/item/clothing/neck/cloak/cap = 1,
		/obj/item/clothing/neck/mantle/capmantle = 1,
		/obj/item/storage/backpack/captain = 1,
		/obj/item/storage/backpack/satchel/cap = 1,
		/obj/item/storage/backpack/duffelbag/captain = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,

		// BLUESHIELD
		/obj/item/clothing/head/beret/blueshield = 1,
		/obj/item/clothing/head/beret/blueshield/navy = 1,
		/obj/item/clothing/under/rank/blueshield = 1,
		/obj/item/clothing/under/rank/blueshield/skirt = 1,
		/obj/item/clothing/under/rank/blueshield/turtleneck = 1,
		/obj/item/clothing/under/rank/blueshield/turtleneck/skirt = 1,
		/obj/item/clothing/suit/armor/vest/blueshield = 1,
		/obj/item/clothing/suit/armor/vest/blueshield/jacket = 1,
		/obj/item/clothing/neck/mantle/bsmantle = 1,
		/obj/item/storage/backpack/blueshield = 1,
		/obj/item/storage/backpack/satchel/blueshield = 1,
		/obj/item/storage/backpack/duffelbag/blueshield = 1,
		/obj/item/clothing/shoes/laceup = 1,
	)
	access_lists["[ACCESS_HOP]"] = list( // Best head btw
		/obj/item/clothing/head/hats/hopcap = 1,
		/obj/item/clothing/head/hopcap/beret = 1,
		/obj/item/clothing/head/hopcap/beret/alt = 1,
		/obj/item/clothing/head/hats/imperial/hop = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/turtleneck = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/turtleneck/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/parade = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/parade/female = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/imperial = 1,
		/obj/item/clothing/suit/armor/vest/hop/hop_formal = 1,
		/obj/item/clothing/neck/cloak/hop = 1,
		/obj/item/clothing/neck/mantle/hopmantle = 1,
		/obj/item/storage/backpack/head_of_personnel = 1,
		/obj/item/storage/backpack/satchel/head_of_personnel = 1,
		/obj/item/storage/backpack/duffelbag/head_of_personnel = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	access_lists["[ACCESS_CMO]"] = list(
		/obj/item/clothing/head/beret/medical/cmo = 1,
		/obj/item/clothing/head/beret/medical/cmo/alt = 1,
		/obj/item/clothing/head/hats/imperial/cmo = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/nova/imperial = 1,
		/obj/item/clothing/neck/cloak/cmo = 1,
		/obj/item/clothing/neck/mantle/cmomantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	access_lists["[ACCESS_RD]"] = list(
		/obj/item/clothing/head/beret/science/rd = 1,
		/obj/item/clothing/head/beret/science/rd/alt = 1,
		/obj/item/clothing/under/rank/rnd/research_director = 1,
		/obj/item/clothing/under/rank/rnd/research_director/skirt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/alt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck = 1,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/nova/imperial = 1,
		/obj/item/clothing/neck/cloak/rd = 1,
		/obj/item/clothing/neck/mantle/rdmantle = 1,
		/obj/item/clothing/suit/toggle/labcoat = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	access_lists["[ACCESS_CE]"] = list(
		/obj/item/clothing/head/beret/engi/ce = 1,
		/obj/item/clothing/head/hats/imperial/ce = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer/skirt = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer/nova/imperial = 1,
		/obj/item/clothing/neck/cloak/ce = 1,
		/obj/item/clothing/neck/mantle/cemantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	access_lists["[ACCESS_HOS]"] = list(
		/obj/item/clothing/head/hats/hos/cap = 1,
		/obj/item/clothing/head/hats/hos/beret/navyhos = 1,
		/obj/item/clothing/head/hats/imperial/hos = 1,
		/obj/item/clothing/under/rank/security/head_of_security/peacekeeper = 1,
		/obj/item/clothing/under/rank/security/head_of_security/alt = 1,
		/obj/item/clothing/under/rank/security/head_of_security/alt/skirt = 1,
		/obj/item/clothing/under/rank/security/head_of_security/nova/imperial = 1,
		/obj/item/clothing/suit/jacket/hos/blue = 1,
		/obj/item/clothing/under/rank/security/head_of_security/parade = 1,
		/obj/item/clothing/suit/armor/hos/hos_formal = 1,
		/obj/item/clothing/neck/cloak/hos = 1,
		/obj/item/clothing/neck/mantle/hosmantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	access_lists["[ACCESS_QM]"] = list(
		/obj/item/clothing/head/beret/cargo/qm = 1,
		/obj/item/clothing/head/beret/cargo/qm/alt = 1,
		/obj/item/clothing/neck/cloak/qm = 1,
		/obj/item/clothing/neck/mantle/qm = 1,
		/obj/item/clothing/under/rank/cargo/qm = 1,
		/obj/item/clothing/under/rank/cargo/qm/skirt = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/gorka = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck/skirt = 1,
		/obj/item/clothing/suit/brownfurrich = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/casual = 1,
		/obj/item/clothing/suit/toggle/jacket/supply/head = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/formal = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/formal/skirt = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)

	access_lists["[ACCESS_COMMAND]"] = list(
		/obj/item/clothing/head/hats/imperial = 5,
		/obj/item/clothing/head/hats/imperial/grey = 5,
		/obj/item/clothing/head/hats/imperial/white = 2,
		/obj/item/clothing/head/hats/imperial/red = 5,
		/obj/item/clothing/head/hats/imperial/helmet = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic/grey = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic/pants = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic/red = 5,
	)


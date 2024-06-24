#define MINIMUM_CLOTHING_STOCK 5

/obj/machinery/vending
	/// Additions to the `products` list  of the vending machine, modularly. Will become null after Initialize, to free up memory.
	var/list/products_monke
	/// Additions to the `product_categories` list of the vending machine, modularly. Will become null after Initialize, to free up memory.
	var/list/product_categories_monke
	/// Additions to the `premium` list  of the vending machine, modularly. Will become null after Initialize, to free up memory.
	var/list/premium_monke
	/// Additions to the `contraband` list  of the vending machine, modularly. Will become null after Initialize, to free up memory.
	var/list/contraband_monke

/obj/machinery/vending/Initialize(mapload)
	if(products_monke)
		// We need this, because duplicates screw up the spritesheet!
		for(var/item_to_add in products_monke)
			products[item_to_add] = products_monke[item_to_add]

	if(product_categories_monke)
		for(var/category in product_categories_monke)
			var/already_exists = FALSE
			for(var/existing_category in product_categories)
				if(existing_category["name"] == category["name"])
					existing_category["products"] += category["products"]
					already_exists = TRUE
					break

			if(!already_exists)
				product_categories += category

	if(premium_monke)
		// We need this, because duplicates screw up the spritesheet!
		for(var/item_to_add in premium_monke)
			premium[item_to_add] = premium_monke[item_to_add]

	if(contraband_monke)
		// We need this, because duplicates screw up the spritesheet!
		for(var/item_to_add in contraband_monke)
			contraband[item_to_add] = contraband_monke[item_to_add]

	// Time to make clothes amounts consistent!
	for (var/obj/item/clothing/item in products)
		if(products[item] < MINIMUM_CLOTHING_STOCK && allow_increase(item))
			products[item] = MINIMUM_CLOTHING_STOCK

	for (var/category in product_categories)
		for(var/obj/item/clothing/item in category["products"])
			if(category["products"][item] < MINIMUM_CLOTHING_STOCK && allow_increase(item))
				category["products"][item] = MINIMUM_CLOTHING_STOCK

	for (var/obj/item/clothing/item in premium)
		if(premium[item] < MINIMUM_CLOTHING_STOCK && allow_increase(item))
			premium[item] = MINIMUM_CLOTHING_STOCK

	QDEL_NULL(products_monke)
	QDEL_NULL(product_categories_monke)
	QDEL_NULL(premium_monke)
	QDEL_NULL(contraband_monke)
	return ..()

/// This proc checks for forbidden traits cause it'd be pretty bad to have 5 insuls available to assistants roundstart at the vendor!
/obj/machinery/vending/proc/allow_increase(obj/item/clothing/clothing_path)
	var/obj/item/clothing/clothing = new clothing_path()

	// Ignore earmuffs!
	if(TRAIT_DEAF in clothing.clothing_traits)
		return FALSE
	// Don't touch sunglasses or welding helmets!
	if(clothing.flash_protect == FLASH_PROTECTION_WELDER)
		return FALSE
	// Don't touch bodyarmour!
	if(ispath(clothing, /obj/item/clothing/suit/armor))
		return FALSE
	// Don't touch protective helmets, like riot helmets!
	if(ispath(clothing, /obj/item/clothing/head/helmet))
		return FALSE
	// Ignore all gloves, because it's almost impossible to check what they do...
	if(ispath(clothing, /obj/item/clothing/gloves))
		return FALSE
	return TRUE

#undef MINIMUM_CLOTHING_STOCK


/obj/machinery/vending/wardrobe/medi_wardrobe
	products_monke = list(
		/obj/item/radio/headset/headset_med = 3,
		/obj/item/clothing/gloves/latex/nitrile = 2,
		/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem/emt = 2,
		/obj/item/clothing/under/rank/medical/scrubs/nova/red = 4,
		/obj/item/clothing/under/rank/medical/scrubs/nova/white = 4,
		/obj/item/clothing/under/rank/medical/doctor/nova/utility = 4,
	)

/obj/machinery/vending/wardrobe/engi_wardrobe
	products_monke = list(
		/obj/item/radio/headset/headset_eng = 3,
		/obj/item/clothing/under/rank/engineering/engineer/nova/trouser = 3,
		/obj/item/clothing/under/rank/engineering/engineer/nova/utility = 3,
		/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem = 3,
		/obj/item/clothing/under/misc/overalls = 3,
		/obj/item/clothing/suit/toggle/jacket/engi = 3,
		/obj/item/clothing/head/utility/hardhat/orange = 2,
		/obj/item/clothing/head/utility/hardhat/welding/orange = 2,
		/obj/item/clothing/head/utility/hardhat/dblue = 2,
		/obj/item/clothing/head/utility/hardhat/welding/dblue = 2,
		/obj/item/clothing/head/utility/hardhat/red = 2,
	)

/obj/machinery/vending/wardrobe/atmos_wardrobe
	products_monke = list(
		/obj/item/clothing/glasses/meson/engine = 2,
		/obj/item/clothing/head/beret/atmos = 4,
	)

/obj/machinery/vending/wardrobe/cargo_wardrobe
	products_monke = list(
		/obj/item/clothing/under/rank/cargo/tech/nova/long = 3,
		/obj/item/clothing/under/rank/cargo/tech/nova/gorka = 3,
		/obj/item/clothing/under/rank/cargo/tech/nova/turtleneck = 3,
		/obj/item/clothing/under/rank/cargo/tech/nova/turtleneck/skirt = 3,
		/obj/item/clothing/under/rank/cargo/tech/nova/utility = 3,
		/obj/item/clothing/under/rank/cargo/tech/nova/casualman = 3,
		/obj/item/clothing/suit/toggle/jacket/supply = 3,
	)

	contraband_monke = list(
		/obj/item/clothing/under/suit/nova/scarface = 2,
		/obj/item/clothing/under/rank/cargo/tech/nova/evil = 2,
	)

/obj/machinery/vending/wardrobe/robo_wardrobe
	products_monke = list(
		/obj/item/clothing/head/beret/science/fancy/robo = 2,
		/obj/item/tank/internals/anesthetic = 2,
		/obj/item/clothing/mask/breath = 2,
		/obj/item/reagent_containers/cup/bottle/morphine = 2,
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/clothing/gloves/color/black = 2, // fire resistant, allows the robo to painlessly mold metal. also its down here because its a treatment item
		/obj/item/bonesetter = 2, // for dislocations
		/obj/item/stack/medical/gauze = 4, // for ALL wounds
		/obj/item/healthanalyzer/simple = 2,
	)

/obj/machinery/vending/wardrobe/science_wardrobe
	products_monke = list(
		/obj/item/clothing/under/rank/rnd/scientist/nova/hlscience = 3,
		/obj/item/clothing/under/rank/rnd/scientist/nova/utility = 3,
		/obj/item/clothing/suit/toggle/jacket/sci = 3,
	)

/obj/machinery/vending/wardrobe/hydro_wardrobe
	contraband_monke = list(
		/obj/item/clothing/under/suit/nova/scarface = 2,
	)

/obj/machinery/vending/wardrobe/bar_wardrobe
	products_monke = list(
		/obj/item/storage/fancy/candle_box/vanilla = 1,
		/obj/item/storage/fancy/candle_box/pear = 1,
		/obj/item/storage/fancy/candle_box/amber = 1,
		/obj/item/storage/fancy/candle_box/jasmine = 1,
		/obj/item/storage/fancy/candle_box/mint = 1,
	)

/obj/machinery/vending/wardrobe/chap_wardrobe
	products_monke = list(
		/obj/item/clothing/suit/costume/nemes = 1,
		/obj/item/clothing/head/costume/nemes = 1,
		/obj/item/clothing/head/costume/pharaoh = 1, //dont google camel by camel worst mistake of my life
	)

/obj/machinery/vending/cart
	products_monke = list(
		/obj/item/radio/headset/headset_srv = 3,
	)

/obj/machinery/vending/wardrobe/chem_wardrobe
	products_monke = list(
		/obj/item/clothing/under/rank/medical/chemist/nova/formal = 2,
		/obj/item/clothing/under/rank/medical/chemist/nova/formal/skirt = 2,
	)

/obj/machinery/vending/wardrobe/viro_wardrobe
	products_monke = list(
		/obj/item/clothing/head/beret/medical/virologist = 2,
	)

/obj/machinery/vending/wardrobe/det_wardrobe
	products_monke = list(
		/obj/item/clothing/head/fedora/beige = 2,
		/obj/item/clothing/head/fedora/white = 2,
		/obj/item/clothing/under/costume/cybersleek = 2,
		/obj/item/clothing/under/costume/cybersleek/long = 2,
		/obj/item/clothing/head/fedora/det_hat/cybergoggles = 2,
	)

/obj/machinery/vending/wardrobe/law_wardrobe
	products_monke = list(
		/obj/item/clothing/under/suit/nova/black_really_collared = 3,
		/obj/item/clothing/under/suit/nova/black_really_collared/skirt = 3,
		/obj/item/clothing/under/suit/nova/inferno = 3,
		/obj/item/clothing/under/suit/nova/inferno/skirt = 3,
		/obj/item/clothing/under/suit/nova/inferno/beeze = 2,
	)


/// Removes given list of products. Must be called before build_inventory() to actually prevent the records from being created.
/obj/machinery/vending/proc/remove_products(list/paths_to_remove)
	if(!length(paths_to_remove))
		return
	for(var/typepath as anything in products)
		for(var/to_remove as anything in paths_to_remove)
			if(ispath(typepath, to_remove))
				products.Remove(typepath)

/obj/machinery/vending/
	/// list of products to exclude when building the vending machine's inventory
	var/list/excluded_products

/obj/machinery/vending/Initialize(mapload)
	remove_products(excluded_products)
	return ..()

/obj/machinery/vending/clothing
	product_categories_monke = list(
		list(
			"name" = "Head",
			"icon" = "hat-cowboy",
			"products" = list(
				/obj/item/clothing/head/beret/badge = 5,
				/obj/item/clothing/head/colourable_flatcap= 5,
				/obj/item/clothing/head/cowboy/nova/cattleman = 5,
				/obj/item/clothing/head/cowboy/nova/cattleman/wide = 5,
				/obj/item/clothing/head/cowboy/nova/wide = 5,
				/obj/item/clothing/head/cowboy/nova/wide/feathered = 5,
				/obj/item/clothing/head/cowboy/nova/flat = 5,
				/obj/item/clothing/head/cowboy/nova/flat/cowl = 5,
				/obj/item/clothing/head/cowboy/nova/flat/sheriff = 5,
				/obj/item/clothing/head/cowboy/nova/flat/deputy = 5,
				/obj/item/clothing/head/cowboy/nova/flat/cowl/sheriff = 5,
				/obj/item/clothing/head/fedora= 5,
				/obj/item/clothing/head/fedora/brown = 5,
				/obj/item/clothing/head/fedora/beige = 5,
				/obj/item/clothing/head/fedora/white = 5,
				/obj/item/clothing/head/standalone_hood = 5,
				/obj/item/clothing/head/small_bow = 5,
				/obj/item/clothing/head/large_bow = 5,
				/obj/item/clothing/head/back_bow = 5,
				/obj/item/clothing/head/sweet_bow = 5,
			),
		),

		list(
			"name" = "Accessories",
			"icon" = "glasses",
			"products" = list(
				/obj/item/clothing/neck/ranger_poncho = 5,
				/obj/item/clothing/neck/cloak/colourable = 5,
				/obj/item/clothing/neck/cloak/colourable/veil = 5,
				/obj/item/clothing/neck/cloak/colourable/shroud = 5,
				/obj/item/clothing/neck/cloak/colourable/boat = 5,
				/obj/item/clothing/neck/mantle/recolorable = 5,
				/obj/item/clothing/neck/long_cape = 5,
				/obj/item/clothing/neck/wide_cape = 5,
				/obj/item/clothing/neck/robe_cape = 5,
				/obj/item/clothing/glasses/regular/betterunshit = 5,
				/obj/item/clothing/glasses/thin = 5,
				/obj/item/clothing/neck/face_scarf = 5,
			),
		),

		list(
			"name" = "Under",
			"icon" = "shirt",
			"products" = list(
				/obj/item/clothing/under/pants/nova/jeans_ripped = 5,
				/obj/item/clothing/under/shorts/nova/shorts_ripped = 5,
				/obj/item/clothing/under/pants/nova/yoga = 5,
				/obj/item/clothing/under/misc/nova/mechanic = 5,
				/obj/item/clothing/under/misc/bluetracksuit = 5,
				/obj/item/clothing/under/suit/nova/recolorable = 5,
				/obj/item/clothing/under/suit/nova/recolorable/skirt = 5,
				/obj/item/clothing/under/pants/nova/kilt = 5,
				/obj/item/clothing/under/suit/fancy = 5,
				/obj/item/clothing/under/texas = 5,
				/obj/item/clothing/under/sweater = 5,
				/obj/item/clothing/under/sweater/keyhole = 5,
				/obj/item/clothing/under/tachawaiian = 5,
				/obj/item/clothing/under/tachawaiian/purple = 5,
				/obj/item/clothing/under/tachawaiian/green = 5,
				/obj/item/clothing/under/tachawaiian/blue = 5,
				/obj/item/clothing/under/suit/nova/black_really_collared = 3,
				/obj/item/clothing/under/suit/nova/black_really_collared/skirt = 3,
				/obj/item/clothing/under/suit/nova/pencil = 3,
				/obj/item/clothing/under/suit/nova/pencil/black_really = 3,
				/obj/item/clothing/under/suit/nova/pencil/charcoal = 3,
				/obj/item/clothing/under/suit/nova/pencil/navy = 3,
				/obj/item/clothing/under/suit/nova/pencil/burgandy = 3,
				/obj/item/clothing/under/suit/nova/pencil/checkered = 3,
				/obj/item/clothing/under/suit/nova/pencil/tan = 3,
				/obj/item/clothing/under/suit/nova/pencil/green = 3,
				/obj/item/clothing/under/suit/nova/inferno = 3,
				/obj/item/clothing/under/suit/nova/inferno/skirt = 3,
				/obj/item/clothing/under/suit/nova/helltaker = 3,
				/obj/item/clothing/under/suit/nova/helltaker/skirt = 3,
				/obj/item/clothing/under/dress/skirt/nova/medium = 5,
				/obj/item/clothing/under/dress/skirt/nova/long = 5,
			),
		),

		list(
			"name" = "Suits & Skirts",
			"icon" = "vest",
			"products" = list(
				/obj/item/clothing/under/dress/skirt/nova/lone_skirt = 5,
				/obj/item/clothing/under/dress/skirt/nova/turtleskirt_knit = 5,
				/obj/item/clothing/under/dress/nova/short_dress = 5,
				/obj/item/clothing/under/dress/nova/pinktutu = 5,
				/obj/item/clothing/under/dress/skirt/nova/jean = 5,
				/obj/item/clothing/under/dress/nova/flower = 5,
				/obj/item/clothing/under/dress/nova/strapless = 5,
				/obj/item/clothing/under/dress/nova/pentagram = 5,
				/obj/item/clothing/suit/varsity = 5,
				/obj/item/clothing/suit/toggle/jacket = 5,
				/obj/item/clothing/suit/toggle/jacket/flannel/gags = 5,
				/obj/item/clothing/suit/toggle/jacket/flannel = 5,
				/obj/item/clothing/suit/toggle/jacket/flannel/red = 5,
				/obj/item/clothing/suit/toggle/jacket/flannel/aqua = 5,
				/obj/item/clothing/suit/toggle/jacket/flannel/brown = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/trim = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/trim/alt = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/branded = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/branded/cti = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/branded/mu = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/branded/smw = 5,
				/obj/item/clothing/suit/toggle/jacket/hoodie/branded/nrti = 5,
				/obj/item/clothing/suit/toggle/jacket/cardigan = 5,
				/obj/item/clothing/suit/toggle/peacoat = 5,
				/obj/item/clothing/suit/toggle/trackjacket = 5,
				/obj/item/clothing/suit/toggle/lawyer/white = 5,
				/obj/item/clothing/suit/urban = 5,
				/obj/item/clothing/suit/duster = 5,
				/obj/item/clothing/suit/fallsparka = 5,
				/obj/item/clothing/suit/jacket/croptop = 5,
				/obj/item/clothing/suit/modernwintercoatthing = 5,
				/obj/item/clothing/suit/apron/chef/colorable_apron = 5,
				/obj/item/clothing/suit/warm_coat = 5,
				/obj/item/clothing/suit/warm_sweater = 5,
				/obj/item/clothing/suit/heart_sweater = 5,
				/obj/item/clothing/suit/crop_jacket = 5,
			),
		),

		list(
			"name" = "Shoes",
			"icon" = "socks",
			"products" = list(
				/obj/item/clothing/shoes/colorable_laceups = 5,
				/obj/item/clothing/shoes/colorable_sandals = 5,
				/obj/item/clothing/shoes/sports = 5,
				/obj/item/clothing/shoes/wraps/colourable = 5,
				/obj/item/clothing/shoes/wraps/cloth = 5,
				/obj/item/clothing/shoes/jungleboots = 5,
				/obj/item/clothing/shoes/jackboots/knee = 5,
				/obj/item/clothing/shoes/jackboots/recolorable = 5,
			),
		),

		//Only put clothing in Special thats either Families or exteremly out-of-place
		list(
			"name" = "Special",
			"icon" = "star",
			"products" = list(
				/obj/item/clothing/under/costume/deckers/alt = 5,
				/obj/item/clothing/under/costume/nova/bathrobe = 5,
			)
		)
	)

	premium_monke = list( //being here means you're artificially rare, congratulations
		/obj/item/clothing/shoes/jackboots/timbs = 2,
		/obj/item/clothing/head/soft/yankee = 3,
		/obj/item/clothing/suit/brownbattlecoat = 1,
		/obj/item/clothing/suit/blackfurrich = 1,
		/obj/item/clothing/suit/frenchtrench = 1,
	)

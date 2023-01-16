/datum/supply_pack/misc
	group = "Miscellaneous Supplies"

/datum/supply_pack/misc/artsupply
	name = "Art Supplies"
	desc = "Make some happy little accidents with a rapid pipe cleaner layer, \
		three spraycans, and lots of crayons!"
	cost = CARGO_CRATE_VALUE * 1.8
	contains = list(/obj/item/rcl,
					/obj/item/storage/toolbox/artistic,
					/obj/item/toy/crayon/spraycan = 3,
					/obj/item/storage/crayons,
					/obj/item/toy/crayon/white,
					/obj/item/toy/crayon/rainbow,
				)
	crate_name = "art supply crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/tattoo_kit
	name = "Tattoo Kit"
	desc = "A tattoo kit with some extra starting ink."
	cost = CARGO_CRATE_VALUE * 1.8
	contains = list(
		/obj/item/tattoo_kit,
		/obj/item/toner = 2)
	crate_name = "tattoo crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/aquarium_kit
	name = "Aquarium Kit"
	desc = "Everything you need to start your own aquarium. Contains aquarium construction kit, \
		fish catalog, fish food and three freshwater fish from our collection."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/book/fish_catalog,
					/obj/item/storage/fish_case/random/freshwater = 3,
					/obj/item/fish_feed,
					/obj/item/storage/box/aquarium_props,
					/obj/item/aquarium_kit,
				)
	crate_name = "aquarium kit crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/aquarium_fish
	name = "Aquarium Fish Case"
	desc = "An aquarium fish bundle handpicked by monkeys from our collection. Contains two random fish."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/random = 2)
	crate_name = "aquarium fish crate"

/datum/supply_pack/misc/freshwater_fish
	name = "Freshwater Fish Case"
	desc = "Aquarium fish that have had most of their mud cleaned off."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/random/freshwater = 2)
	crate_name = "freshwater fish crate"

/datum/supply_pack/misc/saltwater_fish
	name = "Saltwater Fish Case"
	desc = "Aquarium fish that fill the room with the smell of salt."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/random/saltwater = 2)
	crate_name = "saltwater fish crate"

/datum/supply_pack/misc/tiziran_fish
	name = "Tirizan Fish Case"
	desc = "Tiziran saltwater fish imported from the Zagos Sea."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/tiziran = 2)
	crate_name = "tiziran fish crate"

/datum/supply_pack/misc/bicycle
	name = "Bicycle"
	desc = "Nanotrasen reminds all employees to never toy with powers outside their control."
	cost = 1000000 //Special case, we don't want to make this in terms of crates because having bikes be a million credits is the whole meme.
	contains = list(/obj/vehicle/ridden/bicycle)
	crate_name = "bicycle crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/bigband
	name = "Big Band Instrument Collection"
	desc = "Get your sad station movin' and groovin' with this fine collection! \
		Contains nine different instruments!"
	cost = CARGO_CRATE_VALUE * 10
	crate_name = "Big band musical instruments collection"
	contains = list(/obj/item/instrument/violin,
					/obj/item/instrument/guitar,
					/obj/item/instrument/glockenspiel,
					/obj/item/instrument/accordion,
					/obj/item/instrument/saxophone,
					/obj/item/instrument/trombone,
					/obj/item/instrument/recorder,
					/obj/item/instrument/harmonica,
					/obj/structure/musician/piano/unanchored,
				)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/book_crate
	name = "Book Crate"
	desc = "Surplus from the Nanotrasen Archives, these seven books are sure to be good reads."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_LIBRARY
	contains = list(/obj/item/book/codex_gigas,
					/obj/item/book/manual/random = 3,
					/obj/item/book/random = 3,
				)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/commandkeys
	name = "Command Encryption Key Crate"
	desc = "A pack of encryption keys that give access to the command radio network. \
		Nanotrasen reminds unauthorized employees not to eavesdrop in on secure communications channels, \
		or at least to keep heckling of the command staff to a minimum."
	access_view = ACCESS_COMMAND
	access = ACCESS_COMMAND
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/encryptionkey/headset_com = 3)
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "command encryption key crate"

/datum/supply_pack/misc/exploration_drone
	name = "Exploration Drone"
	desc = "A replacement long-range exploration drone."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/exodrone)
	crate_name = "exodrone crate"

/datum/supply_pack/misc/exploration_fuel
	name = "Drone Fuel Pellet"
	desc = "A fresh tank of exploration drone fuel."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/fuel_pellet)
	crate_name = "exodrone fuel crate"

/datum/supply_pack/misc/paper
	name = "Bureaucracy Crate"
	desc = "High stacks of papers on your desk are a big problem - make it pea-sized with \
		these bureaucratic supplies! Contains six pens, some camera film, hand labeler supplies, \
		a paper bin, a carbon paper bin, three folders, a laser pointer, two clipboards and two stamps."
	cost = CARGO_CRATE_VALUE * 3.2
	contains = list(/obj/structure/filingcabinet/chestdrawer/wheeled,
					/obj/item/camera_film,
					/obj/item/hand_labeler,
					/obj/item/hand_labeler_refill = 2,
					/obj/item/paper_bin,
					/obj/item/paper_bin/carbon,
					/obj/item/pen/fourcolor = 2,
					/obj/item/pen,
					/obj/item/pen/fountain,
					/obj/item/pen/blue,
					/obj/item/pen/red,
					/obj/item/folder/blue,
					/obj/item/folder/red,
					/obj/item/folder/yellow,
					/obj/item/clipboard = 2,
					/obj/item/stamp,
					/obj/item/stamp/denied,
					/obj/item/laser_pointer/purple,
				)
	crate_name = "bureaucracy crate"

/datum/supply_pack/misc/fountainpens
	name = "Calligraphy Crate"
	desc = "Sign death warrants in style with these seven executive fountain pens."
	cost = CARGO_CRATE_VALUE * 1.45
	contains = list(/obj/item/storage/box/fountainpens)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "calligraphy crate"

/datum/supply_pack/misc/wrapping_paper
	name = "Festive Wrapping Paper Crate"
	desc = "Want to mail your loved ones gift-wrapped chocolates, stuffed animals, the Clown's severed head? \
		You can do all that, with this crate full of wrapping paper."
	cost = CARGO_CRATE_VALUE * 1.8
	contains = list(/obj/item/stack/wrapping_paper)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "festive wrapping paper crate"


/datum/supply_pack/misc/funeral
	name = "Funeral Supply crate"
	desc = "At the end of the day, someone's gonna want someone dead. Give them a proper send-off with these \
		funeral supplies! Contains a coffin with burial garmets and flowers."
	cost = CARGO_CRATE_VALUE * 1.6
	access_view = ACCESS_CHAPEL_OFFICE
	contains = list(/obj/item/clothing/under/misc/burial,
					/obj/item/food/grown/harebell,
					/obj/item/food/grown/poppy/geranium,
				)
	crate_name = "coffin"
	crate_type = /obj/structure/closet/crate/coffin

/datum/supply_pack/misc/empty
	name = "Empty Supplypod"
	desc = "Presenting the New Nanotrasen-Brand Bluespace Supplypod! Transport cargo with grace and ease! \
		Call today and we'll shoot over a demo unit for just 300 credits!"
	cost = CARGO_CRATE_VALUE * 0.6 //Empty pod, so no crate refund
	contains = list()
	drop_pod_only = TRUE
	crate_type = null
	special_pod = /obj/structure/closet/supplypod/bluespacepod

/datum/supply_pack/misc/empty/generate(atom/A, datum/bank_account/paying_account)
	return

/datum/supply_pack/misc/religious_supplies
	name = "Religious Supplies Crate"
	desc = "Keep your local chaplain happy and well-supplied, lest they call down judgement upon your \
		cargo bay. Contains two bottles of holywater, bibles, chaplain robes, and burial garmets."
	cost = CARGO_CRATE_VALUE * 6 // it costs so much because the Space Church needs funding to build a cathedral
	access_view = ACCESS_CHAPEL_OFFICE
	contains = list(/obj/item/reagent_containers/cup/glass/bottle/holywater = 2,
					/obj/item/storage/book/bible/booze = 2,
					/obj/item/clothing/suit/hooded/chaplain_hoodie = 2,
					/obj/item/clothing/under/misc/burial = 2,
				)
	crate_name = "religious supplies crate"

/datum/supply_pack/misc/toner
	name = "Toner Crate"
	desc = "Spent too much ink printing butt pictures? Fret not, with these six toner refills, \
		you'll be printing butts 'till the cows come home!'"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/toner = 6)
	crate_name = "toner crate"

/datum/supply_pack/misc/toner_large
	name = "Toner Crate (Large)"
	desc = "Tired of changing toner cartridges? These six extra heavy duty refills contain \
		roughly five times as much toner as the base model!"
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/toner/large = 6)
	crate_name = "large toner crate"

/datum/supply_pack/misc/training_toolbox
	name = "Training Toolbox Crate"
	desc = "Hone your combat abiltities with two AURUMILL-Brand Training Toolboxes! \
		Guarenteed to count hits made against living beings!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/training_toolbox = 2)
	crate_name = "training toolbox crate"

/datum/supply_pack/misc/blackmarket_telepad
	name = "Black Market LTSRBT"
	desc = "Need a faster and better way of transporting your illegal goods from and to the \
		station? Fear not, the Long-To-Short-Range-Bluespace-Transceiver (LTSRBT for short) \
		is here to help. Contains a LTSRBT circuit, two bluespace crystals, and one ansible."
	cost = CARGO_CRATE_VALUE * 20
	contraband = TRUE
	contains = list(/obj/item/circuitboard/machine/ltsrbt,
					/obj/item/stack/ore/bluespace_crystal/artificial = 2,
					/obj/item/stock_parts/subspace/ansible,
				)
	crate_name = "crate"

///Special supply crate that generates random syndicate gear up to a determined TC value
/datum/supply_pack/misc/syndicate
	name = "Assorted Syndicate Gear"
	desc = "Contains a random assortment of syndicate gear."
	special = TRUE //Cannot be ordered via cargo
	contains = list()
	crate_name = "syndicate gear crate"
	crate_type = /obj/structure/closet/crate
	///Total TC worth of contained uplink items
	var/crate_value = 30
	var/uplink_flag = UPLINK_TRAITORS

///Generate assorted uplink items, taking into account the same surplus modifiers used for surplus crates
/datum/supply_pack/misc/syndicate/fill(obj/structure/closet/crate/C)
	var/list/uplink_items = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/item = SStraitor.uplink_items_by_type[item_path]
		if(item.purchasable_from & UPLINK_TRAITORS && item.item)
			uplink_items += item

	while(crate_value)
		var/datum/uplink_item/uplink_item = pick(uplink_items)
		if(!uplink_item.surplus || prob(100 - uplink_item.surplus))
			continue
		if(length(uplink_item.restricted_roles) || length(uplink_item.restricted_species))
			continue
		if(crate_value < uplink_item.cost)
			continue
		crate_value -= uplink_item.cost
		new uplink_item.item(C)


/datum/supply_pack/misc/fishing_portal
	name = "Fishing Portal Generator Crate"
	desc = "Not enough fish near your location? Fishing portal has your back."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/machinery/fishing_portal_generator)
	crate_name = "fishing portal crate"

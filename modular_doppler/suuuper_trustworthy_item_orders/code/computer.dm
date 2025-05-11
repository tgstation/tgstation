/datum/crafting_recipe/stationery_supplies_board
	result = /obj/item/circuitboard/computer/order_console/stationery_supplies
	reqs = list(
        /obj/item/epic_loot/civilian_circuit = 1,
    )
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_EQUIPMENT

/obj/item/circuitboard/computer/order_console/stationery_supplies
	name = "Sikth & Kurabi Stationery Supplies ™ Uplink"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/order_console/stationery_supplies

/obj/machinery/computer/order_console/stationery_supplies
	name = "Sikth & Kurabi Stationery Supplies ™ Uplink"
	desc = "An uplink computer to the finest human-facing business run from outside of human space. \
		For sale are a wide variety of items, very little of which can actually be described as 'stationery'. \
		This is thanks to an error in translation, though the business remains popular regardless of this for unknown reasons. \
		Free galactic standard shipping within 4CA space, see terms and conditions for express shipping use."
	circuit = /obj/item/circuitboard/computer/order_console/stationery_supplies
	order_categories = list(
		"Consumable & Perishable",
		"Wholesale Hardware",
		"Pre-Owned Software",
		"Discount Tooling",
		"Industrial Chemical Supply Sample Kits",
	)
	blackbox_key = "greymarket"
	icon_keyboard = "id_key"
	icon_screen = "tcboss"
	cargo_cost_multiplier = 1
	express_cost_multiplier = 5 // Drop pod service is a premium

/obj/machinery/computer/order_console/stationery_supplies/order_groceries(mob/living/purchaser, obj/item/card/id/card, list/groceries)
	var/list/things_to_order = list()
	for(var/datum/orderable_item/item as anything in groceries)
		things_to_order[item.purchase_path] = groceries[item]

	var/datum/supply_pack/custom_grey/order_pack = new(
		purchaser = purchaser, \
		cost = get_total_cost(), \
		contains = things_to_order,
	)
	var/datum/supply_order/disposable/grey_market/new_order = new(
		pack = order_pack,
		orderer = purchaser,
		orderer_rank = "External Supplier",
		orderer_ckey = purchaser.ckey,
		reason = "",
		paying_account = card.registered_account,
		department_destination = null,
		coupon = null,
		charge_on_purchase = FALSE,
		manifest_can_fail = FALSE,
		cost_type = credit_type,
		can_be_cancelled = FALSE,
	)
	say("The order has been delivered to trusted couriers. Contact the customer support line for further assistance.", language = /datum/language/draconic)
	aas_config_announce(/datum/aas_config_entry/order_console/grey_market, list(), src, list(radio_channel), capitalize(blackbox_key))
	SSshuttle.shopping_list += new_order

/datum/aas_config_entry/order_console/grey_market
	name = "External Supplier Console Announcements"

// Supply order for this

/datum/supply_pack/custom_grey
	name = "supply order"
	hidden = TRUE
	crate_name = "supply delivery crate"
	/// Types of crates we can spawn as
	var/random_crate_types = list(
		/obj/structure/closet/crate/internals,
		/obj/structure/closet/crate/medical,
		/obj/structure/closet/crate/deforest,
		/obj/structure/closet/crate/freezer,
		/obj/structure/closet/crate/freezer/food,
		/obj/structure/closet/crate/freezer/donk,
		/obj/structure/closet/crate/radiation,
		/obj/structure/closet/crate/hydroponics,
		/obj/structure/closet/crate/centcom,
		/obj/structure/closet/crate/cargo,
		/obj/structure/closet/crate/robust,
		/obj/structure/closet/crate/cargo/mining,
		/obj/structure/closet/crate/engineering,
		/obj/structure/closet/crate/nakamura,
		/obj/structure/closet/crate/engineering/electrical,
		/obj/structure/closet/crate/engineering/atmos,
		/obj/structure/closet/crate/science,
		/obj/structure/closet/crate/science/robo,
	)

/datum/supply_pack/custom_grey/New(purchaser, cost, list/contains)
	. = ..()
	name = "[purchaser]'s Supply Order"
	src.cost = cost
	src.contains = contains
	crate_type = pick(random_crate_types)

/datum/supply_pack/custom_grey/generate(atom/generate_atom, datum/bank_account/paying_account)
	var/obj/structure/closet/crate/new_crate
	if(!crate_type)
		CRASH("tried to generate a supply pack without a valid crate type")
	else
		new_crate = new crate_type(generate_atom)
		new_crate.name = crate_name
	if(access)
		new_crate.req_access = list(access)
	if(access_any)
		new_crate.req_one_access = access_any

	fill(new_crate)
	return new_crate

// Special supply_order datum for fludging the manifest

/datum/supply_order/disposable/grey_market
	/// List of mostly harmless sounding items to fill the manifest with
	var/list/cover_story_items_list = list(
		/obj/structure/filingcabinet/chestdrawer/wheeled,
		/obj/item/camera_film,
		/obj/item/hand_labeler,
		/obj/item/hand_labeler_refill,
		/obj/item/paper_bin,
		/obj/item/paper_bin/carbon,
		/obj/item/pen/fourcolor,
		/obj/item/pen,
		/obj/item/pen/fountain,
		/obj/item/pen/blue,
		/obj/item/pen/red,
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/folder/yellow,
		/obj/item/clipboard,
		/obj/item/stamp,
		/obj/item/stamp/denied,
		/obj/item/laser_pointer/purple,
		/obj/item/toner,
		/obj/item/toner/large,
		/obj/item/papercutter,
		/obj/item/hatchet/cutterblade,
	)

/datum/supply_order/disposable/grey_market/generateManifest(obj/container, owner, packname, cost)
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest_paper = new(null, id, cost, manifest_can_fail)

	var/station_name = station_name()

	manifest_paper.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"

	var/manifest_text = "<h2>[command_name()] Shipping Manifest</h2>"
	manifest_text += "<hr/>"
	if(owner && !(owner == "Cargo"))
		manifest_text += "Direct purchase from [owner]<br/>"
		manifest_paper.name += " - Purchased by [owner]"
	manifest_text += "Order[packname?"":"s"]: [id]<br/>"
	manifest_text += "Destination: [station_name]<br/>"
	if(packname)
		manifest_text += "Item: [packname]<br/>"
	manifest_text += "Contents: <br/>"
	manifest_text += "<ul>"
	var/container_contents = list()
	for(var/atom/movable/AM in container.contents - manifest_paper)
		var/obj/item/cover_story_item = pick(cover_story_items_list)
		container_contents[cover_story_item.name]++
	for(var/item in container_contents)
		manifest_text += "<li> [container_contents[item]] [item][container_contents[item] == 1 ? "" : "s"]</li>"
	manifest_text += "</ul>"
	manifest_text += "<h4>Stamp below to confirm receipt of goods:</h4>"

	manifest_paper.add_raw_text(manifest_text)

	manifest_paper.update_appearance()
	manifest_paper.forceMove(container)

	if(istype(container, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = container
		C.manifest = manifest_paper
		C.update_appearance()
	else
		container.contents += manifest_paper

	return manifest_paper

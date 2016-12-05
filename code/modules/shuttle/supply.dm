var/list/blacklisted_cargo_types = typecacheof(list(
		/mob/living,
		/obj/structure/blob,
		/obj/effect/rune,
		/obj/structure/spider/spiderling,
		/obj/item/weapon/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/device/radio/beacon,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/quantumpad,
		/obj/machinery/clonepod,
		/obj/effect/mob_spawn
	))

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 600

	dir = WEST
	port_angle = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

	// When TRUE, these vars allow exporting emagged/contraband items, and add some special interactions to existing exports.
	var/contraband = FALSE
	var/emagged = FALSE

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(z == ZLEVEL_STATION)
		return check_blacklist(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstance)
	for(var/trf in areaInstance)
		var/turf/T = trf
		for(var/a in T.GetAllContents())
			if(is_type_in_typecache(a, blacklisted_cargo_types))
				return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request()
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	if(getDockedId() == "supply_away") // Buy when we leave home.
		buy()
	if(..()) // Fly/enter transit.
		return
	if(getDockedId() == "supply_away") // Sell when we get home
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!SSshuttle.shoppinglist.len)
		return

	var/list/empty_turfs = list()
	for(var/turf/open/floor/T in areaInstance)
		if(T.density || T.contents.len)
			continue
		empty_turfs += T

	var/value = 0
	var/purchases = 0
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!empty_turfs.len)
			break
		if(SO.pack.cost > SSshuttle.points)
			continue

		SSshuttle.points -= SO.pack.cost
		value += SO.pack.cost
		SSshuttle.shoppinglist -= SO
		SSshuttle.orderhistory += SO

		SO.generate(pick_n_take(empty_turfs))
		feedback_add_details("cargo_imports",
			"[SO.pack.type]|[SO.pack.name]|[SO.pack.cost]")
		investigate_log("Order #[SO.id] ([SO.pack.name], placed by [key_name(SO.orderer_ckey)]) has shipped.", "cargo")
		if(SO.pack.dangerous)
			message_admins("\A [SO.pack.name] ordered by [key_name_admin(SO.orderer_ckey)] has shipped.")
		purchases++

	investigate_log("[purchases] orders in this shipment, worth [value] credits. [SSshuttle.points] credits left.", "cargo")

/obj/docking_port/mobile/supply/proc/sell()
	var/presale_points = SSshuttle.points

	if(!exports_list.len) // No exports list? Generate it!
		setupExports()

	var/msg = ""
	var/sold_atoms = ""

	for(var/atom/movable/AM in areaInstance)
		if(AM.anchored)
			continue
		sold_atoms += export_item_and_contents(AM, contraband, emagged, dry_run = FALSE)

	if(sold_atoms)
		sold_atoms += "."

	for(var/a in exports_list)
		var/datum/export/E = a
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		SSshuttle.points += E.total_cost
		E.export_end()

	SSshuttle.centcom_message = msg
	investigate_log("Shuttle contents sold for [SSshuttle.points - presale_points] credits. Contents: [sold_atoms || "none."] Message: [SSshuttle.centcom_message || "none."]", "cargo")

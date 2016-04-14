/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 10

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

	var/list/blacklist = list(
		/mob/living,
		/obj/effect/blob,
		/obj/effect/rune,
		/obj/effect/spider/spiderling,
		/obj/item/weapon/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/device/radio/beacon,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/clonepod
	)
	var/list/storage_objects = list(
		/obj/structure/closet,
		/obj/item/weapon/storage,
		/obj/item/weapon/moneybag,
		/obj/item/weapon/folder, // Selling a folder of stamped manifests? Sure, why not!
		/obj/structure/filingcabinet,
		/obj/structure/ore_box,
	)
	var/list/exports = list()
	var/list/exports_floor = list()

	// When TRUE, these vars allow exporting emagged/contraband items, and add some special interactions to existing exports.
	var/contraband = FALSE
	var/emagged = FALSE

/obj/docking_port/mobile/supply/New()
	..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(z == ZLEVEL_STATION)
		return check_blacklist(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(atom/A)
	if(is_type_in_list(A, blacklist))
		return 1
	for(var/thing in A)
		if(.(thing))
			return 1

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
		investigate_log("Order #[SO.id] ([SO.pack.name], placed by [key_name(SO.orderer_ckey)]) has shipped.", "cargo")
		if(SO.pack.dangerous)
			message_admins("\A [SO.pack.name] ordered by [key_name_admin(SO.orderer_ckey)] has shipped.")
		purchases++

	investigate_log("[purchases] orders in this shipment, worth [value] credits. [SSshuttle.points] credits left.", "cargo")

/obj/docking_port/mobile/supply/proc/sell()
	var/presale_points = SSshuttle.points

	if(!exports.len) // No exports list? Generate it!
		exports_floor.Cut()
		var/datum/export/E
		for(var/subtype in subtypesof(/datum/export))
			E = new subtype
			if(E.export_types && E.export_types.len) // Exports without a type are invalid/base types
				exports += E
				if(E.shuttle_floor)
					exports_floor += E

	var/msg = ""
	var/sold_atoms = ""

	for(var/atom/movable/AM in areaInstance)
		if(AM.anchored)
			continue
		sold_atoms += recursive_sell(AM)

	if(sold_atoms)
		sold_atoms += "."

	for(var/a in exports)
		var/datum/export/E = a
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		SSshuttle.points += E.total_cost
		E.export_end()

	SSshuttle.centcom_message = msg
	investigate_log("Shuttle contents sold for [SSshuttle.points - presale_points] credits. Contents: [sold_atoms || "none."] Message: [SSshuttle.centcom_message || "none."]", "cargo")

/obj/docking_port/mobile/supply/proc/recursive_sell(var/obj/O, var/level=0)
	var/sold_atoms = " [O.name]"
	var/list/xports = exports
	if(level == 0)
		xports = exports_floor // If on the floor level, sell floor exports only
	level++

	for(var/a in xports)
		var/datum/export/E = a
		if(E.applies_to(O, contraband, emagged))
			E.sell_object(O, contraband, emagged)
			break

	if(level < 10 && is_type_in_list(O, storage_objects))
		for(var/obj/thing in O)
			sold_atoms += recursive_sell(thing, level)
	qdel(O)
	return sold_atoms
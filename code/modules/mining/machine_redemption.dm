/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets. Points for ore are generated based on type and can be redeemed at a mining equipment vendor."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = 1
	anchored = 1
	input_dir = NORTH
	output_dir = SOUTH
	req_access = list(access_mineral_storeroom)
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/obj/item/weapon/card/id/inserted_id
	var/points = 0
	var/ore_pickup_rate = 15
	var/sheet_per_ore = 1
	var/point_upgrade = 1
	var/list/ore_values = list(("sand" = 1), ("iron" = 1), ("plasma" = 15), ("silver" = 16), ("gold" = 18), ("titanium" = 30), ("uranium" = 30), ("diamond" = 50), ("bluespace crystal" = 50), ("bananium" = 60))
	speed_process = 1

/obj/machinery/mineral/ore_redemption/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/ore_redemption(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/ore_redemption
	name = "Ore Redemption (Machine Board)"
	build_path = /obj/machinery/mineral/ore_redemption
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/device/assembly/igniter = 1)

/obj/machinery/mineral/ore_redemption/RefreshParts()
	var/ore_pickup_rate_temp = 15
	var/point_upgrade_temp = 1
	var/sheet_per_ore_temp = 1
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		sheet_per_ore_temp = 0.65 + (0.35 * B.rating)
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		ore_pickup_rate_temp = 15 * M.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		point_upgrade_temp = 0.65 + (0.35 * L.rating)
	ore_pickup_rate = ore_pickup_rate_temp
	point_upgrade = point_upgrade_temp
	sheet_per_ore = sheet_per_ore_temp

/obj/machinery/mineral/ore_redemption/proc/process_sheet(obj/item/weapon/ore/O)
	var/obj/item/stack/sheet/processed_sheet = SmeltMineral(O)
	if(processed_sheet)
		if(!(processed_sheet in stack_list)) //It's the first of this sheet added
			var/obj/item/stack/sheet/s = new processed_sheet(src,0)
			s.amount = 0
			stack_list[processed_sheet] = s
		var/obj/item/stack/sheet/storage = stack_list[processed_sheet]
		storage.amount += sheet_per_ore //Stack the sheets
		O.loc = null //Let the old sheet...
		qdel(O) //... garbage collect

/obj/machinery/mineral/ore_redemption/process()
	if(!panel_open && powered()) //If the machine is partially disassembled and/or depowered, it should not process minerals
		var/turf/T = get_step(src, input_dir)
		var/i = 0
		if(T)
			for(var/obj/item/weapon/ore/O in T)
				if (i >= ore_pickup_rate)
					break
				else if (!O || !O.refined_type)
					continue
				else
					process_sheet(O)
					i++
		else
			var/obj/structure/ore_box/B = locate() in T
			if(B)
				for(var/obj/item/weapon/ore/O in B.contents)
					if (i >= ore_pickup_rate)
						break
					else if (!O || !O.refined_type)
						continue
					else
						process_sheet(O)
						i++
		if(i > 0 && z == ZLEVEL_STATION)
			var/area/orm_area = get_area(src)
			var/msg = "Now available in [orm_area.map_name]:"
			for(var/s in stack_list) // Making an announcement for cargo
				var/obj/item/stack/sheet/mats = stack_list[s]
				msg += "\n[capitalize(mats.name)]: [mats.amount] sheets"
			for(var/obj/machinery/requests_console/D in allConsoles)
				if(D.department == "Science" || D.department == "Robotics" || D.department == "Research Director's Desk" || D.department == "Chemistry" || D.department == "Bar")
					D.createmessage("Ore Redemption Machine", "New minerals available!", msg, 1, 0)

/obj/machinery/mineral/ore_redemption/attackby(obj/item/weapon/W, mob/user, params)
	if (!powered())
		return
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = user.get_active_held_item()
		if(istype(I) && !istype(inserted_id))
			if(!user.drop_item())
				return
			I.forceMove(src)
			inserted_id = I
			interact(user)
		return
	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/mineral/ore_redemption/on_deconstruction()
	empty_content()

/obj/machinery/mineral/ore_redemption/proc/SmeltMineral(obj/item/weapon/ore/O)
	if(O.refined_type)
		var/obj/item/stack/sheet/M = O.refined_type
		points += O.points * point_upgrade
		return M
	qdel(O)//No refined type? Purge it.
	return

/obj/machinery/mineral/ore_redemption/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/ore_redemption/interact(mob/user)
	var/obj/item/stack/sheet/s
	var/dat

	dat += text("This machine only accepts ore. Gibtonite and Slag are not accepted.<br><br>")
	dat += text("Current unclaimed points: [points]<br>")

	if(istype(inserted_id))
		dat += text("You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>")
		dat += text("<A href='?src=\ref[src];choice=claim'>Claim points.</A><br>")
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>")

	for(var/O in stack_list)
		s = stack_list[O]
		if(s.amount > 0)
			if(O == stack_list[1])
				dat += "<br>"		//just looks nicer
			dat += text("[capitalize(s.name)]: [s.amount] <A href='?src=\ref[src];release=[s.type]'>Release</A><br>")

	var/obj/item/stack/sheet/metalstack
	if(/obj/item/stack/sheet/metal in stack_list)
		metalstack = stack_list[/obj/item/stack/sheet/metal]

	var/obj/item/stack/sheet/plasmastack
	if((/obj/item/stack/sheet/mineral/plasma in stack_list))
		plasmastack = stack_list[/obj/item/stack/sheet/mineral/plasma]

	var/obj/item/stack/sheet/mineral/titaniumstack
	if((/obj/item/stack/sheet/mineral/titanium in stack_list))
		titaniumstack = stack_list[/obj/item/stack/sheet/mineral/titanium]

	if(metalstack && plasmastack && min(metalstack.amount, plasmastack.amount))
		dat += text("Plasteel Alloy (Metal + Plasma): <A href='?src=\ref[src];alloytype1=/obj/item/stack/sheet/metal;alloytype2=/obj/item/stack/sheet/mineral/plasma;alloytypeout=/obj/item/stack/sheet/plasteel'>Smelt</A><BR>")
	if(titaniumstack && plasmastack && min(titaniumstack.amount, plasmastack.amount))
		dat += text("Plastitanium Alloy (Titanium + Plasma): <A href='?src=\ref[src];alloytype1=/obj/item/stack/sheet/mineral/titanium;alloytype2=/obj/item/stack/sheet/mineral/plasma;alloytypeout=/obj/item/stack/sheet/mineral/plastitanium'>Smelt</A><BR>")
	dat += text("<br><div class='statusDisplay'><b>Mineral Value List:</b><BR>[get_ore_values()]</div>")

	var/datum/browser/popup = new(user, "console_stacking_machine", "Ore Redemption Machine", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value * point_upgrade]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/ore_redemption/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
			if(href_list["choice"] == "claim")
				if(access_mining_station in inserted_id.access)
					inserted_id.mining_points += points
					points = 0
				else
					usr << "<span class='warning'>Required access not found.</span>"
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_held_item()
			if(istype(I))
				if(!usr.drop_item())
					return
				I.loc = src
				inserted_id = I
			else usr << "<span class='warning'>No valid ID.</span>"
	if(href_list["release"])
		if(check_access(inserted_id) || allowed(usr)) //Check the ID inside, otherwise check the user.
			if(!(text2path(href_list["release"]) in stack_list)) return
			var/obj/item/stack/sheet/inp = stack_list[text2path(href_list["release"])]
			var/obj/item/stack/sheet/out = new inp.type()
			var/desired = input("How much?", "How much to eject?", 1) as num
			out.amount = round(min(desired,50,inp.amount))
			if(out.amount >= 1)
				inp.amount -= out.amount
				unload_mineral(out)
			if(inp.amount < 1)
				stack_list -= text2path(href_list["release"])
		else
			usr << "<span class='warning'>Required access not found.</span>"
	if(href_list["alloytype1"] && href_list["alloytype2"] && href_list["alloytypeout"])
		var/alloytype1 = text2path(href_list["alloytype1"])
		var/alloytype2 = text2path(href_list["alloytype2"])
		var/alloytypeout = text2path(href_list["alloytypeout"])
		if(check_access(inserted_id) || allowed(usr))
			if(!(alloytype1 in stack_list)) return
			if(!(alloytype2 in stack_list)) return
			var/obj/item/stack/sheet/stack1 = stack_list[alloytype1]
			var/obj/item/stack/sheet/stack2 = stack_list[alloytype2]
			var/desired = input("How much?", "How much would you like to smelt?", 1) as num
			var/obj/item/stack/sheet/alloyout = new alloytypeout
			alloyout.amount = round(min(desired,50,stack1.amount,stack2.amount))
			if(alloyout.amount >= 1)
				stack1.amount -= alloyout.amount
				stack2.amount -= alloyout.amount
				unload_mineral(alloyout)
		else
			usr << "<span class='warning'>Required access not found.</span>"
	updateUsrDialog()
	return

/obj/machinery/mineral/ore_redemption/ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	..()

//empty the redemption machine by stacks of at most max_amount (50 at this time) size
/obj/machinery/mineral/ore_redemption/proc/empty_content()
	var/obj/item/stack/sheet/s

	for(var/O in stack_list)
		s = stack_list[O]
		while(s.amount > s.max_amount)
			new s.type(loc,s.max_amount)
			s.use(s.max_amount)
		s.loc = loc
		s.layer = initial(s.layer)
		s.plane = initial(s.plane)

/obj/machinery/mineral/ore_redemption/power_change()
	..()
	update_icon()

/obj/machinery/mineral/ore_redemption/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return

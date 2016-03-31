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
	var/list/ore_values = list(("sand" = 1), ("iron" = 1), ("plasma" = 15), ("silver" = 16), ("gold" = 18), ("uranium" = 30), ("diamond" = 50), ("bananium" = 60))
	speed_process = 1

/obj/machinery/mineral/ore_redemption/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/device/assembly/igniter(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

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
			if(s.name != "glass" && s.name != "metal")		//we can get these from cargo anyway
				var/msg = "[capitalize(s.name)] sheets are now available in the Cargo Bay."
				for(var/obj/machinery/requests_console/D in allConsoles)
					if(D.department == "Science" || D.department == "Robotics" || D.department == "Research Director's Desk" || (D.department == "Chemistry" && (s.name == "uranium" || s.name == "solid plasma")))
						D.createmessage("Ore Redemption Machine", "New minerals available!", msg, 1, 0)
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

/obj/machinery/mineral/ore_redemption/attackby(obj/item/weapon/W, mob/user, params)
	if (!powered())
		return
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I) && !istype(inserted_id))
			if(!user.drop_item())
				return
			I.loc = src
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
	if(panel_open)
		if(istype(W, /obj/item/weapon/crowbar))
			empty_content()
			default_deconstruction_crowbar(W)
		return 1
	..()

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

	if((/obj/item/stack/sheet/metal in stack_list) && (/obj/item/stack/sheet/mineral/plasma in stack_list))
		var/obj/item/stack/sheet/metalstack = stack_list[/obj/item/stack/sheet/metal]
		var/obj/item/stack/sheet/plasmastack = stack_list[/obj/item/stack/sheet/mineral/plasma]
		if(min(metalstack.amount, plasmastack.amount))
			dat += text("Plasteel Alloy (Metal + Plasma): <A href='?src=\ref[src];plasteel=1'>Smelt</A><BR>")

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
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
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
	if(href_list["plasteel"])
		if(check_access(inserted_id) || allowed(usr))
			if(!(/obj/item/stack/sheet/metal in stack_list)) return
			if(!(/obj/item/stack/sheet/mineral/plasma in stack_list)) return
			var/obj/item/stack/sheet/metalstack = stack_list[/obj/item/stack/sheet/metal]
			var/obj/item/stack/sheet/plasmastack = stack_list[/obj/item/stack/sheet/mineral/plasma]

			var/desired = input("How much?", "How much would you like to smelt?", 1) as num
			var/obj/item/stack/sheet/plasteel/plasteelout = new
			plasteelout.amount = round(min(desired,50,metalstack.amount,plasmastack.amount))
			if(plasteelout.amount >= 1)
				metalstack.amount -= plasteelout.amount
				plasmastack.amount -= plasteelout.amount
				unload_mineral(plasteelout)
		else
			usr << "<span class='warning'>Required access not found.</span>"
	updateUsrDialog()
	return

/obj/machinery/mineral/ore_redemption/ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(severity == 1)
		if(prob(50))
			empty_content()
			qdel(src)
	else if(severity == 2)
		if(prob(25))
			empty_content()
			qdel(src)

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

/obj/machinery/mineral/ore_redemption/power_change()
	..()
	update_icon()

/obj/machinery/mineral/ore_redemption/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return


/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = 1
	anchored = 1
	var/obj/item/weapon/card/id/inserted_id
	var/list/prize_list = list(
		new /datum/data/mining_equipment("Stimpack",			/obj/item/weapon/reagent_containers/hypospray/medipen/stimpack,	    50),
		new /datum/data/mining_equipment("Stimpack Bundle",		/obj/item/weapon/storage/box/medipens/utility,	 				   200),
		new /datum/data/mining_equipment("Whiskey",             /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,    100),
		new /datum/data/mining_equipment("Cigar",               /obj/item/clothing/mask/cigarette/cigar/havana,                    150),
		new /datum/data/mining_equipment("Soap",                /obj/item/weapon/soap/nanotrasen, 						           200),
		new /datum/data/mining_equipment("Laser Pointer",       /obj/item/device/laser_pointer, 				                   300),
		new /datum/data/mining_equipment("Alien Toy",           /obj/item/clothing/mask/facehugger/toy, 		                   300),
		new /datum/data/mining_equipment("Advanced Scanner",	/obj/item/device/t_scanner/adv_mining_scanner,                     800),
		new /datum/data/mining_equipment("Hivelord Stabilizer",	/obj/item/weapon/hivelordstabilizer			 ,                     400),
		new /datum/data/mining_equipment("Shelter Capsule",		/obj/item/weapon/survivalcapsule			 ,                     400),
		new /datum/data/mining_equipment("GAR scanners",		/obj/item/clothing/glasses/meson/gar,					  		   500),
		new /datum/data/mining_equipment("Brute First-Aid Kit",	/obj/item/weapon/storage/firstaid/brute,						   600),
		new /datum/data/mining_equipment("Jaunter",             /obj/item/device/wormhole_jaunter,                                 600),
		new /datum/data/mining_equipment("Kinetic Accelerator", /obj/item/weapon/gun/energy/kinetic_accelerator,               	   750),
		new /datum/data/mining_equipment("Resonator",           /obj/item/weapon/resonator,                                    	   800),
		new /datum/data/mining_equipment("Lazarus Injector",    /obj/item/weapon/lazarus_injector,                                1000),
		new /datum/data/mining_equipment("Silver Pickaxe",		/obj/item/weapon/pickaxe/silver,				                  1000),
		new /datum/data/mining_equipment("Jetpack Upgrade",		/obj/item/hardsuit_jetpack						,	              2000),
		new /datum/data/mining_equipment("Space Cash",    		/obj/item/stack/spacecash/c1000,                    			  2000),
		new /datum/data/mining_equipment("Diamond Pickaxe",		/obj/item/weapon/pickaxe/diamond,				                  2000),
		new /datum/data/mining_equipment("Super Resonator",     /obj/item/weapon/resonator/upgraded,                              2500),
		new /datum/data/mining_equipment("Super Accelerator",	/obj/item/weapon/gun/energy/kinetic_accelerator/super,			  3000),
		new /datum/data/mining_equipment("Point Transfer Card", /obj/item/weapon/card/mining_point_card,               			   500),
		new /datum/data/mining_equipment("Mining Drone",        /mob/living/simple_animal/hostile/mining_drone,                    800),
		new /datum/data/mining_equipment("Drone Melee Upgrade", /obj/item/device/mine_bot_ugprade,      			   			   400),
		new /datum/data/mining_equipment("Drone Health Upgrade",/obj/item/device/mine_bot_ugprade/health,      			   	       400),
		new /datum/data/mining_equipment("Drone Ranged Upgrade",/obj/item/device/mine_bot_ugprade/cooldown,      			   	   600),
		new /datum/data/mining_equipment("Drone AI Upgrade",    /obj/item/slimepotion/sentience/mining,      			   	      1000),
		)

/datum/data/mining_equipment/
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/mining_equipment_vendor(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/power_change()
	..()
	update_icon()

/obj/machinery/mineral/equipment_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return

/obj/machinery/mineral/equipment_vendor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/equipment_vendor/interact(mob/user)
	var/dat
	dat +="<div class='statusDisplay'>"
	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='200'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "miningvendor", "Mining Equipment Vendor", 400, 350)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/mineral/equipment_vendor/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				if(!usr.drop_item())
					return
				I.loc = src
				inserted_id = I
			else usr << "<span class='danger'>No valid ID.</span>"
	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if (!prize || !(prize in prize_list))
				return
			if(prize.cost > inserted_id.mining_points)
			else
				inserted_id.mining_points -= prize.cost
				new prize.equipment_path(src.loc)
	updateUsrDialog()
	return

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/mining_voucher))
		RedeemVoucher(I, user)
		return
	if(istype(I,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = usr.get_active_hand()
		if(istype(C) && !istype(inserted_id))
			if(!usr.drop_item())
				return
			C.loc = src
			inserted_id = C
			interact(user)
		return
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		updateUsrDialog()
		return
	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(I)
		return 1
	..()

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/weapon/mining_voucher/voucher, mob/redeemer)
	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in list("Two Survival Capsules", "Resonator", "Mining Drone", "Advanced Scanner")
	if(!selection || !Adjacent(redeemer) || qdeleted(voucher) || voucher.loc != redeemer)
		return
	switch(selection)
		if("Two Survival Capsules")
			new /obj/item/weapon/survivalcapsule(src.loc)
			new /obj/item/weapon/survivalcapsule(src.loc)
		if("Resonator")
			new /obj/item/weapon/resonator(src.loc)
		if("Mining Drone")
			new /mob/living/simple_animal/hostile/mining_drone(src.loc)
			new /obj/item/weapon/weldingtool/hugetank(src.loc)
		if("Advanced Scanner")
			new /obj/item/device/t_scanner/adv_mining_scanner(src.loc)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(prob(50 / severity) && severity < 3)
		qdel(src)

/**********************Mining Equipment Vendor Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/weapon/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = 1

/**********************Mining Point Card**********************/

/obj/item/weapon/card/mining_point_card
	name = "mining points card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data"
	var/points = 500

/obj/item/weapon/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		if(points)
			var/obj/item/weapon/card/id/C = I
			C.mining_points += points
			user << "<span class='info'>You transfer [points] points to [C].</span>"
			points = 0
		else
			user << "<span class='info'>There's no points left on [src].</span>"
	..()

/obj/item/weapon/card/mining_point_card/examine(mob/user)
	..()
	user << "There's [points] point\s on the card."

/**********************Jaunter**********************/

/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"

/obj/item/device/wormhole_jaunter/attack_self(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==2||device_turf.z>=7)
		user << "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>"
		return
	else
		user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
		var/list/L = list()
		for(var/obj/item/device/radio/beacon/B in world)
			var/turf/T = get_turf(B)
			if(T.z == ZLEVEL_STATION)
				L += B
		if(!L.len)
			user << "<span class='notice'>The [src.name] failed to create a wormhole.</span>"
			return
		var/chosen_beacon = pick(L)
		var/obj/effect/portal/wormhole/jaunt_tunnel/J = new /obj/effect/portal/wormhole/jaunt_tunnel(get_turf(src), chosen_beacon, lifespan=100)
		J.target = chosen_beacon
		try_move_adjacent(J)
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		qdel(src)

/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		if(do_teleport(M, target, 6))
			if(iscarbon(M))
				var/mob/living/carbon/L = M
				L.Weaken(3)
				if(ishuman(L))
					shake_camera(L, 20, 1)
					spawn(20)
						if(L)
							L.vomit(20)

/**********************Resonator**********************/

/obj/item/weapon/resonator
	name = "resonator"
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vacuum."
	w_class = 3
	force = 15
	throwforce = 10
	var/cooldown = 0
	var/fieldsactive = 0
	var/burst_time = 30
	var/fieldlimit = 4
	origin_tech = "magnets=2;combat=2"

/obj/item/weapon/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once."
	icon_state = "resonator_u"
	item_state = "resonator_u"
	origin_tech = "magnets=3;combat=3"
	fieldlimit = 6

/obj/item/weapon/resonator/proc/CreateResonance(target, creator)
	var/turf/T = get_turf(target)
	if(locate(/obj/effect/resonance) in T)
		return
	if(fieldsactive < fieldlimit)
		playsound(src,'sound/weapons/resonator_fire.ogg',50,1)
		new /obj/effect/resonance(T, creator, burst_time)
		fieldsactive++
		spawn(burst_time)
			fieldsactive--

/obj/item/weapon/resonator/attack_self(mob/user)
	if(burst_time == 50)
		burst_time = 30
		user << "<span class='info'>You set the resonator's fields to detonate after 3 seconds.</span>"
	else
		burst_time = 50
		user << "<span class='info'>You set the resonator's fields to detonate after 5 seconds.</span>"

/obj/item/weapon/resonator/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(!check_allowed_items(target, 1)) return
		CreateResonance(target, user)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = 0
	var/resonance_damage = 20

/obj/effect/resonance/New(loc, var/creator = null, var/timetoburst)
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf))
		return
	if(istype(proj_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = proj_turf
		spawn(timetoburst)
			playsound(src,'sound/weapons/resonator_blast.ogg',50,1)
			M.gets_drilled(creator)
			qdel(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance field"
			resonance_damage = 60
		spawn(timetoburst)
			playsound(src,'sound/weapons/resonator_blast.ogg',50,1)
			if(creator)
				for(var/mob/living/L in src.loc)
					add_logs(creator, L, "used a resonator field on", "resonator")
					L << "<span class='danger'>The [src.name] ruptured with you in it!</span>"
					L.adjustBruteLoss(resonance_damage)
			else
				for(var/mob/living/L in src.loc)
					L << "<span class='danger'>The [src.name] ruptured with you in it!</span>"
					L.adjustBruteLoss(resonance_damage)
			qdel(src)

/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger/toy
	item_state = "facehugger_inactive"
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	real = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/Die()
	return

/**********************Mining drone**********************/

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife. A mining scanner can instruct it to drop loose ore. Field repairs can be done with a welder."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	stop_automated_movement_when_pulled = 1
	mouse_opacity = 1
	faction = list("neutral")
	a_intent = "harm"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	wander = 0
	idle_vision_range = 5
	move_to_delay = 10
	retreat_distance = 1
	minimum_distance = 2
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	environment_smash = 0
	check_friendly_fire = 1
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	ranged = 1
	sentience_type = SENTIENCE_MINEBOT
	ranged_message = "shoots"
	ranged_cooldown_cap = 3
	projectiletype = /obj/item/projectile/kinetic
	projectilesound = 'sound/weapons/Gunshot4.ogg'
	speak_emote = list("states")
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/plasma,  /obj/item/weapon/ore/uranium,    /obj/item/weapon/ore/iron,
						  /obj/item/weapon/ore/bananium)
	healable = 0

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding && !stat)
			if(AIStatus != AI_OFF && AIStatus != AI_IDLE)
				user << "<span class='info'>[src] is moving around too much to repair!</span>"
				return
			if(maxHealth == health)
				user << "<span class='info'>[src] is at full integrity.</span>"
			else
				adjustBruteLoss(-10)
				user << "<span class='info'>You repair some of the armor on [src].</span>"
			return
	if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner))
		user << "<span class='info'>You instruct [src] to drop any collected ore.</span>"
		DropOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/death()
	..()
	visible_message("<span class='danger'>[src] is destroyed!</span>")
	new /obj/effect/decal/cleanable/robot_debris(src.loc)
	DropOre()
	qdel(src)
	return

/mob/living/simple_animal/hostile/mining_drone/New()
	..()
	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == "help")
		switch(search_objects)
			if(0)
				SetCollectBehavior()
				M << "<span class='info'>[src] has been set to search and store loose ore.</span>"
			if(2)
				SetOffenseBehavior()
				M << "<span class='info'>[src] has been set to attack hostile wildlife.</span>"
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	idle_vision_range = 7
	search_objects = 0
	wander = 0
	ranged = 1
	retreat_distance = 1
	minimum_distance = 2
	icon_state = "mining_drone_offense"

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		CollectOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	var/obj/item/weapon/ore/O
	for(O in src.loc)
		O.loc = src
	for(var/dir in alldirs)
		var/turf/T = get_step(src,dir)
		for(O in T)
			O.loc = src
	return

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre()
	if(!contents.len)
		return
	for(var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	return

/mob/living/simple_animal/hostile/mining_drone/adjustHealth()
	if(search_objects)
		SetOffenseBehavior()
	. = ..()

/**********************Minebot Upgrades**********************/

//Melee

/obj/item/device/mine_bot_ugprade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'

/obj/item/device/mine_bot_ugprade/afterattack(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(!istype(M))
		return
	upgrade_bot(M, user)

/obj/item/device/mine_bot_ugprade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.melee_damage_upper != initial(M.melee_damage_upper))
		user << "[src] already has a combat upgrade installed!"
		return
	M.melee_damage_lower = 22
	M.melee_damage_upper = 22
	qdel(src)

//Health

/obj/item/device/mine_bot_ugprade/health
	name = "minebot chassis upgrade"

/obj/item/device/mine_bot_ugprade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		user << "[src] already has a reinforced chassis!"
		return
	M.maxHealth = 170
	qdel(src)


//Cooldown

/obj/item/device/mine_bot_ugprade/cooldown
	name = "minebot cooldown upgrade"

/obj/item/device/mine_bot_ugprade/cooldown/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	name = "minebot cooldown upgrade"
	if(M.ranged_cooldown_cap != initial(M.ranged_cooldown_cap))
		user << "[src] already has a decreased weapon cooldown!"
		return
	M.ranged_cooldown_cap = 1
	qdel(src)


//AI
/obj/item/slimepotion/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	sentience_type = SENTIENCE_MINEBOT


/**********************Lazarus Injector**********************/

/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	origin_tech = "biotech=4"

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive(full_heal = 1, admin_revive = 1)
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = 1
						H.friends += user
						H.attack_same = 1
						log_game("[user] has revived hostile mob [target] with a malfunctioning lazarus injector")
					else
						H.attack_same = 0
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				user << "<span class='info'>[src] is only effective on the dead.</span>"
				return
		else
			user << "<span class='info'>[src] is only effective on lesser beings.</span>"
			return

/obj/item/weapon/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/weapon/lazarus_injector/examine(mob/user)
	..()
	if(!loaded)
		user << "<span class='info'>[src] is empty.</span>"
	if(malfunctioning)
		user << "<span class='info'>The display on [src] seems to be flickering.</span>"

/**********************Mining Scanners**********************/

/obj/item/device/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	name = "manual mining scanner"
	icon_state = "mining1"
	item_state = "analyzer"
	w_class = 2
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 0
	origin_tech = "engineering=1;magnets=1"

/obj/item/device/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(!cooldown)
		cooldown = 1
		spawn(40)
			cooldown = 0
		var/list/mobs = list()
		mobs |= user
		mineral_scan_pulse(mobs, get_turf(user))


//Debug item to identify all ore spread quickly
/obj/item/device/mining_scanner/admin

/obj/item/device/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/simulated/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/device/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. This one has an extended range."
	name = "advanced automatic mining scanner"
	icon_state = "mining0"
	item_state = "analyzer"
	w_class = 2
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 35
	var/on_cooldown = 0
	var/range = 7
	var/meson = TRUE
	origin_tech = "engineering=3;magnets=3"

/obj/item/device/t_scanner/adv_mining_scanner/material
	meson = FALSE
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results. This one has an extended range."

/obj/item/device/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results."
	range = 4
	cooldown = 50

/obj/item/device/t_scanner/adv_mining_scanner/lesser/material
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	meson = FALSE

/obj/item/device/t_scanner/adv_mining_scanner/scan()
	if(!on_cooldown)
		on_cooldown = 1
		spawn(cooldown)
			on_cooldown = 0
		var/turf/t = get_turf(src)
		var/list/mobs = recursive_mob_check(t, 1,0,0)
		if(!mobs.len)
			return
		if(meson)
			mineral_scan_pulse(mobs, t, range)
		else
			mineral_scan_pulse_material(mobs, t, range)

//For use with mesons
/proc/mineral_scan_pulse(list/mobs, turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(minerals.len)
		for(var/mob/user in mobs)
			if(user.client)
				var/client/C = user.client
				for(var/turf/simulated/mineral/M in minerals)
					var/turf/F = get_turf(M)
					var/image/I = image('icons/turf/mining.dmi', loc = F, icon_state = M.scan_state, layer = 18)
					C.images += I
					spawn(30)
						if(C)
							C.images -= I

//For use with material scanners
/proc/mineral_scan_pulse_material(list/mobs, turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(minerals.len)
		for(var/turf/simulated/mineral/M in minerals)
			var/obj/effect/overlay/temp/mining_overlay/C = PoolOrNew(/obj/effect/overlay/temp/mining_overlay, M)
			C.icon_state = M.scan_state

/obj/effect/overlay/temp/mining_overlay
	layer = 20
	icon = 'icons/turf/smoothrocks.dmi'
	anchored = 1
	mouse_opacity = 0
	duration = 30
	pixel_x = -4
	pixel_y = -4


/**********************Xeno Warning Sign**********************/
/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"

/******************Hardsuit Jetpack Upgrade*******************/
/obj/item/hardsuit_jetpack
	name = "hardsuit jetpack upgrade"
	icon_state = "jetpack_upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."


/obj/item/hardsuit_jetpack/afterattack(var/obj/item/clothing/suit/space/hardsuit/S, mob/user)
	..()
	if(!istype(S))
		user << "<span class='warning'>This upgrade can only be applied to a hardsuit.</span>"
	else if(S.jetpack)
		user << "<span class='warning'>[S] already has a jetpack installed.</span>"
	else if(S == user.get_item_by_slot(slot_wear_suit)) //Make sure the player is not wearing the suit before applying the upgrade.
		user << "<span class='warning'>You cannot install the upgrade to [S] while wearing it.</span>"
	else
		S.jetpack = new /obj/item/weapon/tank/jetpack/suit(S)
		user << "<span class='notice'>You successfully install the jetpack into [S].</span>"
		qdel(src)

/*********************Hivelord stabilizer****************/

/obj/item/weapon/hivelordstabilizer
	name = "hivelord stabilizer"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject a hivelord core with this stabilizer to preserve its healing powers indefinitely."
	w_class = 1
	origin_tech = "biotech=1"

/obj/item/weapon/hivelordstabilizer/afterattack(obj/item/organ/internal/M, mob/user)
	var/obj/item/organ/internal/hivelord_core/C = M
	if(!istype(C, /obj/item/organ/internal/hivelord_core))
		user << "<span class='warning'>The stabilizer only works on hivelord cores.</span>"
		return ..()
	C.preserved = 1
	user << "<span class='notice'>You inject the hivelord core with the stabilizer. It will no longer go inert.</span>"
	qdel(src)



/****************Explorer's Suit**************************/

/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon_state = "explorer"
	item_state = "explorer"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hooded = 1
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/explorer
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/resonator, /obj/item/device/mining_scanner, /obj/item/device/t_scanner/adv_mining_scanner, /obj/item/weapon/gun/energy/kinetic_accelerator)

/obj/item/clothing/head/explorer
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon_state = "explorer"
	body_parts_covered = HEAD
	flags = NODROP
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 50, bio = 100, rad = 50)
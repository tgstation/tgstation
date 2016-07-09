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
		new /datum/data/mining_equipment("Stimpack",			/obj/item/weapon/reagent_containers/hypospray/medipen/stimpack,	    	50),
		new /datum/data/mining_equipment("Stimpack Bundle",		/obj/item/weapon/storage/box/medipens/utility,	 				  		200),
		new /datum/data/mining_equipment("Whiskey",             /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,    		100),
		new /datum/data/mining_equipment("Absinthe",            /obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/premium,100),
		new /datum/data/mining_equipment("Cigar",               /obj/item/clothing/mask/cigarette/cigar/havana,                    		150),
		new /datum/data/mining_equipment("Soap",                /obj/item/weapon/soap/nanotrasen, 						          		200),
		new /datum/data/mining_equipment("Laser Pointer",       /obj/item/device/laser_pointer, 				                   		300),
		new /datum/data/mining_equipment("Alien Toy",           /obj/item/clothing/mask/facehugger/toy, 		                   		300),
		new /datum/data/mining_equipment("Advanced Scanner",	/obj/item/device/t_scanner/adv_mining_scanner,                     		800),
		new /datum/data/mining_equipment("Stabilizing Serum",	/obj/item/weapon/hivelordstabilizer			 ,                     		400),
		new /datum/data/mining_equipment("Fulton Beacon",		/obj/item/fulton_core			 ,                     					400),
		new /datum/data/mining_equipment("Shelter Capsule",		/obj/item/weapon/survivalcapsule			 ,                     		400),
		new /datum/data/mining_equipment("GAR scanners",		/obj/item/clothing/glasses/meson/gar,					  		   		500),
		new /datum/data/mining_equipment("Explorer's Webbing",	/obj/item/weapon/storage/belt/mining,									500),
		new /datum/data/mining_equipment("Survival Medipen",	/obj/item/weapon/reagent_containers/hypospray/medipen/survival,			500),
		new /datum/data/mining_equipment("Brute First-Aid Kit",	/obj/item/weapon/storage/firstaid/brute,						   		600),
		new /datum/data/mining_equipment("Tracking Implant Kit",/obj/item/weapon/storage/box/minertracker,                              600),
		new /datum/data/mining_equipment("Jaunter",             /obj/item/device/wormhole_jaunter,										750),
		new /datum/data/mining_equipment("Kinetic Accelerator", /obj/item/weapon/gun/energy/kinetic_accelerator,               	   		750),
		new /datum/data/mining_equipment("Resonator",           /obj/item/weapon/resonator,                                    	   		800),
		new /datum/data/mining_equipment("Medivac Balloon",     /obj/item/weapon/extraction_pack/medivac,                               800),
		new /datum/data/mining_equipment("Fulton Pack",         /obj/item/weapon/extraction_pack,                                    	1000),
		new /datum/data/mining_equipment("Lazarus Injector",    /obj/item/weapon/lazarus_injector,                                		1000),
		new /datum/data/mining_equipment("Silver Pickaxe",		/obj/item/weapon/pickaxe/silver,				                  		1000),
		new /datum/data/mining_equipment("Jetpack Upgrade",		/obj/item/weapon/tank/jetpack/suit,	              						2000),
		new /datum/data/mining_equipment("Space Cash",    		/obj/item/stack/spacecash/c1000,                    			  		2000),
		new /datum/data/mining_equipment("Mining Hardsuit",		/obj/item/clothing/suit/space/hardsuit/mining,				            2000),
		new /datum/data/mining_equipment("Diamond Pickaxe",		/obj/item/weapon/pickaxe/diamond,				                  		2000),
		new /datum/data/mining_equipment("Super Resonator",     /obj/item/weapon/resonator/upgraded,                              		2500),
		new /datum/data/mining_equipment("Super Accelerator",	/obj/item/weapon/gun/energy/kinetic_accelerator/super,			  		3000),
		new /datum/data/mining_equipment("Point Transfer Card", /obj/item/weapon/card/mining_point_card,               			   		500),
		new /datum/data/mining_equipment("Mining Drone",        /mob/living/simple_animal/hostile/mining_drone,                   		800),
		new /datum/data/mining_equipment("Drone Melee Upgrade", /obj/item/device/mine_bot_ugprade,      			   			   		400),
		new /datum/data/mining_equipment("Drone Health Upgrade",/obj/item/device/mine_bot_ugprade/health,      			   	       		400),
		new /datum/data/mining_equipment("Drone Ranged Upgrade",/obj/item/device/mine_bot_ugprade/cooldown,      			   	   		600),
		new /datum/data/mining_equipment("Drone AI Upgrade",    /obj/item/slimepotion/sentience/mining,      			   	      		1000),
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
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/mining_equipment_vendor(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	origin_tech = "programming=1;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 3)

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
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='300'>"
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
				feedback_add_details("mining_equipment_bought",
					"[src.type]|[prize.equipment_path]")
				// Add src.type to keep track of free golem purchases
				// seperately.
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
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/weapon/mining_voucher/voucher, mob/redeemer)
	var/items = list("Survival Capsule and Explorer's Webbing", "Resonator and Advanced Scanner", "Mining Drone", "Medivac Kit", "Extraction Kit")

	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in items
	if(!selection || !Adjacent(redeemer) || qdeleted(voucher) || voucher.loc != redeemer)
		return
	switch(selection)
		if("Survival Capsule and Explorer's Webbing")
			new /obj/item/weapon/storage/belt/mining/vendor(src.loc)
		if("Resonator and Advanced Scanner")
			new /obj/item/weapon/resonator(src.loc)
			new /obj/item/device/t_scanner/adv_mining_scanner(src.loc)
		if("Mining Drone")
			new /mob/living/simple_animal/hostile/mining_drone(src.loc)
			new /obj/item/weapon/weldingtool/hugetank(src.loc)
		if("Medivac Kit")
			new /obj/item/stack/sheet/metal/five(loc)
			new /obj/item/fulton_core(loc)
			new /obj/item/weapon/extraction_pack/medivac(loc)
			new /obj/item/weapon/reagent_containers/hypospray/medipen/survival(loc)
		if("Extraction Kit")
			new /obj/item/stack/sheet/metal/five(loc)
			new /obj/item/weapon/extraction_pack(loc)
			new /obj/item/fulton_core(loc)

	feedback_add_details("mining_voucher_redeemed", selection)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(prob(50 / severity) && severity < 3)
		qdel(src)


/****************Golem Point Vendor**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"

/obj/machinery/mineral/equipment_vendor/golem/New()
	..()
	desc += "\nIt seems a few selections have been added."
	prize_list += list(
		new /datum/data/mining_equipment("Science Goggles",       	/obj/item/clothing/glasses/science, 				                   	250),
		new /datum/data/mining_equipment("Monkey Cube",				/obj/item/weapon/reagent_containers/food/snacks/monkeycube,        		300),
		new /datum/data/mining_equipment("Toolbelt",				/obj/item/weapon/storage/belt/utility,	    							350),
		new /datum/data/mining_equipment("Sulphuric Acid",			/obj/item/weapon/reagent_containers/glass/beaker/sulphuric,        		500),
		new /datum/data/mining_equipment("Brute First-Aid Kit",		/obj/item/weapon/storage/firstaid/brute,						   		600),
		new /datum/data/mining_equipment("Grey Slime Extract",		/obj/item/slime_extract/grey,				       		           		1000),
		new /datum/data/mining_equipment("Modification Kit",    	/obj/item/modkit,                                	                	1700),
		new /datum/data/mining_equipment("The Liberator's Legacy",  /obj/item/weapon/storage/box/rndboards,      			      			2000),

		)

	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/mining_equipment_vendor/golem(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/mining_equipment_vendor/golem
	name = "circuit board (Golem Ship Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor/golem


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

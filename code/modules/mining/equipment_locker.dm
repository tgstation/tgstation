/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system
/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets, but cannot produce alloys such as Plasteel. Points for ore are generated based on type and can be redeemed at a mining equipment locker."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/stacking_unit_console/CONSOLE
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50; //ammount to stack before releassing
	input_dir = EAST
	output_dir = WEST
	var/obj/item/weapon/card/id/inserted_id
	var/points = 0
	var/list/ore_values = list(("sand" = 1), ("iron" = 1), ("plasma" = 10), ("gold" = 20), ("silver" = 20), ("uranium" = 20), ("bananium" = 30), ("diamond" = 40))

/obj/machinery/mineral/ore_redemption/proc/process_sheet(obj/item/weapon/ore/O)
	var/obj/item/stack/sheet/processed_sheet = SmeltMineral(O)
	if(processed_sheet)
		if(!(processed_sheet.type in stack_list)) //It's the first of this sheet added
			var/obj/item/stack/sheet/s = new processed_sheet.type(src,0)
			s.amount = 0
			stack_list[processed_sheet.type] = s
		var/obj/item/stack/sheet/storage = stack_list[processed_sheet.type]
		storage.amount += processed_sheet.amount //Stack the sheets
		O.loc = null //Let the old sheet garbage collect
		while(storage.amount > stack_amt) //Get rid of excessive stackage
			var/obj/item/stack/sheet/out = new processed_sheet.type()
			out.amount = stack_amt
			unload_mineral(out)
			storage.amount -= stack_amt

/obj/machinery/mineral/ore_redemption/process()
	var/turf/T = get_step(src, input_dir)
	if(T)
		for(var/obj/item/weapon/ore/O in T)
			process_sheet(O)

/obj/machinery/mineral/ore_redemption/proc/SmeltMineral(var/obj/item/weapon/ore/O)
	if(istype(O, /obj/item/weapon/ore/diamond))
		var/obj/item/stack/sheet/mineral/diamond/M = new /obj/item/stack/sheet/mineral/diamond(src)
		points += 40
		return M
	if(istype(O, /obj/item/weapon/ore/clown))
		points += 30
		var/obj/item/stack/sheet/mineral/clown/M = new /obj/item/stack/sheet/mineral/clown(src)
		return M
	if(istype(O, /obj/item/weapon/ore/uranium))
		var/obj/item/stack/sheet/mineral/uranium/M = new /obj/item/stack/sheet/mineral/uranium(src)
		points += 20
		return M
	if(istype(O, /obj/item/weapon/ore/silver))
		points += 20
		var/obj/item/stack/sheet/mineral/silver/M = new /obj/item/stack/sheet/mineral/silver(src)
		return M
	if(istype(O, /obj/item/weapon/ore/gold))
		points += 20
		var/obj/item/stack/sheet/mineral/gold/M = new /obj/item/stack/sheet/mineral/gold(src)
		return M
	if(istype(O, /obj/item/weapon/ore/plasma))
		points += 10
		var/obj/item/stack/sheet/mineral/plasma/M = new /obj/item/stack/sheet/mineral/plasma(src)
		return M
	if(istype(O, /obj/item/weapon/ore/glass))
		points += 1
		var/obj/item/stack/sheet/glass/M = new /obj/item/stack/sheet/glass(src)
		return M
	if(istype(O, /obj/item/weapon/ore/iron))
		points += 1
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(src)
		return M
	del(O)//If it isn't any of these things, just vaporize it!
	return

/obj/machinery/mineral/ore_redemption/attack_hand(user as mob)

	var/obj/item/stack/sheet/s
	var/dat

	dat += text("<b>Ore Redemption Machine</b><br><br>")
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
			dat += text("[capitalize(s.name)]: [s.amount] <A href='?src=\ref[src];release=[s.type]'>Release</A><br>")

	dat += text("<br>This unit can hold stacks of [stack_amt] sheets of each mineral type.<br><br>")

	dat += text("<HR><b>Mineral Value List:</b><BR>[get_ore_values()]")

	user << browse("[dat]", "window=console_stacking_machine")

	return

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/ore_redemption/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
			if(href_list["choice"] == "claim")
				inserted_id.mining_points += points
				points = 0
				src << "Points transferred."
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else usr << "\red No valid ID."
	if(href_list["release"])
		if(!(text2path(href_list["release"]) in stack_list)) return
		var/obj/item/stack/sheet/inp = stack_list[text2path(href_list["release"])]
		var/obj/item/stack/sheet/out = new inp.type()
		out.amount = inp.amount
		inp.amount = 0
		unload_mineral(out)
	src.updateUsrDialog()
	return

/**********************Mining Equipment Locker**************************/
/obj/machinery/mineral/equipment_locker
	name = "mining equipment locker"
	desc = "An equipment locker for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
	var/obj/item/weapon/card/id/inserted_id
	var/list/prize_list = list(
		new /datum/data/mining_equipment("Chili",               /obj/item/weapon/reagent_containers/food/snacks/hotchili,          100),
		new /datum/data/mining_equipment("Whiskey",             /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,    500),
		new /datum/data/mining_equipment("Cigar",               /obj/item/clothing/mask/cigarette/cigar/havana,                    500),
		new /datum/data/mining_equipment("Soap",                /obj/item/weapon/soap/nanotrasen, 						           500),
		new /datum/data/mining_equipment("Stimulant pills",     /obj/item/weapon/storage/pill_bottle/stimulant, 				   700),
		new /datum/data/mining_equipment("Alien toy",           /obj/item/clothing/mask/facehugger/toy, 		                  1000),
		new /datum/data/mining_equipment("Laser pointer",       /obj/item/device/laser_pointer, 				                  1500),
		new /datum/data/mining_equipment("Space cash",    		/obj/item/weapon/spacecash/c500,                    			  5000),
		new /datum/data/mining_equipment("Drill",               /obj/item/weapon/pickaxe/drill,                                    500),
		new /datum/data/mining_equipment("Sonic Jackhammer",    /obj/item/weapon/pickaxe/jackhammer,                              1000),
		new /datum/data/mining_equipment("Jaunter",             /obj/item/device/wormhole_jaunter,                                1000),
		new /datum/data/mining_equipment("Resonator",           /obj/item/weapon/resonator,                                       1500),
		new /datum/data/mining_equipment("Kinetic accelerator", /obj/item/weapon/gun/energy/kinetic_accelerator,                  2500),
		new /datum/data/mining_equipment("Jetpack",             /obj/item/weapon/tank/jetpack/carbondioxide,                      5000),)

/datum/data/mining_equipment/
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_locker/attack_hand(user as mob)
	var/dat
	dat += text("<b>Mining Equipment Locker</b><br><br>")

	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"

	dat += "<HR><b>Equipment point cost list:</b><BR><table border='0' width='200'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	user << browse("[dat]", "window=mining_equipment_locker")
	return

/obj/machinery/mineral/equipment_locker/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else usr << "\red No valid ID."
	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if (!prize || !(prize in prize_list))
				return
			world << "You tried to purchase something."
			if(prize.cost > inserted_id.mining_points)
				world << "Couldn't afford the item"
			else
				inserted_id.mining_points -= prize.cost
				new prize.equipment_path(src.loc)
		else
			world << "There wasn't an ID inside!"
	src.updateUsrDialog()
	return

/**********************Mining Equipment Locker Items**************************/

//Wormhole jaunter
/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"

/obj/item/device/wormhole_jaunter/attack_self(mob/user as mob)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==2||device_turf.z>=7)
		user << "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>"
		return
	else
		user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
		var/list/L = list()
		for(var/obj/item/device/radio/beacon/B in world)
			var/turf/T = get_turf(B)
			if(T.z == 1)
				L += B
		if(!L.len)
			user << "<span class='notice'>The [src.name] failed to create a wormhole.</span>"
			return
		var/chosen_beacon = pick(L)
		var/obj/effect/portal/wormhole/jaunt_tunnel/J = new /obj/effect/portal/wormhole/jaunt_tunnel(get_turf(src), chosen_beacon, lifespan=100)
		J.target = chosen_beacon
		try_move_adjacent(J)
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		del(src)

/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		do_teleport(M, target, 6)
		if(isliving(M))
			var/mob/living/L = M
			L.Weaken(3)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				spawn(20)
					L.visible_message("<span class='danger'>[L.name] vomits from travelling through the [src.name]!</span>")
					L.nutrition -= 20
					L.adjustToxLoss(-3)
					var/turf/T = get_turf(L)
					T.add_vomit_floor(L)
					playsound(L, 'sound/effects/splat.ogg', 50, 1)

//Mining Resonator

/obj/item/weapon/resonator
	name = "resonator"
	icon = 'icons/obj/items.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vaccuum."
	w_class = 3
	force = 10
	throwforce = 10
	var/cooldown = 0

/obj/item/weapon/resonator/proc/CreateResonance(var/target)
	if(cooldown <= 0)
		playsound(src,'sound/effects/stealthoff.ogg',50,1)
		new /obj/effect/resonance(get_turf(target))
		cooldown = 1
		spawn(25)
			cooldown = 0

/obj/item/weapon/resonator/attack_self(mob/user as mob)
	CreateResonance(src)
	..()

/obj/item/weapon/resonator/attack(var/atom/A)
	CreateResonance(A)
	..()

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = 0
	var/resonance_damage = 30

/obj/effect/resonance/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	if(istype(proj_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = proj_turf
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		M.gets_drilled()
		spawn(5)
			del(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance"
			resonance_damage = 60
		spawn(50)
			playsound(src,'sound/effects/sparks4.ogg',50,1)
			for(var/mob/living/L in src.loc)
				L << "<span class='danger'>The [src.name] ruptured with you in it!</span>"
				L.adjustBruteLoss(resonance_damage)
			del(src)

//Fakehugger Toy
/obj/item/clothing/mask/facehugger/toy
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/examine()//So that giant red text about probisci doesn't show up.
	if(desc)
		usr << desc

/obj/item/clothing/mask/facehugger/toy/Die()
	return

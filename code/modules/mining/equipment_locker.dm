/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets, but cannot produce alloys such as Plasteel. Points for ore are generated based on type and can be redeemed at a mining equipment locker."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	req_one_access = list(
		access_mining_station,
		access_chemistry,
		access_bar,
		access_research,
		access_ce,
		access_virology
	)
	var/datum/materials/materials = new
	var/stack_amt = 50 //amount to stack before releasing
	var/obj/item/weapon/card/id/inserted_id
	var/credits = 0

/obj/machinery/mineral/ore_redemption/initialize()
	for (var/dir in cardinal)
		src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
		if(src.input) break
	for (var/dir in cardinal)
		src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(src.output) break

/obj/machinery/mineral/ore_redemption/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W,/obj/item/weapon/card/id))
		// N3X - Fixes people's IDs getting eaten when a new card is inserted
		if(istype(inserted_id))
			user << "\red There is already an ID card within the machine."
			return
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I))
			usr.drop_item()
			I.loc = src
			inserted_id = I

/obj/machinery/mineral/ore_redemption/proc/process_sheet(obj/item/weapon/ore/O)
	var/obj/item/stack/sheet/processed_sheet = SmeltMineral(O)
	if(processed_sheet)
		var/datum/material/mat = materials.getMaterial(O.material)
		mat.stored += processed_sheet.amount //Stack the sheets
		credits += mat.value * processed_sheet.amount // Gimme my fucking credits
	qdel(O)

/obj/machinery/mineral/ore_redemption/process()
	var/turf/T = get_turf(input)
	var/i
	if(T)
		if(locate(/obj/item/weapon/ore) in T)
			for (i = 0; i < 10; i++)
				var/obj/item/weapon/ore/O = locate() in T
				if(O)
					process_sheet(O)
				else
					break
		else
			var/obj/structure/ore_box/B = locate() in T
			if(B)
				for(var/mat_id in B.materials.storage)
					var/datum/material/mat = B.materials.getMaterial(mat_id)
					materials.addAmount(mat_id,mat.stored)
					credits += mat.value * mat.stored // Gimme my fucking credits
					mat.stored=0

/obj/machinery/mineral/ore_redemption/proc/SmeltMineral(var/obj/item/weapon/ore/O)
	if(O.material)
		var/datum/material/mat = materials.getMaterial(O.material)
		var/obj/item/stack/sheet/M = new mat.sheettype(src)
		//credits += mat.value // Old behavior
		return M
	return

/obj/machinery/mineral/ore_redemption/attack_hand(user as mob)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/ore_redemption/interact(mob/user)
	var/dat

	dat += text("<b>Ore Redemption Machine</b><br><br>")
	dat += text("This machine only accepts ore. Gibtonite and Slag are not accepted.<br><br>")
	dat += text("Current unclaimed credits: $[num2septext(credits)]<br>")

	if(istype(inserted_id))
		dat += "You have [inserted_id.GetBalance(format=1)] credits in your bank account. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
		dat += "<A href='?src=\ref[src];choice=claim'>Claim points.</A><br>"
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>")

	for(var/O in materials.storage)
		var/datum/material/mat = materials.getMaterial(O)
		if(mat.stored > 0)
			dat += text("[capitalize(mat.processed_name)]: [mat.stored] <A href='?src=\ref[src];release=[mat.id]'>Release</A><br>")

	dat += text("<br>This unit can hold stacks of [stack_amt] sheets of each mineral type.<br><br>")

	dat += text("<HR><b>Mineral Value List:</b><BR>[get_ore_values()]")

	user << browse("[dat]", "window=console_stacking_machine")
	user.set_machine(src)
	onclose(user, "console_stacking_machine")
	return

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/mat_id in materials.storage)
		var/datum/material/mat = materials.getMaterial(mat_id)
		dat += "<tr><td>[capitalize(mat.processed_name)]</td><td>[mat.value]</td></tr>"
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
				var/datum/money_account/acct = get_card_account(inserted_id)
				if(acct.charge(-credits,null,"Claimed mining credits.",dest_name = "Ore Redemption"))
					credits = 0
					usr << "\blue Credits transferred."
				else
					usr << "\red Failed to claim credits."
		else if(href_list["choice"] == "insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else
				usr << "\red No valid ID."
				return 1
	else if(href_list["release"] && istype(inserted_id))
		if(check_access(inserted_id))
			var/release=href_list["release"]
			var/datum/material/mat = materials.getMaterial(release)
			if(!mat)
				usr << "\red Unable to find material [release]!"
				return 1
			var/desired = input("How much?","How much [mat.processed_name] to eject?",mat.stored) as num
			if(desired==0)
				return 1
			var/obj/item/stack/sheet/out = new mat.sheettype(output.loc)
			out.amount = between(0,desired,min(mat.stored,out.max_amount))
			mat.stored -= out.amount
	updateUsrDialog()
	return

/obj/machinery/mineral/ore_redemption/ex_act()
	return //So some chucklefuck doesn't ruin miners reward with an explosion

/obj/machinery/mineral/ore_redemption/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/**********************Mining Equipment Locker**************************/

/obj/machinery/mineral/equipment_locker
	name = "mining equipment locker"
	desc = "An equipment locker for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = 1
	anchored = 1.0
	var/obj/item/weapon/card/id/inserted_id
	var/list/prize_list = list(
		new /datum/data/mining_equipment("Chili",               /obj/item/weapon/reagent_containers/food/snacks/hotchili,          100),
		new /datum/data/mining_equipment("Cigar",               /obj/item/clothing/mask/cigarette/cigar/havana,                    100),
		new /datum/data/mining_equipment("Whiskey",             /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,    150),
		new /datum/data/mining_equipment("Soap",                /obj/item/weapon/soap/nanotrasen, 						           150),
		//new /datum/data/mining_equipment("Stimulant pills",     /obj/item/weapon/storage/pill_bottle/stimulant, 				   350),
		new /datum/data/mining_equipment("Alien toy",           /obj/item/clothing/mask/facehugger/toy, 		                   250),
		//new /datum/data/mining_equipment("Laser pointer",       /obj/item/device/laser_pointer, 				                   250),
		new /datum/data/mining_equipment("Lazarus Capsule",     /obj/item/device/mobcapsule,     				                   250),
		new /datum/data/mining_equipment("Trainer's Belt",		/obj/item/weapon/storage/belt/lazarus,							   500),
		new /datum/data/mining_equipment("Point card",    		/obj/item/weapon/card/mining_point_card,               			   500),
		new /datum/data/mining_equipment("Lazarus injector",    /obj/item/weapon/lazarus_injector,                                1000),
		new /datum/data/mining_equipment("Sonic jackhammer",    /obj/item/weapon/pickaxe/jackhammer,                               500),
		new /datum/data/mining_equipment("Mining drone",        /mob/living/simple_animal/hostile/mining_drone/,                   500),
		new /datum/data/mining_equipment("Jaunter",             /obj/item/device/wormhole_jaunter,                                 250),
		new /datum/data/mining_equipment("Resonator",           /obj/item/weapon/resonator,                                        750),
		new /datum/data/mining_equipment("Kinetic accelerator", /obj/item/weapon/gun/energy/kinetic_accelerator,                  1000),
		new /datum/data/mining_equipment("Jetpack",             /obj/item/weapon/tank/jetpack/carbondioxide,                      2000),
	)
	var/datum/money_account/linked_account // Department account.

/datum/data/mining_equipment/
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_locker/attack_hand(user as mob)
	if(..())
		return
	if(!linked_account)
		linked_account = department_accounts["Cargo"]
	interact(user)

/obj/machinery/mineral/equipment_locker/interact(mob/user)
	var/dat
	dat += text("<b>Mining Equipment Locker</b><br><br>")

	if(istype(inserted_id))
		dat += "You have [inserted_id.GetBalance(format=1)] in your account. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br />"
		if(access_qm in inserted_id.GetAccess())
			dat += "Pays to: <a href='?src=\ref[src];choice=link'>"
			if(linked_account == station_account)
				dat += "Station Account"
			else if(linked_account == department_accounts["Cargo"])
				dat += "Cargo Account"
			else
				dat += "Personal Account"
			dat += "</a><br />"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"

	dat += "<HR><b>Equipment point cost list:</b><BR><table border='0' width='200'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	user << browse("[dat]", "window=mining_equipment_locker")
	user.set_machine(src)
	onclose(user, "mining_equipment_locker")
	return

/obj/machinery/mineral/equipment_locker/Topic(href, href_list)
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
				usr.drop_item()
				I.loc = src
				inserted_id = I
			else usr << "\red No valid ID."
	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if (!prize || !(prize in prize_list))
				return 1
			var/balance=inserted_id.GetBalance()
			if(prize.cost <= balance)
				var/datum/money_account/acct = get_card_account(inserted_id,require_pin=1)
				if(acct.charge(prize.cost,linked_account,"Purchased [prize.name]"))
					new prize.equipment_path(src.loc)
	if(href_list["link"])
		if(istype(inserted_id))
			if(access_qm in inserted_id.GetAccess())
				if(linked_account == station_account)
					linked_account = department_accounts["Cargo"]
				else if(linked_account == department_accounts["Cargo"])
					linked_account = get_card_account(inserted_id)
				else
					linked_account = station_account
	updateUsrDialog()
	return

/obj/machinery/mineral/equipment_locker/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mining_voucher))
		RedeemVoucher(W, user)
		return
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I))
			usr.drop_item()
			I.loc = src
			inserted_id = I
		return
	..()

/obj/machinery/mineral/equipment_locker/proc/RedeemVoucher(voucher, redeemer)
	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") in list("Resonator kit", "Kinetic Accelerator", "Mining Drone", "Cancel")
	if(!selection || !Adjacent(redeemer))
		return
	switch(selection)
		if("Resonator kit")
			new /obj/item/weapon/resonator(src.loc)
			//new /obj/item/weapon/storage/pill_bottle/stimulant(src.loc)
		if("Kinetic Accelerator")
			new /obj/item/weapon/gun/energy/kinetic_accelerator(src.loc)
		if("Mining Drone")
			new /mob/living/simple_animal/hostile/mining_drone(src.loc)
		if("Cancel")
			return
	del(voucher)

/obj/machinery/mineral/equipment_locker/ex_act()
	return

/**********************Mining Equipment Locker Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/weapon/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment locker."
	icon = 'icons/obj/items.dmi'
	icon_state = "mining_voucher"
	w_class = 1

/**********************Mining Point Card**********************/

/obj/item/weapon/card/mining_point_card
	name = "gift card"
	desc = "A small card preloaded with credits. Swipe your ID card over it to transfer the credits, then discard."
	icon_state = "data"
	var/points = 500

/obj/item/weapon/card/mining_point_card/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/card/id))
		if(points)
			var/obj/item/weapon/card/id/C = I
			var/datum/money_account/acct = get_card_account(I)
			if(acct.charge(-points,null,"Redeemed gift card.",dest_name = "Gift Card"))
				user << "<span class='info'>You transfer [points] credits to [C].</span>"
				points = 0
			else
				user << "<span class='warning'>Unable to transfer credits.</span>"
		else
			user << "<span class='info'>There's no points left on [src].</span>"
	..()

/obj/item/weapon/card/mining_point_card/examine()
	..()
	usr << "There's [points] credits on the card."

/**********************Jaunter**********************/

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
		var/obj/effect/portal/jaunt_tunnel/J = new /obj/effect/portal/jaunt_tunnel(get_turf(src))
		J.target = chosen_beacon
		try_move_adjacent(J)
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		del(src) //Single-use

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/jaunt_tunnel/New()
	spawn(300) // 30s
		del(src)

/*/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		do_teleport(M, target, 6) */

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect))
		return
	if (!(istype(M, /atom/movable)))
		return
	if (!(target))
		del(src)

	//For safety. May be unnecessary.
	var/T = target
	if(!(isturf(T)))
		T = get_turf(target)

	if(prob(1)) //honk
		T = (locate(rand(5,world.maxx-10), rand(5,world.maxy-10),3))

	do_teleport(M, T, 6)

	if(isliving(M))
		var/mob/living/L = M
		L.Weaken(3)
		if(ishuman(L))
			shake_camera(L, 20, 1)
			spawn(20)
				if(L)
					L.visible_message("<span class='danger'>[L.name] vomits from travelling through the [src.name]!</span>")
					L.nutrition -= 20
					L.adjustToxLoss(-3)
					var/turf/V = get_turf(L) //V for Vomit
					V.add_vomit_floor(L)
					playsound(V, 'sound/effects/splat.ogg', 50, 1)
					return
	return

/**********************Resonator**********************/

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

/obj/item/weapon/resonator/proc/CreateResonance(var/target, var/creator)
	if(cooldown <= 0)
		playsound(get_turf(src),'sound/effects/stealthoff.ogg',50,1)
		var/obj/effect/resonance/R = new /obj/effect/resonance(get_turf(target))
		R.creator = creator
		cooldown = 1
		spawn(20)
			cooldown = 0

/obj/item/weapon/resonator/attack_self(mob/user as mob)
	CreateResonance(src, user)
	..()

/obj/item/weapon/resonator/afterattack(atom/target, mob/user, proximity_flag)
	if(target in user.contents)
		return
	if(proximity_flag)
		CreateResonance(target, user)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = 0
	var/resonance_damage = 30
	var/creator = null

/obj/effect/resonance/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf))
		return
	if(istype(proj_turf, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = proj_turf
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		M.GetDrilled()
		spawn(5)
			del(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance field"
			resonance_damage = 60
		spawn(50)
			playsound(src,'sound/effects/sparks4.ogg',50,1)
			if(creator)
				for(var/mob/living/L in src.loc)
					add_logs(creator, L, "used a resonator field on", object="resonator")
					L << "<span class='danger'>The [src.name] ruptured with you in it!</span>"
					L.adjustBruteLoss(resonance_damage)
			else
				for(var/mob/living/L in src.loc)
					L << "<span class='danger'>The [src.name] ruptured with you in it!</span>"
					L.adjustBruteLoss(resonance_damage)
			del(src)

/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger/toy
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	sterile = 1
	//tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/examine()//So that giant red text about probisci doesn't show up.
	if(desc)
		usr << desc

/obj/item/clothing/mask/facehugger/toy/Die()
	return

/**********************Mining drone**********************/

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "A small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	mouse_opacity = 1
	faction = "neutral"
	a_intent = "hurt"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	wander = 0
	idle_vision_range = 5
	move_to_delay = 10
	retreat_distance = 1
	minimum_distance = 2
	health = 100
	maxHealth = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	environment_smash = 0
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	ranged = 1
	ranged_message = "shoots"
	ranged_cooldown_cap = 3
	projectiletype = /obj/item/projectile/beam
	projectilesound = 'sound/weapons/Laser.ogg'
	wanted_objects = list(/obj/item/weapon/ore)

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding && !stat)
			if(stance != HOSTILE_STANCE_IDLE)
				user << "<span class='info'>[src] is moving around too much to repair!</span>"
				return
			if(maxHealth == health)
				user << "<span class='info'>[src] is at full integrity.</span>"
			else
				health += 10
				user << "<span class='info'>You repair some of the armor on [src].</span>"
			return
	if(istype(I, /obj/item/device/mining_scanner))
		user << "<span class='info'>You instruct [src] to drop any collected ore.</span>"
		DropOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/Die()
	..()
	visible_message("<span class='danger'>[src] is destroyed!</span>")
	new /obj/effect/decal/remains/robot(src.loc)
	DropOre()
	del src
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
	stop_automated_movement_when_pulled = 1
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	stop_automated_movement_when_pulled = 0
	idle_vision_range = 5
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

/mob/living/simple_animal/hostile/mining_drone/adjustBruteLoss()
	if(search_objects)
		SetOffenseBehavior()
	..()

/**********************Lazarus Injector**********************/

/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	var/loaded = 1

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.stat == DEAD)
				M.faction = "lazarus \ref[user]"
				M.revive()
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					H.friends += user
					log_game("[user] has revived hostile mob [target] with a lazarus injector")
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

/obj/item/weapon/lazarus_injector/examine()
	..()
	if(!loaded)
		usr << "<span class='info'>[src] is empty.</span>"


/*********************Mob Capsule*************************/

/obj/item/device/mobcapsule
	name = "Lazarus Capsule"
	desc = "It allows you to store and deploy lazarus injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	throwforce = 00
	throw_speed = 4
	throw_range = 20
	force = 0
	var/storage_capacity = 1
	var/mob/living/capsuleowner = null
	var/tripped = 0
	var/colorindex = 0
	var/mob/contained_mob

/obj/item/device/mobcapsule/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/pen))
		if(user != capsuleowner)
			user << "<span class='warning'>The [src.name] flashes briefly in error.</span>"
			return 0
		spawn()
			var/name = sanitize(input("Choose a name for your friend.", "Name your friend", contained_mob.name) as text | null)
			if(name)
				contained_mob.name = name
				user << "<span class='notice'>Rename successful, say hello to [contained_mob]</span>"
	..()

/obj/item/device/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(!tripped)
		if(contained_mob)
			dump_contents(user)
			tripped = 1
		else
			take_contents(user)
			tripped = 1



/obj/item/device/mobcapsule/proc/insert(var/atom/movable/AM, mob/user)

	if(contained_mob)
		return -1


	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.buckled)
			return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
	else if(!istype(AM, /obj/item) && !istype(AM, /obj/effect/dummy/chameleon))
		return 0
	else if(AM.density || AM.anchored)
		return 0
	AM.loc = src
	contained_mob = AM
	return 1


/obj/item/device/mobcapsule/pickup(mob/user)
	tripped = 0
	capsuleowner = user


/obj/item/device/mobcapsule/proc/dump_contents(mob/user)
	/*
	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.loc = src.loc

	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/M in src)
		M.loc = src.loc
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
*/
	if(contained_mob)
		contained_mob.loc = src.loc
		if(contained_mob.client)
			contained_mob.client.eye = contained_mob.client.mob
			contained_mob.client.perspective = MOB_PERSPECTIVE
		contained_mob = null

/obj/item/device/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	icon_state = "mobcap[colorindex]"
	update_icon()

/obj/item/device/mobcapsule/proc/take_contents(mob/user)
	for(var/mob/living/simple_animal/AM in src.loc)
		if(istype(AM))
			var/mob/living/simple_animal/M = AM
			var/mob/living/simple_animal/hostile/H = M
			for(var/things in H.friends)
				if(capsuleowner in H.friends)
					if(insert(AM, user) == -1) // limit reached
						break



/**********************Mining Scanner**********************/
/obj/item/device/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals, it can also be used to stop gibtonite detonations. Requires you to wear mesons to work properly."
	name = "mining scanner"
	icon_state = "mining"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 0

/obj/item/device/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(!cooldown)
		cooldown = 1
		spawn(40)
			cooldown = 0
		var/client/C = user.client
		var/list/L = list()
		var/turf/unsimulated/mineral/M
		for(M in range(7, user))
			if(M.scan_state)
				L += M
		if(!L.len)
			user << "<span class='info'>[src] reports that nothing was detected nearby.</span>"
			return
		else
			for(M in L)
				var/turf/T = get_turf(M)
				var/image/I = image('icons/turf/walls.dmi', loc = T, icon_state = M.scan_state, layer = 18)
				C.images += I
				spawn(30)
					if(C)
						C.images -= I

/**********************Xeno Warning Sign**********************/
/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"
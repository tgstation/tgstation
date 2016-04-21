var/const/SAFETY_COOLDOWN = 100

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine which is used to recycle small items ineffeciently; there are lights on the side of it."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/grinding = 0
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_dir = WEST
	var/amount_produced = 1
	var/datum/material_container/materials
	var/circuit = /obj/item/weapon/circuitboard/recycler
	var/transmute = FALSE

/obj/machinery/recycler/New()
	// On us
	..()
	component_parts = list()
	component_parts += new circuit(null)
	if(!transmute)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
		component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	materials = new /datum/material_container(src, list(MAT_METAL=1, MAT_GLASS=1, MAT_PLASMA=1, MAT_SILVER=1, MAT_GOLD=1, MAT_DIAMOND=1, MAT_URANIUM=1, MAT_BANANIUM=1))
	RefreshParts()
	update_icon()

/obj/machinery/recycler/RefreshParts()
	var/amt_made = 0
	var/mat_mod = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		mat_mod = 2 * B.rating
	mat_mod *= 50000
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		amt_made = 25 * M.rating //% of materials salvaged
	materials.max_amount = mat_mod
	amount_produced = min(100, amt_made)

/obj/machinery/recycler/examine(mob/user)
	..()
	user << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	if(!transmute)
		user << "The safety-mode light is [safety_mode ? "on" : "off"]."
		user << "The safety-sensors status light is [emagged ? "off" : "on"]."

/obj/machinery/recycler/power_change()
	..()
	update_icon()


/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	default_deconstruction_crowbar(I)
	..()
	add_fingerprint(user)
	return

/obj/machinery/recycler/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(safety_mode)
			safety_mode = 0
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)
		user << "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>"

/obj/machinery/recycler/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

// This is purely for admin possession !FUN!.
/obj/machinery/recycler/Bump(atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)


/obj/machinery/recycler/Bumped(atom/movable/AM)

	if(stat & (BROKEN|NOPOWER))
		return
	if(!anchored)
		return
	if(safety_mode)
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(isliving(AM))
			if(emagged)
				eat(AM)
			else
				stop(AM)
		else if(istype(AM, /obj/item))
			recycle(AM)
		else // Can't recycle
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc

/obj/machinery/recycler/proc/recycle(obj/item/I, sound = 1)
	I.loc = src.loc
	if(!istype(I))
		return

	if(sound)
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	var/material_amount = materials.get_item_material_amount(I)
	if(!material_amount)
		qdel(I)
		return
	materials.insert_item(I, multiplier = (amount_produced / 100))
	qdel(I)
	materials.retrieve_all()


/obj/machinery/recycler/proc/stop(mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/recycler/proc/eat(mob/living/L)

	L.loc = src.loc

	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = 1
	// By default, the emagged recycler will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!")
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()

	// Remove and recycle the equipped items.
	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			recycle(I, 0)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)

	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
	else if(emagged == 1)
		L.adjustBruteLoss(1000)



/obj/item/weapon/paper/recycler
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"



/obj/machinery/recycler/alchemizer
	name = "Alchemical Transformer"
	desc = "A large machine that transmutes objects into precious minerals."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	amount_produced = 10
	transmute = TRUE
	circuit = /obj/item/weapon/circuitboard/alchemizer
	var/itemsallowed = TRUE	//If we are allowed to transmute items. False makes us only transmute mobs

/obj/machinery/recycler/alchemizer/New()
	// On us
	..()
	emagged = 1
	amount_produced = rand(5,20)
	update_icon()

/obj/machinery/recycler/alchemizer/RefreshParts()
	return

/obj/machinery/recycler/alchemizer/exchange_parts()
	return

/obj/machinery/recycler/alchemizer/recycle(obj/item/I, sound = 1)
	transmute(I, sound)

/obj/machinery/recycler/alchemizer/proc/transmute(var/obj/item/I, var/sound = 1, var/amount_mod = 1, var/override = 0)
	if(override == 0) //only way I could think of to let this eat both mobs and items without worse code.
		I.loc = src.loc
		if(!itemsallowed)
			qdel(I)
			if(sound)
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
			return
		qdel(I)
	var/output = pickweight(list(/obj/item/stack/sheet/metal = 5,
		/obj/item/stack/sheet/glass = 15,
		/obj/item/stack/sheet/plasteel = 15,
		/obj/item/stack/sheet/rglass = 15,
		/obj/item/stack/sheet/mineral/plasma = 15,
		/obj/item/stack/sheet/mineral/silver = 15,
		/obj/item/stack/sheet/mineral/gold = 10,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/mineral/bananium = 5))
	var/finalamount = amount_produced * amount_mod
	while (finalamount > 50)
		var/obj/item/stack/sheet/capout = new output(loc)
		capout.amount = 50
		finalamount -= 50
	var/obj/item/stack/sheet/lastout = new output(loc)
	lastout.amount = finalamount

	if(sound)
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)

/obj/machinery/recycler/alchemizer/eat(mob/living/L)

	L.loc = src.loc

	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	if(iscarbon(L))
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!")
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()

	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			transmute(I, 0)
	if(L.ckey) //no sacrificing mindless mobs heh
		if(isloyal(L))	//Honk
			transmute(null,0,3,1)
		else
			transmute(null,0,2,1)

	L.gib(no_brain = 1)
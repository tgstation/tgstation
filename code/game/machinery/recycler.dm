var/const/SAFETY_COOLDOWN = 100

/obj/machinery/recycler
	name = "crusher"
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
	var/probability_mod = 1
	var/extra_materials = 0
	var/list/blacklist = list(/obj/item/pipe, /obj/item/pipe_meter, /obj/structure/disposalconstruct, /obj/item/weapon/reagent_containers, /obj/item/weapon/paper, /obj/item/stack/, /obj/item/weapon/pen, /obj/item/weapon/storage/, /obj/item/clothing/mask/cigarette) // Don't allow us to grind things we can poop out at 200 a second for free.

/obj/machinery/recycler/New()
	// On us
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/recycler/RefreshParts()
	var/amt_made = 0
	var/prob_mod = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		amt_made = 1 * B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		if(M.rating > 1)
			prob_mod = 2 * M.rating
		else
			prob_mod = 1 * M.rating
		if(M.rating >= 3)
			extra_materials = 1
		else
			extra_materials = 0
	probability_mod = prob_mod
	amount_produced = amt_made

/obj/machinery/recycler/examine(mob/user)
	..()
	user << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	user << "The safety-mode light is [safety_mode ? "on" : "off"]."
	user << "The safety-sensors status light is [emagged ? "off" : "on"]."

/obj/machinery/recycler/power_change()
	..()
	update_icon()


/obj/machinery/recycler/attackby(var/obj/item/I, var/mob/user, params)
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

/obj/machinery/recycler/emag_act(user as mob)
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
/obj/machinery/recycler/Bump(var/atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)


/obj/machinery/recycler/Bumped(var/atom/movable/AM)

	if(stat & (BROKEN|NOPOWER))
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

/obj/machinery/recycler/proc/recycle(var/obj/item/I, var/sound = 1)
	I.loc = src.loc
	if(is_type_in_list(I, blacklist))
		qdel(I)
		if(sound)
			playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		return
	qdel(I)
	if(prob(15 + probability_mod))
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(loc)
		M.amount = amount_produced
	if(prob(10 + probability_mod))
		var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(loc)
		G.amount = amount_produced
	if(prob(2 + probability_mod))
		var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel(loc)
		P.amount = amount_produced
	if(prob(1 + probability_mod))
		var/obj/item/stack/sheet/rglass/R = new /obj/item/stack/sheet/rglass(loc)
		R.amount = amount_produced
	if(extra_materials)
		if(prob(3 + probability_mod))
			var/obj/item/stack/sheet/mineral/gold/GS = new /obj/item/stack/sheet/mineral/gold(loc)
			GS.amount = amount_produced
		if(prob(2 + probability_mod))
			var/obj/item/stack/sheet/mineral/silver/S = new /obj/item/stack/sheet/mineral/silver(loc)
			S.amount = amount_produced
		if(prob(1 + probability_mod))
			var/obj/item/stack/sheet/mineral/bananium/B = new /obj/item/stack/sheet/mineral/bananium(loc)
			B.amount = amount_produced
	if(sound)
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)


/obj/machinery/recycler/proc/stop(var/mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/recycler/proc/eat(var/mob/living/L)

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

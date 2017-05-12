#define SAFETY_COOLDOWN 100

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle small items inefficiently. There are lights on the side."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	anchored = 1
	density = 1
	var/safety_mode = FALSE // Temporarily stops machine if it detects a mob
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_dir = WEST
	var/amount_produced = 50
	var/datum/material_container/materials
	var/crush_damage = 1000
	var/eat_victim_items = TRUE
	var/item_recycle_sound = 'sound/items/Welder.ogg'

/obj/machinery/recycler/New()
	..()
	materials = new /datum/material_container(src, list(MAT_METAL, MAT_GLASS, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM))
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/recycler(null)
	B.apply_default_parts(src)
	update_icon()

/obj/item/weapon/circuitboard/machine/recycler
	name = "Recycler (Machine Board)"
	build_path = /obj/machinery/recycler
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/machinery/recycler/RefreshParts()
	var/amt_made = 0
	var/mat_mod = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		mat_mod = 2 * B.rating
	mat_mod *= 50000
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		amt_made = 12.5 * M.rating //% of materials salvaged
	materials.max_amount = mat_mod
	amount_produced = min(50, amt_made) + 50

/obj/machinery/recycler/examine(mob/user)
	..()
	to_chat(user, "The power light is [(stat & NOPOWER) ? "off" : "on"].")
	to_chat(user, "The safety-mode light is [safety_mode ? "on" : "off"].")
	to_chat(user, "The safety-sensors status light is [emagged ? "off" : "on"].")

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

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/recycler/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(safety_mode)
			safety_mode = FALSE
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)
		to_chat(user, "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>")

/obj/machinery/recycler/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = FALSE
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
		eat(AM)

/obj/machinery/recycler/proc/eat(atom/AM0, sound=TRUE)
	var/list/to_eat
	if(istype(AM0, /obj/item))
		to_eat = AM0.GetAllContents()
	else
		to_eat = list(AM0)

	var/items_recycled = 0

	for(var/i in to_eat)
		var/atom/movable/AM = i
		var/obj/item/bodypart/head/as_head = AM
		var/obj/item/device/mmi/as_mmi = AM
		var/brain_holder = istype(AM, /obj/item/organ/brain) || (istype(as_head) && as_head.brain) || (istype(as_mmi) && as_mmi.brain)
		if(isliving(AM) || brain_holder)
			if(emagged)
				if(!brain_holder)
					crush_living(AM)
			else
				emergency_stop(AM)
		else if(istype(AM, /obj/item))
			recycle_item(AM)
			items_recycled++
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc

	if(items_recycled && sound)
		playsound(src.loc, item_recycle_sound, 50, 1)

/obj/machinery/recycler/proc/recycle_item(obj/item/I)
	I.loc = src.loc

	var/material_amount = materials.get_item_material_amount(I)
	if(!material_amount)
		qdel(I)
		return
	materials.insert_item(I, multiplier = (amount_produced / 100))
	qdel(I)
	materials.retrieve_all()


/obj/machinery/recycler/proc/emergency_stop(mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = TRUE
	update_icon()
	L.loc = src.loc
	addtimer(CALLBACK(src, .proc/reboot), SAFETY_COOLDOWN)

/obj/machinery/recycler/proc/reboot()
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
	safety_mode = FALSE
	update_icon()

/obj/machinery/recycler/proc/crush_living(mob/living/L)

	L.loc = src.loc

	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = TRUE
	// By default, the emagged recycler will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = FALSE
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!")
		add_mob_blood(L)

	if(!blood && !issilicon(L))
		blood = TRUE
		update_icon()

	// Remove and recycle the equipped items
	if(eat_victim_items)
		for(var/obj/item/I in L.get_equipped_items())
			if(L.dropItemToGround(I))
				eat(I, sound=FALSE)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)

	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
	else if(emagged == 1)
		L.adjustBruteLoss(crush_damage)

/obj/machinery/recycler/deathtrap
	name = "dangerous old crusher"
	emagged = TRUE
	crush_damage = 120
	flags = NODECONSTRUCT

/obj/item/weapon/paper/recycler
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"

#undef SAFETY_COOLDOWN
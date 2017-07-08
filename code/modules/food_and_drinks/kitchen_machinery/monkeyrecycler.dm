/obj/machinery/monkey_recycler
	name = "monkey recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes. It currently produces 1 cube for every 5 monkeys inserted." // except it literally never does
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1


/obj/machinery/monkey_recycler/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/monkey_recycler(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/monkey_recycler
	name = "Monkey Recycler (Machine Board)"
	build_path = /obj/machinery/monkey_recycler
	origin_tech = "programming=1;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 1
	for(var/obj/item/weapon/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		cubes_made = M.rating
	cube_production = cubes_made
	required_grind = req_grind
	src.desc = "A machine used for recycling dead monkeys into monkey cubes. It currently produces [cubes_made] cube(s) for every [required_grind] monkey(s) inserted."

/obj/machinery/monkey_recycler/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	if(default_deconstruction_crowbar(O))
		return

	if(stat) //NOPOWER etc
		return
	else
		return ..()

/obj/machinery/monkey_recycler/MouseDrop_T(mob/living/target, mob/living/user)
	if(!istype(target))
		return
	if(ismonkey(target))
		stuff_monkey_in(target, user)

/obj/machinery/monkey_recycler/proc/stuff_monkey_in(mob/living/carbon/monkey/target, mob/living/user)
	if(!istype(target))
		return
	if(target.stat == 0)
		to_chat(user, "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>")
		return
	if(target.buckled || target.has_buckled_mobs())
		to_chat(user, "<span class='warning'>The monkey is attached to something.</span>")
		return
	qdel(target)
	to_chat(user, "<span class='notice'>You stuff the monkey into the machine.</span>")
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	use_power(500)
	grinded++
	sleep(50)
	pixel_x = initial(pixel_x) //return to its spot after shaking
	to_chat(user, "<span class='notice'>The machine now has [grinded] monkey\s worth of material stored.</span>")


/obj/machinery/monkey_recycler/attack_hand(mob/user)
	if (src.stat != 0) //NOPOWER etc
		return
	if(grinded >= required_grind)
		to_chat(user, "<span class='notice'>The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.</span>")
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		grinded -= required_grind
		for(var/i = 0, i < cube_production, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube(src.loc)
		to_chat(user, "<span class='notice'>The machine's display flashes that it has [grinded] monkeys worth of material left.</span>")
	else
		to_chat(user, "<span class='danger'>The machine needs at least [required_grind] monkey(s) worth of material to produce a monkey cube. It only has [grinded].</span>")
	return

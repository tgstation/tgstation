/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	var/grinded = 0

/obj/machinery/monkey_recycler/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/monkey_recycler,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/micro_laser/high
	)

	RefreshParts()

/obj/machinery/monkey_recycler/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (src.stat != 0) //NOPOWER etc
		return
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(istype(grabbed, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/target = grabbed
			if(target.stat == 0)
				user << "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>"
			if(target.wear_mask || target.l_hand || target.r_hand || target.back || target.uniform || target.hat)
				user << "<span class='warning'>The monkey may not have abiotic items on.</span>"
			else
				user.drop_item()
				del(target)
				user << "<span class='notice'>You stuff the monkey in the machine."
				playsound(get_turf(src), 'sound/machines/juicer.ogg', 50, 1)
				use_power(500)
				src.grinded++
				user << "<span class='notice'>The machine now has [grinded] monkeys worth of material stored.</span>"
		else
			user << "<span class='warning'>The machine only accepts monkeys!</span>"
	else if(istype(O, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/target = O
		if(target.stat == 0)
			user << "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>"
		if(target.wear_mask || target.l_hand || target.r_hand || target.back || target.uniform || target.hat)
			user << "<span class='warning'>The monkey may not have abiotic items on.</span>"
		else
			del(target)
			user << "<span class='notice'>You stuff the monkey in the machine.</span>"
			playsound(get_turf(src), 'sound/machines/juicer.ogg', 50, 1)
			use_power(500)
			src.grinded++
			user << "<span class='notice'>The machine now has [grinded] monkeys worth of material stored.</span>"
	return

/obj/machinery/monkey_recycler/attack_hand(var/mob/user as mob)
	if (src.stat != 0) //NOPOWER etc
		return
	if(grinded >=3)
		user << "<span class='notice'>The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.</span>"
		playsound(get_turf(src), 'sound/machines/hiss.ogg', 50, 1)
		grinded -= 3
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src.loc)
		user << "<span class='notice'>The machine's display flashes that it has [grinded] monkeys worth of material left.</span>"
	else
		user << "<span class='warning'>The machine needs at least 3 monkeys worth of material to produce a monkey cube. It only has [grinded].</span>"
	return

/obj/machinery/monkey_recycler/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	attackby(O,user)

/obj/machinery/chicken_processor
	name = "Chicken Processor"
	desc = "Ensures a quick and painless death of the poultry."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

/obj/machinery/chicken_processor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/chicken_processor,
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

/obj/machinery/chicken_processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (src.stat != 0) //NOPOWER etc
		return
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(istype(grabbed, /mob/living/simple_animal/chicken))
			var/mob/living/simple_animal/chicken/target = grabbed
			user.drop_item()
			del(target)
			user << "<span class='notice'>You stuff the chicken in the machine.</span>"
			playsound(get_turf(src), 'sound/machines/ya_dun_clucked.ogg', 50, 1)
			use_power(500)
			spawn(10)
				new /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets(src.loc)

		else if(istype(grabbed, /mob/living/simple_animal/chick))
			var/mob/living/simple_animal/chick/target = grabbed
			user.drop_item()
			del(target)
			user << "<span class='notice'>You stuff the chick in the machine, you monster.</span>"
			playsound(get_turf(src), 'sound/machines/ya_dun_clucked.ogg', 50, 1)
			use_power(500)
			spawn(10)
				new /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets(src.loc)

		else if(istype(grabbed, /mob/living/carbon/human))
			var/mob/living/carbon/human/target = grabbed
			if (istype(target.wear_suit,/obj/item/clothing/suit/chickensuit) && istype(target.head,/obj/item/clothing/head/chicken))
				if(emagged)
					playsound(get_turf(src), 'sound/machines/ya_dun_clucked.ogg', 50, 1)
					user.drop_item()
					var/throwzone = list()
					for(var/turf/T in range(src,5))
						throwzone += T
					for(var/obj/O in target.contents)
						O.loc = src.loc
						O.throw_at(pick(throwzone),rand(2,5),0)
					hgibs(src.loc, target.viruses, target.dna, target.species.flesh_color, target.species.blood_color)
					del(target)
					for(var/i = 1;i<=6;i++))
						new /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets(src.loc)
						sleep(2)
				else
					user << "<span class='warning'>This chicken is too damn large for the machine!</span>"
			else
				user << "<span class='warning'>The machine only accepts poultry!</span>"

		else
			user << "<span class='warning'>The machine only accepts poultry!</span>"

	else if(istype(O, /mob/living/simple_animal/chicken))
		var/mob/living/simple_animal/chicken/target = O
		del(target)
		user << "<span class='notice'>You stuff the chicken in the machine.</span>"
		playsound(get_turf(src), 'sound/machines/ya_dun_clucked.ogg', 50, 1)
		use_power(500)
		spawn(10)
			new /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets(src.loc)

	else if(istype(O, /mob/living/simple_animal/chick))
		var/mob/living/simple_animal/chick/target = O
		del(target)
		user << "<span class='notice'>You stuff the chick in the machine, you monster.</span>"
		playsound(get_turf(src), 'sound/machines/ya_dun_clucked.ogg', 50, 1)
		use_power(500)
		spawn(10)
			new /obj/item/weapon/reagent_containers/food/snacks/chicken_nuggets(src.loc)
	return

/obj/machinery/vending/emag(mob/user)
	if(!emagged)
		emagged = 1
		src << "Bwak?"
		return 1
	return -1

/obj/machinery/chicken_processor/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	attackby(O,user)

/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/maximum_volume = TANK_VOLUME
	var/starting_volume = -1
	var/starting_reagent

/obj/structure/reagent_dispensers/New()
	. = ..()
	create_reagents(maximum_volume)
	if(starting_reagent)
		var/volume = starting_volume
		if(volume == -1)
			volume = maximum_volume
		reagents.add_reagent(starting_reagent, volume)

/obj/structure/reagent_dispensers/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
		if(3)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act(obj/effect/blob/B)
	if(prob(50))
		qdel(src)

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/reagent_containers))
		return 0 //so we can refill them via their afterattack.
	else
		return ..()

/obj/structure/reagent_dispensers/New()
	create_reagents(TANK_VOLUME)
	..()

/obj/structure/reagent_dispensers/examine(mob/user)
	..()
	user << "It contains [reagents.total_volume] units."

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "water tank"
	desc = "A water tank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"

	starting_reagent = "water"

/obj/structure/reagent_dispensers/watertank/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(50))
				rupture()
		if(3)
			if(prob(5))
				rupture()

/obj/structure/reagent_dispensers/watertank/blob_act(obj/effect/blob/B)
	if(prob(50))
		rupture()

/obj/structure/reagent_dispensers/watertank/proc/rupture()
	PoolOrNew(/obj/effect/particle_effect/water, loc)
	qdel(src)

/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A fuel tank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"

	starting_reagent = "welding_fuel"

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/Proj)
	..()
	if(istype(Proj) && !Proj.nodamage && ((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE)))
		message_admins("[key_name_admin(Proj.firer)] triggered a fueltank explosion.")
		log_game("[key_name(Proj.firer)] triggered a fueltank explosion.")
		boom()

/obj/structure/reagent_dispensers/fueltank/proc/boom()
	explosion(src.loc,0,1,5,7,10, flame_range = 5)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/blob_act(obj/effect/blob/B)
	boom()


/obj/structure/reagent_dispensers/fueltank/ex_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/fire_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/tesla_act()
	..() //extend the zap
	boom()

/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0

	maximum_volume = 1000
	starting_reagent=  "condensedcapsaicin"

/obj/structure/reagent_dispensers/water_cooler
	name = "liquid cooler"
	desc = "A machine that dispenses liquid to drink."
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	anchored = 1

	maximum_volume = 1500
	starting_reagent = "water"

	var/cups = 50

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/living/carbon/human/user)
	if((!istype(user)) || (user.stat))
		return
	if(cups <= 0)
		user << "<span class='warning'>No cups left!</span>"
		return
	cups--
	var/obj/item/weapon/reagent_containers/food/drinks/sillycup/SC = new(loc)
	if(Adjacent(user)) //not TK
		user.put_in_hands(SC)
		user.visible_message("[user] gets a cup from [src].","<span class='notice'>You get a cup from [src].</span>")


/obj/structure/reagent_dispensers/water_cooler/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper))
		if(!user.drop_item())
			return
		qdel(I)
		cups++
	else
		return ..()

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"

	maximum_volume = 5867 // 58.67l
	starting_reagent = "beer"

/obj/structure/reagent_dispensers/beerkeg/blob_act(obj/effect/blob/B)
	explosion(src.loc,0,3,5,7,10)


/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	anchored = 1

	maximum_volume = 1000
	starting_reagent = "virusfood"

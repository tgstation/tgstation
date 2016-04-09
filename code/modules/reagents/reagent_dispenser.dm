/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE

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

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W, mob/user, params)
	return

/obj/structure/reagent_dispensers/New()
	create_reagents(1000)
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

/obj/structure/reagent_dispensers/watertank/New()
	..()
	reagents.add_reagent("water",1000)

/obj/structure/reagent_dispensers/watertank/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				PoolOrNew(/obj/effect/particle_effect/water, src.loc)
				qdel(src)
				return
		if(3)
			if (prob(5))
				PoolOrNew(/obj/effect/particle_effect/water, src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/watertank/blob_act()
	if(prob(50))
		PoolOrNew(/obj/effect/particle_effect/water, loc)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A fuel tank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"

/obj/structure/reagent_dispensers/fueltank/New()
	..()
	reagents.add_reagent("welding_fuel",1000)


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

/obj/structure/reagent_dispensers/fueltank/blob_act()
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

/obj/structure/reagent_dispensers/peppertank/New()
	..()
	reagents.add_reagent("condensedcapsaicin",1000)


/obj/structure/reagent_dispensers/water_cooler
	name = "water cooler"
	desc = "A machine that dispenses water to drink."
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	anchored = 1
	var/cups = 50

/obj/structure/reagent_dispensers/water_cooler/New()
	..()
	reagents.add_reagent("water",500)

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
		return
	else
		..()
/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"

/obj/structure/reagent_dispensers/beerkeg/New()
	..()
	reagents.add_reagent("beer",1000)

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)


/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	anchored = 1

/obj/structure/reagent_dispensers/virusfood/New()
	..()
	reagents.add_reagent("virusfood", 1000)

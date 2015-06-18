/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

/obj/structure/reagent_dispensers/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	return

/obj/structure/reagent_dispensers/New()
	create_reagents(1000)
	if (!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
	..()

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	New()
		..()
		reagents.add_reagent("water",1000)

/obj/structure/reagent_dispensers/watertank/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				PoolOrNew(/obj/effect/effect/water, src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				PoolOrNew(/obj/effect/effect/water, src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/watertank/blob_act()
	if(prob(50))
		PoolOrNew(/obj/effect/effect/water, loc)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	New()
		..()
		reagents.add_reagent("welding_fuel",1000)


/obj/structure/reagent_dispensers/fueltank/bullet_act(var/obj/item/projectile/Proj)
	..()
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(Proj.nodamage)
				return
			message_admins("[key_name_admin(Proj.firer)] triggered a fueltank explosion.")
			log_game("[key_name(Proj.firer)] triggered a fueltank explosion.")
			explosion(src.loc,-1,0,2, flame_range = 2)


/obj/structure/reagent_dispensers/fueltank/blob_act()
	explosion(src.loc,0,1,5,7,10, flame_range = 5)


/obj/structure/reagent_dispensers/fueltank/ex_act()
	explosion(src.loc,-1,0,2, flame_range = 2)
	if(src)
		qdel(src)


/obj/structure/reagent_dispensers/fueltank/fire_act()
	blob_act() //saving a few lines of copypasta


/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45
	New()
		..()
		reagents.add_reagent("condensedcapsaicin",1000)


/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink"
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1
	var/cups = 50
	New()
		..()
		reagents.add_reagent("water",500)

/obj/structure/reagent_dispensers/water_cooler/attack_hand(var/mob/living/carbon/human/user)
	if((!istype(user)) || (user.stat))
		return
	if(cups <= 0)
		user << "<span class='warning'>No cups left!</span>"
		return
	cups--
	user.put_in_hands(new /obj/item/weapon/reagent_containers/food/drinks/sillycup)
	user.visible_message("[user] gets a cup from [src].","<span class='notice'>You get a cup from [src].</span>")

/obj/structure/reagent_dispensers/water_cooler/attackby(var/obj/item/I, var/mob/user, params)
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
	desc = "A beer keg"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10
	New()
		..()
		reagents.add_reagent("beer",1000)

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)


/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = 1

	New()
		..()
		reagents.add_reagent("virusfood", 1000)
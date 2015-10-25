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

/obj/structure/reagent_dispensers/examine(mob/user)
	..()
	user << "<span class='info'>It contains:</span>"
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			user << "<span class='info'>[R.volume] units of [R.name]</span>"
	else
		user << "<span class='info'>Nothing.</span>"

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
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/watertank/blob_act()
	if(prob(50))
		new /obj/effect/effect/water(src.loc)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	var/modded = 0
	var/obj/item/device/assembly_holder/rig = null
	New()
		..()
		reagents.add_reagent("fuel",1000)


/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	..()
	if (modded)
		user << "<span class='warning'>The fuel faucet is wrenched open, leaking the fuel!</span>"
	if(rig)
		user << "<span class='notice'>There is some kind of device rigged to the tank.</span>"



/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if (rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]")
		if(do_after(usr, 20, target = src))
			usr.visible_message("\blue [usr] detaches [rig] from \the [src].", "\blue  You detach [rig] from \the [src]")
			if(rig)
				rig.loc = get_turf(usr)
				rig = null
			overlays = new/list()

/obj/structure/reagent_dispensers/fueltank/HasProximity(atom/movable/AM as mob|obj)
	if(rig)
		rig.HasProximity(AM)
	return



/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W,/obj/item/weapon/wrench))
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
		"You wrench [src]'s faucet [modded ? "closed" : "open"]")
		modded = modded ? 0 : 1
	if (istype(W,/obj/item/device/assembly_holder))
		if (issilicon(user))
			var/mob/living/silicon/M = user
			if(M.keeper)
				M <<"<span class= 'warning'>Your laws prevent you from doing this</span>" // no welderbombing for mommis
				return

		if (rig)
			user << "\red There is another device in the way."
			return ..()
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src]")
		if(do_after(user, 20, target = src))
			user.visible_message("\blue [user] rigs [W] to \the [src].", "\blue  You rig [W] to \the [src]")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")
				log_game("[key_name(user)] rigged fueltank at ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W
			user.drop_item()
			W.loc = src

			var/icon/test = getFlatIcon(W)
			test.Shift(NORTH,1)
			test.Shift(EAST,6)
			overlays += test

	return ..()


/obj/structure/reagent_dispensers/fueltank/bullet_act(var/obj/item/projectile/Proj)
	..()
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(Proj.nodamage)
				return
			message_admins("[key_name_admin(Proj.firer)] triggered a fueltank explosion.")
			log_game("[key_name(Proj.firer)] triggered a fueltank explosion.")
			explosion(src.loc,-1,2,5,5, flame_range = 5)


/obj/structure/reagent_dispensers/fueltank/blob_act()
	explosion(src.loc,0,1,5,7,10, flame_range = 5)


/obj/structure/reagent_dispensers/fueltank/ex_act()
	explosion(src.loc,-1,2,5,5, flame_range = 5)
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
		user << "<span class='danger'>What? No cups?"
		return
	cups--
	user.put_in_hands(new /obj/item/weapon/reagent_containers/food/drinks/sillycup)
	user.visible_message("<span class='notice'>[user] gets a cup from [src].","<span class='notice'>You get a cup from [src].")

/obj/structure/reagent_dispensers/water_cooler/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/paper))
		user.drop_item()
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
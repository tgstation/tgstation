/*
 * Wooden barricades have been reworked. You can now make forts with them
 * Or at least, build a lot of interesting things
 * Also the base tile type is a "pane", just like windows
 * And you have special sub-types that go on windows
 * Also, they do inherit windows. They just do
 */

/obj/structure/window/barricade
	name = "wood barricade"
	desc = "A barricade made out of wood planks, it looks like it can take a few solid hits."
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade"
	anchored = 1
	opacity = 1 //Wood isn't transparent, the last time I checked
	health = 60 //Fairly strong
	var/busy = 0 //Oh god fucking do_after's

	fire_temp_threshold = 100 //Wooden barricades REALLY don't like fire
	fire_volume_mod = 10 //They REALLY DON'T

/obj/structure/window/barricade/examine(mob/user)

	..()
	//Switch most likely can't take inequalities, so here's that if block
	if(health >= initial(health)) //Sanity
		to_chat(user, "It's in perfect shape, not even a scratch.")
	else if(health >= 0.8*initial(health))
		to_chat(user, "It has a few splinters and a plank is broken.")
	else if(health >= 0.5*initial(health))
		to_chat(user, "It has a fair amount of splinters and broken plants.")
	else if(health >= 0.2*initial(health))
		to_chat(user, "It has most of its planks broken, you can barely tell how much weight the support beams are bearing.")
	else
		to_chat(user, "It has only one or two planks still in shape, it's a miracle it's even standing.")

//Allows us to quickly check if we should break the barricade, can handle not having an user
//Sound is technically deprecated, but barricades should really have a build sound
/obj/structure/window/barricade/healthcheck(var/mob/M, var/sound = 1)

	if(health <= 0)
		Destroy()

//Note : We don't want glass knocking sounds to play
/obj/structure/window/barricade/attack_hand(mob/user as mob)

	//Bang against the barricade
	if(usr.a_intent == I_HURT)
		user.delayNextAttack(10)
		health -= 2
		healthcheck()
		//playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")

	//Knock against it
	else
		user.delayNextAttack(10)
		//playsound(get_turf(src), 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] knocks on \the [src].</span>", \
		"<span class='notice'>You knock on \the [src].</span>", \
		"You hear knocking.")

	..() //Hulk

	return

/obj/structure/window/barricade/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/crowbar) && user.a_intent == I_HURT && !busy) //Only way to deconstruct, needs harm intent
		playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
		user.visible_message("<span class='warning'>[user] starts struggling to pry \the [src] back into planks.</span>", \
		"<span class='notice'>You start struggling to pry \the [src] back into planks.</span>")
		busy = 1

		if(do_after(user, src, 50)) //Takes a while because it is a barricade instant kill
			playsound(loc, 'sound/items/Deconstruct.ogg', 75, 1)
			user.visible_message("<span class='warning'>[user] finishes turning \the [src] back into planks.</span>", \
			"<span class='notice'>You finish turning \the [src] back into planks.</span>")
			busy = 0
			qdel(src)
			return
		else
			busy = 0

	if(W.damtype == BRUTE || W.damtype == BURN)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		healthcheck(user)
		return
	else
		..() //Weapon checks for weapons without brute or burn damage type and grab check

/obj/structure/window/barricade/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)

	if(air_group || !height) //The mover is an airgroup
		return 1 //We aren't airtight, only exception to PASSGLASS
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	return 1

/obj/structure/window/barricade/Destroy()

	density = 0 //Sanity while we do the rest
	getFromPool(/obj/item/stack/sheet/wood, loc, sheetamount)

	..()

//We don't want to update our icon, period
/obj/structure/window/barricade/update_icon()

	return

/obj/structure/window/barricade/update_nearby_tiles()

	return

/obj/structure/window/barricade/update_nearby_icons()

	return

/obj/structure/window/barricade/full
	name = "wood barricade"
	desc = "A barricade made out of wood planks, it is very likely going to be a tough nut to crack"
	icon_state = "barricade_full"
	health = 150
	sheetamount = 3
	layer = 3.21 //Just above windows (for window barricades) and other barricades

//Basically the barricade version of full windows, and inherits the former rather than the later
/obj/structure/window/barricade/full/New(loc)

	..(loc)
	flags &= ~ON_BORDER

/obj/structure/window/barricade/full/CheckExit(atom/movable/O as mob|obj, target as turf)

	return 1

/obj/structure/window/barricade/full/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)

	if(air_group || !height) //The mover is an airgroup
		return 1 //We aren't airtight, only exception to PASSGLASS
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	return 0

/obj/structure/window/barricade/full/can_be_reached(mob/user)

	return 1 //That about it Captain

/obj/structure/window/barricade/full/is_fulltile()

	return 1

/obj/structure/window/barricade/full/block //Used by the barricade kit when it is placed on airlocks or windows

	icon_state = "barricade_block"
	health = 35 //Can take a few hits, but not very robust at all
	sheetamount = 1

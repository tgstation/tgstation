/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/objects.dmi'
	anchored = 1
	can_buckle = 1
	buckle_lying = 1
	burn_state = 0 //Burnable
	burntime = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	var/foldabletype //to fold into an item (e.g. roller bed item)

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"

/obj/structure/bed/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/bed/attack_animal(mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)

/obj/structure/bed/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(70))
				if(buildstacktype)
					new buildstacktype(loc, buildstackamount)
				qdel(src)
				return
		if(3)
			if(prob(50))
				if(buildstacktype)
					new buildstacktype(loc, buildstackamount)
				qdel(src)
				return

/obj/structure/bed/blob_act()
	if(buildstacktype)
		new buildstacktype(loc, buildstackamount)
	qdel(src)

/obj/structure/bed/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&ABSTRACT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
		qdel(src)

/obj/structure/bed/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(foldabletype)
		if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
			if(!ishuman(usr))
				return
			if(buckled_mob)
				return 0
			usr.visible_message("[usr] collapses \the [src.name].", "<span class='notice'>You collapse \the [src.name].</span>")
			new foldabletype(get_turf(src))
			qdel(src)



/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	burn_state = -1 //Not Burnable
	foldabletype = /obj/item/roller

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		density = 1
		icon_state = "up"
		M.pixel_y = initial(M.pixel_y)
	else
		density = 0
		icon_state = "down"
		M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)


/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 4 // Can't be put in backpacks.


/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/robo //ROLLER ROBO DA!
	name = "roller bed dock"
	var/loaded = null

/obj/item/roller/robo/New()
	loaded = new /obj/structure/bed/roller(src)
	desc = "A collapsed roller bed that can be ejected for emergency use. Must be collected or replaced after use."
	..()

/obj/item/roller/robo/examine(mob/user)
	..()
	user << "The dock is [loaded ? "loaded" : "empty"]"

/obj/item/roller/robo/attack_self(mob/user)
	if(loaded)
		var/obj/structure/bed/roller/R = loaded
		R.loc = user.loc
		user.visible_message("[user] deploys [loaded].", "<span class='notice'>You deploy [loaded].</span>")
		loaded = null
	else
		user << "<span class='warning'>The dock is empty!</span>"

/obj/item/roller/robo/afterattack(obj/target, mob/user , proximity)
	if(istype(target,/obj/structure/bed/roller))
		if(!proximity)
			return
		if(loaded)
			user << "<span class='warning'>You already have a roller bed docked!</span>"
			return

		var/obj/structure/bed/roller/R = target
		if(R.buckled_mob)
			R.user_unbuckle_mob(user)

		loaded = target
		target.loc = src
		user.visible_message("[user] collects [loaded].", "<span class='notice'>You collect [loaded].</span>")
	..()


//Dog bed

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, in case the gravity turns off."
	anchored = 0
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 10


//Stool

/obj/structure/bed/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = 0
	buildstackamount = 1



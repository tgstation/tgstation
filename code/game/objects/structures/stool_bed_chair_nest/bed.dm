/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/stool/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	can_buckle = 1
	buckle_lying = 1

/obj/structure/stool/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"

/obj/structure/stool/bed/Move(atom/newloc, direct) //Some bed children move
	. = ..()
	if(buckled_mob)
		buckled_mob.buckled = null
		if(!buckled_mob.Move(loc, direct))
			loc = buckled_mob.loc //we gotta go back
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			. = 0
		buckled_mob.buckled = src

/obj/structure/stool/bed/Process_Spacemove(var/movement_dir = 0)
	if(buckled_mob)
		return buckled_mob.Process_Spacemove(movement_dir)
	return ..()

/obj/structure/stool/bed/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(mover == buckled_mob)
		return 1
	return ..()

/obj/structure/stool/bed/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/stool/bed/attack_animal(var/mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
		return


/*
 * Roller beds
 */
/obj/structure/stool/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	pressure_resistance = 5

/obj/structure/stool/bed/roller/post_buckle_mob(mob/living/M)
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
	w_class = 4.0 // Can't be put in backpacks.


/obj/item/roller/attack_self(mob/user)
	var/obj/structure/stool/bed/roller/R = new /obj/structure/stool/bed/roller(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/stool/bed/roller/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(buckled_mob)
			return 0
		usr.visible_message("[usr] collapses \the [src.name].", "<span class='notice'>You collapse \the [src.name].</span>")
		new/obj/item/roller(get_turf(src))
		qdel(src)
		return

/obj/item/roller/robo //ROLLER ROBO DA!
	name = "roller bed dock"
	var/loaded = null

/obj/item/roller/robo/New()
	loaded = new /obj/structure/stool/bed/roller(src)
	desc = "A collapsed roller bed that can be ejected for emergency use. Must be collected or replaced after use."
	..()

/obj/item/roller/robo/examine(mob/user)
	..()
	user << "The dock is [loaded ? "loaded" : "empty"]"

/obj/item/roller/robo/attack_self(mob/user)
	if(loaded)
		var/obj/structure/stool/bed/roller/R = loaded
		R.loc = user.loc
		user.visible_message("[user] deploys [loaded].", "<span class='notice'>You deploy [loaded].</span>")
		loaded = null
	else
		user << "<span class='warning'>The dock is empty!</span>"

/obj/item/roller/robo/afterattack(obj/target, mob/user , proximity)
	if(istype(target,/obj/structure/stool/bed/roller))
		if(!proximity)
			return
		if(loaded)
			user << "<span class='warning'>You already have a roller bed docked!</span>"
			return

		var/obj/structure/stool/bed/roller/R = target
		if(R.buckled_mob)
			R.user_unbuckle_mob(user)

		loaded = target
		target.loc = src
		user.visible_message("[user] collects [loaded].", "<span class='notice'>You collect [loaded].</span>")
	..()


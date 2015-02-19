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
	var/const/buckled_pixel_y_offset = 6 //Mobs buckled will have their pixel_y offset by this much


/obj/structure/stool/bed/roller/post_buckle_mob(mob/M)
	if(M == buckled_mob)
		density = 1
		icon_state = "up"
		M.pixel_y = initial(M.pixel_y)
	else
		density = 0
		icon_state = "down"
		if(buckled_mob)
			buckled_mob.pixel_y = initial(buckled_mob.pixel_y)
			if(buckled_mob.lying)
				buckled_mob.pixel_y -= buckled_pixel_y_offset


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
		visible_message("<span class='notice'>[usr] collapses \the [src.name].</span>")
		new/obj/item/roller(get_turf(src))
		qdel(src)
		return
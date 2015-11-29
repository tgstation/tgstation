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
	icon = 'icons/obj/stools-chairs-beds.dmi'

	locked_should_lie = 1
	dense_when_locking = 0
	anchored = 1
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amt = 1

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"

/obj/structure/bed/cultify()
	var/obj/structure/bed/chair/wood/wings/I = new /obj/structure/bed/chair/wood/wings(loc)
	I.dir = dir
	. = ..()

/obj/structure/bed/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/bed/attack_hand(mob/user as mob)
	manual_unbuckle(user)

/obj/structure/bed/attack_animal(mob/user as mob)
	manual_unbuckle(user)

/obj/structure/bed/attack_robot(mob/user as mob)
	if(Adjacent(user))
		manual_unbuckle(user)

/obj/structure/bed/MouseDrop(atom/over_object)
	return

/obj/structure/bed/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!istype(M))
		return

	buckle_mob(M, user)

/obj/structure/bed/proc/manual_unbuckle(mob/user as mob)
	if(!locked_atoms.len)
		return

	var/mob/M = locked_atoms[1]
	if(M != user)
		M.visible_message(\
			"<span class='notice'>[M] was unbuckled by [user]!</span>",\
			"You were unbuckled from \the [src] by [user].",\
			"You hear metal clanking")
	else
		M.visible_message(\
			"<span class='notice'>[M] unbuckled \himself!</span>",\
			"You unbuckle yourself from \the [src].",\
			"You hear metal clanking")

	unlock_atom(M)

	add_fingerprint(user)

/obj/structure/bed/proc/buckle_mob(mob/M as mob, mob/user as mob)
	if(!ismob(M) || !Adjacent(user) || (M.loc != src.loc) || user.restrained() || user.lying || user.stat || M.locked_to || istype(user, /mob/living/silicon/pai) )
		return

	if(isanimal(M))
		if(M.size <= SIZE_TINY) //Fuck off mice
			to_chat(user, "The [M] is too small to buckle in.")
			return

	if(istype(M, /mob/living/carbon/slime))
		to_chat(user, "The [M] is too squishy to buckle in.")
		return

	if(locked_atoms.len)
		to_chat(user, "Somebody else is already buckled into \the [src]!")

	if(M == usr)
		M.visible_message(\
			"<span class='notice'>[M.name] buckles in!</span>",\
			"You buckle yourself to [src].",\
			"You hear metal clanking")
	else
		M.visible_message(\
			"<span class='notice'>[M.name] is buckled in to [src] by [user.name]!</span>",\
			"You are buckled in to [src] by [user.name].",\
			"You hear metal clanking")

	add_fingerprint(user)

	lock_atom(M)

/*
 * Roller beds
 */

#define ROLLERBED_Y_OFFSET 6

/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	dense_when_locking = 1

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 4 // Can't be put in backpacks. Oh well.

/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/bed/roller/lock_atom(var/atom/movable/AM)
	..()
	AM.pixel_y += ROLLERBED_Y_OFFSET
	density = 1
	icon_state = "up"

/obj/structure/bed/roller/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	AM.pixel_y -= ROLLERBED_Y_OFFSET
	icon_state = "down"

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr))
			return

		if(locked_atoms.len)
			return 0

		visible_message("[usr] collapses \the [src.name]")

		new/obj/item/roller(get_turf(src))

		qdel(src)

/obj/structure/bed/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		getFromPool(sheet_type, get_turf(src), 2)
		qdel(src)
		return

	. = ..()

#undef ROLLERBED_Y_OFFSET

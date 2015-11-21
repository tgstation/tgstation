/obj/structure/bed/chair/vehicle/wheelchair
	name = "wheelchair"
	nick = "cripplin' ride"
	desc = "A chair with fitted wheels. Used by handicapped to make life easier, however it still requires hands to drive."
	icon = 'icons/obj/objects.dmi'
	icon_state = "wheelchair"

	anchored = 0
	density = 1

	movement_delay = 3

	health = 50
	max_health = 50

	var/image/wheel_overlay

/obj/structure/bed/chair/vehicle/wheelchair/New()
	. = ..()
	wheel_overlay = image("icons/obj/objects.dmi", "[icon_state]_overlay", MOB_LAYER + 0.1)

/obj/structure/bed/chair/vehicle/wheelchair/unlock_atom(var/atom/movable/AM)
	. = ..()
	density = 1
	animate_movement = initial(animate_movement)
	update_icon()

/obj/structure/bed/chair/vehicle/wheelchair/lock_atom(var/atom/movable/AM)
	. = ..()
	density = 0
	animate_movement = SYNC_STEPS
	update_icon()

/obj/structure/bed/chair/vehicle/wheelchair/update_icon()
	..()
	if(occupant)
		overlays |= wheel_overlay
	else
		overlays -= wheel_overlay

/obj/structure/bed/chair/vehicle/wheelchair/can_buckle(mob/M, mob/user)
	if(M != user || !Adjacent(user) || (!ishuman(user) && !isalien(user) && !ismonkey(user)) || user.restrained() || user.stat || user.locked_to || destroyed || occupant) //Same as vehicle/can_buckle, minus check for user.lying as well as allowing monkey and ayliens
		return 0
	return 1

/obj/structure/bed/chair/vehicle/wheelchair/proc/check_hands(var/mob/user)
	//Returns a number from 0 to 4 depending on usability of user's hands
	//Human with no hands gets 0
	//Human with one hand holding something gets 1
	//Human with one empty hand gets 2
	//Human with two hands both holding something gets 2
	//Human with one empty and one full hand gets 3
	//Human with two empty hands gets 4

	//Wheelchair's speed depends on the resulting value
	var/mob/living/carbon/M = user
	if(!M) return 0

	var/left_hand_exists = 1
	var/right_hand_exists = 1

	if(M.handcuffed)
		return 0

	if(ishuman(M)) //Human check - 0 to 4
		var/mob/living/carbon/human/H = user

		if(H.l_hand == null) left_hand_exists++ //Check to see if left hand is holding anything
		var/datum/organ/external/left_hand = H.get_organ("l_hand")
		if(!left_hand)
			left_hand_exists = 0
		else if(left_hand.status & ORGAN_DESTROYED)
			left_hand_exists = 0

		if(H.r_hand == null) right_hand_exists++
		var/datum/organ/external/right_hand = H.get_organ("r_hand")
		if(!right_hand)
			right_hand_exists = 0
		else if(right_hand.status & ORGAN_DESTROYED)
			right_hand_exists = 0
	else if( ismonkey(M) || isalien(M) ) //Monkey and alien check - 0 to 2
		left_hand_exists = 0
		if(user.l_hand == null) left_hand_exists++

		right_hand_exists = 0
		if(user.r_hand == null) right_hand_exists++

	return ( left_hand_exists + right_hand_exists )

/obj/structure/bed/chair/vehicle/wheelchair/getMovementDelay()
	//Speed is determined by amount of usable hands and whether they're carrying something
	var/hands = check_hands(occupant) //See check_hands() proc above
	if(hands <= 0) return 0
	return movement_delay * (4 / hands)

/obj/structure/bed/chair/vehicle/wheelchair/relaymove(var/mob/user, direction)
	if(!check_key(user))
		user << "<span class='warning'>You need at least one hand to use [src]!</span>"
		return 0
	return ..()

/obj/structure/bed/chair/vehicle/wheelchair/handle_layer()
	if(dir == NORTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/bed/chair/vehicle/wheelchair/check_key(var/mob/user)
	if(check_hands(user))
		return 1
	return 0

/obj/structure/bed/chair/vehicle/wheelchair/emp_act(severity)
	return

/obj/structure/bed/chair/vehicle/wheelchair/update_mob()
	if(occupant)
		occupant.pixel_x = 0
		occupant.pixel_y = 3

/obj/structure/bed/chair/vehicle/wheelchair/die()
	getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 4)
	getFromPool(/obj/item/stack/rods, get_turf(src), 2)
	qdel(src)

/obj/structure/bed/chair/vehicle/wheelchair/multi_people
	nick = "hella ride"
	desc = "A chair with fitted wheels. Something seems off about this one..."

/obj/structure/bed/chair/vehicle/wheelchair/multi_people/examine(mob/user)
	..()

	if(locked_atoms.len > 9)
		user << "<b>WHAT THE FUCK</b>"

/obj/structure/bed/chair/vehicle/wheelchair/multi_people/can_buckle(mob/M, mob/user)
	//Same as parent's, but no occupant check!
	if(M != user || !Adjacent(user) || (!ishuman(user) && !isalien(user) && !ismonkey(user)) || user.restrained() || user.stat || user.locked_to || destroyed)
		return 0
	return 1

/obj/structure/bed/chair/vehicle/wheelchair/multi_people/update_mob()
	var/i = 0
	for(var/mob/living/L in locked_atoms)
		L.pixel_x = 0
		L.pixel_y = 3 + (i*6) //Stack people on top of each other!

		i++

/obj/structure/bed/chair/vehicle/wheelchair/multi_people/manual_unbuckle(mob/user)
	..()

	update_mob() //Update the rest

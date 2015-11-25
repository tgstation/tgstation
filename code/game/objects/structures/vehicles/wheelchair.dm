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
		to_chat(user, "<span class='warning'>You need at least one hand to use [src]!</span>")
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
		to_chat(user, "<b>WHAT THE FUCK</b>")

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

/obj/structure/bed/chair/vehicle/wheelchair/motorized
	name = "motorized wheelchair"
	nick = "cripplin' revenge"
	desc = "A chair with fitted wheels which is powered by an internal cell. It propels itself without the need for hands as long as it is charged."
	var/maintenance = 0
	var/default_cell_path = /obj/item/weapon/cell/high
	var/obj/item/weapon/cell/internal_battery = null


/obj/structure/bed/chair/vehicle/wheelchair/motorized/New()
	..()
	internal_battery = new default_cell_path(src)

/obj/structure/bed/chair/vehicle/wheelchair/motorized/examine(mob/user)
	..()
	if(internal_battery)
		to_chat(user, "<span class='info'>The battery meter reads: [round(internal_battery.percent(),1)]%</span>")
	else
		to_chat(user, "<span class='warning'>The 'check battery' light is blinking.</span>")

/obj/structure/bed/chair/vehicle/wheelchair/motorized/Move()
	..()
	if(internal_battery)
		internal_battery.use(2) //Example use: 100 charge to get from the cargo desk to medbay side entrance

/obj/structure/bed/chair/vehicle/wheelchair/motorized/getMovementDelay()
	if(internal_battery && internal_battery.charge)
		return 0
	else
		return (..() * 2) //It's not designed to move this way!

/obj/structure/bed/chair/vehicle/wheelchair/motorized/check_key(var/mob/user)
	if(internal_battery && internal_battery.charge)
		return 1
	else
		return ..()

/obj/structure/bed/chair/vehicle/wheelchair/motorized/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isscrewdriver(W))
		user.visible_message("<span class='notice'>[user] screws [maintenance ? "closed" : "open"] \the [src]'s battery compartment.</span>", "<span class='notice'>You screw [maintenance ? "closed" : "open"] the battery compartment.</span>", "You hear screws being loosened.")
		maintenance = !maintenance
	else if(iscrowbar(W)&&maintenance)
		if(internal_battery)
			user.put_in_hands(internal_battery)
			internal_battery = null
		user.visible_message("<span class='notice'>[user] pries out \the [src]'s battery.</span>", "<span class='notice'>You pry out \the [src]'s battery.</span>", "You hear a clunk.")
	else if(istype(W,/obj/item/weapon/cell)&&maintenance&&!internal_battery)
		if(user.drop_item(W,src))
			internal_battery = W
			user.visible_message("<span class='notice'>[user] inserts \the [W] into the \the [src].</span>", "<span class='notice'>You insert \the [W] into \the [src].</span>", "You hear something being slid into place.")
	else ..()

/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate
	nick = "medical malpractice"
	desc = "A chair with fitted wheels which is powered by an internal cell. It seems to ride higher than other wheelchairs."
	default_cell_path = /obj/item/weapon/cell/hyper

/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate/Bump(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(isrobot(L))
			src.visible_message("<span class='warning'>[src] slams into [L]!</span>")
			L.Stun(2)
			L.Weaken(2)
			L.adjustBruteLoss(rand(4,6))
		else
			src.visible_message("<span class='warning'>[src] knocks over [L]!</span>")
			L.stop_pulling()
			L.Stun(8)
			L.Weaken(5)
			L.lying = 1
			L.update_icons()
	..()

/obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate/proc/crush(var/mob/living/H,var/bloodcolor) //Basically identical to the MULE, see mulebot.dm
	src.visible_message("<span class='warning'>[src] drives over [H]!</span>")
	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
	var/damage = rand(5,10) //We're not as heavy as a MULE. Where it does 30-90 damage, we do 20-40 damage
	H.apply_damage(damage, BRUTE, "head")
	H.apply_damage(damage, BRUTE, "chest")
	H.apply_damage(0.5*damage, BRUTE, "l_leg")
	H.apply_damage(0.5*damage, BRUTE, "r_leg")
	H.apply_damage(0.5*damage, BRUTE, "l_arm")
	H.apply_damage(0.5*damage, BRUTE, "r_arm")

/obj/item/syndicate_wheelchair_kit
	name = "Compressed Wheelchair Kit"
	desc = "Collapsed parts, prepared to immediately spring into the shape of a wheelchair. One use. The Syndicate is not responsible for injury related to the use of this product."
	icon = 'icons/obj/objects.dmi'
	icon_state = "wheelchair-item"
	item_state = "syringe_kit" //This is just a grayish square
	w_class = 4

/obj/item/syndicate_wheelchair_kit/attack_self(mob/user)
	new /obj/structure/bed/chair/vehicle/wheelchair/motorized/syndicate(get_turf(user))
	user.visible_message("<span class='warning'>The wheelchair springs into shape!</span>")
	qdel(src)

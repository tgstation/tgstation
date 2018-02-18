/obj/vehicle/ridden/wheelchair
	name = "wheelchair"
	desc = "A chair with fitted wheels. Used by handicapped to make life easier, however it still requires hands to drive."
	icon_state = "wheelchair"

	anchored = FALSE
	density = TRUE

	max_integrity = 50

	var/normal_move_delay = 4
	var/mutable_appearance/wheel_overlay

/obj/vehicle/ridden/wheelchair/Initialize()
	. = ..()
	wheel_overlay = mutable_appearance(icon, "[icon_state]_overlay", ABOVE_MOB_LAYER)
	add_overlay(wheel_overlay)

/obj/vehicle/ridden/wheelchair/emp_act()
	return

/obj/vehicle/ridden/wheelchair/proc/check_hands(mob/living/carbon/C)
	. = 0
	if(C.get_bodypart("l_arm"))
		. += 1
	if(C.get_bodypart("r_arm"))
		. += 1

/obj/vehicle/ridden/wheelchair/driver_move(mob/user, direction)
	var/hands = check_hands(user) //See check_hands() proc above
	if(hands <= 0)
		return FALSE
	movedelay = normal_move_delay * (4 / hands)
	vehicle_move(direction)
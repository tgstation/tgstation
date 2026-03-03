//the one boulder to rule them all, rust reference
/obj/item/boulder/true_boulder
	name = "One rock to rule them all"
	desc = "A stone that is well weighted and easy to hold, one side is easy and comfortable to hold, you could easily bash somebodys head in with this or mine a metal node."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
	item_flags = NO_MAT_REDEMPTION | SLOWS_WHILE_IN_HAND
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 25 // rock
	throw_range = 5
	force = 25 // the one rock to rule them all
	armour_penetration = 100 //the rock does not care what you wear
	block_chance = 25 // funny
	tk_throw_range = 0 // no fancy magic tricks with the rock
	throw_speed = 0.5
	slowdown = 2
	drag_slowdown = 1.5 // It's still a big rock.

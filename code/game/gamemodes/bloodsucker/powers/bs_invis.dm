
// CONCEPTS

// Slowly disappear when in darkness, while enabled.

/*
/obj/effect/proc_holder/spell/bloodsucker/invis
	name = "Enshroud"
	desc = "Vanish from sight when surrounded by darkness. The darker your surroundings, the more transparent you'll become and the more rapidly you'll do it."
	bloodcost = 15
	charge_max = 100
	amToggleable = TRUE
	amTargetted = FALSE
	action_icon_state = "power_speed"				// State for that image inside icon
*/


// TIP: Use do_mob() to determine if you've moved. If you have, then we can reset your invis.


// OTHER IDEAS:  HIDE POWER
// You can hide so long as you're next to a solid object, and you are not in VISUAL RANGE of them anymore. Press button to try to hide.

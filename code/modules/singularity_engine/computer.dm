// MBTODO: Make it have its own speaker for singularity operations.
// Can be disabled with wirecutter.
/obj/machinery/computer/singularity
	name = "singularity control console"
	desc = "Transforming the singularity from a terror-inducing class action lawsuit into a useful class action lawsuit, this console safely controls the equipment containing the singularity, as well as harnessing its energy output."
	icon_screen = "commsyndie" // idk
	light_color = COLOR_SOFT_RED

// not now, definitely later
/obj/machinery/computer/singularity/screwdriver_act(mob/living/user, obj/item/I)
	balloon_alert(user, "you can't find the panel!")
	return TRUE

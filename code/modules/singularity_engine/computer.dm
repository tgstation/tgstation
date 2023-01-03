GLOBAL_LIST_EMPTY_TYPED(singularity_computers, /obj/machinery/computer/singularity)

// MBTODO: Make it have its own speaker for singularity operations.
// Can be disabled with wirecutter.
/obj/machinery/computer/singularity
	name = "singularity control console"
	desc = "Transforming the singularity from a terror-inducing class action lawsuit into a useful class action lawsuit, this console safely controls the equipment containing the singularity, as well as harnessing its energy output."
	icon_screen = "commsyndie" // idk
	light_color = COLOR_SOFT_RED

	var/list/connected_machines = list()

// HACK: We assume these won't be moving for the prototype.
// Thus, we don't care about building a new one on top of an existing powernet.
/obj/machinery/computer/singularity/Initialize(mapload)
	. = ..()
	GLOB.singularity_computers += src

/obj/machinery/computer/singularity/Destroy()
	GLOB.singularity_computers -= src
	return ..()

// not now, definitely later
/obj/machinery/computer/singularity/screwdriver_act(mob/living/user, obj/item/I)
	balloon_alert(user, "you can't find the panel!")
	return TRUE

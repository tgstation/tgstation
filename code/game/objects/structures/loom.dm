/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/W = I
		if(W.is_fabric && W.amount > 1)
			user.show_message("<span class='notice'>You start weaving the [W.name] through the loom..</span>", 1)
			if(W.use_tool(src, user, W.pull_effort))
				new W.loom_result(drop_location())
				user.show_message("<span class='notice'>You weave the [W.name] into a workable fabric.</span>", 1)
				W.amount = (W.amount - 2)
				if(W.amount < 1)
					qdel(W)
		else
			user.show_message("<span class='notice'>You need a valid fabric and at least 2 of said fabric before using this.</span>")
	else
		return ..()

#define FABRIC_PER_SHEET 4

<<<<<<< HEAD

///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
=======
>>>>>>> Updated this old code to fork
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/attackby(obj/item/I, mob/user)
<<<<<<< HEAD
	if(weave(I, user))
		return
	return ..()

/obj/structure/loom/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I, 5)
	return TRUE

///Handles the weaving.
/obj/structure/loom/proc/weave(obj/item/stack/sheet/cotton/W, mob/user)
	if(!istype(W))
		return FALSE
	if(!anchored)
		user.show_message("<span class='notice'>The loom needs to be wrenched down.</span>", 1)
		return FALSE
	if(W.amount < FABRIC_PER_SHEET)
		user.show_message("<span class='notice'>You need at least [FABRIC_PER_SHEET] units of fabric before using this.</span>", 1)
		return FALSE
	user.show_message("<span class='notice'>You start weaving \the [W.name] through the loom..</span>", 1)
	if(W.use_tool(src, user, W.pull_effort))
		if(W.amount >= FABRIC_PER_SHEET)
			new W.loom_result(drop_location())
			W.use(FABRIC_PER_SHEET)
			user.show_message("<span class='notice'>You weave \the [W.name] into a workable fabric.</span>", 1)
	return TRUE
=======
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/W = I
		if(W.is_fabric && W.amount > 1)
			user.show_message("<span class='notice'>You start weaving the [W.name] through the loom..</span>", 1)
			if(W.use_tool(src, user, W.pull_effort))
				new W.loom_result(drop_location())
				user.show_message("<span class='notice'>You weave the [W.name] into a workable fabric.</span>", 1)
				W.amount = (W.amount - FABRIC_PER_SHEET)
				if(W.amount < 1)
					qdel(W)
		else
			user.show_message("<span class='notice'>You need a valid fabric and at least [FABRIC_PER_SHEET] of said fabric before using this.</span>")
	else
		return ..()
>>>>>>> Updated this old code to fork

#undef FABRIC_PER_SHEET

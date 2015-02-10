
/obj/structure/mirror_frame
	name = "mirror frame"
	desc = "Looks like it holds a sample or a mirror for getting lasered."

	icon='icons/obj/machines/optical/beamsplitter.dmi'
	icon_state = "base"

	anchored = 0
	density = 1
	opacity = 0 // Think table-height.

/obj/structure/mirror_frame/attackby(var/obj/item/W,var/mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		user << "<span class='info'>You begin to unfasten \the [src]'s bolts.</span>"
		if(do_after(user,20))
			anchored=!anchored
			user.visible_message("<span class='info'>You unfasten \the [src]'s bolts.</span>", "[user] unfastens the [src]'s bolts.","You hear a ratchet.")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			user << "Now welding the [src]..."
			if(do_after(user, 20))
				if(!src || !WT.isOn()) return
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] cuts the [src] apart.</span>", "<span class='warning'>You cut the [src] apart.</span>", "You hear welding.")
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
				M.amount = 5
				qdel(src)
				return
			else
				user << "<span class='notice'>The welding tool needs to be on to start this task.</span>"
		else
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"

	if(istype(W, /obj/item/stack/sheet/glass/plasmarglass))
		var/obj/item/stack/sheet/glass/plasmarglass/stack = W
		if(stack.amount < 5)
			user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
			return
		if(do_after(user,10))
			if(stack.amount < 5)
				user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
				return
			stack.use(5)
			var/obj/machinery/mirror/beamsplitter/BS = new (get_turf(src))
			user.visible_message("[user] completes the [BS].", "<span class='info'>You successfully build the [BS]!</span>", "You hear a click.")
			qdel(src)
		return

	if(istype(W, /obj/item/stack/sheet/glass/rglass))
		var/obj/item/stack/sheet/glass/rglass/stack = W
		if(stack.amount < 5)
			user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
			return
		if(do_after(user,10))
			if(stack.amount < 5)
				user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
				return
			stack.use(5)
			var/obj/machinery/mirror/mirror = new (get_turf(src))
			user.visible_message("[user] completes the [mirror].", "<span class='info'>You successfully build the [mirror]!</span>", "You hear a click.")
			qdel(src)
			return

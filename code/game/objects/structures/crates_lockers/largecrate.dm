/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "densecrate"
	density = 1

/obj/structure/largecrate/attack_hand(mob/user as mob)
	user << "<span class='warning'>You need a crowbar to pry this open!</span>"
	return

/obj/structure/largecrate/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /obj/item/stack/sheet/mineral/wood(src)
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.loc = T
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"


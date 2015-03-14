/obj/effect/decal/cleanable
	var/list/random_icon_states = list()

/obj/effect/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	create_reagents(250)
	..()

/obj/effect/decal/cleanable/attackby(obj/item/weapon/W as obj, mob/user as mob,)
	if(istype(W, /obj/item/weapon/reagent_containers/glass) || istype(W, /obj/item/weapon/reagent_containers/food/drinks))
		if(src.reagents && W.reagents)
			if(!src.reagents.total_volume)
				user << "<span class='notice'>[src] isn't thick enough to scoop up!</span>"
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				user << "<span class='notice'>[W] is full!</span>"
				return
			else
				user << "<span class='notice'>you scoop up [src] into [W]!</span>"
				reagents.trans_to(W, reagents.total_volume)
				if(!reagents.total_volume) //scooped up all of it
					qdel(src)
//A massive gear, effectively a girder for clocks.
/obj/structure/destructible/clockwork/wall_gear
	name = "massive gear"
	icon_state = "wall_gear"
	climbable = TRUE
	max_integrity = 50
	obj_integrity = 50
	desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, or just climb over it."
	clockwork_desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, just climb over it, or proselytize it into replicant alloy."
	break_message = "<span class='warning'>The gear breaks apart into shards of alloy!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 4, \
	/obj/item/clockwork/alloy_shards/small = 2) //slightly more debris than the default, totals 26 alloy

/obj/structure/destructible/clockwork/wall_gear/displaced
	anchored = FALSE

/obj/structure/destructible/clockwork/wall_gear/examine(mob/user)
	..()
	user << "<span class='notice'>[src] is [anchored ? "":"not "]secured to the floor.</span>"

/obj/structure/destructible/clockwork/wall_gear/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, I, 10)
		return 1
	else if(istype(I, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/W = I
		if(W.get_amount() < 1)
			user << "<span class='warning'>You need one brass sheet to do this!</span>"
			return
		var/turf/T = get_turf(src)
		if(iswallturf(T))
			user << "<span class='warning'>There is already a wall present!</span>"
			return
		if(!isfloorturf(T))
			user << "<span class='warning'>A floor must be present to build a [anchored ? "false ":""]wall!</span>"
			return
		if(locate(/obj/structure/falsewall) in T.contents)
			user << "<span class='warning'>There is already a false wall present!</span>"
			return
		user << "<span class='notice'>You start adding [W] to [src]...</span>"
		if(do_after(user, 20, target = src))
			var/brass_floor = FALSE
			if(istype(T, /turf/open/floor/clockwork)) //if the floor is already brass, costs less to make(conservation of masssssss)
				brass_floor = TRUE
			if(W.use(2 - brass_floor))
				if(anchored)
					T.ChangeTurf(/turf/closed/wall/clockwork)
				else
					T.ChangeTurf(/turf/open/floor/clockwork)
					new /obj/structure/falsewall/brass(T)
				qdel(src)
			else
				user << "<span class='warning'>You need more brass to make a [anchored ? "false ":""]wall!</span>"
		return 1
	return ..()

/obj/item/weapon/fishing_pole
	name = "fishing pole"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fishing_pole"
	desc = "A fish."
	var/fishing_time = 500
	var/obj/item/weapon/fishing_bait/bait
	var/fishing = 0

/obj/item/weapon/fishing_pole/examine(mob/user as mob)
	..()
	if(bait)
		user << "It has [bait.name]. It can be used [bait.uses] times."
	else
		user << "It has no bait, and cannot be used."

/obj/item/weapon/fishing_pole/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/weapon/fishing_bait))
		if(!bait)
			user << "You add the bait to [src]."
			bait = C
			user.drop_item()
			C.loc = src
			return
		else
			user << "[src] already has bait!"
			return

/obj/item/weapon/fishing_pole/proc/fish(var/mob/living/carbon/human/user, var/turf/space/S)
	if(fishing)
		user << "You're already fishing."
		return
	else
		if(bait)
			user << "You begin to fish."
			if(do_after(user, fishing_time/bait.rating))
				var/picked_fish = pick(types_of_fish)
				var/obj/item/weapon/fish = new picked_fish(S)
				bait.uses--
				if(bait.uses == 0)
					qdel(bait)
				var/fish_size = rand(11,40)
				user << "You catch a [fish]! It's [fish_size] inches!"
			else
				user << "You fail to fish!"
				return
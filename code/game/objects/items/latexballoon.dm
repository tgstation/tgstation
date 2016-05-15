/obj/item/latexballon
	name = "latex glove"
	desc = "A latex glove."
	icon_state = "latexballoon"
	item_state = "lgloves"
	force = 0
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 1
	throw_range = 15
	var/popped = 0
	var/datum/gas_mixture/air_contents = null

/obj/item/latexballon/proc/blow(obj/item/weapon/tank/tank)
	if(popped)
		return
	src.air_contents = tank.remove_air_volume(3)
	icon_state = "latexballoon_blow"
	item_state = "latexballon"
	name = "latex glove balloon"
	desc = "An inflated latex glove."

/obj/item/latexballon/proc/burst()
	if (!air_contents)
		return
	playsound(src, 'sound/weapons/Gunshot.ogg', 100, 1)
	icon_state = "latexballoon_bursted"
	item_state = "lgloves"
	popped = 1
	loc.assume_air(air_contents)

/obj/item/latexballon/ex_act(severity)
	burst()
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)

/obj/item/latexballon/bullet_act()
	burst()

/obj/item/latexballon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C+100)
		burst()
	return

/obj/item/latexballon/attackby(obj/item/W as obj, mob/user as mob)
	if (W.sharpness)
		burst()
	if(istype(W, /obj/item/latexballon) && !istype(src, /obj/item/latexballon/pair))
		var/obj/item/latexballon/L = W
		if(!air_contents || !L.air_contents)
			return
		to_chat(user, "You tie \the [src]s together.")
		if(W.loc == user)
			user.drop_item(W, force_drop = 1)
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/latexballon/pair/LB = new (get_turf(user))
			LB.air_contents = air_contents
			LB.air_contents.volume += L.air_contents.volume
			LB.air_contents.merge(L.air_contents.remove_ratio(1))
			user.put_in_hands(LB)
		else
			var/obj/item/latexballon/pair/LB = new (get_turf(user))
			LB.air_contents = air_contents
			LB.air_contents.volume += L.air_contents.volume
			LB.air_contents.merge(L.air_contents.remove_ratio(1))
		qdel(W)
		qdel(src)

/obj/item/latexballon/pair
	name = "pair of latex glove balloons"
	desc = "A pair of inflated latex gloves."
	icon_state = "latexballoon_pair"
	item_state = "latexballon"

/obj/item/latexballon/pair/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/toy/crayon/red))
		to_chat(user, "You color \the [src] light red using \the [W].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/clothing/gloves/anchor_arms/A = new (get_turf(user))
			user.put_in_hands(A)
		else
			new /obj/item/clothing/gloves/anchor_arms(get_turf(src.loc))
		qdel(src)
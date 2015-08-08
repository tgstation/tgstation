/obj/item/stack/tile/light
	name = "light tile"
	singular_name = "light floor tile"
	desc = "A floor tile, made out of glass. It produces light."
	icon_state = "tile_e"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	turf_type = /turf/simulated/floor/light
	var/state = 0

/obj/item/stack/tile/light/New(var/loc, var/amount=null)
	..()
	if(prob(5))
		state = 3 //broken
	else if(prob(5))
		state = 2 //breaking
	else if(prob(10))
		state = 1 //flickering occasionally
	else
		state = 0 //fine

/obj/item/stack/tile/light/attackby(obj/item/O, mob/user, params)
	..()
	if(istype(O,/obj/item/weapon/crowbar))
		new/obj/item/stack/sheet/metal(user.loc)
		amount--
		new/obj/item/stack/light_w(user.loc)
		if(amount <= 0)
			user.unEquip(src, 1)
			qdel(src)
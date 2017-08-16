/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby(obj/item/O, mob/user, params)

	if(istype(O, /obj/item/weapon/wirecutters))
		var/obj/item/stack/cable_coil/CC = new (user.loc)
		CC.amount = 5
		CC.add_fingerprint(user)
		amount--
		var/obj/item/stack/sheet/glass/G = new (user.loc)
		G.add_fingerprint(user)
		if(amount <= 0)
			qdel(src)

	else if(istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		if (M.use(1))
			use(1)
			var/obj/item/L = new /obj/item/stack/tile/light(user.loc)
			to_chat(user, "<span class='notice'>You make a light tile.</span>")
			L.add_fingerprint(user)
		else
			to_chat(user, "<span class='warning'>You need one metal sheet to finish the light tile!</span>")
	else
		return ..()

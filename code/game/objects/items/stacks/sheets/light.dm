/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby(obj/item/O, mob/user, params)
	..()
	if(istype(O,/obj/item/weapon/wirecutters))
		var/obj/item/stack/cable_coil/CC = new (user.loc)
		CC.amount = 5
		CC.add_fingerprint(user)
		amount--
		var/obj/item/stack/sheet/glass/G = new (user.loc)
		G.add_fingerprint(user)
		if(amount <= 0)
			user.unEquip(src, 1)
			qdel(src)

	if(istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		if (M.use(1))
			use(1)
			var/obj/item/stack/tile/light/L = new (user.loc)
			user << "<span class='notice'>You make a light tile.</span>"
			L.add_fingerprint(user)
		else
			user << "<span class='warning'>You need one metal sheet to finish the light tile!</span>"
			return

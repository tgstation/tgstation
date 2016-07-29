<<<<<<< HEAD
/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	w_class = 3
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby(obj/item/O, mob/user, params)

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

	else if(istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		if (M.use(1))
			use(1)
			var/obj/item/L = PoolOrNew(/obj/item/stack/tile/light, user.loc)
			user << "<span class='notice'>You make a light tile.</span>"
			L.add_fingerprint(user)
		else
			user << "<span class='warning'>You need one metal sheet to finish the light tile!</span>"
	else
		return ..()
=======
/obj/item/stack/light_w
	name = "wired glass tiles"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = W_CLASS_MEDIUM
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	max_amount = 60

/obj/item/stack/light_w/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/wirecutters))
		var/obj/item/stack/cable_coil/CC = new/obj/item/stack/cable_coil(user.loc)
		CC.amount = 5
		amount--
		new/obj/item/stack/sheet/glass/glass(user.loc)
		if(amount <= 0)
			user.drop_from_inventory(src)
			qdel(src)
		return

	if(istype(O,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		M.use(1)
		src.use(1)

		drop_stack(/obj/item/stack/tile/light, get_turf(user), 1, user)

		return
	return ..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

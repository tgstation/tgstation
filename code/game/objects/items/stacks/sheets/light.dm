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

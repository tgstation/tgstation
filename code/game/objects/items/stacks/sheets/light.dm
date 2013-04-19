/obj/item/part/stack/light_w
	name = "wired glass tiles"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	max_amount = 60

/obj/item/part/stack/light_w/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if(istype(O,/obj/item/part/wirecutters))
		var/obj/item/part/cable_coil/CC = new/obj/item/part/cable_coil(user.loc)
		CC.amount = 5
		amount--
		new/obj/item/part/stack/sheet/glass(user.loc)
		if(amount <= 0)
			user.drop_from_inventory(src)
			del(src)

	if(istype(O,/obj/item/part/stack/sheet/metal))
		var/obj/item/part/stack/sheet/metal/M = O
		M.amount--
		if(M.amount <= 0)
			user.drop_from_inventory(M)
			del(M)
		amount--
		new/obj/item/part/stack/tile/light(user.loc)
		if(amount <= 0)
			user.drop_from_inventory(src)
			del(src)

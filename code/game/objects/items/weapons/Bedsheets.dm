/obj/item/weapon/bedsheet/ex_act(severity)
	if (severity <= 2)
		del(src)
		return
	return

/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	if(layer == initial(layer))
		layer = 5
	else
		layer = initial(layer)
	add_fingerprint(user)
	return
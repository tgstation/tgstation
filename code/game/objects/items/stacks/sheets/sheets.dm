/obj/item/stack/sheet
	name = "sheet"
	flags = FPRINT | TABLEPASS
	w_class = 3.0
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/perunit = 3750

/obj/item/stack/sheet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/sheetsnatcher))
		var/obj/item/weapon/sheetsnatcher/S = W
		if(!S.mode)
			S.add(src,user)
		else
			for (var/obj/item/stack/sheet/stack in locate(src.x,src.y,src.z))
				S.add(stack,user)
	..()
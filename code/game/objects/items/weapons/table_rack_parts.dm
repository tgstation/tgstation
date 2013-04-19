/* Table parts and rack parts
 * Contains:
 *		Table Parts
 *		Reinforced Table Parts
 *		Wooden Table Parts
 *		Rack Parts
 */



/*
 * Table Parts
 */
/obj/item/part/table/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/part/stack/sheet/metal( user.loc )
		//SN src = null
		del(src)
	if (istype(W, /obj/item/part/stack/rods))
		if (W:amount >= 4)
			new /obj/item/part/table/reinforced( user.loc )
			user << "\blue You reinforce the [name]."
			W:use(4)
			del(src)
		else if (W:amount < 4)
			user << "\red You need at least four rods to do this."

/obj/item/part/table/attack_self(mob/user as mob)
	new /obj/structure/table( user.loc )
	user.drop_item()
	del(src)
	return


/*
 * Reinforced Table Parts
 */
/obj/item/part/table/reinforced/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/part/stack/sheet/metal( user.loc )
		new /obj/item/part/stack/rods( user.loc )
		del(src)

/obj/item/part/table/reinforced/attack_self(mob/user as mob)
	new /obj/structure/table/reinforced( user.loc )
	user.drop_item()
	del(src)
	return

/*
 * Wooden Table Parts
 */
/obj/item/part/table/wood/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/part/stack/sheet/wood( user.loc )
		del(src)

/obj/item/part/table/wood/attack_self(mob/user as mob)
	new /obj/structure/table/woodentable( user.loc )
	user.drop_item()
	del(src)
	return

/*
 * Rack Parts
 */
/obj/item/part/rack/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/part/stack/sheet/metal( user.loc )
		del(src)
		return
	return

/obj/item/part/rack/attack_self(mob/user as mob)
	var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
	R.add_fingerprint(user)
	user.drop_item()
	del(src)
	return
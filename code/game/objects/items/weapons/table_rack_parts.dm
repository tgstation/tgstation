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
/obj/item/weapon/table_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/iron( user.loc )
		//SN src = null
		qdel(src)
	if (istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.use(4))
			new /obj/item/weapon/table_parts/reinforced( user.loc )
			user << "<span class='notice'>You reinforce the [name].</span>"
			qdel(src)
		else
			user << "<span class='warning'>You need four rods to reinforce table parts.</span>"
			return

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	user << "<span class='notice'>Constructing table..</span>"
	if (do_after(user, construct_delay))
		var/obj/new_table = new table_type( user.loc )
		new_table.add_fingerprint(user)
		user.drop_item()
		qdel(src)
		return

/*
 * Reinforced Table Parts
 */
/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/iron( user.loc )
		new /obj/item/stack/rods( user.loc )
		qdel(src)

/*
 * Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/mineral/wood( user.loc )
		qdel(src)

	if (istype(W, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/Grass = W
		if(Grass.amount > 1)
			Grass.amount -= 1
		else
			qdel(Grass)
		var/obj/item/weapon/table_parts/wood/poker/P = new
		user.put_in_hands(P)
		visible_message("<span class='notice'>[user] adds grass to the wooden table parts</span>")

		qdel(src)


/*
 * Poker Table Parts
 */

/obj/item/weapon/table_parts/wood/poker/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/mineral/wood( user.loc )
		new /obj/item/stack/tile/grass( user.loc )
		qdel(src)

/*
 * Rack Parts
 */
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/iron( user.loc )
		qdel(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	user << "<span class='notice'>Constructing rack...</span>"
	if (do_after(user, 50))
		var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
		R.add_fingerprint(user)
		user.drop_item()
		qdel(src)
		return

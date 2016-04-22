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
	if (iswrench(W))
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		//SN src = null
		qdel(src)
	if (istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = W
		if (rods.amount >= 4)
			new /obj/item/weapon/table_parts/reinforced( user.loc )
			to_chat(user, "<span class='notice'>You reinforce the [name].</span>")
			rods.use(4)
			qdel(src)
		else if (rods.amount < 4)
			to_chat(user, "<span class='warning'>You need at least four rods to do this.</span>")
	if (istype(W, /obj/item/stack/sheet/glass/glass))
		var/obj/item/stack/sheet/glass/glass = W
		if (glass.amount >= 1)
			new /obj/item/weapon/table_parts/glass( user.loc )
			to_chat(user, "<span class='notice'>You add glass panes to \the [name].</span>")
			glass.use(1)
			qdel(src)
		

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	new /obj/structure/table( user.loc )
	user.drop_item(src, force_drop = 1)
	qdel(src)
	


/*
 * Reinforced Table Parts
 */
/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswrench(W))
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		new /obj/item/stack/rods( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/reinforced/attack_self(mob/user as mob)
	new /obj/structure/table/reinforced( user.loc )
	user.drop_item(src, force_drop = 1)
	qdel(src)
	return

/*
 * Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswrench(W))
		new /obj/item/stack/sheet/wood( user.loc )
		qdel(src)

	if (istype(W, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/Grass = W

		if(!Grass.use(1)) return

		new /obj/item/weapon/table_parts/wood/poker( get_turf(src) )
		visible_message("<span class='notice'>[user] adds grass to the wooden table parts.</span>")
		qdel(src)

/obj/item/weapon/table_parts/wood/attack_self(mob/user as mob)
	new /obj/structure/table/woodentable( user.loc )
	user.drop_item(src, force_drop = 1)
	qdel(src)
	return


/*
 * Poker Table Parts
 */

/obj/item/weapon/table_parts/wood/poker/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswrench(W))
		new /obj/item/stack/sheet/wood( user.loc )
		new /obj/item/stack/tile/grass( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/wood/poker/attack_self(mob/user as mob)
	new /obj/structure/table/woodentable/poker( user.loc )
	user.drop_item(src, force_drop = 1)
	qdel(src)
	return

/*
* Glass
*/

/obj/item/weapon/table_parts/glass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (iswrench(W))
		new /obj/item/stack/sheet/glass/glass( user.loc )
		new /obj/item/stack/sheet/metal( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/glass/attack_self(mob/user as mob)
	new /obj/structure/table/glass( user.loc )
	qdel(src)
	


/*
 * Rack Parts
 */
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (iswrench(W))
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		qdel(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
	R.add_fingerprint(user)
	user.drop_item(src, force_drop = 1)
	qdel(src)
	return

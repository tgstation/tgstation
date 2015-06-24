/* Table Frames
 * Contains:
 *		Frames
 *		Wooden Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = 0
	anchored = 0
	layer = 2.8
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2

/obj/structure/table_frame/attackby(var/obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You start disassembling [src]...</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			for(var/i = 1, i <= framestackamount, i++)
				new framestack(get_turf(src))
			qdel(src)
			return
	if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/P = I
		if(P.get_amount() < 1)
			user << "<span class='warning'>You need one plasteel sheet to do this!</span>"
			return
		user << "<span class='notice'>You start adding [P] to [src]...</span>"
		if(do_after(user, 50, target = src))
			P.use(1)
			new /obj/structure/table/reinforced(src.loc)
			qdel(src)
		return
	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 1)
			user << "<span class='warning'>You need one metal sheet to do this!</span>"
			return
		user << "<span class='notice'>You start adding [M] to [src]...</span>"
		if(do_after(user, 20, target = src))
			M.use(1)
			new /obj/structure/table(src.loc)
			qdel(src)
		return
	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 1)
			user << "<span class='warning'>You need one glass sheet to do this!</span>"
			return
		user << "<span class='notice'>You start adding [G] to [src]...</span>"
		if(do_after(user, 20, target = src))
			G.use(1)

			new /obj/structure/table/glass(src.loc)
			qdel(src)
		return

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2

/obj/structure/table_frame/wood/attackby(var/obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		..()
	if(istype(I, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/W = I
		if(W.get_amount() < 1)
			user << "<span class='warning'>You need one wood sheet to do this!</span>"
			return
		user << "<span class='notice'>You start adding [W] to [src]...</span>"
		if(do_after(user, 20, target = src))
			W.use(1)
			new /obj/structure/table/wood(src.loc)
			qdel(src)
		return
	if(istype(I, /obj/item/stack/tile/carpet))
		var/obj/item/stack/tile/carpet/C = I
		if(C.get_amount() < 1)
			user << "<span class='warning'>You need one carpet sheet to do this!</span>"
			return
		user << "<span class='notice'>You start adding [C] to [src]...</span>"
		if(do_after(user, 20, target = src))
			C.use(1)
			new /obj/structure/table/wood/poker(src.loc)
			qdel(src)
		return

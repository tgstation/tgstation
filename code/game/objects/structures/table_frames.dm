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
		if(do_after(user, 30))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			for(var/i = 1, i <= framestackamount, i++)
				var/obj/item/stack/rods/R = new framestack(get_turf(src))
				if(material)
					R.material = material
					R.init_material()
			qdel(src)
			return
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = I
		if(!S.material)
			return
		if(S.get_amount() < 1)
			user << "<span class='warning'>You need one [S] sheet to do this!</span>"
			return
		user << "<span class='notice'>You start adding [S] to [src]...</span>"
		if(do_after(user, 20))
			S.use(1)
			if(istype(S.material, /datum/material/plasteel))
				new /obj/structure/table/reinforced(src.loc)
				qdel(src)
				return
			if(istype(S.material, /datum/material/iron))
				new /obj/structure/table(src.loc)
				qdel(src)
				return
			if(istype(S.material, /datum/material/glass))
				new /obj/structure/table/glass(src.loc)
				qdel(src)
				return
			if(istype(S.material, /datum/material/wood))
				new /obj/structure/table/wood(src.loc)
				qdel(src)
				return
			else
				var/obj/structure/table/T = new /obj/structure/table(src.loc)
				T.material = S.material
				T.init_material()
				T.icon = 'icons/obj/greyscale.dmi'
				qdel(src)
				return
	if(istype(I, /obj/item/stack/tile))
		var/obj/item/stack/tile/L = I
		if(!L.material)
			return
		if(L.get_amount() < 1)
			user << "<span class='warning'>You need one [L] tile to do this!</span>"
			return
		user << "<span class='notice'>You start adding [L] to [src]...</span>"
		if(do_after(user, 20))
			L.use(1)
			if(istype(L.material, /datum/material/carpet))
				new /obj/structure/table/wood/poker(src.loc)
				qdel(src)
				return
			else
				var/obj/structure/table/T = new /obj/structure/table(src.loc)
				T.material = L.material
				T.init_material()
				qdel(src)
				return
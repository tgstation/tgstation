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
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 100
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2

/obj/structure/table_frame/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			deconstruct(TRUE)
		return
	
	var/obj/item/stack/material = I
	if (istype(I, /obj/item/stack) && material?.tableVariant)
		if(material.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one [material.name] sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [material] to [src]...</span>")
		if(do_after(user, 20, target = src) && material.use(1))
			make_new_table(material.tableVariant)
	else
		return ..()

/obj/structure/table_frame/proc/make_new_table(table_type) //makes sure the new table made retains what we had as a frame
	var/obj/structure/table/T = new table_type(loc)
	T.frame = type
	T.framestack = framestack
	T.framestackamount = framestackamount
	qdel(src)

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)
	qdel(src)

/obj/structure/table_frame/narsie_act()
	new /obj/structure/table_frame/wood(src.loc)
	qdel(src)

/obj/structure/table_frame/ratvar_act()
	new /obj/structure/table_frame/brass(src.loc)
	qdel(src)

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/stack))
		var/obj/item/stack/material = I
		var/toConstruct // stores the table variant
		if(istype(I, /obj/item/stack/sheet/mineral/wood))
			toConstruct = /obj/structure/table/wood
		else if(istype(I, /obj/item/stack/tile/carpet))
			toConstruct = /obj/structure/table/wood/poker

		if (toConstruct)
			if(material.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need one [material.name] sheet to do this!</span>")
				return
			to_chat(user, "<span class='notice'>You start adding [material] to [src]...</span>")
			if(do_after(user, 20, target = src) && material.use(1))
				make_new_table(toConstruct)
	else
		return ..()

/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	framestack = /obj/item/stack/tile/brass
	framestackamount = 1

/obj/structure/table_frame/brass/Initialize()
	. = ..()
	change_construction_value(1)

/obj/structure/table_frame/brass/Destroy()
	change_construction_value(-1)
	return ..()

/obj/structure/table_frame/brass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tile/brass))
		var/obj/item/stack/tile/brass/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one brass sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
		if(do_after(user, 20, target = src) && W.use(1))
			make_new_table(/obj/structure/table/reinforced/brass)
	else
		return ..()

/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

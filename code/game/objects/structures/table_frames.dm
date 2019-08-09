///Crafting datum that's solely used to determine what material matches what table.
/datum/table_construction //Oh hell yeah. Datums that solely exist to hold variables.
	var/material
	var/table_type
	var/time
	var/amount

/datum/table_construction/New(material, table_type, time = 20, amount = 1)
	src.material = material //Do NOT remove the src.whatever. They are actually needed here.
	src.table_type = table_type
	src.time = time
	src.amount = amount

///Crafting list for metal tables.
GLOBAL_LIST_INIT(table_construction_metal, list( \
	new /datum/table_construction(/obj/item/stack/sheet/plasteel, /obj/structure/table/reinforced, time = 50),
	new /datum/table_construction(/obj/item/stack/sheet/metal, /obj/structure/table),
	new /datum/table_construction(/obj/item/stack/sheet/glass, /obj/structure/table/glass),
	new /datum/table_construction(/obj/item/stack/sheet/mineral/silver, /obj/structure/table/optable),
	new /datum/table_construction(/obj/item/stack/tile/carpet/black, /obj/structure/table/wood/fancy/black), /* Important, keep subtypes in front of the main type */
	new /datum/table_construction(/obj/item/stack/tile/carpet, /obj/structure/table/wood/fancy),
	new /datum/table_construction(/obj/item/stack/tile/bronze, /obj/structure/table/bronze)))

///A normal table frame. Can be used to create tables.
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
	var/list/tablelist

/obj/structure/table_frame/Initialize()
	. = ..()
	set_table_list()

///Called on init. Links the table crafting with a global list. Overridden in subtypes.
/obj/structure/table_frame/proc/set_table_list()
	tablelist = GLOB.table_construction_metal

///Deconstructs the frame.
/obj/structure/table_frame/wrench_act(mob/user, obj/item/I)
	..()
	. = TRUE //Never attack.
	to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
	I.play_tool_sound(src)
	if(!I.use_tool(src, user, 30))
		return
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)

///Handles the crafting if this gets attacked with a stack.
/obj/structure/table_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack)) //Sorry for the nesting.
		var/obj/item/stack/P = I
		for(var/i in tablelist)
			var/datum/table_construction/tc = i
			if(!istype(P, tc.material))
				continue
			. = TRUE //No afterattack.
			if(P.get_amount() < tc.amount)
				to_chat(user, "<span class='warning'>You need [tc.amount] [P.singular_name][tc.amount == 1 ? "" : "s"] to do this!</span>")
				return //We can safely return here.
			to_chat(user, "<span class='notice'>You start adding [P] to [src]...</span>")
			if(!do_after(user, tc.time, target = src) && P.use(tc.amount))
				return
			var/obj/structure/table/T = new tc.table_type(loc)//makes sure the new table made retains what we had as a frame
			T.frame = type
			T.framestack = framestack
			T.framestackamount = framestackamount
			qdel(src)
			return
	. = ..()

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)
	qdel(src)

/obj/structure/table_frame/narsie_act()
	new /obj/structure/table_frame/wood(loc)
	qdel(src)

/obj/structure/table_frame/ratvar_act()
	new /obj/structure/table_frame/brass(loc)
	qdel(src)

/*
 * Wooden Frames
 */

GLOBAL_LIST_INIT(table_construction_wood, list(
	new /datum/table_construction(/obj/item/stack/tile/carpet/black, /obj/structure/table/wood/fancy/black),
	new /datum/table_construction(/obj/item/stack/tile/carpet, /obj/structure/table/wood/poker),
	new /datum/table_construction(/obj/item/stack/sheet/mineral/wood, /obj/structure/table/wood)))

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/set_table_list()
	tablelist = GLOB.table_construction_wood

GLOBAL_LIST_INIT(table_construction_brass, list(
	new /datum/table_construction(/obj/item/stack/sheet/plasteel, /obj/structure/table/reinforced, time = 50),
	new /datum/table_construction(/obj/item/stack/sheet/metal, /obj/structure/table),
	new /datum/table_construction(/obj/item/stack/sheet/glass, /obj/structure/table/glass),
	new /datum/table_construction(/obj/item/stack/sheet/mineral/silver, /obj/structure/table/optable),
	new /datum/table_construction(/obj/item/stack/tile/bronze, /obj/structure/table/bronze),
	new /datum/table_construction(/obj/item/stack/tile/brass, /obj/structure/table/reinforced/brass)))

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

/obj/structure/table_frame/brass/set_table_list()
	tablelist = GLOB.table_construction_brass

/obj/structure/table_frame/brass/narsie_act()
	..()
	if(QDELETED(src)) //do we still exist?
		return
	var/previouscolor = color
	color = "#960000"
	animate(src, color = previouscolor, time = 8)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

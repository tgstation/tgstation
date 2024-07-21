/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 200
	armor_type = /datum/armor/structure_light_construct

	///Light construction stage (LIGHT_CONSTRUCT_EMPTY, LIGHT_CONSTRUCT_WIRED, LIGHT_CONSTRUCT_CLOSED)
	var/stage = LIGHT_CONSTRUCT_EMPTY
	///Type of fixture for icon state
	var/fixture_type = "tube"
	///Amount of sheets gained on deconstruction
	var/sheets_refunded = 2
	///Reference for light object
	var/obj/machinery/light/new_light = null
	///Reference for the internal cell
	var/obj/item/stock_parts/power_store/cell
	///Can we support a cell?
	var/cell_connectors = TRUE

/datum/armor/structure_light_construct
	melee = 50
	bullet = 10
	laser = 10
	fire = 80
	acid = 50

/obj/structure/light_construct/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
	find_and_hang_on_wall()

/obj/structure/light_construct/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/structure/light_construct/get_cell()
	return cell

/obj/structure/light_construct/examine(mob/user)
	. = ..()
	switch(stage)
		if(LIGHT_CONSTRUCT_EMPTY)
			. += span_notice("It's an empty frame with no wires.")
		if(LIGHT_CONSTRUCT_WIRED)
			. += span_notice("It is wired, but the bolts are not screwed in.")
		if(LIGHT_CONSTRUCT_CLOSED)
			. += span_notice("The casing is closed.")
	if(cell_connectors)
		if(cell)
			. += span_notice("You see [cell] inside the casing.")
		else
			. += span_notice("The casing has no power cell for backup power.")
	else
		. += span_danger("This casing doesn't support power cells for backup power.")

/obj/structure/light_construct/attack_hand(mob/user, list/modifiers)
	if(!cell)
		return
	user.visible_message(span_notice("[user] removes [cell] from [src]!"), span_notice("You remove [cell]."))
	user.put_in_hands(cell)
	cell.update_appearance()
	cell = null
	add_fingerprint(user)

/obj/structure/light_construct/attack_tk(mob/user)
	if(!cell)
		return
	to_chat(user, span_notice("You telekinetically remove [cell]."))
	var/obj/item/stock_parts/power_store/cell_reference = cell
	cell = null
	cell_reference.forceMove(drop_location())
	return cell_reference.attack_tk(user)

/obj/structure/light_construct/attackby(obj/item/tool, mob/user, params)
	add_fingerprint(user)
	if(istype(tool, /obj/item/stock_parts/power_store/cell))
		if(!cell_connectors)
			to_chat(user, span_warning("This [name] can't support a power cell!"))
			return
		if(HAS_TRAIT(tool, TRAIT_NODROP))
			to_chat(user, span_warning("[tool] is stuck to your hand!"))
			return
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
			return
		if(user.temporarilyRemoveItemFromInventory(tool))
			user.visible_message(span_notice("[user] hooks up [tool] to [src]."), \
			span_notice("You add [tool] to [src]."))
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			tool.forceMove(src)
			cell = tool
			add_fingerprint(user)
			return
	if(istype(tool, /obj/item/light))
		to_chat(user, span_warning("This [name] isn't finished being setup!"))
		return

	switch(stage)
		if(LIGHT_CONSTRUCT_EMPTY)
			if(tool.tool_behaviour == TOOL_WRENCH)
				if(cell)
					to_chat(user, span_warning("You have to remove the cell first!"))
					return
				to_chat(user, span_notice("You begin deconstructing [src]..."))
				if (tool.use_tool(src, user, 30, volume=50))
					new /obj/item/stack/sheet/iron(drop_location(), sheets_refunded)
					user.visible_message(span_notice("[user.name] deconstructs [src]."), \
						span_notice("You deconstruct [src]."), span_hear("You hear a ratchet."))
					playsound(src, 'sound/items/deconstruct.ogg', 75, TRUE)
					qdel(src)
				return

			if(istype(tool, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = tool
				if(coil.use(1))
					icon_state = "[fixture_type]-construct-stage2"
					stage = LIGHT_CONSTRUCT_WIRED
					user.visible_message(span_notice("[user.name] adds wires to [src]."), \
						span_notice("You add wires to [src]."))
				else
					to_chat(user, span_warning("You need one length of cable to wire [src]!"))
				return
		if(LIGHT_CONSTRUCT_WIRED)
			if(tool.tool_behaviour == TOOL_WRENCH)
				to_chat(usr, span_warning("You have to remove the wires first!"))
				return

			if(tool.tool_behaviour == TOOL_WIRECUTTER)
				stage = LIGHT_CONSTRUCT_EMPTY
				icon_state = "[fixture_type]-construct-stage1"
				new /obj/item/stack/cable_coil(drop_location(), 1, "red")
				user.visible_message(span_notice("[user.name] removes the wiring from [src]."), \
					span_notice("You remove the wiring from [src]."), span_hear("You hear clicking."))
				tool.play_tool_sound(src, 100)
				return

			if(tool.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user.name] closes [src]'s casing."), \
					span_notice("You close [src]'s casing."), span_hear("You hear screwing."))
				tool.play_tool_sound(src, 75)
				switch(fixture_type)
					if("tube")
						new_light = new /obj/machinery/light/built(loc)
					if("bulb")
						new_light = new /obj/machinery/light/small/built(loc)
				new_light.setDir(dir)
				transfer_fingerprints_to(new_light)
				if(!QDELETED(cell))
					new_light.cell = cell
					cell.forceMove(new_light)
					cell = null
				qdel(src)
				return
	return ..()

/obj/structure/light_construct/blob_act(obj/structure/blob/attacking_blob)
	if(attacking_blob && attacking_blob.loc == loc)
		qdel(src)

/obj/structure/light_construct/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc, sheets_refunded)

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1

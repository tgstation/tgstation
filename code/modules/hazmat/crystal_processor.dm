#define CRYSTAL_MACHINE_COLOR "colorizer"
#define CRYSTAL_MACHINE_SHAPE "shaper"
#define CRYSTAL_MACHINE_SIZE "sizer"
/obj/machinery/hazmat/crystal_processor
	name = "crystal processor"
	desc = "Modify whatever crystal you got."
	icon_state = "crystal_maker"
	var/machinery_type = CRYSTAL_MACHINE_COLOR
	var/processing_speech = "Doing the Needful to CRYSTAL"

/obj/machinery/hazmat/crystal_maker/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/crystal))
		var/obj/item/crystal/C = I
		var/obj/item/crystal/newcrystal = new(get_turf(src))
		C.malf_chance += 5
		newcrystal.malf_chance = C.malf_chance
		switch(machinery_type)
			if(CRYSTAL_MACHINE_COLOR)
				newcrystal.crystal_size = C.crystal_size
				newcrystal.crystal_shape = C.crystal_shape
				newcrystal.crystal_color = pick(CRYSTAL_COLOR_RED, CRYSTAL_COLOR_BLUE, CRYSTAL_COLOR_GREEN)
			if(CRYSTAL_MACHINE_SHAPE)
				newcrystal.crystal_size = C.crystal_size
				newcrystal.crystal_shape = pick(CRYSTAL_SHAPE_SQUARE, CRYSTAL_SHAPE_CIRCLE, CRYSTAL_SHAPE_TRIANGLE, CRYSTAL_SHAPE_CYLINDER)
				newcrystal.crystal_color = C.crystal_color
			if(CRYSTAL_MACHINE_SIZE)
				newcrystal.crystal_size = pick(CRYSTAL_SIZE_SMALL, CRYSTAL_SIZE_MEDIUM, CRYSTAL_SIZE_LARGE)
				newcrystal.crystal_shape = C.crystal_shape
				newcrystal.crystal_color = C.crystal_color
		qdel(C)
		newcrystal.generate_crystal_visuals()
		say("[processing_speech]. Crystal structural stability: [malf_chance]%.")
	say("ERROR: Not a crystal.")

/obj/machinery/hazmat/crystal_processor/size
	name = "crystal sizer"
	desc = "Resizes crystals.
	icon_state = "crystal_sizer"
	machinery_type = CRYSTAL_MACHINE_SIZE
	processing_speech = "Artifically resizing CRYSTAL."

/obj/machinery/hazmat/crystal_processor/shape
	name = "crystal shaper"
	desc = "Shapes crystals.
	icon_state = "crystal_shaper"
	machinery_type = CRYSTAL_MACHINE_SHAPE
	processing_speech = "Artifically reshaping CRYSTAL."

/obj/machinery/hazmat/crystal_processor/color
	name = "crystal colorizer"
	desc = "Recolors crystals.
	icon_state = "crystal_colorer"
	machinery_type = CRYSTAL_MACHINE_COLOR
	processing_speech = "Applying industrial grade dye to CRYSTAL."

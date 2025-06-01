/obj/structure/closet/get_save_vars()
	. = ..()
	. += NAMEOF(src, opened)
	. += NAMEOF(src, contents_initialized)
	. += NAMEOF(src, welded)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, anchorable)
	//basically if this closet has never been opened then don't save its contents cause it will spawn its own stuff
	if(!opened && contents_initialized)
		. += NAMEOF(src, contents)

/obj/structure/sign/painting/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)

/obj/structure/falsewall/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)

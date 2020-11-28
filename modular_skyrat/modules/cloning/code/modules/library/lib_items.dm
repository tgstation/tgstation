/obj/structure/bookcase/manuals/medical
	name = "medical manuals bookcase"

/obj/structure/bookcase/manuals/medical/Initialize()
	. = ..()
	new /obj/item/book/manual/wiki/medical_cloning(src)
	update_icon()

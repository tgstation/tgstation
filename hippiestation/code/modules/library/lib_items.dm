/obj/structure/bookcase/manuals/medical	//hippie start, re-add cloning
	name = "medical manuals bookcase"

/obj/structure/bookcase/manuals/medical/Initialize()	//hippie end, re-add cloning
	. = ..()
	new /obj/item/book/manual/wiki/medical_cloning(src)
	update_icon()

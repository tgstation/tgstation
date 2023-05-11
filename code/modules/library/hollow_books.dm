/obj/item/book/hollow
	name = "hollowed book"
	desc = "I guess someone didn't like it."

/obj/item/book/hollow/Initialize(mapload)
	. = ..()
	carve_out()
	PopulateContents()

/obj/item/book/hollow/PopulateContents()
	return

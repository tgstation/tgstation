/obj/item/slimecross
	name = "crossbred slime extract"
	desc = "An extremely potent slime extract, formed through crossbreeding."
	var/colour = "null"

/obj/item/slimecross/Initialize()
	..()
	name = colour + " " + name
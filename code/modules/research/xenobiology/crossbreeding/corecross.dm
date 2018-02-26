/obj/item/slimecross
	name = "crossbred slime extract"
	desc = "An extremely potent slime extract, formed through crossbreeding."
	var/colour = "null"

/obj/item/slimecross/reproductive/Initialize()
	name = colour + " " + name
	..()

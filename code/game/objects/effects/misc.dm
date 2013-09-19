//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/effect/mark
	icon = 'icons/misc/mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0
	unacidable = 1	//Just to be sure.
	var/mark = ""

/obj/effect/beam
	name = "beam"
	unacidable = 1	//Just to be sure.
	pass_flags = PASSTABLE
	var/def_zone

//used by grabs somehow
/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null
	var/list/container = list()

/obj/effect/spawner
	name = "object spawner"
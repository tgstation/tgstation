//The effect when you wrap a dead body in gift wrap
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/effect/mark
	var/mark = ""
	icon = 'icons/misc/mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0
	unacidable = 1//Just to be sure.

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE

/obj/effect/spawner
	name = "object spawner"

/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )
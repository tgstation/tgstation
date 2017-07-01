
/obj/wood
	icon = 'world.dmi'
	icon_state = "wood"

/obj/tree
	icon = 'world.dmi'
	icon_state = "tree"

/obj/axe
	icon = 'world.dmi'
	icon_state = "axe"

/obj/fire
	icon = 'world.dmi'
	icon_state = "fire"


/mob/verb/make_wood()
	set category = "GOAP TESTS"
	new /obj/wood(get_turf(src))

/mob/verb/make_tree()
	set category = "GOAP TESTS"
	new /obj/tree(get_turf(src))

/mob/verb/make_axe()
	set category = "GOAP TESTS"
	new /obj/axe(get_turf(src))

/mob/verb/make_fire()
	set category = "GOAP TESTS"
	new /obj/fire(get_turf(src))


/mob/verb/make_firemaker()
	set category = "GOAP TESTS"
	new /mob/living/carbon/firemaker(get_turf(src))
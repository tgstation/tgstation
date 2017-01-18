// Shamelessly stolen from Urist McStation. Thanks!

/obj/structure/chair/couch
	name = "couch"
	desc = "A couch. Looks pretty comfortable."
	icon = 'icons/obj/Couch.dmi'
	icon_state = "chair"
	color = rgb(255,255,255)
	var/image/armrest = null
	var/couchpart = 0 //0 = middle, 1 = left, 2 = right

/obj/structure/chair/couch/New()
	if(couchpart == 1)
		armrest = image("icons/urist/structures&machinery/Couch.dmi", "armrest_left")
		armrest.layer = MOB_LAYER + 0.1
	else if(couchpart == 2)
		armrest = image("icons/urist/structures&machinery/Couch.dmi", "armrest_right")
		armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/chair/couch/post_buckle_mob()
	if(has_buckled_mobs())
		overlays += armrest
	else
		overlays -= armrest

/obj/structure/chair/couch/left
	couchpart = 1
	icon_state = "couch_left"

/obj/structure/chair/couch/right
	couchpart = 2
	icon_state = "couch_right"

/obj/structure/chair/couch/middle
	icon_state = "couch_middle"

/obj/structure/chair/couch/left/black
	color = rgb(167,164,153)

/obj/structure/chair/couch/right/black
	color = rgb(167,164,153)

/obj/structure/chair/couch/middle/black
	color = rgb(167,164,153)

/obj/structure/chair/couch/left/teal
	color = rgb(0,255,255)

/obj/structure/chair/couch/right/teal
	color = rgb(0,255,255)

/obj/structure/chair/couch/middle/teal
	color = rgb(0,255,255)

/obj/structure/chair/couch/left/beige
	color = rgb(255,253,195)

/obj/structure/chair/couch/right/beige
	color = rgb(255,253,195)

/obj/structure/chair/couch/middle/beige
	color = rgb(255,253,195)

/obj/structure/chair/couch/left/brown
	color = rgb(255,113,0)

/obj/structure/chair/couch/right/brown
	color = rgb(255,113,0)

/obj/structure/chair/couch/middle/brown
	color = rgb(255,113,0)

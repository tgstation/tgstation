/obj/structure/chair/pew
	name = "wooden pew"
	desc = "Kneel here and pray."
	icon = 'icons/obj/chairs_wide.dmi'
	icon_state = "pewmiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	item_chair = null

///This proc adds the rotate component, overwrite this if you for some reason want to change some specific args.
/obj/structure/chair/pew/MakeRotate()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED)

/obj/structure/chair/pew/left
	name = "left wooden pew end"
	icon_state = "pewend_left"
	has_armrest = TRUE

/obj/structure/chair/pew/right
	name = "right wooden pew end"
	icon_state = "pewend_right"
	has_armrest = TRUE

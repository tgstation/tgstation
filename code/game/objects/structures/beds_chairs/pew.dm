/obj/structure/chair/pew
	name = "wooden pew"
	desc = "Kneel here and pray."
	icon = 'icons/obj/sofa.dmi'
	icon_state = "pewmiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	item_chair = null

///This proc adds the rotate component, overwrite this if you for some reason want to change some specific args.
/obj/structure/chair/pew/MakeRotate()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_ANCHORED_ALLOWED)

/obj/structure/chair/pew/left
	name = "left wooden pew end"
	icon_state = "pewend_left"
	var/mutable_appearance/leftpewarmrest

/obj/structure/chair/pew/left/Initialize(mapload)
	leftpewarmrest = GetLeftPewArmrest()
	leftpewarmrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/pew/left/proc/GetLeftPewArmrest()
	return mutable_appearance('icons/obj/sofa.dmi', "pewend_left_armrest")

/obj/structure/chair/pew/left/Destroy()
	QDEL_NULL(leftpewarmrest)
	return ..()

/obj/structure/chair/pew/left/post_buckle_mob(mob/living/M)
	. = ..()
	update_leftpewarmrest()

/obj/structure/chair/pew/left/proc/update_leftpewarmrest()
	if(has_buckled_mobs())
		add_overlay(leftpewarmrest)
	else
		cut_overlay(leftpewarmrest)

/obj/structure/chair/pew/left/post_unbuckle_mob()
	. = ..()
	update_leftpewarmrest()

/obj/structure/chair/pew/right
	name = "right wooden pew end"
	icon_state = "pewend_right"
	var/mutable_appearance/rightpewarmrest

/obj/structure/chair/pew/right/Initialize(mapload)
	rightpewarmrest = GetRightPewArmrest()
	rightpewarmrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/pew/right/proc/GetRightPewArmrest()
	return mutable_appearance('icons/obj/sofa.dmi', "pewend_right_armrest")

/obj/structure/chair/pew/right/Destroy()
	QDEL_NULL(rightpewarmrest)
	return ..()

/obj/structure/chair/pew/right/post_buckle_mob(mob/living/M)
	. = ..()
	update_rightpewarmrest()

/obj/structure/chair/pew/right/proc/update_rightpewarmrest()
	if(has_buckled_mobs())
		add_overlay(rightpewarmrest)
	else
		cut_overlay(rightpewarmrest)

/obj/structure/chair/pew/right/post_unbuckle_mob()
	. = ..()
	update_rightpewarmrest()

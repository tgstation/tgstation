/obj/item/stack/tile/carpet/peaks
	name = "peaks carpet"
	singular_name = "peaks carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet
	resistance_flags = FLAMMABLE

/turf/open/floor/carpet/peaks
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "carp_tp"
	floor_tile = /obj/item/stack/tile/carpet/peaks

/obj/structure/curtain/red
	name = "red curtain"
	desc = "Contains less than 1% mercury."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "closed"
	alpha = 255 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = 0
	density = FALSE
	open = TRUE

/obj/item/device/flashlight/slamp
	name = "stand lamp"
	desc = "Floor lamp in a minimalist style."
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "slamp"
	item_state = "slamp"
	force = 9
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	color = LIGHT_COLOR_YELLOW
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	materials = list()
	on = TRUE
	anchored = TRUE

/obj/structure/statue/sandstone/venus/afrodita
	name = "Afrodita"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'code/white/statue_w.dmi'
	icon_state = "venus"

/obj/structure/chair/comfy/arm
	name = "Armchair"
	desc = "It looks comfy.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'code/white/pieceofcrap.dmi'
	icon_state = "armchair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	var/mutable_appearance/armresttp
	buildstackamount = 2
	item_chair = null

/obj/structure/chair/comfy/arm/Initialize()
	armresttp = mutable_appearance('code/white/pieceofcrap.dmi', "comfychair_armrest")
	armresttp.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/comfy/arm/Destroy()
	QDEL_NULL(armresttp)
	return ..()

/obj/structure/chair/comfy/arm/post_buckle_mob(mob/living/M)
	..()
	if(has_buckled_mobs())
		add_overlay(armresttp)
	else
		cut_overlay(armresttp)

/area/ruin/redroom
	name = "The Red Room "
	ambientsounds = list('sound/ambience/redroom.ogg')

/datum/map_template/ruin/space/redroom
 	id = "redroom"
 	suffix = "redroom.dmm"
 	name = "Red Room"

/obj/effect/decal/cleanable/blood
	desc = "It's gooey. Perhaps it's the chef's cooking?"

/obj/effect/decal/cleanable/blood/Crossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		if(H.shoes && blood_state && bloodiness && !HAS_TRAIT(H, TRAIT_LIGHT_STEP))
			var/obj/item/clothing/shoes/S = H.shoes
			if(!S.can_be_bloody)
				return
			S.bloody_shoe_color = blood_color

/obj/effect/decal/cleanable/blood/update_icon()
	if(blood_color && blood_color != "#ffffff")
		var/icon/newIcon = icon("spacestation413/icons/effects/blood.dmi")
		newIcon.Blend(blood_color,ICON_MULTIPLY)
		icon = newIcon
	. = ..()

/obj/effect/decal/cleanable/trail_holder/update_icon()
	if(blood_color && blood_color != "#ffffff")
		var/icon/newIcon = icon("spacestation413/icons/effects/blood.dmi")
		newIcon.Blend(blood_color,ICON_MULTIPLY)
		icon = newIcon
	. = ..()

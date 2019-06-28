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

/turf
	var/elevation = 10
	var/pinned = null

/turf/Destroy(force)
	..()

	if (pinned)
		var/mob/living/carbon/human/H = pinned

		if (istype(H))
			H.anchored = FALSE
			H.pinned_to = null
			H.do_pindown(src, 0)
			H.update_canmove()

			for (var/obj/item/stack/rods/R in H.contents)
				if (R.pinned)
					R.pinned = null

/turf/Initialize()
    check_hippie_icon()
    return ..()
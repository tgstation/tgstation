/turf
	var/elevation = 10
	var/pinned = null

/turf/open/floor
	elevation = 11

/turf/open/floor/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks about normal height.</span>")

/turf/open/floor/engine
	elevation = 7

/turf/open/floor/engine/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks lower than normal.</span>")

/turf/open/floor/plating
	elevation = 6

/turf/open/floor/plating/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Its height seems low.</span>")

/turf/open/pool
	elevation = 0

/turf/open/pool/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Its height seems very low.</span>")

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
/obj/structure/closet/crate/slime
	name = "suspicious green crate"
	desc = "Nothing will happen if you open this crate. I promise."
	icon_state = "hydrocrate"
	base_icon_state = "hydrocrate"
	open_sound = 'troutstation/sound/machines/crate/slime_open.ogg'
	close_sound = 'troutstation/sound/machines/crate/slime_close.ogg'
	var/slimed = FALSE //will only slime once

/obj/structure/closet/crate/slime/after_open(mob/living/user, force)
	. = ..()
	if(!slimed)
		slimed = TRUE
		to_chat(user, span_greentext("Watch out! Slime attack!"))
		explosion(src, 0, 0, 1, 0, 0, FALSE, FALSE, TRUE, FALSE, TRUE)
		var/include_flags = INCLUDE_HELD|INCLUDE_ACCESSORIES|INCLUDE_POCKETS

		for (var/turf/open/floor/T in RANGE_TURFS(pick(1,2), src.loc))
			new /obj/effect/decal/cleanable/greenglow(T)

			for (var/mob/living/M in T)
				for (var/obj/item/slimedHold in M.get_equipped_items(include_flags))
					slimedHold.add_atom_colour("#47b200", WASHABLE_COLOUR_PRIORITY)

			for (var/obj/slimeItem in T)
				slimeItem.add_atom_colour("#47b200", WASHABLE_COLOUR_PRIORITY)

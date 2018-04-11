/obj/item/clothing/head/xenos
	alternate_screams = list('sound/voice/hiss6.ogg')

/obj/item/clothing/head/cardborg
	alternate_screams = list('hippiestation/sound/voice/scream_silicon.ogg')

/obj/item/clothing/head/ushanka
	alternate_screams = list('hippiestation/sound/misc/cyka1.ogg', 'hippiestation/sound/misc/cheekibreeki.ogg')

/obj/item/clothing/head/hippie/zoothat
	name = "zoot suit hat"
	desc = "What's swingin', toots?"
	icon_state = "zoothat"

/obj/item/clothing/head/hippie/toad
	name = "bup boy hat"
	desc = "Shout out to simpleflips"
	icon_state = "toad"
	alternate_screams = list('hippiestation/sound/voice/aaaaaa.ogg', 'hippiestation/sound/voice/ahwowow.ogg')

/obj/item/clothing/head/hippie/turban
	name = "turban"
	desc = "Allahu Akbar. Ashhadu an la ilaha illa Allah. Ashadu anna Muhammadan Rasool Allah. Hayya ala-s-Salah. Hayya ala-l-Falah. Allahu Akbar. La ilaha illa Allah."
	icon_state = "turban"

/*
	Stackable hats

	You can now stack any hat on top of another hat
	AltClick on the stack to remove a hat from the top
*/
/obj/item/clothing/head
	var/stack_offset_x = 0 // In case the icon needs to be adjusted to fit the stack
	var/stack_offset_y = 0
	var/list/stacked_hats = list()
	var/max_hats = 500

/obj/item/clothing/head/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/clothing/head))
		var/obj/item/clothing/head/H = I
		var/current_count = LAZYLEN(stacked_hats)
		var/trying_to_add = LAZYLEN(H.stacked_hats) + 1

		if (current_count + trying_to_add >= max_hats)
			to_chat(user, "<span class='warning'>You think to yourself \"perhaps this is too many hats\" and decide not to add any more</span>")
		else
			if (!user.transferItemToLoc(H, src))
				return

			LAZYADD(stacked_hats, H)

			if (LAZYLEN(H.stacked_hats) > 0)
				// First add the hat we're holding and then add the other items
				for (var/obj/item/clothing/head/J in H.stacked_hats)
					LAZYADD(stacked_hats, J)

				// Then reset the overlaws and stacked list
				H.cut_overlays()
				LAZYCLEARLIST(H.stacked_hats)

			update_overlays()
			to_chat(user, "<span class='notice'>You gently place the [H.name] on top of the [name].</span>")
			update_name()

			// In case it's on their head
			if (istype(user, /mob/living/carbon))
				var /mob/living/carbon/C = user
				C.update_inv_head()
	else
		. = ..()

/obj/item/clothing/head/proc/update_name()
	switch(LAZYLEN(stacked_hats))
		if (0)
			name = initial(name)
			desc = initial(desc)
		if (1)
			name = "pile of hats"
			desc = "A meagre pile of hats"
		if (3)
			name = "stack of hats"
			desc = "A decent stack of hats"
		else
			name = "towering pillar of hats"
			desc = "A magnificent display of pride and wealth"

	if (LAZYLEN(stacked_hats) > 0)
		desc = desc + "<br>Alt-click to remove a hat from the pile"

/obj/item/clothing/head/proc/update_overlays()
	cut_overlays()
	var/I = 1
	for (var/obj/item/clothing/head/H in stacked_hats)
		var/mutable_appearance/new_hat = mutable_appearance(H.icon, "[initial(H.icon_state)]")
		new_hat.pixel_y = (6 * I) - 1
		new_hat.pixel_x += H.stack_offset_x
		new_hat.pixel_y += H.stack_offset_y
		add_overlay(new_hat)
		I += 1

/obj/item/clothing/head/Destroy()
	for (. in stacked_hats)
		qdel(.)
	return ..()

/obj/item/clothing/head/AltClick(mob/living/user)
	// Remove the top most hat
	if (LAZYLEN(stacked_hats) > 0)
		var/obj/item/clothing/head/H = pop(stacked_hats)
		if (istype(H))
			H.update_name()
			user.put_in_hands(H)
			update_overlays()
			update_name()

			// In case it's on their head
			if (istype(user, /mob/living/carbon))
				var/mob/living/carbon/C = user
				C.update_inv_head()
	else
		return ..()
/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null

/obj/structure/closet/crate/bin/New()
	..()
	update_icon()

/obj/structure/closet/crate/bin/update_icon()
	..()
	cut_overlays()
	if(contents.len == 0)
		add_overlay("largebing")
	else if(contents.len >= storage_capacity)
		add_overlay("largebinr")
	else
		add_overlay("largebino")

/obj/structure/closet/crate/bin/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/storage/bag/trash))
		var/obj/item/weapon/storage/bag/trash/T = W
		to_chat(user, "<span class='notice'>You fill the bag.</span>")
		for(var/obj/item/O in src)
			if(T.can_be_inserted(O, 1))
				O.loc = T
		T.update_icon()
		do_animate()
	else if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(src.loc, W.usesound, 75, 1)
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, 1, -3)
	flick("animate_largebins", src)
	spawn(13)
		playsound(loc, close_sound, 15, 1, -3)
		update_icon()

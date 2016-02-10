/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE

/obj/structure/closet/crate/bin/New()
	..()
	update_icon()

/obj/structure/closet/crate/bin/update_icon()
	..()
	overlays.Cut()
	if(contents.len == 0)
		overlays += "largebing"
	else if(contents.len >= storage_capacity)
		overlays += "largebinr"
	else
		overlays += "largebino"

/obj/structure/closet/crate/bin/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/storage/bag/trash))
		var/obj/item/weapon/storage/bag/trash/T = W
		user << "<span class='notice'>You fill the bag.</span>"
		for(var/obj/item/O in src)
			if(T.can_be_inserted(O, 1))
				O.loc = T
		T.update_icon()
		do_animate()
	else if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
	else
		..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, 1, -3)
	flick("animate_largebins", src)
	spawn(13)
		playsound(loc, close_sound, 15, 1, -3)
		update_icon()

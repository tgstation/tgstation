/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null
	can_install_electronics = FALSE

/obj/structure/closet/crate/bin/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/closet/crate/bin/update_overlays()
	. = ..()
	if(contents.len == 0)
		. += "largebing"
		return
	if(contents.len >= storage_capacity)
		. += "largebinr"
		return
	. += "largebino"

/obj/structure/closet/crate/bin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/T = W
		to_chat(user, span_notice("You fill the bag."))
		for(var/obj/item/O in src)
			T.atom_storage?.attempt_insert(T, O, user, TRUE)
		T.update_appearance()
		do_animate()
		return TRUE
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, TRUE, -3)
	flick("animate_largebins", src)
	addtimer(CALLBACK(src, .proc/do_close), 13)

/obj/structure/closet/crate/bin/proc/do_close()
	playsound(loc, close_sound, 15, TRUE, -3)
	update_appearance()

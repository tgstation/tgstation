/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "largebins"
	base_icon_state = "largebins"
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null
	can_install_electronics = FALSE
	paint_jobs = null

/obj/structure/closet/crate/bin/Initialize(mapload)
	. = ..()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_TURF_RECEIVE_SWEEPED_ITEMS = PROC_REF(ready_for_trash),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

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
			T.atom_storage?.attempt_insert(O, user, TRUE)
		T.update_appearance()
		do_animate()
		return TRUE
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, TRUE, -3)
	flick("animate_largebins", src)
	addtimer(CALLBACK(src, PROC_REF(do_close)), 13)

/obj/structure/closet/crate/bin/proc/do_close()
	playsound(loc, close_sound, 15, TRUE, -3)
	update_appearance()

///Called when a push broom is trying to sweep items onto the turf this object is standing on. Garbage will be moved inside.
/obj/structure/closet/crate/bin/proc/ready_for_trash(datum/source, obj/item/pushbroom/broom, mob/user, list/items_to_sweep)
	SIGNAL_HANDLER

	if(!items_to_sweep || !opened)
		return

	for (var/obj/item/garbage in items_to_sweep)
		garbage.forceMove(loc)

	items_to_sweep.Cut()

	to_chat(user, span_notice("You sweep the pile of garbage into [src]."))
	playsound(broom.loc, 'sound/weapons/thudswoosh.ogg', 30, TRUE, -1)

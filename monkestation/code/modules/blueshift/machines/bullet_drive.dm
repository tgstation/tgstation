/obj/machinery/dish_drive/bullet
	name = "bullet drive"
	desc = "A modified verison of the dish drive, for security. Because they're lazy."
	icon = 'monkestation/code/modules/blueshift/icons/misc/bulletdrive.dmi'
	icon_state = "synthesizer"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/dish_drive/bullet
	collectable_items = list(/obj/item/ammo_casing)
	suck_distance = 8
	binrange = 10

/obj/item/circuitboard/machine/dish_drive/bullet
	name = "Bullet Drive (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/dish_drive/bullet
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/datum/stock_part/manipulator = 1,
		/datum/stock_part/matter_bin = 2,
	)
	needs_anchored = TRUE

/obj/machinery/dish_drive/bullet/do_the_dishes(manual)
	if(!LAZYLEN(dish_drive_contents))
		if(manual)
			visible_message(span_notice("[src] is empty!"))
		return
	var/obj/machinery/disposal/bin/bin = locate() in view(binrange, src) //NOVA EDIT CHANGE
	if(!bin)
		if(manual)
			visible_message(span_warning("[src] buzzes. There are no disposal bins in range!"))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	var/disposed = 0
	for(var/obj/item/ammo_casing/A in dish_drive_contents)
		if(!A.loaded_projectile)
			LAZYREMOVE(dish_drive_contents, A)
			qdel(A)
			use_power(active_power_usage)
			disposed++
	if(disposed)
		visible_message(span_notice("[src] [pick("whooshes", "bwooms", "fwooms", "pshooms")] and demoleculizes [disposed] stored item\s into the nearby void."))
		playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
		playsound(bin, 'sound/items/pshoom.ogg', 50, TRUE)
		flick("synthesizer_beam", src)
	else
		visible_message(span_notice("There are no disposable items in [src]!"))
	time_since_dishes = world.time + 600

/obj/machinery/dish_drive/bullet/process()
	if(time_since_dishes <= world.time && transmit_enabled)
		do_the_dishes()
	if(!suction_enabled)
		return
	for(var/obj/item/I in view(2 + suck_distance, src))
		if(istype(I, /obj/machinery/dish_drive/bullet))
			visible_message(span_userdanger("[src] has detected another bullet drive nearby, and is sad!"))
			break
		if(is_type_in_list(I, collectable_items) && I.loc != src && (!I.reagents || !I.reagents.total_volume))
			if(I.Adjacent(src))
				LAZYADD(dish_drive_contents, I)
				visible_message(span_notice("[src] beams up [I]!"))
				I.moveToNullspace()
				playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
				flick("synthesizer_beam", src)
			else
				step_towards(I, src)

/obj/effect/turf_decal/plaque/toolbox
	name = "plaque"
	icon = 'icons/oldschool/ss13sign1rowdecals.dmi'
	var/ismain = 0
/obj/effect/turf_decal/plaque/toolbox/New()
	. = ..()
	if(ismain)
		if(!isturf(loc))
			qdel(src)
			return
		var/startx = x-3
		for(var/i=1,i<=7,i++)
			var/turf/T = locate(startx,y,z)
			if(istype(T))
				var/obj/effect/turf_decal/plaque/toolbox/P = new(T)
				if(T == loc)
					P = src
				else
					P = new(T)
				P.icon_state = "S[i]"
			startx++
		ismain = 0

//rapid parts exchanger can now replace apc cells
/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W) || !cell)
		return FALSE
	if(!W.works_from_distance && ((!usr.Adjacent(src)) || (cant_parts_exchange())))
		return FALSE
	for(var/obj/item/stock_parts/cell/C in W.contents)
		if(C.maxcharge > cell.maxcharge)
			var/atom/movable/oldcell = cell
			if(W.remove_from_storage(C))
				C.doMove(oldcell.loc)
				if(W.handle_item_insertion(oldcell, 1))
					cell = C
					W.notify_user_of_success(user,C,oldcell)
					W.play_rped_sound()
					return TRUE
	return ..()

/obj/machinery/power/apc/cant_parts_exchange()
	if(!panel_open)
		return 1

/obj/machinery/proc/cant_parts_exchange()
	if(flags_1 & NODECONSTRUCT_1)
		return 1


/obj/item/storage/part_replacer/proc/notify_user_of_success(mob/user,atom/newitem,atom/olditem)
	if(!user || !newitem || !olditem)
		return
	to_chat(user, "<span class='notice'>[olditem.name] replaced with [newitem.name].</span>")

//Cells construct with fullhealth
/obj/machinery/rnd/production/proc/Make_Cells_Fucking_Full_Charge_Because_Thats_So_Gay(obj/item/stock_parts/cell/C)
	if(istype(C))
		C.charge = C.maxcharge
		C.update_icon()

//reinforced delivery window. allows items to be placed on tables underneath it
/obj/structure/window/reinforced/fulltile/delivery
	name = "reinforced delivery window"
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "delivery_window"
	flags_1 = 0
	smooth = SMOOTH_FALSE
	canSmoothWith = list()
	glass_amount = 5
	CanAtmosPass = ATMOS_PASS_YES

/obj/structure/window/reinforced/fulltile/delivery/unanchored
	anchored = FALSE
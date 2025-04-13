/obj/machinery/recharger/portable_recharger
	name = "portable recharger kit"
	desc = "A metal suitcase that has a special port for charging energy weapons. Due to its compact design, it does not have access to internal components."
	icon = 'modular_meta/features/more_cell_interactions/icons/portable_recharger.dmi'
	icon_state = "portable_recharger"
	anchored = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	var/closed = TRUE
	var/obj/item/case_portable_recharger/portable_recharger

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating


/obj/machinery/recharger/portable_recharger/Initialize(mapload, portable_recharger)
	. = ..()
	if(!portable_recharger)
		return INITIALIZE_HINT_QDEL
	src.portable_recharger = portable_recharger
/**
Очень долго ебался, но вроде сделал
Возможно потребуется калибровка множителей
*/
/obj/machinery/recharger/portable_recharger/process()
	using_power = FALSE

	if(!portable_recharger.incell)
		return PROCESS_KILL

	if(portable_recharger.incell.charge < 200 * recharge_coeff)
		return PROCESS_KILL

	if(charging)
		var/obj/item/stock_parts/power_store/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff)
				portable_recharger.incell.use(250 * recharge_coeff)
				using_power = TRUE
			update_icon()

		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				portable_recharger.incell.use(200 * recharge_coeff)
				using_power = TRUE
			update_icon()
	else
		return PROCESS_KILL


/**
Возможно требуется доработка
Узнаю после тестмерджа
 */


/obj/machinery/recharger/portable_recharger/attackby(obj/item/G, mob/user, params)
	if(G.tool_behaviour == TOOL_WRENCH)
		return
	if(G.tool_behaviour == TOOL_SCREWDRIVER)
		return
	var/allowed = is_type_in_typecache(G, allowed_devices)

	if(allowed)
		if(charging)
			to_chat(user, "<span class='warning'>There is only one charging port in the [src].</span>")
			return TRUE
		if (istype(G, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = G
			if(!E.can_charge)
				to_chat(user, "<span class='notice'>This weapon does not have a weapon charging port.</span>")
				return TRUE

		if(!user.transferItemToLoc(G, src))
			return TRUE
		setCharging(G)

		return TRUE

/obj/machinery/recharger/portable_recharger/Destroy()
	QDEL_NULL(portable_recharger)
	end_processing()
	return ..()

//складывание
/obj/machinery/recharger/portable_recharger/mouse_drop_dragged(atom/over_object, src_location, over_location)
	if(over_object == usr) // Я ОЧЕНЬ СИЛЬНО НАДЕЮСЬ ЧТО ГОСТЫ НЕ СМОГУТ ЗАКРЫВАТЬ ЧОМОДАН
		if(charging)
			usr.visible_message(self_message = "<span class='notice'>It is necessary to remove the [charging] before folding the [src.name].</span>")
			return
		usr.visible_message("<span class='notice'>[usr] begins to fold the [src] into a compact case.</span>", "<span class='notice'>We put the [src] into a compact case.</span>")
		if(do_after(usr, 5, target = usr))
			end_processing()
			usr.put_in_hands(portable_recharger)
			moveToNullspace()
			closed = TRUE

//Картиночки
/obj/machinery/recharger/portable_recharger/update_overlays()
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	luminosity = 1
	if (charging)

		if(portable_recharger.incell.charge < 200 * recharge_coeff)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-fail", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-fail", EMISSIVE_RENDER_PLATE, EMISSIVE_PLANE, dir, alpha)
		else if(using_power)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-charging", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-charging", EMISSIVE_RENDER_PLATE, EMISSIVE_PLANE, dir, alpha)
		else
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-full", layer, plane, dir, alpha)
			SSvis_overlays.add_vis_overlay(src, icon, "recharger-full", EMISSIVE_RENDER_PLATE, EMISSIVE_PLANE, dir, alpha)
	else
		SSvis_overlays.add_vis_overlay(src, icon, "recharger-empty", layer, plane, dir, alpha)
		SSvis_overlays.add_vis_overlay(src, icon, "recharger-empty", EMISSIVE_RENDER_PLATE, EMISSIVE_PLANE, dir, alpha)

// используем старый код чтобы заставить работать новый
/obj/machinery/recharger/portable_recharger/proc/setCharging(new_charging)
	charging = new_charging
	if (new_charging)
		START_PROCESSING(SSmachines, src)
		use_power = ACTIVE_POWER_USE
		using_power = TRUE
		update_icon()
	else
		use_power = IDLE_POWER_USE
		using_power = FALSE
		update_icon()


//кейс с зарядником
/obj/item/case_portable_recharger
	name = "portable recharger case"
	desc = "A metal case with a small inscription \"Portable Charging Complex\"."
	icon = 'modular_meta/features/more_cell_interactions/icons/portable_recharger.dmi'
	icon_state = "case_portable_recharger"
	// На время тестов выпилено
	//lefthand_file = 'lambda/ss7v/icons/obj/lefthand.dmi'
	//righthand_file = 'lambda/ss7v/icons/obj/righthand.dmi'
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	var/obj/machinery/recharger/portable_recharger/link
	var/obj/item/stock_parts/power_store/cell/incell = null

/obj/item/case_portable_recharger/examine(mob/user)
	. = ..()
	. += "<hr><span class='notice'>Is there [incell ? "a [incell]." : "no cell."] inside.</span>"
	if(incell)
		. += "<hr><span class='notice'>[incell] charge [incell.percent()].</span>"

//Типа линковка
/obj/item/case_portable_recharger/Initialize()
	link = new(null, src)
	. = ..()

/obj/item/case_portable_recharger/Destroy()
	if(!QDELETED(link))
		QDEL_NULL(link)
	return ..()

//Раскладывание
/obj/item/case_portable_recharger/attack_self(mob/user)
	if(!isturf(user.loc))
		return
	add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] starts to unfold [link] on the floor.</span>", "<span class='notice'>Deploying the [link] on the floor.</span>")
	if(do_after(user, 5, target = user))
		link.forceMove(get_turf(src))
		link.closed = FALSE
		user.transferItemToLoc(src, link, TRUE)
		atom_storage.close_all()

/obj/item/case_portable_recharger/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/stock_parts/power_store/cell))
		if(incell)
			to_chat(user, "<span class='warning'> There is already a battery inside the [src].</span>")
		if(!incell)
			incell = W
			user.transferItemToLoc(W, src)
			update_icon()
			to_chat(user, "<span class='notice'>Insert [incell] in [src].</span>")
	else
		return

/obj/item/case_portable_recharger/attack_hand_secondary(mob/user)
	. = ..()
	if(incell)
		user.put_in_hands(incell)
		incell = null
		incell.update_icon()
		to_chat(user, "<span class='notice'>Eject [incell] from [src].</span>")
	else
		to_chat(user, "<span class='notice'>There is nothing inside.</span>")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/design/case_portable_recharger
	name = "Portable Recharger Case"
	desc = "A metal suitcase that has a special port for charging energy weapons. Due to its compact design, it does not have access to internal components."
	id = "case_portable_recharger"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 10, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/case_portable_recharger
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

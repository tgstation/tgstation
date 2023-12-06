/obj/machinery/suit_storage_unit
	var/obj/item/choice_beacon/space_suit = null
	var/space_suit_type = null
	/// What type of additional item the unit starts with when spawned.

/obj/machinery/suit_storage_unit/captain
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/captain

/obj/machinery/suit_storage_unit/engine
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/engineering

/obj/machinery/suit_storage_unit/atmos
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/atmos

/obj/machinery/suit_storage_unit/ce
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/ce

/obj/machinery/suit_storage_unit/security
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/security

/obj/machinery/suit_storage_unit/hos
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/hos

/obj/machinery/suit_storage_unit/mining/eva
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/mining

/obj/machinery/suit_storage_unit/cmo
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/cmo

/obj/machinery/suit_storage_unit/rd
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/rd

/obj/machinery/suit_storage_unit/syndicate
	mod_type = null
	space_suit_type = /obj/item/choice_beacon/space_suit/syndi

/obj/machinery/suit_storage_unit/Initialize(mapload)
	. = ..()
	if(space_suit_type)
		space_suit = new space_suit_type(src)

/obj/machinery/suit_storage_unit/dump_inventory_contents()
	. = ..()
	space_suit = null

/obj/machinery/suit_storage_unit/interact(mob/living/user)
	var/static/list/items
	if (!items)
		items = list(
			"suit" = create_silhouette_of(/obj/item/clothing/suit/space/eva),
			"helmet" = create_silhouette_of(/obj/item/clothing/head/helmet/space/eva),
			"mask" = create_silhouette_of(/obj/item/clothing/mask/breath),
			"mod" = create_silhouette_of(/obj/item/mod/control),
			"storage" = create_silhouette_of(/obj/item/tank/internals/oxygen),
			"space_suit" = create_silhouette_of(/obj/item/choice_beacon/space_suit),
		)

	. = ..()
	if (.)
		return
	if (!check_interactable(user))
		return
	var/list/choices = list()
	if (locked)
		choices["unlock"] = icon('icons/hud/radial.dmi', "radial_unlock")
	else if (state_open)
		choices["close"] = icon('icons/hud/radial.dmi', "radial_close")
		for (var/item_key in items)
			var/item = vars[item_key]
			if (item)
				choices[item_key] = item
			else
				// If the item doesn't exist, put a silhouette in its place
				choices[item_key] = items[item_key]
	else
		choices["open"] = icon('icons/hud/radial.dmi', "radial_open")
		choices["disinfect"] = icon('icons/hud/radial.dmi', "radial_disinfect")
		choices["lock"] = icon('icons/hud/radial.dmi', "radial_lock")
	var/choice = show_radial_menu(
		user,
		src,
		choices,
		custom_check = CALLBACK(src, PROC_REF(check_interactable), user),
		require_near = !issilicon(user),
	)
	if (!choice)
		return
	switch (choice)
		if ("open")
			if (!state_open)
				open_machine(drop = FALSE)
				if (occupant)
					dump_inventory_contents()
		if ("close")
			if (state_open)
				close_machine()
		if ("disinfect")
			if (occupant && safeties)
				say("Alert: safeties triggered, occupant detected!")
				return
			else if (!helmet && !mask && !suit && !storage && !occupant)
			else if (!helmet && !mask && !suit && !storage && !occupant && !space_suit)
				to_chat(user, "There's nothing inside [src] to disinfect!")
				return
			else
				if (occupant)
					var/mob/living/mob_occupant = occupant
					to_chat(mob_occupant, span_userdanger("[src]'s confines grow warm, then hot, then scorching. You're being burned [!mob_occupant.stat ? "alive" : "away"]!"))
				cook()
		if ("lock", "unlock")
			if (!state_open)
				locked = !locked
				update_icon()
		else
			var/obj/item/item_to_dispense = vars[choice]
			if (item_to_dispense)
				vars[choice] = null
				try_put_in_hand(item_to_dispense, user)
				update_icon()
			else
				var/obj/item/in_hands = user.get_active_held_item()
				if (in_hands)
					attackby(in_hands, user)
				update_icon()
	interact(user)

/obj/machinery/suit_storage_unit/cook()
	var/mob/living/mob_occupant = occupant
	if(uv_cycles)
		uv_cycles--
		uv = TRUE
		locked = TRUE
		update_appearance()
		if(mob_occupant)
			if(uv_super)
				mob_occupant.adjustFireLoss(rand(20, 36))
			else
				mob_occupant.adjustFireLoss(rand(10, 16))
			if(iscarbon(mob_occupant) && mob_occupant.stat < UNCONSCIOUS)
				//Awake, organic and screaming
				mob_occupant.emote("scream")
		addtimer(CALLBACK(src, PROC_REF(cook)), 50)
	else
		uv_cycles = initial(uv_cycles)
		uv = FALSE
		locked = FALSE
		if(uv_super)
			visible_message(span_warning("[src]'s door creaks open with a loud whining noise. A cloud of foul black smoke escapes from its chamber."))
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
			var/datum/effect_system/fluid_spread/smoke/bad/black/smoke = new
			smoke.set_up(0, holder = src, location = src)
			smoke.start()
			QDEL_NULL(helmet)
			QDEL_NULL(suit)
			QDEL_NULL(mask)
			QDEL_NULL(mod)
			QDEL_NULL(storage)
			QDEL_NULL(space_suit)
			// The wires get damaged too.
			wires.cut_all()
		else
			if(!mob_occupant)
				visible_message(span_notice("[src]'s door slides open. The glowing yellow lights dim to a gentle green."))
			else
				visible_message(span_warning("[src]'s door slides open, barraging you with the nauseating smell of charred flesh."))
				qdel(mob_occupant.GetComponent(/datum/component/irradiated))
			playsound(src, 'sound/machines/airlockclose.ogg', 25, TRUE)
			var/list/things_to_clear = list() //Done this way since using GetAllContents on the SSU itself would include circuitry and such.
			if(suit)
				things_to_clear += suit
				things_to_clear += suit.get_all_contents()
			if(helmet)
				things_to_clear += helmet
				things_to_clear += helmet.get_all_contents()
			if(mask)
				things_to_clear += mask
				things_to_clear += mask.get_all_contents()
			if(mod)
				things_to_clear += mod
				things_to_clear += mod.get_all_contents()
			if(storage)
				things_to_clear += storage
				things_to_clear += storage.get_all_contents()
			if(space_suit)
				things_to_clear += space_suit
				things_to_clear += space_suit.get_all_contents()
			if(mob_occupant)
				things_to_clear += mob_occupant
				things_to_clear += mob_occupant.get_all_contents()
			for(var/am in things_to_clear) //Scorches away blood and forensic evidence, although the SSU itself is unaffected
				var/atom/movable/dirty_movable = am
				dirty_movable.wash(CLEAN_ALL)
		open_machine(FALSE)
		if(mob_occupant)
			dump_inventory_contents()

// SUIT STORAGE UNIT /////////////////
/obj/machinery/suit_storage_unit
	name = "suit storage unit"
	desc = "An industrial unit made to hold and decontaminate irradiated equipment. It comes with a built-in UV cauterization mechanism. A small warning label advises that organic matter should not be placed into the unit."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "classic"
	base_icon_state = "classic"
	power_channel = AREA_USAGE_EQUIP
	density = TRUE
	obj_flags = NO_BUILD // Becomes undense when the unit is open
	max_integrity = 250
	circuit = /obj/item/circuitboard/machine/suit_storage_unit

	var/obj/item/clothing/suit/space/suit = null
	var/obj/item/clothing/head/helmet/space/helmet = null
	var/obj/item/clothing/mask/mask = null
	var/obj/item/mod/control/mod = null
	var/obj/item/storage = null
								// if you add more storage slots, update cook() to clear their radiation too.

	/// What type of spacesuit the unit starts with when spawned.
	var/suit_type = null
	/// What type of space helmet the unit starts with when spawned.
	var/helmet_type = null
	/// What type of breathmask the unit starts with when spawned.
	var/mask_type = null
	/// What type of MOD the unit starts with when spawned.
	var/mod_type = null
	/// What type of additional item the unit starts with when spawned.
	var/storage_type = null

	state_open = FALSE
	/// If the SSU's doors are locked closed. Can be toggled manually via the UI, but is also locked automatically when the UV decontamination sequence is running.
	var/locked = FALSE
	panel_open = FALSE
	/// If the safety wire is cut/pulsed, the SSU can run the decontamination sequence while occupied by a mob. The mob will be burned during every cycle of cook().
	var/safeties = TRUE

	/// If UV decontamination sequence is running. See cook()
	var/uv = FALSE
	/**
	* If the hack wire is cut/pulsed.
	* Modifies effects of cook()
	* * If FALSE, decontamination sequence will clear radiation for all atoms (and their contents) contained inside the unit, and burn any mobs inside.
	* * If TRUE, decontamination sequence will delete all items contained within, and if occupied by a mob, intensifies burn damage delt. All wires will be cut at the end.
	*/
	var/uv_super = FALSE
	/// How many cycles remain for the decontamination sequence.
	var/uv_cycles = 6
	/// Cooldown for occupant breakout messages via relaymove()
	var/message_cooldown
	/// How long it takes to break out of the SSU.
	var/breakout_time = 300
	/// Power contributed by this machine to charge the mod suits cell without any capacitors
	var/base_charge_rate = 200
	// Final charge rate which is base_charge_rate + contribution by capacitors
	var/final_charge_rate = 250


/obj/machinery/suit_storage_unit/standard_unit
	suit_type = /obj/item/clothing/suit/space/eva
	helmet_type = /obj/item/clothing/head/helmet/space/eva
	mask_type = /obj/item/clothing/mask/breath

/obj/machinery/suit_storage_unit/spaceruin
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/oxygen

/obj/machinery/suit_storage_unit/captain
	mask_type = /obj/item/clothing/mask/gas/atmos/captain
	storage_type = /obj/item/tank/jetpack/oxygen/captain
	mod_type = /obj/item/mod/control/pre_equipped/magnate

/obj/machinery/suit_storage_unit/centcom
	mask_type = /obj/item/clothing/mask/gas/atmos/centcom
	storage_type = /obj/item/tank/jetpack/oxygen/captain
	mod_type = /obj/item/mod/control/pre_equipped/corporate

/obj/machinery/suit_storage_unit/engine
	mask_type = /obj/item/clothing/mask/breath
	mod_type = /obj/item/mod/control/pre_equipped/engineering

/obj/machinery/suit_storage_unit/atmos
	mask_type = /obj/item/clothing/mask/gas/atmos
	storage_type = /obj/item/watertank/atmos
	mod_type = /obj/item/mod/control/pre_equipped/atmospheric

/obj/machinery/suit_storage_unit/ce
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/clothing/shoes/magboots/advance
	mod_type = /obj/item/mod/control/pre_equipped/advanced

/obj/machinery/suit_storage_unit/security
	mask_type = /obj/item/clothing/mask/gas/sechailer
	mod_type = /obj/item/mod/control/pre_equipped/security

/obj/machinery/suit_storage_unit/hos
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/safeguard

/obj/machinery/suit_storage_unit/mining
	suit_type = /obj/item/clothing/suit/hooded/explorer
	mask_type = /obj/item/clothing/mask/gas/explorer

/obj/machinery/suit_storage_unit/mining/eva
	suit_type = null
	mask_type = /obj/item/clothing/mask/breath
	mod_type = /obj/item/mod/control/pre_equipped/mining

/obj/machinery/suit_storage_unit/medical
	mask_type = /obj/item/clothing/mask/breath/medical
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/medical

/obj/machinery/suit_storage_unit/cmo
	mask_type = /obj/item/clothing/mask/breath/medical
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/rescue

/obj/machinery/suit_storage_unit/rd
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/research

/obj/machinery/suit_storage_unit/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/harness
	mod_type = /obj/item/mod/control/pre_equipped/nuclear

/obj/machinery/suit_storage_unit/void_old
	suit_type = /obj/item/clothing/suit/space/nasavoid/old
	helmet_type = /obj/item/clothing/head/helmet/space/nasavoid/old
	storage_type = /obj/item/tank/internals/oxygen/yellow

/obj/machinery/suit_storage_unit/void_old/jetpack
	storage_type = /obj/item/tank/jetpack/void

/obj/machinery/suit_storage_unit/radsuit
	name = "radiation suit storage unit"
	suit_type = /obj/item/clothing/suit/utility/radiation
	helmet_type = /obj/item/clothing/head/utility/radiation
	storage_type = /obj/item/geiger_counter

/obj/machinery/suit_storage_unit/open
	state_open = TRUE
	density = FALSE

/obj/machinery/suit_storage_unit/industrial
	name = "industrial suit storage unit"
	icon_state = "industrial"
	base_icon_state = "industrial"

/obj/machinery/suit_storage_unit/industrial/loader
	mod_type = /obj/item/mod/control/pre_equipped/loader

/obj/machinery/suit_storage_unit/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/suit_storage_unit(src)
	if(suit_type)
		suit = new suit_type(src)
	if(helmet_type)
		helmet = new helmet_type(src)
	if(mask_type)
		mask = new mask_type(src)
	if(mod_type)
		mod = new mod_type(src)
	if(storage_type)
		storage = new storage_type(src)
	update_appearance()

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(suit)
	QDEL_NULL(helmet)
	QDEL_NULL(mask)
	QDEL_NULL(mod)
	QDEL_NULL(storage)
	return ..()

/obj/machinery/suit_storage_unit/update_overlays()
	. = ..()
	//if things arent powered, these show anyways
	if(panel_open)
		. += "[base_icon_state]_panel"
	if(state_open)
		. += "[base_icon_state]_open"
		if(suit || mod)
			. += "[base_icon_state]_suit"
		if(helmet)
			. += "[base_icon_state]_helm"
		if(storage)
			. += "[base_icon_state]_storage"
	if(!(machine_stat & BROKEN || machine_stat & NOPOWER))
		if(state_open)
			. += "[base_icon_state]_lights_open"
		else
			if(uv)
				if(uv_super)
					. += "[base_icon_state]_super"
				. += "[base_icon_state]_lights_red"
			else
				. += "[base_icon_state]_lights_closed"
		//top lights
		if(uv)
			if(uv_super)
				. += "[base_icon_state]_uvstrong"
			else
				. += "[base_icon_state]_uv"
		else if(locked)
			. += "[base_icon_state]_locked"
		else
			. += "[base_icon_state]_ready"

/obj/machinery/suit_storage_unit/RefreshParts()
	. = ..()
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		final_charge_rate = base_charge_rate + (capacitor.tier * 50)

/obj/machinery/suit_storage_unit/power_change()
	. = ..()
	if(!is_operational && state_open)
		open_machine()
		dump_inventory_contents()
	update_appearance()

/obj/machinery/suit_storage_unit/dump_inventory_contents()
	. = ..()
	helmet = null
	suit = null
	mask = null
	mod = null
	storage = null
	set_occupant(null)

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		open_machine()
		dump_inventory_contents()
	return ..()

/obj/machinery/suit_storage_unit/interact(mob/living/user)
	var/static/list/items

	if (!items)
		items = list(
			"suit" = create_silhouette_of(/obj/item/clothing/suit/space/eva),
			"helmet" = create_silhouette_of(/obj/item/clothing/head/helmet/space/eva),
			"mask" = create_silhouette_of(/obj/item/clothing/mask/breath),
			"mod" = create_silhouette_of(/obj/item/mod/control),
			"storage" = create_silhouette_of(/obj/item/tank/internals/oxygen),
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

/obj/machinery/suit_storage_unit/proc/check_interactable(mob/user)
	if (!state_open && !can_interact(user))
		return FALSE

	if (panel_open)
		return FALSE

	if (uv)
		return FALSE

	return TRUE

/obj/machinery/suit_storage_unit/proc/create_silhouette_of(atom/item)
	var/image/image = image(initial(item.icon), initial(item.icon_state))
	image.alpha = 128
	image.color = COLOR_RED
	return image

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/A, mob/living/user)
	if(!istype(user) || user.stat || !Adjacent(user) || !Adjacent(A) || !isliving(A))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.body_position == LYING_DOWN)
			return
	var/mob/living/target = A
	if(!state_open)
		to_chat(user, span_warning("The unit's doors are shut!"))
		return
	if(!is_operational)
		to_chat(user, span_warning("The unit is not operational!"))
		return
	if(occupant || helmet || suit || storage)
		to_chat(user, span_warning("It's too cluttered inside to fit in!"))
		return

	if(target == user)
		user.visible_message(span_warning("[user] starts squeezing into [src]!"), span_notice("You start working your way into [src]..."))
	else
		target.visible_message(span_warning("[user] starts shoving [target] into [src]!"), span_userdanger("[user] starts shoving you into [src]!"))

	if(do_after(user, 30, target))
		if(occupant || helmet || suit || storage)
			return
		if(target == user)
			user.visible_message(span_warning("[user] slips into [src] and closes the door behind [user.p_them()]!"), span_notice("You slip into [src]'s cramped space and shut its door."))
		else
			target.visible_message(span_warning("[user] pushes [target] into [src] and shuts its door!"), span_userdanger("[user] shoves you into [src] and shuts the door!"))
		close_machine(target)
		add_fingerprint(user)

/**
 * UV decontamination sequence.
 * Duration is determined by the uv_cycles var.
 * Effects determined by the uv_super var.
 * * If FALSE, all atoms (and their contents) contained are cleared of radiation. If a mob is inside, they are burned every cycle.
 * * If TRUE, all items contained are destroyed, and burn damage applied to the mob is increased. All wires will be cut at the end.
 * All atoms still inside at the end of all cycles are ejected from the unit.
*/
/obj/machinery/suit_storage_unit/proc/cook()
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
			if(mob_occupant)
				things_to_clear += mob_occupant
				things_to_clear += mob_occupant.get_all_contents()
			for(var/am in things_to_clear) //Scorches away blood and forensic evidence, although the SSU itself is unaffected
				var/atom/movable/dirty_movable = am
				dirty_movable.wash(CLEAN_ALL)
		open_machine(FALSE)
		if(mob_occupant)
			dump_inventory_contents()

/obj/machinery/suit_storage_unit/process(delta_time)
	var/obj/item/stock_parts/cell/cell
	if(suit && istype(suit))
		cell = suit.cell
	if(mod)
		cell = mod.get_cell()
	if(!cell || cell.charge == cell.maxcharge)
		return

	var/cell_charged = cell.give(final_charge_rate * delta_time)
	if(cell_charged)
		use_power((active_power_usage + final_charge_rate) * delta_time)

/obj/machinery/suit_storage_unit/proc/shock(mob/user, prb)
	if(!prob(prb))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		if(electrocute_mob(user, src, src, 1, TRUE))
			return 1

/obj/machinery/suit_storage_unit/relaymove(mob/living/user, direction)
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open_machine()
	dump_inventory_contents()

/obj/machinery/suit_storage_unit/container_resist_act(mob/living/user)
	if(!locked)
		open_machine()
		dump_inventory_contents()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the doors of [src]!"), \
		span_notice("You start kicking against the doors... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear a thump from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		open_machine()
		dump_inventory_contents()

	add_fingerprint(user)
	if(locked)
		visible_message(span_notice("You see [user] kicking against the doors of [src]!"), \
			span_notice("You start kicking against the doors..."))
		addtimer(CALLBACK(src, PROC_REF(resist_open), user), 300)
	else
		open_machine()
		dump_inventory_contents()

/obj/machinery/suit_storage_unit/proc/resist_open(mob/user)
	if(!state_open && occupant && (user in src) && user.stat == CONSCIOUS) // Check they're still here.
		visible_message(span_notice("You see [user] burst out of [src]!"), \
			span_notice("You escape the cramped confines of [src]!"))
		open_machine()

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user, params)
	if(state_open && is_operational)
		if(istype(I, /obj/item/clothing/suit))
			if(suit)
				to_chat(user, span_warning("The unit already contains a suit!."))
				return
			if(!user.transferItemToLoc(I, src))
				return
			suit = I
		else if(istype(I, /obj/item/clothing/head))
			if(helmet)
				to_chat(user, span_warning("The unit already contains a helmet!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			helmet = I
		else if(istype(I, /obj/item/clothing/mask))
			if(mask)
				to_chat(user, span_warning("The unit already contains a mask!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			mask = I
		else if(istype(I, /obj/item/mod/control))
			if(mod)
				to_chat(user, span_warning("The unit already contains a MOD!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			mod = I
		else
			if(storage)
				to_chat(user, span_warning("The auxiliary storage compartment is full!"))
				return
			if(!user.transferItemToLoc(I, src))
				return
			storage = I

		visible_message(span_notice("[user] inserts [I] into [src]"), span_notice("You load [I] into [src]."))
		update_appearance()
		return

	if(panel_open)
		if(is_wire_tool(I))
			wires.interact(user)
			return
		else if(I.tool_behaviour == TOOL_CROWBAR)
			default_deconstruction_crowbar(I)
			return
	if(!state_open)
		if(default_deconstruction_screwdriver(user, "[base_icon_state]", "[base_icon_state]", I))	//Set to base_icon_state because the panels for this are overlays
			update_appearance()
			return
	if(default_pry_open(I))
		dump_inventory_contents()
		return

	return ..()

/* ref tg-git issue #45036
	screwdriving it open while it's running a decontamination sequence without closing the panel prior to finish
	causes the SSU to break due to state_open being set to TRUE at the end, and the panel becoming inaccessible.
*/
/obj/machinery/suit_storage_unit/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER && uv)
		to_chat(user, span_warning("It might not be wise to fiddle with [src] while it's running..."))
		return TRUE
	return ..()


/obj/machinery/suit_storage_unit/default_pry_open(obj/item/I)//needs to check if the storage is locked.
	. = !(state_open || panel_open || is_operational || locked || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open \the [src]."))
		open_machine()

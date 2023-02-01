/obj/machinery/power/apc/attackby(obj/item/attacking_object, mob/living/user, params)
	if(HAS_TRAIT(attacking_object, TRAIT_APC_SHOCKING))
		var/metal = 0
		var/shock_source = null
		metal += LAZYACCESS(attacking_object.custom_materials, GET_MATERIAL_REF(/datum/material/iron))//This prevents wooden rolling pins from shocking the user

		if(cell || terminal) //The mob gets shocked by whichever powersource has the most electricity
			if(cell && terminal)
				shock_source = cell.charge > terminal.powernet.avail ? cell : terminal.powernet
			else
				shock_source = terminal?.powernet || cell

		if(shock_source && metal && (panel_open || opened)) //Now you're cooking with electricity
			if(!electrocute_mob(user, shock_source, src, siemens_coeff = 1, dist_check = TRUE))//People with insulated gloves just attack the APC normally. They're just short of magical anyway
				return
			do_sparks(5, TRUE, src)
			user.visible_message(span_notice("[user.name] shoves [attacking_object] into the internal components of [src], erupting into a cascade of sparks!"))
			if(shock_source == cell)//If the shock is coming from the cell just fully discharge it, because it's funny
				cell.use(cell.charge)
			return

	if(issilicon(user) && get_dist(src,user) > 1)
		return attack_hand(user)

	if(istype(attacking_object, /obj/item/stock_parts/cell) && opened)
		if(cell)
			balloon_alert(user, "cell already installed!")
			return
		if(machine_stat & MAINT)
			balloon_alert(user, "no connector for a cell!")
			return
		if(!user.transferItemToLoc(attacking_object, src))
			return
		cell = attacking_object
		user.visible_message(span_notice("[user.name] inserts the power cell to [src.name]!"))
		balloon_alert(user, "cell inserted")
		chargecount = 0
		update_appearance()
		return

	if(attacking_object.GetID())
		togglelock(user)
		return

	if(istype(attacking_object, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			CRASH("attackby on APC when it's not on a turf")
		if(host_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			balloon_alert(user, "remove the floor plating!")
			return
		if(terminal)
			balloon_alert(user, "already wired!")
			return
		if(!has_electronics)
			balloon_alert(user, "no board to wire!")
			return

		var/obj/item/stack/cable_coil/installing_cable = attacking_object
		if(installing_cable.get_amount() < 10)
			balloon_alert(user, "need ten lengths of cable!")
			return

		user.visible_message(span_notice("[user.name] adds cables to the APC frame."))
		balloon_alert(user, "adding cables to the frame...")
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		if(!do_after(user, 20, target = src))
			return
		if(installing_cable.get_amount() < 10 || !installing_cable)
			return
		if(terminal || !opened || !has_electronics)
			return
		var/turf/our_turf = get_turf(src)
		var/obj/structure/cable/cable_node = our_turf.get_cable_node()
		if(prob(50) && electrocute_mob(usr, cable_node, cable_node, 1, TRUE))
			do_sparks(5, TRUE, src)
			return
		installing_cable.use(10)
		balloon_alert(user, "cables added to the frame")
		make_terminal()
		terminal.connect_to_network()
		return

	if(istype(attacking_object, /obj/item/electronics/apc) && opened)
		if(has_electronics)
			balloon_alert(user, "there is already a board!")
			return

		if(machine_stat & BROKEN)
			balloon_alert(user, "the frame is damaged!")
			return

		user.visible_message(span_notice("[user.name] inserts the power control board into [src]."))
		balloon_alert(user, "you start to insert the board...")
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)

		if(!do_after(user, 10, target = src) || has_electronics)
			return

		has_electronics = APC_ELECTRONICS_INSTALLED
		locked = FALSE
		balloon_alert(user, "board installed")
		qdel(attacking_object)
		return

	if(istype(attacking_object, /obj/item/electroadaptive_pseudocircuit) && opened)
		var/obj/item/electroadaptive_pseudocircuit/pseudocircuit = attacking_object
		if(!has_electronics)
			if(machine_stat & BROKEN)
				balloon_alert(user, "frame is too damaged!")
				return
			if(!pseudocircuit.adapt_circuit(user, 50))
				return
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a power control board and click it into place in [src]'s guts."))
			has_electronics = APC_ELECTRONICS_INSTALLED
			locked = FALSE
			return

		if(!cell)
			if(machine_stat & MAINT)
				balloon_alert(user, "no board for a cell!")
				return
			if(!pseudocircuit.adapt_circuit(user, 500))
				return
			var/obj/item/stock_parts/cell/crap/empty/bad_cell = new(src)
			bad_cell.forceMove(src)
			cell = bad_cell
			chargecount = 0
			user.visible_message(span_notice("[user] fabricates a weak power cell and places it into [src]."), \
			span_warning("Your [pseudocircuit.name] whirrs with strain as you create a weak power cell and place it into [src]!"))
			update_appearance()
			return

		balloon_alert(user, "has both board and cell!")
		return

	if(istype(attacking_object, /obj/item/wallframe/apc) && opened)
		if(!(machine_stat & BROKEN || opened == APC_COVER_REMOVED || atom_integrity < max_integrity)) // There is nothing to repair
			balloon_alert(user, "no reason for repairs!")
			return
		if(!(machine_stat & BROKEN) && opened == APC_COVER_REMOVED) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message(span_notice("[user.name] replaces missing APC's cover."))
			balloon_alert(user, "replacing APC's cover...")
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				balloon_alert(user, "cover replaced")
				qdel(attacking_object)
				opened = APC_COVER_OPENED
				update_appearance()
			return
		if(has_electronics)
			balloon_alert(user, "remove the board inside!")
			return
		user.visible_message(span_notice("[user.name] replaces the damaged APC frame with a new one."))
		balloon_alert(user, "replacing damaged frame...")
		if(do_after(user, 50, target = src))
			balloon_alert(user, "replaced frame")
			qdel(attacking_object)
			set_machine_stat(machine_stat & ~BROKEN)
			atom_integrity = max_integrity
			if(opened == APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_appearance()
		return

	if(panel_open && !opened && is_wire_tool(attacking_object))
		wires.interact(user)
		return

	return ..()

/obj/machinery/power/apc/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/apc_interactor = user
	var/obj/item/organ/internal/stomach/ethereal/maybe_ethereal_stomach = apc_interactor.getorganslot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_ethereal_stomach))
		togglelock(user)
	else
		if(maybe_ethereal_stomach.crystal_charge >= ETHEREAL_CHARGE_NORMAL)
			togglelock(user)
		ethereal_interact(user, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Special behavior for when an ethereal interacts with an APC.
/obj/machinery/power/apc/proc/ethereal_interact(mob/living/user, list/modifiers)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/ethereal = user
	var/obj/item/organ/internal/stomach/maybe_stomach = ethereal.getorganslot(ORGAN_SLOT_STOMACH)
	// how long we wanna wait before we show the balloon alert. don't want it to be very long in case the ethereal wants to opt-out of doing that action, just long enough to where it doesn't collide with previously queued balloon alerts.
	var/alert_timer_duration = 0.75 SECONDS

	if(!istype(maybe_stomach, /obj/item/organ/internal/stomach/ethereal))
		return
	var/charge_limit = ETHEREAL_CHARGE_DANGEROUS - APC_POWER_GAIN
	var/obj/item/organ/internal/stomach/ethereal/stomach = maybe_stomach
	if(!((stomach?.drain_time < world.time) && LAZYACCESS(modifiers, RIGHT_CLICK)))
		return
	if(ethereal.combat_mode)
		if(cell.charge <= (cell.maxcharge / 2)) // ethereals can't drain APCs under half charge, this is so that they are forced to look to alternative power sources if the station is running low
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "safeties prevent draining!"), alert_timer_duration)
			return
		if(stomach.crystal_charge > charge_limit)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "charge is full!"), alert_timer_duration)
			return
		stomach.drain_time = world.time + APC_DRAIN_TIME
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "draining power"), alert_timer_duration)
		if(do_after(user, APC_DRAIN_TIME, target = src))
			if(cell.charge <= (cell.maxcharge / 2) || (stomach.crystal_charge > charge_limit))
				return
			balloon_alert(ethereal, "received charge")
			stomach.adjust_charge(APC_POWER_GAIN)
			cell.use(APC_POWER_GAIN)
		return

	if(cell.charge >= cell.maxcharge - APC_POWER_GAIN)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "APC can't receive more power!"), alert_timer_duration)
		return
	if(stomach.crystal_charge < APC_POWER_GAIN)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "charge is too low!"), alert_timer_duration)
		return
	stomach.drain_time = world.time + APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "transfering power"), alert_timer_duration)
	if(!do_after(user, APC_DRAIN_TIME, target = src))
		return
	if((cell.charge >= (cell.maxcharge - APC_POWER_GAIN)) || (stomach.crystal_charge < APC_POWER_GAIN))
		balloon_alert(ethereal, "can't transfer power!")
		return
	if(istype(stomach))
		balloon_alert(ethereal, "transfered power")
		stomach.adjust_charge(-APC_POWER_GAIN)
		cell.give(APC_POWER_GAIN)
	else
		balloon_alert(ethereal, "can't transfer power!")

// attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message(span_notice("[user] removes \the [cell] from [src]!"))
			balloon_alert(user, "cell removed")
			user.put_in_hands(cell)
			cell.update_appearance()
			cell = null
			charging = APC_NOT_CHARGING
			update_appearance()
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE)
	// APC being at 0 integrity doesnt delete it outright. Combined with take_damage this might cause runtimes.
	if(machine_stat & BROKEN && atom_integrity <= 0)
		if(sound_effect)
			play_attack_sound(damage_amount, damage_type, damage_flag)
		return
	return ..()

/obj/machinery/power/apc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(machine_stat & BROKEN)
		return damage_amount
	. = ..()

/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(isAdminGhostAI(user))
		return TRUE
	if(!user.has_unlimited_silicon_privilege)
		return TRUE
	var/mob/living/silicon/ai/AI = user
	var/mob/living/silicon/robot/robot = user
	if(aidisabled || malfhack && istype(malfai) && ((istype(AI) && (malfai != AI && malfai != AI.parent)) || (istype(robot) && (robot in malfai.connected_robots))))
		if(!loud)
			balloon_alert(user, "it's disabled!")
		return FALSE
	return TRUE

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = clamp(malfai.malf_picker.processing_time - 10,0,1000)
	operating = FALSE
	atom_break()
	if(occupier)
		malfvacate(TRUE)
	update()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	if(isalien(user))
		return FALSE
	if(electrocute_mob(user, src, src, 1, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/power/apc/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH) || !isturf(loc))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/apc_interactor = user
	var/obj/item/organ/internal/stomach/ethereal/maybe_ethereal_stomach = apc_interactor.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_ethereal_stomach))
		togglelock(user)
	else
		if(maybe_ethereal_stomach.cell.charge() >= ETHEREAL_CHARGE_NORMAL)
			togglelock(user)
		ethereal_interact(user, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Special behavior for when an ethereal interacts with an APC.
/obj/machinery/power/apc/proc/ethereal_interact(mob/living/user, list/modifiers)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/ethereal = user
	var/obj/item/organ/internal/stomach/maybe_stomach = ethereal.get_organ_slot(ORGAN_SLOT_STOMACH)
	// how long we wanna wait before we show the balloon alert. don't want it to be very long in case the ethereal wants to opt-out of doing that action, just long enough to where it doesn't collide with previously queued balloon alerts.
	var/alert_timer_duration = 0.75 SECONDS

	if(!istype(maybe_stomach, /obj/item/organ/internal/stomach/ethereal))
		return
	var/charge_limit = ETHEREAL_CHARGE_DANGEROUS - APC_POWER_GAIN
	var/obj/item/organ/internal/stomach/ethereal/stomach = maybe_stomach
	var/obj/item/stock_parts/power_store/stomach_cell = stomach.cell
	if(!((stomach?.drain_time < world.time) && LAZYACCESS(modifiers, RIGHT_CLICK)))
		return
	if(ethereal.combat_mode)
		if(cell.charge <= (cell.maxcharge / 2)) // ethereals can't drain APCs under half charge, this is so that they are forced to look to alternative power sources if the station is running low
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "safeties prevent draining!"), alert_timer_duration)
			return
		if(stomach_cell.charge() > charge_limit)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "charge is full!"), alert_timer_duration)
			return
		stomach.drain_time = world.time + APC_DRAIN_TIME
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "draining power"), alert_timer_duration)
		while(do_after(user, APC_DRAIN_TIME, target = src))
			if(cell.charge <= (cell.maxcharge / 2) || (stomach_cell.charge() > charge_limit))
				return
			balloon_alert(ethereal, "received charge")
			stomach.adjust_charge(APC_POWER_GAIN)
			cell.use(APC_POWER_GAIN)
		return

	if(cell.charge >= cell.maxcharge - APC_POWER_GAIN)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "APC can't receive more power!"), alert_timer_duration)
		return
	if(stomach_cell.charge() < APC_POWER_GAIN)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "charge is too low!"), alert_timer_duration)
		return
	stomach.drain_time = world.time + APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), ethereal, "transfering power"), alert_timer_duration)
	if(!do_after(user, APC_DRAIN_TIME, target = src))
		return
	if((cell.charge >= (cell.maxcharge - APC_POWER_GAIN)) || (stomach_cell.charge() < APC_POWER_GAIN))
		balloon_alert(ethereal, "can't transfer power!")
		return
	if(istype(stomach))
		while(do_after(user, APC_DRAIN_TIME, target = src))
			balloon_alert(ethereal, "transferred power")
			cell.give(-stomach.adjust_charge(-APC_POWER_GAIN))
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
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	atom_break()

/obj/machinery/power/apc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armor_penetration = 0)
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

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(isAdminGhostAI(user))
		return TRUE
	if(!HAS_SILICON_ACCESS(user))
		return TRUE
	. = TRUE
	if(isAI(user) || iscyborg(user))
		if(aidisabled)
			. = FALSE
		else if(istype(malfai) && !(malfai == user || (user in malfai.connected_robots)))
			. = FALSE
	if (!. && !loud)
		balloon_alert(user, "it's disabled!")
	return .

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

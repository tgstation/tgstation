// Ethereals:
/// How long it takes an ethereal to drain or charge APCs. Also used as a spam limiter.
#define ETHEREAL_APC_DRAIN_TIME (3 SECONDS)
/// How much power ethereals gain/drain from APCs.
#define ETHEREAL_APC_POWER_GAIN (0.1 * STANDARD_ETHEREAL_CHARGE)
/// Delay between ethereal action and balloon alert, to avoid colliding with previously queued balloon alerts.
#define ETHEREAL_APC_ALERT_DELAY (0.75 SECONDS)

/obj/machinery/power/apc/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!can_interact(user))
		return
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH) || !isturf(loc))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/stomach/ethereal/maybe_ethereal_stomach = human_user.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(maybe_ethereal_stomach))
		togglelock(user)
	else
		if(maybe_ethereal_stomach.cell.charge() >= ETHEREAL_CHARGE_NORMAL)
			togglelock(user)
		ethereal_interact(human_user, maybe_ethereal_stomach, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Special behavior for when an ethereal interacts with an APC.
/obj/machinery/power/apc/proc/ethereal_interact(mob/living/carbon/human/user, obj/item/organ/stomach/ethereal/used_stomach, list/modifiers)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if(isnull(cell))
		return
	if(used_stomach.drain_time > world.time)
		return
	if(user.combat_mode)
		discharge_to_ethereal(user, used_stomach)
	else
		charge_from_ethereal(user, used_stomach)

/// Handles discharging our internal cell to an ethereal and their stomach
/obj/machinery/power/apc/proc/discharge_to_ethereal(mob/living/carbon/human/user, obj/item/organ/stomach/ethereal/used_stomach)
	var/half_max_charge = cell.max_charge() / 2
	// Ethereals can't drain APCs under half charge, so that they are forced to look to alternative power sources if the station is running low
	if(cell.charge() < half_max_charge)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "safeties prevent draining!"), ETHEREAL_APC_ALERT_DELAY)
		return

	var/obj/item/stock_parts/power_store/stomach_cell = used_stomach.cell
	used_stomach.drain_time = world.time + ETHEREAL_APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "draining power..."), ETHEREAL_APC_ALERT_DELAY)
	while(do_after(user, ETHEREAL_APC_DRAIN_TIME, target = src))
		if(isnull(used_stomach) || (used_stomach != user.get_organ_slot(ORGAN_SLOT_STOMACH)))
			balloon_alert(user, "stomach removed!?")
			return
		if(isnull(cell))
			balloon_alert(user, "cell removed!")
			return
		if(cell.charge() < half_max_charge)
			balloon_alert(user, "safeties kicked in!")
			return

		var/our_available_charge = cell.charge() - half_max_charge
		var/stomach_used_charge = stomach_cell.used_charge()
		var/potential_charge = min(our_available_charge, stomach_used_charge)
		var/to_drain = min(ETHEREAL_APC_POWER_GAIN, potential_charge)
		var/energy_drained = cell.use(to_drain, force = TRUE)
		used_stomach.adjust_charge(energy_drained)

		if(stomach_cell.used_charge() <= 0)
			balloon_alert(user, "your charge is full!")
			return
		if(cell.charge() <= 0)
			balloon_alert(user, "apc is empty!")
			return

/// Handles charging our internal cell from an ethereal and their stomach
/obj/machinery/power/apc/proc/charge_from_ethereal(mob/living/carbon/human/user, obj/item/organ/stomach/ethereal/used_stomach)
	if(cell.charge() >= cell.max_charge())
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "apc full!"), ETHEREAL_APC_ALERT_DELAY)
		return
	var/obj/item/stock_parts/power_store/stomach_cell = used_stomach.cell
	if(stomach_cell.charge() <= 0)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "charge is too low!"), ETHEREAL_APC_ALERT_DELAY)
		return

	used_stomach.drain_time = world.time + ETHEREAL_APC_DRAIN_TIME
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, balloon_alert), user, "transferring power..."), ETHEREAL_APC_ALERT_DELAY)
	if(!do_after(user, ETHEREAL_APC_DRAIN_TIME, target = src))
		return
	if(isnull(used_stomach) || (used_stomach != user.get_organ_slot(ORGAN_SLOT_STOMACH)))
		balloon_alert(user, "stomach removed!?")
		return
	if(isnull(cell))
		balloon_alert(user, "cell removed!")
		return

	var/stomach_charge = stomach_cell.charge()
	var/our_used_charge = cell.used_charge()
	var/potential_charge = min(stomach_charge, our_used_charge)
	var/to_drain = min(ETHEREAL_APC_POWER_GAIN, potential_charge)
	var/energy_drained = used_stomach.adjust_charge(-to_drain)
	cell.give(-energy_drained)

	if(cell.used_charge() <= 0)
		balloon_alert(user, "apc is full!")
		return
	if(stomach_cell.charge() <= 0)
		balloon_alert(user, "out of charge!")
		return


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

#undef ETHEREAL_APC_DRAIN_TIME
#undef ETHEREAL_APC_POWER_GAIN
#undef ETHEREAL_APC_ALERT_DELAY

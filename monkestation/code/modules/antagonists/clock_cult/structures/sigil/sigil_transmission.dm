#define POWER_GIVE 40
#define POWER_SIPHON 20

/obj/structure/destructible/clockwork/sigil/transmission
	name = "sigil of transmission"
	desc = "A strange sigil, swirling with a yellow light."
	clockwork_desc = "A glorious sigil used to power Rat'varian structures and recharge energy-based objects."
	icon_state = "sigiltransmission"
	effect_stand_time = 1 SECONDS
	idle_color = "#f1a746"
	invocation_color = "#f5c529"
	pulse_color = "#f8df8b"
	fail_color = "#f1a746"
	looping = TRUE
	living_only = FALSE
	/// A list of structures linked to this sigil
	var/list/linked_structures = list()


/obj/structure/destructible/clockwork/sigil/transmission/Initialize(mapload)
	. = ..()

	for(var/obj/structure/destructible/clockwork/gear_base/powered/gear_base in range(src, SIGIL_TRANSMISSION_RANGE))
		gear_base.link_to_sigil(src)

	START_PROCESSING(SSobj, src)


/obj/structure/destructible/clockwork/sigil/transmission/Destroy()
	STOP_PROCESSING(SSobj, src)

	for(var/obj/structure/destructible/clockwork/gear_base/powered/gear_base as anything in linked_structures)
		gear_base.unlink_to_sigil(src)

	return ..()


/obj/structure/destructible/clockwork/sigil/transmission/process()
	for(var/obj/structure/destructible/clockwork/gear_base/powered/gear_base as anything in linked_structures)
		if(gear_base.transmission_sigils[1] != src) // [1] Ensures we are the master (first) transmission signal
			continue

		gear_base.update_power()


/obj/structure/destructible/clockwork/sigil/transmission/can_affect(atom/movable/atom_movable)
	return (ismecha(atom_movable) || iscyborg(atom_movable) || ishuman(atom_movable))


/obj/structure/destructible/clockwork/sigil/transmission/apply_effects(atom/movable/apply_to)
	if(ismecha(apply_to))
		var/obj/vehicle/sealed/mecha/target_mech = apply_to
		var/is_clockie = FALSE

		for(var/mob/living/living_mob in target_mech.occupants)
			if(!IS_CLOCK(living_mob))
				continue

			is_clockie = TRUE // If one person is a cultist, we just say "they good" to the mech itself
			break

		var/obj/item/stock_parts/cell/power_cell = target_mech.cell

		if(!power_cell)
			return

		if(is_clockie)
			if((power_cell.charge < power_cell.maxcharge) && GLOB.clock_power >= POWER_GIVE)
				target_mech.give_power(power_cell.chargerate)
				GLOB.clock_power -= POWER_GIVE

		else
			if(power_cell.charge)
				target_mech.use_power(power_cell.chargerate)
				GLOB.clock_power += POWER_SIPHON

	else if(iscyborg(apply_to))
		var/mob/living/silicon/robot/borg = apply_to
		var/obj/item/stock_parts/cell/power_cell = borg.get_cell()

		if(!power_cell)
			return

		if(IS_CLOCK(borg))
			if((power_cell.charge < power_cell.maxcharge) && GLOB.clock_power >= POWER_GIVE)
				power_cell.give(power_cell.chargerate)
				GLOB.clock_power -= POWER_GIVE

		else if(power_cell.charge > power_cell.chargerate)
			power_cell.give(-power_cell.chargerate)
			GLOB.clock_power += POWER_SIPHON

	else if(ishuman(apply_to))
		var/mob/living/carbon/human/human = apply_to
		var/list/human_contents = human.get_contents()

		for(var/obj/item/content_item as anything in human_contents)
			var/obj/item/stock_parts/cell/power_cell = content_item.get_cell()

			if(!power_cell)
				continue

			if(IS_CLOCK(human))
				if((power_cell.charge < power_cell.maxcharge) && GLOB.clock_power >= POWER_GIVE)
					power_cell.give(power_cell.chargerate)
					GLOB.clock_power -= POWER_GIVE

			else
				if(power_cell.charge > power_cell.chargerate)
					power_cell.give(-power_cell.chargerate)
					GLOB.clock_power += POWER_SIPHON

#undef POWER_GIVE
#undef POWER_SIPHON

/obj/item/organ/stomach/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."
	organ_traits = list(TRAIT_NOHUNGER) // We have our own hunger mechanic.
	/// Where the energy of the stomach is stored.
	var/obj/item/stock_parts/power_store/cell
	///used to keep ethereals from spam draining power sources
	var/drain_time = 0

/obj/item/organ/stomach/ethereal/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/power_store/cell/ethereal(src)

/obj/item/organ/stomach/ethereal/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/organ/stomach/ethereal/on_life(seconds_per_tick, times_fired)
	. = ..()
	adjust_charge(-ETHEREAL_DISCHARGE_RATE * seconds_per_tick)
	handle_charge(owner, seconds_per_tick, times_fired)

/obj/item/organ/stomach/ethereal/on_mob_insert(mob/living/carbon/stomach_owner)
	. = ..()
	RegisterSignal(stomach_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
	RegisterSignal(stomach_owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/organ/stomach/ethereal/on_mob_remove(mob/living/carbon/stomach_owner)
	. = ..()
	UnregisterSignal(stomach_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(stomach_owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	stomach_owner.clear_mood_event("charge")
	stomach_owner.clear_alert(ALERT_ETHEREAL_CHARGE)
	stomach_owner.clear_alert(ALERT_ETHEREAL_OVERCHARGE)

/obj/item/organ/stomach/ethereal/handle_hunger_slowdown(mob/living/carbon/human/human)
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (1.5 * (1 - cell.charge() / 100)))

/obj/item/organ/stomach/ethereal/proc/charge(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER

	charge_cell.Invoke(cell, seconds_per_tick / 3.5) // Ethereals don't have NT designed charging ports, so they charge slower.

/obj/item/organ/stomach/ethereal/proc/on_electrocute(datum/source, shock_damage, shock_source, siemens_coeff = 1, flags = NONE)
	SIGNAL_HANDLER
	if(flags & SHOCK_ILLUSION)
		return
	adjust_charge(shock_damage * siemens_coeff * 2)
	to_chat(owner, span_notice("You absorb some of the shock into your body!"))

/**Changes the energy of the crystal stomach.
* Args:
* - amount: The change of the energy, in joules.
* Returns: The amount of energy that actually got changed in joules.
**/
/obj/item/organ/stomach/ethereal/proc/adjust_charge(amount)
	var/amount_changed = clamp(amount, ETHEREAL_CHARGE_NONE - cell.charge(), ETHEREAL_CHARGE_DANGEROUS - cell.charge())
	return cell.change(amount_changed)

/obj/item/organ/stomach/ethereal/proc/handle_charge(mob/living/carbon/carbon, seconds_per_tick, times_fired)
	switch(cell.charge())
		if(-INFINITY to ETHEREAL_CHARGE_NONE)
			carbon.add_mood_event("charge", /datum/mood_event/decharged)
			carbon.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/emptycell/ethereal)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.65, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			carbon.add_mood_event("charge", /datum/mood_event/decharged)
			carbon.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/lowcell/ethereal, 3)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.325 * seconds_per_tick, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			carbon.add_mood_event("charge", /datum/mood_event/lowpower)
			carbon.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/lowcell/ethereal, 2)
		if(ETHEREAL_CHARGE_ALMOSTFULL to ETHEREAL_CHARGE_FULL)
			carbon.add_mood_event("charge", /datum/mood_event/charged)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			carbon.add_mood_event("charge", /datum/mood_event/overcharged)
			carbon.throw_alert(ALERT_ETHEREAL_OVERCHARGE, /atom/movable/screen/alert/ethereal_overcharge, 1)
			carbon.apply_damage(0.2, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			carbon.add_mood_event("charge", /datum/mood_event/supercharged)
			carbon.throw_alert(ALERT_ETHEREAL_OVERCHARGE, /atom/movable/screen/alert/ethereal_overcharge, 2)
			carbon.apply_damage(0.325 * seconds_per_tick, TOX, null, null, carbon)
			if(SPT_PROB(5, seconds_per_tick)) // 5% each seacond for ethereals to explosively release excess energy if it reaches dangerous levels
				discharge_process(carbon)
		else
			owner.clear_mood_event("charge")
			carbon.clear_alert(ALERT_ETHEREAL_CHARGE)
			carbon.clear_alert(ALERT_ETHEREAL_OVERCHARGE)

/obj/item/organ/stomach/ethereal/proc/discharge_process(mob/living/carbon/carbon)
	to_chat(carbon, span_warning("You begin to lose control over your charge!"))
	carbon.visible_message(span_danger("[carbon] begins to spark violently!"))

	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	carbon.add_overlay(overcharge)

	if(do_after(carbon, 5 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED)))
		if(ishuman(carbon))
			var/mob/living/carbon/human/human = carbon
			if(human.dna?.species)
				//fixed_mut_color is also ethereal color (for some reason)
				carbon.flash_lighting_fx(5, 7, human.dna.species.fixed_mut_color ? human.dna.species.fixed_mut_color : human.dna.features[FEATURE_MUTANT_COLOR])

		playsound(carbon, 'sound/effects/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		carbon.cut_overlay(overcharge)
		// Only a small amount of the energy gets discharged as the zap. The rest dissipates as heat. Keeps the damage and energy from the zap the same regardless of what STANDARD_CELL_CHARGE is.
		var/discharged_energy = -adjust_charge(ETHEREAL_CHARGE_FULL - cell.charge()) * min(7500 / STANDARD_CELL_CHARGE, 1)
		tesla_zap(source = carbon, zap_range = 2, power = discharged_energy, cutoff = 1 KILO JOULES, zap_flags = ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN | ZAP_ALLOW_DUPLICATES)
		carbon.visible_message(span_danger("[carbon] violently discharges energy!"), span_warning("You violently discharge energy!"))

		if(prob(10)) //chance of developing heart disease to dissuade overcharging oneself
			carbon.apply_status_effect(/datum/status_effect/heart_attack)
			to_chat(carbon, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
			carbon.playsound_local(carbon, 'sound/effects/singlebeat.ogg', 100, 0)

		carbon.Paralyze(100)

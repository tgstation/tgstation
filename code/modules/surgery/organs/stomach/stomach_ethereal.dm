/obj/item/organ/stomach/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."
	low_threshold_passed = "<span class='info'>You can feel your power draining as a feeling of pins and needles fills your abdomen.</span>"
	high_threshold_passed = "<span class='warning'>Your abdomen is filled with the feeling of shocks and electric discharges!</span>"
	high_threshold_cleared = "<span class='info'>The electric feeling in your stomach seems to fade away, leaving behind a feeling of pins and needles.</span>"
	low_threshold_cleared = "<span class='info'>The pins and needles feeling seems to die out as your charge starts to feel far more stable.</span>"
	///basically satiety but electrical
	var/crystal_charge = ETHEREAL_CHARGE_FULL
	///used to keep ethereals from spam draining power sources
	var/drain_time = 0
	var/damagemodifer = 0.25
	decay_factor = STANDARD_ORGAN_DECAY * 0.9 // fails around 16.5 minutes, the battery is one of the last organs to die (of the ones we have)
	
/obj/item/organ/stomach/ethereal/on_life(delta_time, times_fired)
	. = ..()
	adjust_charge(-ETHEREAL_CHARGE_FACTOR * delta_time)
	if(damage > maxHealth)//cap battery damage
		damage = maxHealth
	if(damage < low_threshold)
		handle_charge(owner, delta_time, times_fired)
		return
	adjust_charge(-ETHEREAL_CHARGE_FACTOR * (damage / 5) * delta_time) //at 100 damage ethereals will loose 16 charge per second
	handle_charge(owner, delta_time, times_fired)
	var/mob/living/carbon/organ_owner = owner
	if (prob(7))
		to_chat(owner, "<span class='warning'>You feel a jolt of elecricity from your abdomen!</span>")
	if(!(organ_flags & ORGAN_FAILING))
		return
	if(organ_owner)
		organ_owner.adjustToxLoss(0.65 * delta_time, TRUE, TRUE)
	if (crystal_charge > ETHEREAL_CHARGE_NONE)
		crystal_charge = ETHEREAL_CHARGE_NONE
		if (prob(40))
			to_chat(owner,"<span class='userdanger'>You feel your life draining as your battery fails to contain any charge!</span>")
	

/obj/item/organ/stomach/ethereal/Insert(mob/living/carbon/carbon, special = 0)
	. = ..()
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/charge)
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_electrocute)
	ADD_TRAIT(owner, TRAIT_NOHUNGER, src)

/obj/item/organ/stomach/ethereal/Remove(mob/living/carbon/carbon, special = 0)
	UnregisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	REMOVE_TRAIT(owner, TRAIT_NOHUNGER, src)

	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "charge")
	carbon.clear_alert("ethereal_charge")
	carbon.clear_alert("ethereal_overcharge")

	return ..()

/obj/item/organ/stomach/ethereal/handle_hunger_slowdown(mob/living/carbon/human/human)
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (1.5 * (1 - crystal_charge / 100)))

/obj/item/organ/stomach/ethereal/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	if(!repairs)
		adjust_charge(amount / 3.5)
		return
	if(crystal_charge < ETHEREAL_CHARGE_FULL - amount / 3.5)
		adjust_charge(amount / 3.5)
		return
	if(crystal_charge > ETHEREAL_CHARGE_OVERLOAD) //prevents reduction of charge of overcharged ethereals
		return
	adjust_charge(ETHEREAL_CHARGE_FULL - crystal_charge) //perfectly tops off an ethereal if the amount of power that would be applied would go into overcharge

/obj/item/organ/stomach/ethereal/proc/on_electrocute(datum/source, shock_damage, siemens_coeff = 1, flags = NONE)
	SIGNAL_HANDLER
	if(flags & SHOCK_ILLUSION)
		return
	adjust_charge(shock_damage * siemens_coeff * 2)
	to_chat(owner, span_notice("You absorb some of the shock into your body!"))

/obj/item/organ/stomach/ethereal/proc/adjust_charge(amount)
	crystal_charge = clamp(crystal_charge + amount, ETHEREAL_CHARGE_NONE, ETHEREAL_CHARGE_DANGEROUS)

/obj/item/organ/stomach/ethereal/proc/handle_charge(mob/living/carbon/carbon, delta_time, times_fired)
	switch(crystal_charge)
		if(-INFINITY to ETHEREAL_CHARGE_NONE)
			SEND_SIGNAL(carbon, COMSIG_ADD_MOOD_EVENT, "charge", /datum/mood_event/decharged)
			carbon.clear_alert("ethereal_overcharge")
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/emptycell/ethereal)
			if(carbon.health > 10.5 && !(organ_flags & ORGAN_FAILING)) //special interaction for failiure
				carbon.apply_damage(0.65, TOX, null, null, carbon)
				damage += (0.5 * damagemodifer)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			SEND_SIGNAL(carbon, COMSIG_ADD_MOOD_EVENT, "charge", /datum/mood_event/decharged)
			carbon.clear_alert("ethereal_overcharge")
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/lowcell/ethereal, 3)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.325 * delta_time, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			SEND_SIGNAL(carbon, COMSIG_ADD_MOOD_EVENT, "charge", /datum/mood_event/lowpower)
			carbon.clear_alert("ethereal_overcharge")
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/lowcell/ethereal, 2)
		if(ETHEREAL_CHARGE_ALMOSTFULL to ETHEREAL_CHARGE_FULL)
			carbon.clear_alert("ethereal_overcharge")
			carbon.clear_alert("ethereal_charge")
			SEND_SIGNAL(carbon, COMSIG_ADD_MOOD_EVENT, "charge", /datum/mood_event/charged)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			SEND_SIGNAL(carbon, COMSIG_ADD_MOOD_EVENT, "charge", /datum/mood_event/overcharged)
			carbon.clear_alert("ethereal_charge")
			carbon.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 1)
			carbon.apply_damage(0.2, TOX, null, null, carbon)
			damage += (1 * damagemodifer)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			SEND_SIGNAL(carbon, COMSIG_ADD_MOOD_EVENT, "charge", /datum/mood_event/supercharged)
			carbon.clear_alert("ethereal_charge")
			carbon.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 2)
			carbon.apply_damage(0.325 * delta_time, TOX, null, null, carbon)
			damage += (8 * damagemodifer)
			if(DT_PROB(5, delta_time)) // 5% each seacond for ethereals to explosively release excess energy if it reaches dangerous levels
				discharge_process(carbon)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "charge")
			carbon.clear_alert("ethereal_charge")
			carbon.clear_alert("ethereal_overcharge")

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
				carbon.flash_lighting_fx(5, 7, human.dna.species.fixed_mut_color ? human.dna.species.fixed_mut_color : human.dna.features["mcolor"])

		playsound(carbon, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		carbon.cut_overlay(overcharge)
		tesla_zap(carbon, 2, crystal_charge*2.5, ZAP_OBJ_DAMAGE | ZAP_ALLOW_DUPLICATES)
		adjust_charge(ETHEREAL_CHARGE_FULL - crystal_charge)
		to_chat(carbon, span_warning("You violently discharge energy!"))
		carbon.visible_message(span_danger("[carbon] violently discharges energy!"))
		damage += (40 * damagemodifer)
		if(prob(10)) //chance of battery failing instantly, heart disease effect removed in favor of this better thing
			to_chat(carbon, span_userdanger("You collapse in pain as you feel your battery burst open from the charge!"))
			damage += 200
			carbon.emote("Scream")
			carbon.AdjustUnconscious(2.5 SECONDS)
			carbon.visible_message(span_danger("[carbon] collapses in utter agony!"))
		carbon.Paralyze(100)
		

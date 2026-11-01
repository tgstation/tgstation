/// Ratwood's blood (living/blood.dm: handle_blood(), bleed()) on medieval maps, in place of TG's handle_blood(): the body
/// makes its blood back by itself, constitution, traits and yielding slow or quicken the bleeding, and low blood weakens
/// the body in three steps before it starts to choke it; no instant death at the bottom, as with TG. The wounds bleed as
/// TG counts them, but an opened artery (a critical cut or stab) at Ratwood's rate, and a stump (combat/dismember.dm)
/// with it. The numbers are Ratwood's per Life tick of 2 seconds (ROGUE_LIFE_TICK).

/mob/living/carbon/human
	/// The step of blood loss the body is at (Ratwood bleeding_tier): 0 none, 1 dizzy, 2 faint, 3 drained.
	var/rogue_bleed_tier = 0

/datum/wound
	/// Which artery a crit opened with this cut or stab (crits.dm): the throat's or the heart's; null for a limb's.
	var/rogue_artery
	/// The crit that opened it has had its say (the paincrit and the stagger of Ratwood's artery).
	var/rogue_artery_opened = FALSE

/// Blood per second this wound loses at Ratwood's rate where it bleeds harder than TG lets it: 0 if TG's count stands.
/datum/wound/proc/rogue_artery_bleed()
	return 0

/datum/wound/slash/flesh/rogue_artery_bleed()
	return rogue_artery_rate()

/datum/wound/pierce/bleed/rogue_artery_bleed()
	return rogue_artery_rate()

/// A critical cut or stab is an opened artery, as the strike line names it (combat/chat.dm).
/datum/wound/proc/rogue_artery_rate()
	if(severity < WOUND_SEVERITY_CRITICAL)
		return 0
	switch(rogue_artery)
		if(ROGUE_ARTERY_THROAT)
			return ROGUE_ARTERY_BLEED_NECK
		if(ROGUE_ARTERY_HEART)
			return ROGUE_ARTERY_BLEED_CHEST
	return ROGUE_ARTERY_BLEED

/// What TG's refresh_bleed_rate() makes of a limb's bleeding: lying slows it, a grasp and a tourniquet stem it.
/obj/item/bodypart/proc/rogue_bleed_factor()
	. = 1
	if(owner?.body_position == LYING_DOWN)
		. *= 0.75
	if(grasped_by)
		. *= 0.7
	if(LAZYACCESS(applied_items, LIMB_ITEM_TOURNIQUET))
		. *= 0.1

/// Ratwood's blood, and with it Ratwood's wounds (TRAIT_ROGUE_WOUNDS: blows open its dynamic wounds instead of TG's rolled ones,
/// combat/wounds.dm); a new bleeding wound soaks through the bandage on its limb, and the leeches on the limbs drink.
/datum/element/rogue_blood

/datum/element/rogue_blood/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_ROGUE_WOUNDS, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(on_handle_blood))
	RegisterSignal(target, COMSIG_CARBON_GAIN_WOUND, PROC_REF(on_gain_wound))
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/element/rogue_blood/Detach(datum/source, ...)
	REMOVE_TRAIT(source, TRAIT_ROGUE_WOUNDS, ELEMENT_TRAIT(type))
	UnregisterSignal(source, list(COMSIG_HUMAN_ON_HANDLE_BLOOD, COMSIG_CARBON_GAIN_WOUND, COMSIG_LIVING_LIFE))
	return ..()

/// Ratwood handle_embedded_objects() -> on_embed_life(): each Life tick, living or dead, the leeches on the limbs drink, or a
/// squeezed cheele gives (combat/leeches.dm).
/datum/element/rogue_blood/proc/on_life(mob/living/carbon/human/source, seconds_per_tick)
	SIGNAL_HANDLER
	for(var/obj/item/bodypart/limb as anything in source.bodyparts)
		for(var/obj/item/natural/worms/leech/leech as anything in limb.rogue_leeches)
			leech.rogue_leech_tick(source, seconds_per_tick / ROGUE_LIFE_TICK)

/datum/element/rogue_blood/proc/on_handle_blood(mob/living/carbon/human/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!CAN_HAVE_BLOOD(source))
		return NONE
	source.rogue_handle_blood(seconds_per_tick)
	return HANDLE_BLOOD_HANDLED

/// Ratwood on_bodypart_gain(): "new bleeding wounds always expire bandages" (combat/medicine.dm rogue_soaks_bandage()).
/datum/element/rogue_blood/proc/on_gain_wound(mob/living/carbon/human/source, datum/wound/wound, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	if(limb?.rogue_bandage && wound.rogue_soaks_bandage())
		limb.rogue_bandage.rogue_soak_through(limb)

/// One Life tick of Ratwood's handle_blood(): the blood comes back, its loss weakens the body, then the body bleeds.
/mob/living/carbon/human/proc/rogue_handle_blood(seconds_per_tick)
	var/ticks = seconds_per_tick / ROGUE_LIFE_TICK
	var/changed = FALSE
	var/volume = get_blood_volume()
	if(volume > 0 && volume < BLOOD_VOLUME_NORMAL)
		changed = !!adjust_blood_volume(ROGUE_BLOOD_REGEN * ticks, maximum = BLOOD_VOLUME_NORMAL)
	if(stat != DEAD)
		rogue_blood_loss_effects(ticks)
	var/rate = rogue_bleed_rate(ticks)
	var/amount = rate > 0 ? rogue_bleed_amount(rate * seconds_per_tick) : 0
	if(amount > 0)
		bleed(amount)
		changed = TRUE
		bleed_warn(rate)
		rogue_bleed_sound(amount / ticks)
		if(volume > 0 && get_blood_volume() <= 0)
			to_chat(src, span_userdanger("The last of my lyfeblood ebbs from my ravaged body and soaks the cold earth below..."))
	// TG's handle_blood() lets the bleeding stacks of the limbs run out; it does not run now. A bandage soaked in medicine heals
	// the limb it binds (combat/medicine.dm).
	for(var/obj/item/bodypart/bodypart as anything in get_bodyparts())
		if(bodypart.generic_bleedstacks)
			bodypart.adjustBleedStacks(-1, 0)
		bodypart.rogue_bandage?.rogue_medicine_tick(bodypart, ticks)
	if(changed)
		update_health_hud()

/// Blood per second, limb by limb (rogue_limb_bleed_rate()). With ticks the bandages soak up this tick's blood (Ratwood
/// process_bandage()); without, they are only looked at.
/mob/living/carbon/human/proc/rogue_bleed_rate(ticks = 0)
	. = 0
	if(HAS_TRAIT(src, TRAIT_GODMODE) || !can_bleed())
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. += limb.rogue_limb_bleed_rate(ticks)
	. *= GET_PHYSIOLOGY(src, PHYS_COEFF_BLEED)

/// Ratwood's get_bleed_rate() of a limb, a second's: TG's count of the limb (wounds, Ratwood's dynamic wounds, stumps, what is
/// lodged in it), opened arteries at Ratwood's rate, less what the stitches hold back (combat/medicine.dm), and under a bandage
/// its share.
/obj/item/bodypart/proc/rogue_limb_bleed_rate(ticks = 0)
	var/rate = cached_bleed_rate
	if(LAZYLEN(wounds))
		var/factor = rogue_bleed_factor()
		for(var/datum/wound/wound as anything in wounds)
			rate += wound.rogue_bleed_delta() * factor
	rate = max(rate, 0)
	if(rate && rogue_bandage)
		rate = rogue_bandaged_rate(rate, ticks)
	return rate

/// What Ratwood's counting changes in TG's for this wound: an opened artery bleeds harder, stitches hold blood back.
/datum/wound/proc/rogue_bleed_delta()
	var/extra = max(rogue_artery_bleed() - blood_flow, 0)
	return extra - min(rogue_stitched, blood_flow + extra)

/// Ratwood's bleed(): constitution slows or quickens the bleeding of a body with a mind, as thick blood, critical
/// resistance and weakness do; one who yields bleeds a quarter, and adrenaline stops it.
/mob/living/carbon/human/proc/rogue_bleed_amount(amount)
	if(HAS_TRAIT(src, TRAIT_ADRENALINE_RUSH))
		return 0
	if(mind)
		var/constitution = min(rogue_stat(ROGUE_STAT_CONSTITUTION), ROGUE_BLEED_CON_CAP)
		amount -= amount * (constitution - ROGUE_BLEED_CON_BASE) * ROGUE_BLEED_CON_SHARE
		if(HAS_TRAIT(src, TRAIT_BLOOD_RESISTANCE))
			amount *= ROGUE_BLEED_THICK_BLOOD
		else if(HAS_TRAIT(src, TRAIT_CRITICAL_RESISTANCE))
			amount *= ROGUE_BLEED_CRIT_RESISTANCE
		if(HAS_TRAIT(src, TRAIT_CRITICAL_WEAKNESS))
			amount *= ROGUE_BLEED_CRIT_WEAKNESS
	if(rogue_yielding)
		amount *= ROGUE_BLEED_YIELD
	return max(amount, 0)

/// The bleeding heard, by the blood a Life tick loses (Ratwood bleed (1)-(3).ogg); not from one lying down.
/mob/living/carbon/human/proc/rogue_bleed_sound(per_tick)
	if(body_position == LYING_DOWN)
		return
	var/sound
	if(per_tick > ROGUE_BLEED_SOUND_HIGH)
		sound = 'modular_redtard/rockhill/sound/misc/bleed (3).ogg'
	else if(per_tick > ROGUE_BLEED_SOUND_MID)
		sound = 'modular_redtard/rockhill/sound/misc/bleed (2).ogg'
	else if(per_tick > ROGUE_BLEED_SOUND_LOW)
		sound = 'modular_redtard/rockhill/sound/misc/bleed (1).ogg'
	if(sound)
		playsound(src, sound, 100, FALSE)

/// Ratwood's effects of blood loss: dizzy, faint and drained, each weaker and slower; a drained body may black out and
/// chokes, the more so near the bottom; above the bad level the choking heals.
/mob/living/carbon/human/proc/rogue_blood_loss_effects(ticks)
	if(HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
		rogue_set_bleed_tier(0)
		return
	var/volume = get_blood_volume()
	var/tier = 0
	if(volume < ROGUE_BLOOD_BAD)
		tier = 3
	else if(volume < ROGUE_BLOOD_OKAY)
		tier = 2
	else if(volume < ROGUE_BLOOD_SAFE)
		tier = 1
	rogue_set_bleed_tier(tier)
	if(tier && prob(ROGUE_BLEED_SIGN_CHANCE * ticks))
		if(tier == 1)
			to_chat(src, span_warning("I feel dizzy."))
		else
			set_eye_blur_if_lower(ROGUE_BLEED_BLUR)
			to_chat(src, span_warning("I feel faint."))
	if(tier == 3 && !IsUnconscious() && prob(ROGUE_BLEED_SIGN_CHANCE * ticks))
		Unconscious(rand(ROGUE_BLEED_FAINT_MIN, ROGUE_BLEED_FAINT_MAX))
		to_chat(src, span_warning("I feel drained."))
	if(volume <= ROGUE_BLOOD_BAD)
		adjust_oxy_loss((volume <= ROGUE_BLOOD_SURVIVE ? ROGUE_BLEED_OXY_SURVIVE : ROGUE_BLEED_OXY_BAD) * ticks)
	else if(get_oxy_loss())
		adjust_oxy_loss(-ROGUE_BLEED_OXY_HEAL * ticks)

/// Puts on the debuff of the step and takes off the others, only when the step changes (as Ratwood's bleeding_tier).
/mob/living/carbon/human/proc/rogue_set_bleed_tier(tier)
	if(tier == rogue_bleed_tier)
		return
	rogue_bleed_tier = tier
	var/static/list/steps = list(/datum/status_effect/rogue_bleeding, /datum/status_effect/rogue_bleeding/faint, /datum/status_effect/rogue_bleeding/drained)
	for(var/index in 1 to length(steps))
		if(index == tier)
			apply_status_effect(steps[index])
		else
			remove_status_effect(steps[index])

/// Ratwood's bleeding debuffs (debuff/bleeding, bleedingworse, bleedingworst), with their alerts.
/datum/status_effect/rogue_bleeding
	id = "rogue_bleeding_dizzy"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/rogue_bleeding

/// The stat changes of the step (Ratwood effectedstats).
/datum/status_effect/rogue_bleeding/proc/rogue_stats()
	return list(ROGUE_STAT_SPEED = ROGUE_BLEED_DIZZY_SPEED)

/datum/status_effect/rogue_bleeding/on_apply()
	owner.attributes?.set_variable_attribute_modifier(id, rogue_stats())
	return TRUE

/datum/status_effect/rogue_bleeding/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	return ..()

/datum/status_effect/rogue_bleeding/faint
	id = "rogue_bleeding_faint"
	alert_type = /atom/movable/screen/alert/status_effect/rogue_bleeding/faint

/datum/status_effect/rogue_bleeding/faint/rogue_stats()
	return list(ROGUE_STAT_STRENGTH = ROGUE_BLEED_FAINT_STRENGTH, ROGUE_STAT_SPEED = ROGUE_BLEED_FAINT_SPEED)

/datum/status_effect/rogue_bleeding/drained
	id = "rogue_bleeding_drained"
	alert_type = /atom/movable/screen/alert/status_effect/rogue_bleeding/drained

/datum/status_effect/rogue_bleeding/drained/rogue_stats()
	return list(ROGUE_STAT_STRENGTH = ROGUE_BLEED_DRAINED_STRENGTH, ROGUE_STAT_SPEED = ROGUE_BLEED_DRAINED_SPEED)

/atom/movable/screen/alert/status_effect/rogue_bleeding
	name = "Dizzy"
	desc = "I have lost some blood. My steps are slower."
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "bleed1"

/atom/movable/screen/alert/status_effect/rogue_bleeding/faint
	name = "Faint"
	desc = "I have lost much blood. I am weaker and slower."
	icon_state = "bleed2"

/atom/movable/screen/alert/status_effect/rogue_bleeding/drained
	name = "Drained"
	desc = "Too much of my blood is gone. I can hardly stand, and my breath fails me."
	icon_state = "bleed3"

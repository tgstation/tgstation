/datum/status_effect/irradiated
	id = "mob_irradiated"
	alert_type = /atom/movable/screen/alert/status_effect/irradiated
	tick_interval = 1 SECONDS
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN|HEAL_TOX|HEAL_NEGATIVE_MUTATIONS|HEAL_STATUS
	/// World time that the effect was applied
	VAR_PRIVATE/beginning_of_irradiation
	/// Whether the radiation can propagate to nearby entities
	VAR_PRIVATE/can_propogate = FALSE
	/// Cooldown for radiation propagation to nearby entities
	COOLDOWN_DECLARE(propogation_cooldown)
	/// Cooldown for healing from cleaning effects
	COOLDOWN_DECLARE(clean_cooldown)
	/// Cooldown for the last tox damage tick
	COOLDOWN_DECLARE(last_tox_damage)
	/// Cooldown for the last burn damage tick
	COOLDOWN_DECLARE(last_burn)

/datum/status_effect/irradiated/on_creation(mob/living/new_owner, can_propogate)
	src.can_propogate = can_propogate
	return ..()

/datum/status_effect/irradiated/on_apply()
	if(!ishuman(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_RADIMMUNE) || HAS_TRAIT(owner, TRAIT_IRRADIATED))
		return FALSE

	ADD_TRAIT(owner, TRAIT_IRRADIATED, id)
	beginning_of_irradiation = world.time

	owner.rad_glow(can_propogate ? 1.5 : 1.0)
	owner.apply_damage(12, TOX)
	COOLDOWN_START(src, last_tox_damage, 20 SECONDS)
	COOLDOWN_START(src, last_burn, rand(30 SECONDS, 60 SECONDS))

	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(owner, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))
	RegisterSignal(owner, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_RADIMMUNE), PROC_REF(radimmune_gained))
	return TRUE

/datum/status_effect/irradiated/on_remove()
	owner.remove_filter("rad_glow")
	REMOVE_TRAIT(owner, TRAIT_IRRADIATED, id)
	UnregisterSignal(owner, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_GEIGER_COUNTER_SCAN,
		COMSIG_LIVING_HEALTHSCAN,
		SIGNAL_ADDTRAIT(TRAIT_RADIMMUNE),
	))
	return ..()

/datum/status_effect/irradiated/tick(seconds_between_ticks)
	var/radlevel = owner.get_tox_loss()
	if(radlevel <= 0)
		qdel(src)
		return

	if(!COOLDOWN_FINISHED(src, clean_cooldown))
		return

	if(can_propogate && COOLDOWN_FINISHED(src, propogation_cooldown) && isturf(owner.loc))
		radiation_pulse(owner, 2, radlevel >= 50 ? RAD_MEDIUM_INSULATION : RAD_LIGHT_INSULATION)
		COOLDOWN_START(src, propogation_cooldown, 10 SECONDS)

	if(HAS_TRAIT(owner, TRAIT_STASIS) || HAS_TRAIT(owner, TRAIT_NO_RADIATION_EFFECTS))
		return

	var/radtime = world.time - beginning_of_irradiation
	if(owner.stat != DEAD)
		random_effects(radtime, seconds_between_ticks)

	if(COOLDOWN_FINISHED(src, last_tox_damage))
		tox_effects(radtime, seconds_between_ticks)
		COOLDOWN_START(src, last_tox_damage, 10 SECONDS)

	if(COOLDOWN_FINISHED(src, last_burn))
		burn_effects(radtime, seconds_between_ticks)
		COOLDOWN_START(src, last_burn, rand(30 SECONDS, 60 SECONDS))

/datum/status_effect/irradiated/proc/tox_effects(time_since_irradiated, seconds_per_tick)
	owner.apply_damage(1, TOX)

	if(!SPT_PROB(20 * (time_since_irradiated / (10 MINUTES)), seconds_per_tick))
		return

	var/mob/living/carbon/human/human_owner = owner
	for(var/obj/item/organ/organ as anything in shuffle(human_owner.organs))
		if(organ.organ_flags & ORGAN_VITAL)
			continue
		if(IS_ROBOTIC(organ))
			continue
		if(HAS_TRAIT(organ, TRAIT_IRRADIATED))
			continue
		organ.make_irradiated()
		break

/datum/status_effect/irradiated/proc/burn_effects(time_since_irradiated, seconds_per_tick)
	var/obj/item/bodypart/affected_limb = owner.get_bodypart(owner.get_random_valid_zone())
	owner.visible_message(
		span_boldwarning("[owner]'s [affected_limb.plaintext_zone] bubbles unnaturally, then bursts into blisters!"),
		span_boldwarning("Your [affected_limb.plaintext_zone] bubbles unnaturally, then bursts into blisters!"),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)

	owner.apply_damage(12, BURN, affected_limb, wound_clothing = FALSE)
	playsound(owner, SFX_SIZZLE, 50, vary = TRUE)

/datum/status_effect/irradiated/proc/random_effects(time_since_irradiated, seconds_per_tick)
	if(time_since_irradiated > 2 MINUTES && SPT_PROB(0.5, seconds_per_tick))
		if(!owner.IsParalyzed())
			owner.emote("collapse")
		owner.Paralyze(0.3 SECONDS)
		to_chat(owner, span_danger("You feel weak."))

	if(time_since_irradiated > 2 MINUTES && SPT_PROB(0.5, seconds_per_tick))
		var/mob/living/carbon/get_sick = owner
		get_sick.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 10)

	if(time_since_irradiated > 2 MINUTES && SPT_PROB(0.5, seconds_per_tick) && owner.can_mutate())
		var/mob/living/carbon/get_mutated = owner
		to_chat(owner, span_danger("You mutate!"))
		get_mutated.easy_random_mutate(NEGATIVE | MINOR_NEGATIVE)
		get_mutated.emote("gasp")
		get_mutated.domutcheck()

	if(time_since_irradiated > 1 MINUTES && SPT_PROB(7.5, seconds_per_tick))
		var/obj/item/bodypart/head/head = owner.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head) && head.hairstyle != "Bald" && (head.head_flags & (HEAD_HAIR|HEAD_FACIAL_HAIR)))
			to_chat(owner, span_danger("Your hair starts to fall out in clumps..."))
			addtimer(CALLBACK(src, PROC_REF(go_bald)), 5 SECONDS, TIMER_DELETE_ME)

/datum/status_effect/irradiated/proc/go_bald()
	owner.set_facial_hairstyle("Shaved", update = FALSE)
	owner.set_hairstyle("Bald", update = FALSE)
	owner.update_hair()

/datum/status_effect/irradiated/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_RADIATION))
		return NONE

	COOLDOWN_START(src, clean_cooldown, (SSMACHINES_DT + (1 SECONDS)))
	owner.adjust_tox_loss(-0.5, forced = TRUE)
	if(owner.get_tox_loss() <= 0)
		qdel(src)
	return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/datum/status_effect/irradiated/proc/on_geiger_counter_scan(datum/source, mob/user, obj/item/geiger_counter/geiger_counter)
	SIGNAL_HANDLER

	var/small_icon = icon2html(geiger_counter, user)
	to_chat(user, span_bolddanger("[small_icon] Subject is irradiated: \
		Contamination traces back to roughly [DisplayTimeText(world.time - beginning_of_irradiation, 5)] ago"))
	to_chat(user, span_bolddanger("[small_icon] Radiation levels: [owner.get_tox_loss()]"))
	if(can_propogate)
		to_chat(user, span_bolddanger("[small_icon] Danger: Radiation levels high, subject may contaminate others."))

	return COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL

/datum/status_effect/irradiated/proc/on_healthscan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	if(HAS_TRAIT(owner, TRAIT_UNBOTHERED_BY_RADIATION))
		return

	render_list += "<span class='alert ml-1'>"
	render_list += conditional_tooltip("Subject is irradiated.", "Supply antiradiation or antitoxin, such as [/datum/reagent/medicine/potass_iodide::name] or [/datum/reagent/medicine/pen_acid::name].", tochat)
	render_list += "</span><br>"

/datum/status_effect/irradiated/proc/radimmune_gained(...)
	SIGNAL_HANDLER

	qdel(src)

/atom/movable/screen/alert/status_effect/irradiated
	name = "Irradiated"
	desc = "You're irradiated! Heal your toxins quick, and stand under a shower to halt the incoming damage."
	icon_state = ALERT_IRRADIATED

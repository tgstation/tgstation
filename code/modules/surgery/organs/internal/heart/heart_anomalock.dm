/*!
 * Contains Voltaic Combat Cyberheart
 */
#define DOAFTER_IMPLANTING_HEART "implanting"

/obj/item/organ/internal/heart/cybernetic/anomalock
	name = "voltaic combat cyberheart"
	desc = "A cutting-edge cyberheart, originally designed for Nanotrasen killsquad usage but later declassified for normal research. Voltaic technology allows the heart to keep the body upright in dire circumstances, alongside redirecting anomalous flux energy to fully shield the user from shocks and electro-magnetic pulses. Requires a refined Flux core as a power source."
	icon_state = "anomalock_heart"
	bleed_prevention = TRUE
	toxification_probability = 0

	COOLDOWN_DECLARE(survival_cooldown)
	///Cooldown for the activation of the organ
	var/survival_cooldown_time = 5 MINUTES
	///The lightning effect on our mob when the implant is active
	var/mutable_appearance/lightning_overlay
	///how long the lightning lasts
	var/lightning_timer

	//---- Anomaly core variables:
	///The core item the organ runs off.
	var/obj/item/assembly/signaler/anomaly/core
	///Accepted types of anomaly cores.
	var/required_anomaly = /obj/item/assembly/signaler/anomaly/flux
	///If this one starts with a core in.
	var/prebuilt = FALSE
	///If the core is removable once socketed.
	var/core_removable = TRUE

/obj/item/organ/internal/heart/cybernetic/anomalock/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!core)
		return
	add_lightning_overlay(30 SECONDS)
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)
	organ_owner.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	organ_owner.apply_status_effect(/datum/status_effect/stabilized/yellow, src)
	RegisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), PROC_REF(activate_survival))
	RegisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

/obj/item/organ/internal/heart/cybernetic/anomalock/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!core)
		return
	UnregisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION))
	organ_owner.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	organ_owner.remove_status_effect(/datum/status_effect/stabilized/yellow)
	tesla_zap(source = organ_owner, zap_range = 20, power = 2.5e5, cutoff = 1e3)
	qdel(src)

/obj/item/organ/internal/heart/cybernetic/anomalock/attack(mob/living/target_mob, mob/living/user, params)
	if(target_mob != user || !istype(target_mob) || !core)
		return ..()

	if(DOING_INTERACTION(user, DOAFTER_IMPLANTING_HEART))
		return
	user.balloon_alert(user, "this will hurt...")
	to_chat(user, span_userdanger("Black cyberveins tear your skin apart, pulling the heart into your ribcage. This feels unwise.."))
	if(!do_after(user, 5 SECONDS, interaction_key = DOAFTER_IMPLANTING_HEART))
		return ..()
	playsound(target_mob, 'sound/items/weapons/slice.ogg', 100, TRUE)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)
	user.apply_damage(100, BRUTE, BODY_ZONE_CHEST)
	user.emote("scream")
	return TRUE

/obj/item/organ/internal/heart/cybernetic/anomalock/proc/on_emp_act(severity)
	SIGNAL_HANDLER
	add_lightning_overlay(10 SECONDS)

/obj/item/organ/internal/heart/cybernetic/anomalock/proc/add_lightning_overlay(time_to_last = 10 SECONDS)
	if(lightning_overlay)
		lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay)), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE))
		return
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	owner.add_overlay(lightning_overlay)
	lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay)), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE))

/obj/item/organ/internal/heart/cybernetic/anomalock/proc/clear_lightning_overlay()
	owner.cut_overlay(lightning_overlay)
	lightning_overlay = null

/obj/item/organ/internal/heart/cybernetic/anomalock/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(core)
		return attack(user, user, modifiers)

/obj/item/organ/internal/heart/cybernetic/anomalock/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.blood_volume <= BLOOD_VOLUME_NORMAL)
		owner.blood_volume += 5 * seconds_per_tick
	if(owner.health <= owner.crit_threshold)
		activate_survival(owner)

///Does a few things to try to help you live whatever you may be going through
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/activate_survival(mob/living/carbon/organ_owner)
	if(!COOLDOWN_FINISHED(src, survival_cooldown))
		return

	organ_owner.apply_status_effect(/datum/status_effect/voltaic_overdrive)
	add_lightning_overlay(30 SECONDS)
	COOLDOWN_START(src, survival_cooldown, survival_cooldown_time)
	addtimer(CALLBACK(src, PROC_REF(notify_cooldown), organ_owner), COOLDOWN_TIMELEFT(src, survival_cooldown))

///Alerts our owner that the organ is ready to do its thing again
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/notify_cooldown(mob/living/carbon/organ_owner)
	balloon_alert(organ_owner, "your heart strenghtens")
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)

///Returns the mob we are implanted in so that the electricity effect doesn't runtime
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/get_held_mob()
	return owner

/obj/item/organ/internal/heart/cybernetic/anomalock/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, required_anomaly))
		return NONE
	if(core)
		balloon_alert(user, "core already in!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	core = tool
	balloon_alert(user, "core installed")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	add_organ_trait(TRAIT_SHOCKIMMUNE)
	update_icon_state()
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/internal/heart/cybernetic/anomalock/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "no core!")
		return
	if(!core_removable)
		balloon_alert(user, "can't remove core!")
		return
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	balloon_alert(user, "core removed")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	remove_organ_trait(TRAIT_SHOCKIMMUNE)
	update_icon_state()

/obj/item/organ/internal/heart/cybernetic/anomalock/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (core ? "-core" : "")

/obj/item/organ/internal/heart/cybernetic/anomalock/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux(src)
	update_icon_state()

/datum/status_effect/voltaic_overdrive
	id = "voltaic_overdrive"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/anomalock_active
	show_duration = TRUE

/datum/status_effect/voltaic_overdrive/tick(seconds_between_ticks)
	. = ..()

	if(owner.health <= owner.crit_threshold)
		owner.heal_overall_damage(5, 5)
		owner.adjustOxyLoss(-5)
		owner.adjustToxLoss(-5)

/datum/status_effect/voltaic_overdrive/on_apply()
	. = ..()
	owner.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
	owner.reagents.add_reagent(/datum/reagent/medicine/coagulant, 5)
	owner.add_filter("emp_shield", 2, outline_filter(1, "#639BFF"))
	to_chat(owner, span_revendanger("You feel a burst of energy! It's do or die!"))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.gain_trauma(/datum/brain_trauma/special/tenacity, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/status_effect/voltaic_overdrive/on_remove()
	. = ..()
	owner.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	owner.remove_filter("emp_shield")
	owner.balloon_alert(owner, "your heart weakens")
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.cure_trauma_type(/datum/brain_trauma/special/tenacity, TRAUMA_RESILIENCE_ABSOLUTE)


/atom/movable/screen/alert/status_effect/anomalock_active
	name = "voltaic overdrive"
	icon_state = "anomalock_heart"
	desc = "Voltaic energy is flooding your muscles, keeping your body upright. You have 30 seconds before it falters!"

#undef DOAFTER_IMPLANTING_HEART

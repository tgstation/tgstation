/*!
 * Contains Voltaic Combat Cyberheart
 */
#define DOAFTER_IMPLANTING_HEART "implanting"

/obj/item/organ/heart/cybernetic/anomalock
	name = "voltaic combat cyberheart"
	desc = "A cutting-edge cyberheart, originally designed for Nanotrasen killsquad usage but later declassified for normal research. \
		Voltaic technology allows the heart to keep the body upright in dire circumstances, \
		alongside redirecting anomalous flux energy to fully shield the user from shocks and the heart from electro-magnetic pulses. \
		Requires a refined Flux core as a power source."
	icon_state = "anomalock_heart"
	beat_noise = "an astonishing <b>BZZZ</b> of immense electrical power"
	bleed_prevention = TRUE
	toxification_probability = 0

	COOLDOWN_DECLARE(survival_cooldown)
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5, /datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
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
	///If the core is removable once socketed.
	var/core_removable = TRUE

/obj/item/organ/heart/cybernetic/anomalock/Destroy()
	deltimer(lightning_timer)
	lightning_overlay = null
	QDEL_NULL(core)
	return ..()

/obj/item/organ/heart/cybernetic/anomalock/examine(mob/user)
	. = ..()
	. += span_info("The voltaic boost will avoid healing toxin damage at all in slime-based humanoids, to prevent harmful side effects.")

/obj/item/organ/heart/cybernetic/anomalock/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!core)
		return
	add_lightning_overlay(30 SECONDS)
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)
	RegisterSignal(organ_owner, COMSIG_MOB_STATCHANGE, PROC_REF(activate_survival_comsig))

/obj/item/organ/heart/cybernetic/anomalock/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!core)
		return
	clear_lightning_overlay(organ_owner)
	UnregisterSignal(organ_owner, COMSIG_MOB_STATCHANGE)
	tesla_zap(source = organ_owner, zap_range = 20, power = 2.5e5, cutoff = 1e3)
	apply_organ_damage(INFINITY)

/obj/item/organ/heart/cybernetic/anomalock/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with != user || !iscarbon(user) || isnull(core))
		return NONE

	return self_implant(user)

/obj/item/organ/heart/cybernetic/anomalock/proc/self_implant(mob/living/carbon/user)
	if(DOING_INTERACTION(user, DOAFTER_IMPLANTING_HEART))
		return ITEM_INTERACT_BLOCKING
	user.balloon_alert(user, "this will hurt...")
	to_chat(user, span_userdanger("Black cyberveins tear your skin apart, pulling the heart into your ribcage. This feels unwise.."))
	if(!do_after(user, 5 SECONDS, interaction_key = DOAFTER_IMPLANTING_HEART))
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(src))
		return ITEM_INTERACT_BLOCKING
	if(!Insert(user))
		forceMove(user.drop_location())
		return ITEM_INTERACT_BLOCKING

	playsound(user, 'sound/items/weapons/slice.ogg', 100, TRUE)
	user.apply_damage(100, BRUTE, BODY_ZONE_CHEST)
	user.emote("scream")
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/heart/cybernetic/anomalock/proc/add_lightning_overlay(time_to_last = 10 SECONDS)
	if(lightning_overlay)
		lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay), owner), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME))
		return
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	owner.add_overlay(lightning_overlay)
	lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay), owner), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME))

/obj/item/organ/heart/cybernetic/anomalock/proc/clear_lightning_overlay(mob/organ_owner)
	organ_owner?.cut_overlay(lightning_overlay)
	deltimer(lightning_timer)
	lightning_overlay = null

/obj/item/organ/heart/cybernetic/anomalock/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(!isnull(core) && (self_implant(user) & ITEM_INTERACT_ANY_BLOCKER))
		return TRUE

/obj/item/organ/heart/cybernetic/anomalock/on_life(seconds_per_tick)
	. = ..()
	if(!core)
		return

	if(owner.health <= owner.crit_threshold)
		activate_survival(owner)

	if(SSmobs.times_fired % (1 SECONDS))
		return

	var/list/batteries = list()
	for(var/obj/item/stock_parts/power_store/cell in assoc_to_values(owner.get_all_cells()))
		if(cell.used_charge())
			batteries += cell

	if(!length(batteries))
		return

	var/obj/item/stock_parts/power_store/cell = pick(batteries)
	cell.give(cell.max_charge() * 0.1)

/obj/item/organ/heart/cybernetic/anomalock/proc/activate_survival_comsig(mob/living/carbon/organ_owner, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat == SOFT_CRIT || new_stat == HARD_CRIT)
		activate_survival(organ_owner)

/// Does a few things to try to help you live whatever you may be going through. Returns TRUE if it activated successfully.
/obj/item/organ/heart/cybernetic/anomalock/proc/activate_survival(mob/living/carbon/organ_owner)
	if(!COOLDOWN_FINISHED(src, survival_cooldown))
		return FALSE

	organ_owner.apply_status_effect(/datum/status_effect/voltaic_overdrive)
	add_lightning_overlay(30 SECONDS)
	COOLDOWN_START(src, survival_cooldown, survival_cooldown_time)
	addtimer(CALLBACK(src, PROC_REF(notify_cooldown), organ_owner), COOLDOWN_TIMELEFT(src, survival_cooldown))
	return TRUE

///Alerts our owner that the organ is ready to do its thing again
/obj/item/organ/heart/cybernetic/anomalock/proc/notify_cooldown(mob/living/carbon/organ_owner)
	balloon_alert(organ_owner, "your heart strengthtens")
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)

/obj/item/organ/heart/cybernetic/anomalock/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, required_anomaly))
		return NONE
	if(!isnull(core))
		balloon_alert(user, "core already in!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "core installed")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/heart/cybernetic/anomalock/screwdriver_act(mob/living/user, obj/item/tool)
	if(isnull(core))
		balloon_alert(user, "no core!")
		return ITEM_INTERACT_BLOCKING
	if((organ_flags & ORGAN_FAILING) || !core_removable)
		balloon_alert(user, "can't remove core!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "core removed")
	user.put_in_hands(core)
	return ITEM_INTERACT_SUCCESS

/obj/item/organ/heart/cybernetic/anomalock/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == core)
		core = null
		blood_regeneration_multiplier = initial(blood_regeneration_multiplier)
		remove_organ_trait(TRAIT_SHOCKIMMUNE)
		update_appearance(UPDATE_ICON_STATE)
		RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/item/organ/heart/cybernetic/anomalock/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/assembly/signaler/anomaly) && isnull(core))
		core = arrived
		blood_regeneration_multiplier = 21
		add_organ_trait(TRAIT_SHOCKIMMUNE)
		update_appearance(UPDATE_ICON_STATE)
		AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/item/organ/heart/cybernetic/anomalock/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (core ? "-core" : "")

/obj/item/organ/heart/cybernetic/anomalock/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux()
	core.forceMove(src)

/datum/status_effect/voltaic_overdrive
	id = "voltaic_overdrive"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/anomalock_active
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY

/datum/status_effect/voltaic_overdrive/tick(seconds_between_ticks)
	. = ..()
	if(owner.health > owner.crit_threshold)
		return
	var/needs_update = FALSE
	needs_update += owner.heal_overall_damage(brute = 5, burn = 5, updating_health = FALSE)
	needs_update += owner.adjust_oxy_loss(-5, updating_health = FALSE)
	if(!HAS_TRAIT(owner, TRAIT_TOXINLOVER))
		needs_update += owner.adjust_tox_loss(-5, updating_health = FALSE)
	if(needs_update)
		owner.updatehealth()

/datum/status_effect/voltaic_overdrive/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_lost))
	owner.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	owner.reagents.add_reagent(/datum/reagent/medicine/coagulant, 5)
	owner.add_filter("emp_shield", 2, outline_filter(1, "#639BFF"))
	to_chat(owner, span_revendanger("You feel a burst of energy! It's do or die!"))
	owner.add_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), TRAIT_STATUS_EFFECT(id))

/datum/status_effect/voltaic_overdrive/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	owner.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	owner.remove_filter("emp_shield")
	owner.balloon_alert(owner, "your heart weakens")
	owner.remove_traits(list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_ANALGESIA), TRAIT_STATUS_EFFECT(id))

/// Called when an organ is lost in the owner. In the event the owner just lost their voltaic (presumably, the one giving this effect), ends the buff and clears the overlay.
/datum/status_effect/voltaic_overdrive/proc/on_organ_lost(mob/living/carbon/source, obj/item/organ/organ, special)
	SIGNAL_HANDLER
	if(istype(organ, /obj/item/organ/heart/cybernetic/anomalock))
		qdel(src)

/atom/movable/screen/alert/status_effect/anomalock_active
	name = "voltaic overdrive"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "anomalock_heart"
	desc = "Voltaic energy is flooding your muscles, keeping your body upright. You have 30 seconds before it falters!"

/obj/item/organ/heart/cybernetic/anomalock/hear_beat_noise(mob/living/hearer)
	if(prob(1))
		to_chat(hearer, span_danger("Yeah. Press a metal disk to the chest of a living arc flash hazard. See what that gets you.")) //the guy is LITERALLY sparking like a tesla coil.
	else
		to_chat(hearer, span_danger("An electrical arc strikes your stethoscope, conducting into you!"))
	if(hearer.electrocute_act(15, "stethoscope", flags = SHOCK_NOGLOVES)) //the stethoscope is in your ears. (returns true if it does damage so we only scream in that case)
		hearer.emote("scream")
	return span_danger("[owner.p_Their()] heart produces [beat_noise].")

#undef DOAFTER_IMPLANTING_HEART

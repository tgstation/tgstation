/obj/item/organ/internal/heart/cybernetic/anomalock
	name = "voltaic combat cyberheart"
	desc = "A cutting-edge cyberheart, originally designed for Nanotrasen killsquad usage but later declassified for normal research. Voltaic technology allows the heart to keep the body upright in dire circumstances, alongside redirecting anomalous flux energy to fully shield the user from shocks and electro-magnetic pulses. Requires a refined Flux core as a power source."
	icon_state = "anomalock_heart"
	///Cooldown for the activation of the organ
	var/survival_cooldown = 5 MINUTES
	///Stores current time of when the organ was last activated
	var/last_activation = -5 MINUTES //We should be off cooldown even if world.time is 0
	///Maximum amount of time the organ will remain "active"
	var/active_duration = 30 SECONDS
	///If our organ is currently active
	var/active = FALSE
	///The lightning effect on our mob when the implant is active
	var/mutable_appearance/lightning_overlay

	//---- Anomaly core variables:
	///The core item the organ runs off.
	var/obj/item/assembly/signaler/anomaly/core
	///Accepted types of anomaly cores.
	var/list/accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/flux)
	///If this one starts with a core in.
	var/prebuilt = FALSE
	///If the core is removable once socketed.
	var/core_removable = TRUE

/obj/item/organ/internal/heart/cybernetic/anomalock/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(!core)
		return
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	organ_owner.add_overlay(lightning_overlay)
	addtimer(CALLBACK(organ_owner, TYPE_PROC_REF(/atom, cut_overlay), lightning_overlay), 3 SECONDS)
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)
	ADD_TRAIT(organ_owner, TRAIT_SHOCKIMMUNE, REF(src))
	organ_owner.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	organ_owner.apply_status_effect(/datum/status_effect/stabilized/yellow, src)
	RegisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), PROC_REF(activate_survival))
	RegisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))

/obj/item/organ/internal/heart/cybernetic/anomalock/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!core)
		return
	UnregisterSignal(organ_owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION))
	REMOVE_TRAIT(organ_owner, TRAIT_SHOCKIMMUNE, REF(src))
	organ_owner.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	organ_owner.remove_status_effect(/datum/status_effect/stabilized/yellow)
	tesla_zap(source = organ_owner, zap_range = 20, power = 2.5e5, cutoff = 1e3)
	qdel(src)

/obj/item/organ/internal/heart/cybernetic/anomalock/attack(mob/living/target_mob, mob/living/user, params)
	if(target_mob == user && istype(target_mob) && core)
		if(DOING_INTERACTION(user, "implanting"))
			return
		user.balloon_alert(user, "this will hurt...")
		to_chat(user, span_userdanger("silver-striped black cyberveins tear your skin apart, pulling the heart into your ribcage. This feels unwise.."))
		if(!do_after(user, 5 SECONDS, interaction_key = "implanting"))
			return ..()
		playsound(target_mob, 'sound/weapons/slice.ogg', 50, TRUE)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		Insert(user)
		user.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
		user.emote("scream")
		return TRUE
	return ..()

/obj/item/organ/internal/heart/cybernetic/anomalock/proc/on_emp_act(severity)
	SIGNAL_HANDLER
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	owner.add_overlay(lightning_overlay)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, cut_overlay), lightning_overlay), 3 SECONDS)

/obj/item/organ/internal/heart/cybernetic/anomalock/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(core)
		return attack(user, user, modifiers)

/obj/item/organ/internal/heart/cybernetic/anomalock/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume += 5 * seconds_per_tick
	if(active && owner.health < owner.crit_threshold)
		owner.heal_overall_damage(5, 5)
		owner.adjustOxyLoss(-5)
		owner.adjustToxLoss(-5)

///Does a few things to try to help you live whatever you may be going through
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/activate_survival(mob/living/carbon/organ_owner)
	if(world.time < last_activation + survival_cooldown)
		return
	last_activation = world.time
	organ_owner.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	organ_owner.gain_trauma(/datum/brain_trauma/special/tenacity)
	REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
	active = TRUE
	organ_owner.reagents.add_reagent(/datum/reagent/medicine/coagulant, 5)
	organ_owner.add_filter("emp_shield", 2, outline_filter(1, "#639BFF"))
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	organ_owner.add_overlay(lightning_overlay)
	to_chat(organ_owner, span_revendanger("You feel a burst of energy! It's do or die!"))
	organ_owner.throw_alert("anomalock heart", /atom/movable/screen/alert/anomalock_active)
	addtimer(CALLBACK(src, PROC_REF(stop_survival), organ_owner), active_duration)

///Stops the positive effects we've gotten from the organ
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/stop_survival(mob/living/carbon/organ_owner)
	organ_owner.cure_trauma_type(/datum/brain_trauma/special/tenacity)
	organ_owner.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
	active = FALSE
	organ_owner.remove_filter("emp_shield")
	organ_owner.cut_overlay(lightning_overlay)
	balloon_alert(organ_owner, "your heart weakens")
	organ_owner.clear_alert("anomalock heart")
	addtimer(CALLBACK(src, PROC_REF(notify_cooldown), organ_owner), last_activation + survival_cooldown)

///Alerts our owner that the organ is ready to do its thing again
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/notify_cooldown(mob/living/carbon/organ_owner)
	balloon_alert(organ_owner, "your heart strenghtens")
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)

///Returns the mob we are implanted in so that the electricity effect doesn't runtime
/obj/item/organ/internal/heart/cybernetic/anomalock/proc/get_held_mob()
	return owner

/obj/item/organ/internal/heart/cybernetic/anomalock/attackby(obj/item/item, mob/living/user, params)
	if(item.type in accepted_anomalies)
		if(core)
			balloon_alert(user, "core already in!")
			return
		if(!user.transferItemToLoc(item, src))
			return
		core = item
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_icon_state()
	else
		return ..()

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
	update_icon_state()

/obj/item/organ/internal/heart/cybernetic/anomalock/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (core ? "-core" : "")

/obj/item/organ/internal/heart/cybernetic/anomalock/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/flux(src)
	update_icon_state()

/atom/movable/screen/alert/anomalock_active
	name = "voltaic cyberheart energy"
	icon_state = "anomalock_heart"
	desc = "Voltaic energy is flooding your muscles, keeping your body upright. You have 30 seconds before it falters!"

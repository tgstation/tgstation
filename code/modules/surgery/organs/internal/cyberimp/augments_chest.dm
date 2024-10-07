/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "Implants for the organs in your torso."
	zone = BODY_ZONE_CHEST

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "nutriment pump implant"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "nutriment_implant"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = ORGAN_SLOT_STOMACH_AID

/obj/item/organ/internal/cyberimp/chest/nutriment/on_life(seconds_per_tick, times_fired)
	if(synthesizing)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, span_notice("You feel less hungry..."))
		owner.adjust_nutrition(25 * seconds_per_tick)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 5 SECONDS)

/obj/item/organ/internal/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.reagents.add_reagent(/datum/reagent/toxin/bad_food, poison_amount / severity)
	to_chat(owner, span_warning("You feel like your insides are burning."))


/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "adv_nutriment_implant"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "reviver_implant"
	slot = ORGAN_SLOT_HEART_AID
	var/revive_cost = 0
	var/reviving = FALSE
	COOLDOWN_DECLARE(reviver_cooldown)
	COOLDOWN_DECLARE(defib_cooldown)

/obj/item/organ/internal/cyberimp/chest/reviver/on_death(seconds_per_tick, times_fired)
	if(isnull(owner)) // owner can be null, on_death() gets called by /obj/item/organ/internal/process() for decay
		return
	try_heal() // Allows implant to work even on dead people

/obj/item/organ/internal/cyberimp/chest/reviver/on_life(seconds_per_tick, times_fired)
	try_heal()

/obj/item/organ/internal/cyberimp/chest/reviver/proc/try_heal()
	if(reviving)
		if(owner.stat == CONSCIOUS)
			COOLDOWN_START(src, reviver_cooldown, revive_cost)
			reviving = FALSE
			to_chat(owner, span_notice("Your reviver implant shuts down and starts recharging. It will be ready again in [DisplayTimeText(revive_cost)]."))
		else
			addtimer(CALLBACK(src, PROC_REF(heal)), 3 SECONDS)
		return

	if(!COOLDOWN_FINISHED(src, reviver_cooldown) || HAS_TRAIT(owner, TRAIT_SUICIDED))
		return

	if(owner.stat != CONSCIOUS)
		revive_cost = 0
		reviving = TRUE
		to_chat(owner, span_notice("You feel a faint buzzing as your reviver implant starts patching your wounds..."))
		COOLDOWN_START(src, defib_cooldown, 8 SECONDS) // 5 seconds after heal proc delay


/obj/item/organ/internal/cyberimp/chest/reviver/proc/heal()
	if(COOLDOWN_FINISHED(src, defib_cooldown))
		revive_dead()

	/// boolean that stands for if PHYSICAL damage being patched
	var/body_damage_patched = FALSE
	var/need_mob_update = FALSE
	if(owner.getOxyLoss())
		need_mob_update += owner.adjustOxyLoss(-5, updating_health = FALSE)
		revive_cost += 5
	if(owner.getBruteLoss())
		need_mob_update += owner.adjustBruteLoss(-2, updating_health = FALSE)
		revive_cost += 40
		body_damage_patched = TRUE
	if(owner.getFireLoss())
		need_mob_update += owner.adjustFireLoss(-2, updating_health = FALSE)
		revive_cost += 40
		body_damage_patched = TRUE
	if(owner.getToxLoss())
		need_mob_update += owner.adjustToxLoss(-1, updating_health = FALSE)
		revive_cost += 40
	if(need_mob_update)
		owner.updatehealth()

	if(body_damage_patched && prob(35)) // healing is called every few seconds, not every tick
		owner.visible_message(span_warning("[owner]'s body twitches a bit."), span_notice("You feel like something is patching your injured body."))


/obj/item/organ/internal/cyberimp/chest/reviver/proc/revive_dead()
	if(!COOLDOWN_FINISHED(src, defib_cooldown) || owner.stat != DEAD || owner.can_defib() != DEFIB_POSSIBLE)
		return
	owner.notify_revival("You are being revived by [src]!")
	revive_cost += 10 MINUTES // Additional 10 minutes cooldown after revival.
	owner.grab_ghost()

	defib_cooldown += 16 SECONDS // delay so it doesn't spam

	owner.visible_message(span_warning("[owner]'s body convulses a bit."))
	playsound(owner, SFX_BODYFALL, 50, TRUE)
	playsound(owner, 'sound/machines/defib/defib_zap.ogg', 75, TRUE, -1)
	owner.set_heartattack(FALSE)
	owner.revive()
	owner.emote("gasp")
	owner.set_jitter_if_lower(200 SECONDS)
	SEND_SIGNAL(owner, COMSIG_LIVING_MINOR_SHOCK)
	log_game("[owner] been revived by [src]")


/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(reviving)
		revive_cost += 200
	else
		reviver_cooldown += 20 SECONDS

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		if(human_owner.stat != DEAD && prob(50 / severity) && human_owner.can_heartattack())
			human_owner.set_heartattack(TRUE)
			to_chat(human_owner, span_userdanger("You feel a horrible agony in your chest!"))
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), 600 / severity)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return
	human_owner.set_heartattack(FALSE)
	if(human_owner.stat == CONSCIOUS)
		to_chat(human_owner, span_notice("You feel your heart beating again!"))


/obj/item/organ/internal/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpacks, this device has no stabilization system."
	slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_jetpack"
	base_icon_state = "imp_jetpack"
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE

/obj/item/organ/internal/cyberimp/chest/thrusters/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/jetpack, \
		FALSE, \
		1.5 NEWTONS, \
		1.2 NEWTONS, \
		COMSIG_THRUSTER_ACTIVATED, \
		COMSIG_THRUSTER_DEACTIVATED, \
		THRUSTER_ACTIVATION_FAILED, \
		CALLBACK(src, PROC_REF(allow_thrust), 0.01), \
		/datum/effect_system/trail_follow/ion, \
	)

/obj/item/organ/internal/cyberimp/chest/thrusters/Remove(mob/living/carbon/thruster_owner, special, movement_flags)
	if(on)
		deactivate(silent = TRUE)
	..()

/obj/item/organ/internal/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/toggle(silent = FALSE)
	if(on)
		deactivate()
	else
		activate()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/activate(silent = FALSE)
	if(on)
		return
	if(organ_flags & ORGAN_FAILING)
		if(!silent)
			to_chat(owner, span_warning("Your thrusters set seems to be broken!"))
		return
	if(SEND_SIGNAL(src, COMSIG_THRUSTER_ACTIVATED, owner) & THRUSTER_ACTIVATION_FAILED)
		return

	on = TRUE
	owner.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
	if(!silent)
		to_chat(owner, span_notice("You turn your thrusters set on."))
	update_appearance()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/deactivate(silent = FALSE)
	if(!on)
		return
	SEND_SIGNAL(src, COMSIG_THRUSTER_DEACTIVATED, owner)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
	if(!silent)
		to_chat(owner, span_notice("You turn your thrusters set off."))
	on = FALSE
	update_appearance()

/obj/item/organ/internal/cyberimp/chest/thrusters/update_icon_state()
	icon_state = "[base_icon_state][on ? "-on" : null]"
	return ..()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/allow_thrust(num, use_fuel = TRUE)
	if(!owner)
		return FALSE

	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf) // No more runtimes from being stuck in nullspace.
		return FALSE

	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = owner_turf.return_air()
	if(environment && environment.return_pressure() > 30)
		return TRUE

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num * 100)
		if(use_fuel)
			owner.adjustPlasma(-num * 100)
		return TRUE

	// Priority 3: use internals tank.
	var/datum/gas_mixture/internal_mix = owner.internal?.return_air()
	if(internal_mix && internal_mix.total_moles() > num)
		if(!use_fuel)
			return TRUE
		var/datum/gas_mixture/removed = internal_mix.remove(num)
		if(removed.total_moles() > 0.005)
			owner_turf.assume_air(removed)
			return TRUE
		else
			owner_turf.assume_air(removed)

	deactivate(silent = TRUE)
	return FALSE

/obj/item/organ/internal/cyberimp/chest/spine
	name = "\improper Herculean gravitronic spinal implant"
	desc = "This gravitronic spinal interface is able to improve the athletics of a user, allowing them greater physical ability. \
		Contains a slot which can be upgraded with a gravity anomaly core, improving its performance."
	icon_state = "herculean_implant"
	slot = ORGAN_SLOT_SPINE
	/// How much faster does the spinal implant improve our lifting speed, workout ability, reducing falling damage and improving climbing and standing speed
	var/athletics_boost_multiplier = 0.8
	/// How much additional throwing range does our spinal implant grant us.
	var/added_throw_range = 2
	/// How much additional boxing damage and tackling power do we add?
	var/strength_bonus = 4
	/// Whether or not a gravity anomaly core has been installed, improving the effectiveness of the spinal implant.
	var/core_applied = FALSE
	/// The overlay for our implant to indicate that, yes, this person has an implant inserted.
	var/mutable_appearance/stone_overlay

/obj/item/organ/internal/cyberimp/chest/spine/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, span_warning("You feel sheering pain as your body is crushed like a soda can!"))
	owner.apply_damage(20/severity, BRUTE, def_zone = BODY_ZONE_CHEST)

/obj/item/organ/internal/cyberimp/chest/spine/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	stone_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "stone")
	organ_owner.add_overlay(stone_overlay)
	if(core_applied)
		organ_owner.AddElement(/datum/element/forced_gravity, 1)

/obj/item/organ/internal/cyberimp/chest/spine/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(stone_overlay)
		organ_owner.cut_overlay(stone_overlay)
		stone_overlay = null
	if(core_applied)
		organ_owner.RemoveElement(/datum/element/forced_gravity, 1)

/obj/item/organ/internal/cyberimp/chest/spine/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(core_applied)
		user.balloon_alert(user, "core already installed!")
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/assembly/signaler/anomaly/grav))
		user.balloon_alert(user, "core installed.")
		athletics_boost_multiplier = 0.25
		added_throw_range += 2
		strength_bonus += 4
		core_applied = TRUE
		name = "\improper Atlas gravitonic spinal implant"
		desc = "This gravitronic spinal interface is able to improve the athletics of a user, allowing them greater physical ability. \
			This one has been improved through the installation of a gravity anomaly core, allowing for personal gravity manipulation."
		icon_state = "herculean_implant_core"
		update_appearance()
		qdel(tool)
		return ITEM_INTERACT_SUCCESS

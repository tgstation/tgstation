/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "Implants for the organs in your torso."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = BODY_ZONE_CHEST

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
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
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/internal/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.reagents.add_reagent(/datum/reagent/toxin/bad_food, poison_amount / severity)
	to_chat(owner, span_warning("You feel like your insides are burning."))


/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10

/obj/item/organ/internal/cyberimp/chest/nutriment/plus/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
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
	playsound(owner, 'sound/machines/defib_zap.ogg', 75, TRUE, -1)
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

/obj/item/organ/internal/cyberimp/chest/reviver/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/chest/reviver/better/heal() // syndicate reviver had a lower cooldown.
	if(COOLDOWN_FINISHED(src, defib_cooldown))
		revive_dead()

	var/need_mob_update = FALSE
	if(owner.getOxyLoss())
		need_mob_update += owner.adjustOxyLoss(-5, updating_health = FALSE)
		revive_cost += 1
	if(owner.getBruteLoss())
		need_mob_update += owner.adjustBruteLoss(-2, updating_health = FALSE)
		revive_cost += 10
	if(owner.getFireLoss())
		need_mob_update += owner.adjustFireLoss(-2, updating_health = FALSE)
		revive_cost += 10
	if(owner.getToxLoss())
		need_mob_update += owner.adjustToxLoss(-1, updating_health = FALSE)
		revive_cost += 10
	if(need_mob_update)
		owner.updatehealth()

/obj/item/organ/internal/cyberimp/chest/reviver/better/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpacks, this device has no stabilization system."
	slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_jetpack"
	base_icon_state = "imp_jetpack"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE

/obj/item/organ/internal/cyberimp/chest/thrusters/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/jetpack, \
		FALSE, \
		COMSIG_THRUSTER_ACTIVATED, \
		COMSIG_THRUSTER_DEACTIVATED, \
		THRUSTER_ACTIVATION_FAILED, \
		CALLBACK(src, PROC_REF(allow_thrust), 0.01), \
		/datum/effect_system/trail_follow/ion \
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

/obj/item/organ/internal/cyberimp/chest/thrusters/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN


/obj/item/organ/internal/cyberimp/chest/regenerativebetter
	name = "regenerative implant"
	desc = "A surgical implant that when inserted into the body will slowly repair the host. Allowing for very slow recovery of all forms of damage."
	icon_state = "chest_implant"
	slot = ORGAN_SLOT_HEART_AID
	var/healing = FALSE

/obj/item/organ/internal/cyberimp/chest/regenerativebetter/on_life(seconds_per_tick, times_fired)
	if(healing)
		addtimer(CALLBACK(src, PROC_REF(heal)), 1 SECONDS)
	else
		healing = TRUE
		to_chat(owner, span_notice("Your regenerative implant was integrated successfully."))
	return

/obj/item/organ/internal/cyberimp/chest/regenerativebetter/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-2.5)
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-1)
	if(owner.getFireLoss())
		owner.adjustFireLoss(-1)
	if(owner.getToxLoss())
		owner.adjustToxLoss(-0.5)

	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_HEART, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_EYES, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_EARS, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_TONGUE, -0.5)
	owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -0.5)

/obj/item/organ/internal/cyberimp/chest/regenerativebetter/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN


/obj/item/organ/internal/cyberimp/chest/regenerative
	name = "regenerative implant"
	desc = "A surgical implant that when inserted into the body will slowly repair the host. Allowing for very slow recovery of all forms of damage."
	icon_state = "chest_implant"
	slot = ORGAN_SLOT_HEART_AID
	var/healing = FALSE

/obj/item/organ/internal/cyberimp/chest/regenerative/on_life(seconds_per_tick, times_fired)
	if(healing)
		addtimer(CALLBACK(src, PROC_REF(heal)), 1 SECONDS)
	else
		healing = TRUE
		to_chat(owner, span_notice("Your regenerative implant was integrated successfully."))
	return

/obj/item/organ/internal/cyberimp/chest/regenerative/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-1)
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-0.5)
	if(owner.getFireLoss())
		owner.adjustFireLoss(-0.5)
	if(owner.getToxLoss())
		owner.adjustToxLoss(-0.25)

	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_HEART, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_EYES, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_EARS, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_TONGUE, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -0.25)

/obj/item/organ/internal/cyberimp/chest/regenerative/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN


/obj/item/organ/internal/cyberimp/chest/jellypersonregen
	name = "gelatine sythesis implant"
	desc = "A surgical implant that when inserted into the body will slowly repair the host. Specifically tailored to jellypeople."
	icon_state = "chest_implant"
	slot = ORGAN_SLOT_HEART_AID

/obj/item/organ/internal/cyberimp/chest/jellypersonregen/on_life(seconds_per_tick, times_fired)
	if(isjellyperson(owner))
		addtimer(CALLBACK(src, PROC_REF(heal)), 1 SECONDS)
	return

/obj/item/organ/internal/cyberimp/chest/jellypersonregen/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-3)
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-1.5)
	if(owner.getFireLoss())
		owner.adjustFireLoss(-1.5)
	if(owner.getToxLoss())
		owner.adjustToxLoss(1)

	if(owner.blood_volume <= BLOOD_VOLUME_SAFE)
		owner.blood_volume += 1

	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_HEART, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_EYES, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_EARS, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_TONGUE, -1)
	owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -1)

/obj/item/organ/internal/cyberimp/chest/jellypersonregen/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN


/obj/item/organ/internal/cyberimp/chest/spinalspeed
	name = "neural overclocker implant"
	desc = "Stimulates your central nervous system in order to enable you to perform muscle movements faster. Careful not to overuse it."
	slot = ORGAN_SLOT_SPINAL_AUG
	icon_state = "imp_spinal"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	var/syndicate_implant = TRUE
	var/on = FALSE
	var/time_on = 0
	var/hasexerted = FALSE
	var/list/hsv
	var/last_step = 0
	COOLDOWN_DECLARE(alertcooldown)
	COOLDOWN_DECLARE(startsoundcooldown)
	COOLDOWN_DECLARE(endsoundcooldown)

/obj/item/organ/internal/cyberimp/chest/spinalspeed/Insert(mob/living/carbon/M, special = 0)
	. = ..()

/obj/item/organ/internal/cyberimp/chest/spinalspeed/Remove(mob/living/carbon/M, special = 0)
	if(on)
		toggle(silent = TRUE)
	..()

/obj/item/organ/internal/cyberimp/chest/spinalspeed/ui_action_click()
	toggle()

/obj/item/organ/internal/cyberimp/chest/spinalspeed/proc/toggle(silent = FALSE)
	if(!on)
		if(COOLDOWN_FINISHED(src, startsoundcooldown))
			playsound(owner, 'sound/effects/spinal_implant_on.ogg', 60)
			COOLDOWN_START(src, startsoundcooldown, 1 SECONDS)
		if(syndicate_implant)//the toy doesn't do anything aside from the trail and the sound
			if(ishuman(owner))
				owner.add_actionspeed_modifier(/datum/actionspeed_modifier/neuraloverclockactions)
			owner.next_move_modifier *= 0.7
			owner.add_movespeed_modifier(/datum/movespeed_modifier/neuraloverclock, update=TRUE)
		RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(move_react))
	else
		if(COOLDOWN_FINISHED(src, endsoundcooldown))
			playsound(owner, 'sound/effects/spinal_implant_off.ogg', 70)
			COOLDOWN_START(src, endsoundcooldown, 1 SECONDS)
		if(syndicate_implant)
			if(ishuman(owner))
				owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/neuraloverclockactions)
			owner.next_move_modifier /= 0.7
			owner.remove_movespeed_modifier(/datum/movespeed_modifier/neuraloverclock)
		UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	on = !on
	if(!silent)
		to_chat(owner, span_notice("You turn your spinal implant [on? "on" : "off"]."))
	update_appearance(UPDATE_ICON)

/obj/item/organ/internal/cyberimp/chest/spinalspeed/update_icon_state()
	. = ..()
	if(on)
		icon_state = "imp_spinal-on"
	else
		icon_state = "imp_spinal"
	for(var/datum/action/A as anything in actions)
		A.build_all_button_icons()

/obj/item/organ/internal/cyberimp/chest/spinalspeed/proc/move_react()//afterimage
	var/turf/currentloc = get_turf(owner)
	var/obj/effect/temp_visual/decoy/fading/F = new(currentloc, owner)
	if(!hsv)
		hsv = rgb2hsv(rgb(255, 0, 0))
	//hsv = RotateHue(hsv, world.time - last_step * 15)
	//last_step = world.time
	F.color = hsv2rgb(hsv)	//gotta add the flair

/obj/item/organ/internal/cyberimp/chest/spinalspeed/on_life()
	if(!syndicate_implant)//the toy doesn't have a drawback
		return

	if(on)
		if(owner.stat == UNCONSCIOUS || owner.stat == DEAD)
			toggle(silent = TRUE)
		time_on += 1
		switch(time_on)
			if(20 to 50)
				if(COOLDOWN_FINISHED(src, alertcooldown))
					to_chat(owner, span_alert("You feel your spine tingle."))
					COOLDOWN_START(src, alertcooldown, 10 SECONDS)
				owner.adjust_hallucinations(20 SECONDS)
				owner.adjustFireLoss(1)
			if(50 to 100)
				if(COOLDOWN_FINISHED(src, alertcooldown) || !hasexerted)
					to_chat(owner, span_userdanger("Your spine and brain feel like they're burning!"))
					COOLDOWN_START(src, alertcooldown, 5 SECONDS)
				hasexerted = TRUE
				owner.set_drugginess(2 SECONDS)
				owner.adjust_hallucinations(20 SECONDS)
				owner.adjustFireLoss(5)
			if(100 to INFINITY)//no infinite abuse
				to_chat(owner, span_userdanger("You feel a slight sense of shame as your brain and spine rip themselves apart from overexertion."))
				owner.gib()
	else
		time_on -= 2

	time_on = max(time_on, 0)
	if(hasexerted && time_on == 0)
		to_chat(owner, "Your brains feels normal again.")
		hasexerted = FALSE

/obj/item/organ/internal/cyberimp/chest/spinalspeed/emp_act(severity)
	. = ..()
	if(!syndicate_implant)//the toy has a different emp act
		owner.adjust_dizzy(severity SECONDS)
		to_chat(owner, span_warning("Your spinal implant makes you feel queasy!"))
		return

	owner.set_drugginess(4 * severity)
	owner.adjust_hallucinations((50 * severity) SECONDS)
	owner.adjust_eye_blur(2 * severity)
	owner.adjust_dizzy(severity SECONDS)
	time_on += severity
	owner.adjustFireLoss(severity)
	to_chat(owner, span_warning("Your spinal implant malfunctions and you feel it scramble your brain!"))

/obj/item/organ/internal/cyberimp/chest/spinalspeed/toy
	name = "glowy after-image trail implant"
	desc = "Donk Co's first forray into the world of entertainment implants. Projects a series of after-images as you move, perfect for starting a dance party all on your own."
	syndicate_implant = FALSE

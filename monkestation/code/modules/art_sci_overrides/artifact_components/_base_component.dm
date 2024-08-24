#define BASE_MAX_ACTIVATORS 2
#define BASE_MAX_EFFECTS 2

/datum/component/artifact
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//The object we are attached to
	var/obj/structure/artifact/holder
	///size class for visuals (ARTIFACT_SIZE_TINY,ARTIFACT_SIZE_SMALL,ARTIFACT_SIZE_LARGE)
	var/artifact_size = ARTIFACT_SIZE_LARGE
	///type name for displaying on analysis forms
	var/type_name = "Generic Artifact Type"
	/// fake name for when unanalyzed
	var/fake_name
	///the randomly generated name using our origin
	var/generated_name
	///Is the artifact active?
	var/active = FALSE
	///activators that activate the artifact
	var/list/datum/artifact_activator/activators = list()
	var/max_activators = BASE_MAX_ACTIVATORS
	///Valid activators to pick
	var/list/valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon,
		/datum/artifact_activator/touch/data,

		/datum/artifact_activator/range/force,
		/datum/artifact_activator/range/heat,
		/datum/artifact_activator/range/shock,
		/datum/artifact_activator/range/radiation,
	)
	///valid list of faults with their weights [10 is base]
	var/list/valid_faults = list(
		/datum/artifact_fault/ignite = 10,
		/datum/artifact_fault/warp = 10,
		/datum/artifact_fault/reagent/poison = 10,
		/datum/artifact_fault/death = 1,
		/datum/artifact_fault/tesla_zap = 5,
		/datum/artifact_fault/shrink = 10,
		/datum/artifact_fault/explosion = 2,
		/datum/artifact_fault/speech = 10,
		/datum/artifact_fault/whisper = 8,
		/datum/artifact_fault/monkey_mode = 4,
		/datum/artifact_fault/shutdown = 10,
		/datum/artifact_fault/bioscramble = 5
	)
	///origin datum
	var/datum/artifact_origin/artifact_origin
	///origin datums to pick
	var/list/valid_origins = list(
		/datum/artifact_origin/narsie,
		/datum/artifact_origin/wizard,
		/datum/artifact_origin/silicon,
		/datum/artifact_origin/precursor,
		/datum/artifact_origin/martian
	)
	var/activation_message
	var/activation_sound
	var/deactivation_message
	var/deactivation_sound
	var/mutable_appearance/act_effect

	///we store our analysis form var here
	var/obj/item/sticker/analysis_form/analysis

	var/mutable_appearance/extra_effect
	///the fault we picked from the listed ones. Can be null!
	var/datum/artifact_fault/chosen_fault
	///the amount of times an artifact WONT do something bad, even though it should have
	var/freebies = 3
	///if we have a special examine IE borgers
	var/explict_examine

	//The activators we have discovered.
	var/list/datum/artifact_activator/discovered_activators = list()
	//Have we discovered what the bad is?
	var/fault_discovered = FALSE
	//A list of effects the artifact has
	var/list/datum/artifact_effect/artifact_effects = list()
	//A list of effects that have been discovered
	var/list/datum/artifact_effect/discovered_effects = list()

/datum/component/artifact/Initialize(forced_origin,forced_effect)
	. = ..(forced_origin,forced_effect)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	holder = parent
	GLOB.running_artifact_list[holder] = src

	if(forced_origin)
		valid_origins = list(forced_origin)
	var/picked_origin = pick(valid_origins)
	artifact_origin = new picked_origin
	fake_name = "[pick(artifact_origin.name_vars["adjectives"])] [pick(isitem(holder) ? artifact_origin.name_vars["small-nouns"] : artifact_origin.name_vars["large-nouns"])]"
	if(rand(0,100)<95)
		var/picked_fault = pick_weight(valid_faults)
		chosen_fault = new picked_fault

	generated_name = artifact_origin.generate_name()
	if(!generated_name)
		generated_name  = "[pick(artifact_origin.name_vars["adjectives"])] [pick(isitem(holder) ? artifact_origin.name_vars["small-nouns"] : artifact_origin.name_vars["large-nouns"])]"

	holder.name = fake_name
	holder.desc = "Some sort of artifact from a time long past."

	var/dat_icon
	switch(artifact_size)
		if(ARTIFACT_SIZE_LARGE)
			holder.icon = artifact_origin.icon_file_large
			dat_icon = "[artifact_origin.sprite_name]-[rand(1,artifact_origin.max_icons)]"
		if(ARTIFACT_SIZE_SMALL)
			holder.icon = artifact_origin.icon_file_medium
			dat_icon = "[artifact_origin.sprite_name]-[rand(1,artifact_origin.max_item_icons)]"
		if(ARTIFACT_SIZE_TINY)
			holder.icon = artifact_origin.icon_file_small
			dat_icon = "[artifact_origin.sprite_name]-[rand(1,artifact_origin.max_item_icons_small)]"
	holder.icon_state = dat_icon

	//wizards got an extract MA for the gem coloring, if we have extras add them below this
	if(artifact_origin.type_name == ORIGIN_WIZARD)
		extra_effect = mutable_appearance(holder.icon, "[holder.icon_state]-gem", ABOVE_OBJ_LAYER, offset_spokesman = holder)
		extra_effect.color = random_rgb_pairlists(artifact_origin.overlays_reds, artifact_origin.overlays_blues, artifact_origin.overlays_greens, artifact_origin.overlays_alpha)

	holder.update_appearance() // force an all update specifically to try and apply secondary overlays

	act_effect = mutable_appearance(holder.icon, "[holder.icon_state]fx", offset_spokesman = holder, alpha = rand(artifact_origin.overlays_alpha[1], artifact_origin.overlays_alpha[2]))
	act_effect.color = random_rgb_pairlists(artifact_origin.overlays_reds, artifact_origin.overlays_blues, artifact_origin.overlays_greens, artifact_origin.overlays_alpha)
	act_effect.overlays += emissive_appearance(act_effect.icon, act_effect.icon_state, holder, alpha = act_effect.alpha)
	activation_sound = pick(artifact_origin.activation_sounds)
	if(LAZYLEN(artifact_origin.deactivation_sounds))
		deactivation_sound = pick(artifact_origin.deactivation_sounds)

	var/activator_amount = rand(1,max_activators)
	while(activator_amount>0)
		var/selection = pick(valid_activators)
		valid_activators -= selection
		activators += new selection()
		activator_amount--
	var/effect_amount = rand(1,BASE_MAX_EFFECTS)
	var/list/datum/artifact_effect/all_possible_effects = GLOB.artifact_effect_rarity["all"]// We need all of them as we check later if ifs a valid origin
	while(effect_amount >0)
		if(length(all_possible_effects) <= 0)
			logger.Log(LOG_CATEGORY_ARTIFACT, "[src] has ran out of possible artifact effects! It may not have any at all!")
			effect_amount = 0
			continue
		var/datum/artifact_effect/effect = pick_weight(all_possible_effects)
		if(effect.valid_origins)
			if(!effect.valid_origins.Find(picked_origin))
				all_possible_effects -= effect
				continue
		if(effect.valid_activators)
			var/good_activators = FALSE
			for(var/datum/artifact_activator/activator in activators) //Only need one to be correct.
				if(effect.valid_activators.Find(activator))
					good_activators = TRUE
					break
			if(good_activators)
				all_possible_effects -= effect
				continue
		if(effect.artifact_size)
			if(artifact_size != effect.artifact_size)
				all_possible_effects -=effect
				continue
		var/datum/artifact_effect/added = new effect
		artifact_effects += added
		added.setup()
		effect_amount--
		all_possible_effects -= effect
	if(forced_effect)
		var/datum/artifact_effect/added_boogaloo = new forced_effect
		artifact_effects += added_boogaloo
		added_boogaloo.setup()
	ADD_TRAIT(holder, TRAIT_HIDDEN_EXPORT_VALUE, INNATE_TRAIT)
	setup()
	for(var/datum/artifact_activator/activator in activators)
		var/potency = rand(0,100)
		activators += list(activator.type = potency)
		activator.setup(potency)

/datum/component/artifact/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_ATOM_DESTRUCTION, COMSIG_QDELETING), PROC_REF(on_destroy))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_STICKER_STICKED, PROC_REF(on_sticker))
	RegisterSignal(parent, COMSIG_STICKER_UNSTICKED, PROC_REF(on_desticker))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_unarmed))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(on_robot_attack))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(ex_act))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_PULLED, PROC_REF(log_pull))
	RegisterSignal(parent, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(log_stop_pull))

/datum/component/artifact/UnregisterFromParent()
	GLOB.running_artifact_list -= parent
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_STICKER_STICKED,
		COMSIG_STICKER_UNSTICKED,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_ROBOT,
		COMSIG_ATOM_EX_ACT,
		COMSIG_ATOM_EMP_ACT,
		COMSIG_ATOM_NO_LONGER_PULLED,
		COMSIG_ATOM_PULLED,
	))

/datum/component/artifact/proc/setup()
	return

/datum/component/artifact/proc/artifact_activate(silent)
	if(active) //dont activate activated objects
		return FALSE

	if(activation_sound && !silent)
		playsound(holder, activation_sound, 75, TRUE)
	if(activation_message && !silent)
		holder.visible_message(span_notice("[holder] [activation_message]"))
	active = TRUE
	holder.add_overlay(act_effect)
	logger.Log(LOG_CATEGORY_ARTIFACT, "[parent] has been activated")
	for(var/datum/artifact_effect/effect in artifact_effects)
		effect.effect_activate(silent)
	return TRUE

/datum/component/artifact/proc/artifact_deactivate(silent)
	if(!active)
		return
	if(deactivation_sound && !silent)
		playsound(holder, deactivation_sound, 75, TRUE)
	if(deactivation_message && !silent)
		holder.visible_message(span_notice("[holder] [deactivation_message]"))
	active = FALSE
	holder.cut_overlay(act_effect)
	logger.Log(LOG_CATEGORY_ARTIFACT, "[parent] has been deactivated")
	for(var/datum/artifact_effect/effect in artifact_effects)
		effect.effect_deactivate(silent)

/datum/component/artifact/proc/process_stimuli(stimuli, stimuli_value, triggers_faults = TRUE)
	if(!stimuli || active) // if called without a stimuli dont bother, if active we dont wanna reactivate
		return
	var/checked_fault = FALSE
	for(var/datum/artifact_activator/listed_activator in activators)
		if(!(listed_activator.required_stimuli & stimuli) && chosen_fault)
			if(!triggers_faults)
				continue
			if(freebies >= 1)
				freebies--
				continue
			if(checked_fault)
				continue
			checked_fault = TRUE
			if(prob(chosen_fault.trigger_chance))
				logger.Log(LOG_CATEGORY_ARTIFACT, "[parent]'s fault has been triggered, trigger type [chosen_fault].")
				chosen_fault.on_trigger(src)
				if(chosen_fault.visible_message)
					holder.visible_message("[holder] [chosen_fault.visible_message]")
			continue
		checked_fault = TRUE
		if(istype(listed_activator, /datum/artifact_activator/range))
			var/datum/artifact_activator/range/ranged_activator = listed_activator
			//if we fail the range check check if we are in hint range to send out the hint
			if(!ISINRANGE(stimuli_value, ranged_activator.amount, ranged_activator.upper_range))
				if(!ISINRANGE(stimuli_value, ranged_activator.amount - ranged_activator.hint_range, ranged_activator.upper_range + ranged_activator.hint_range))
					continue
				if(!prob(ranged_activator.hint_prob))
					continue
				continue
		artifact_activate()

/datum/component/artifact/proc/stimulate_from_turf_heat(turf/target)
	if(!QDELETED(target))
		process_stimuli(STIMULUS_HEAT, target.return_air().temperature, FALSE)

/datum/component/artifact/proc/stimulate_from_rad_act(intensity)
	process_stimuli(STIMULUS_RADIATION, intensity)

#undef BASE_MAX_ACTIVATORS
#undef BASE_MAX_EFFECTS

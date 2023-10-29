#define BASE_MAX_ACTIVATORS 2

/datum/component/artifact
	///object related to this datum for spawning
	var/obj/associated_object
	///actual specific object for this instance
	var/obj/holder
	///list weight for picking this artifact datum (0 = never)
	var/weight = 0
	///size class for visuals (ARTIFACT_SIZE_TINY,ARTIFACT_SIZE_SMALL,ARTIFACT_SIZE_LARGE)
	var/artifact_size = ARTIFACT_SIZE_LARGE
	///type name for displaying on analysis forms
	var/type_name = "Generic Artifact Type"
	/// fake name for when unanalyzed
	var/fake_name
	///randomly generated names by origin for when it gets analyzed
	var/list/names = list()
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
	///origin datum
	var/datum/artifact_origin/artifact_origin
	///origin datums to pick
	var/list/valid_origins = list(
		ORIGIN_NARSIE,
		ORIGIN_WIZARD,
		ORIGIN_SILICON,
		ORIGIN_PRECURSOR,
		ORIGIN_MARTIAN,
	)
	var/activation_message
	var/activation_sound
	var/deactivation_message
	var/deactivation_sound
	var/hint_text = "emits a <i>faint</i> noise.."
	var/examine_hint
	var/mutable_appearance/act_effect
	/// Potency in percentage, used for making more strong artifacts need more stimulus. (1% - 100%) 100 is strongest.
	var/potency = 1

	///structure description from x-ray machines
	var/xray_result = "NONE"
	///we store our analysis form var here
	var/obj/item/sticker/analysis_form/analysis

	var/mutable_appearance/extra_effect

/datum/component/artifact/Initialize(forced_origin = null)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	holder = parent
	SSartifacts.artifacts[holder] = src

	if(forced_origin)
		valid_origins = list(forced_origin)

	artifact_origin = SSartifacts.artifact_origins_by_typename[pick(valid_origins)]
	fake_name = "[pick(artifact_origin.name_vars["adjectives"])] [pick(isitem(holder) ? artifact_origin.name_vars["small-nouns"] : artifact_origin.name_vars["large-nouns"])]"
	
	for(var/datum/artifact_origin/origins in SSartifacts.artifact_origins)
		var/a_name = origins.generate_name()
		if(a_name)
			names[origins.type_name] = a_name
		else
			names[origins.type_name] = "[pick(origins.name_vars["adjectives"])] [pick(isitem(holder) ? origins.name_vars["small-nouns"] : origins.name_vars["large-nouns"])]"

	holder.name = fake_name
	holder.desc = "You have absolutely no clue what this thing is or how it got here."

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
	
	holder.update_appearance()

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

	ADD_TRAIT(holder, TRAIT_HIDDEN_EXPORT_VALUE, INNATE_TRAIT)
	setup()
	potency = clamp(potency, 0, 100)
	for(var/datum/artifact_activator/activator in activators)
		activator.setup(potency)
		hint_text = activator.grab_hint()

/datum/component/artifact/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_ATOM_DESTRUCTION, COMSIG_PARENT_QDELETING), PROC_REF(on_destroy))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_STICKER_STICKED, PROC_REF(on_sticker))
	RegisterSignal(parent, COMSIG_STICKER_UNSTICKED, PROC_REF(on_desticker))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_unarmed))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ROBOT, PROC_REF(on_robot_attack))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(ex_act))

/datum/component/artifact/UnregisterFromParent()
	SSartifacts.artifacts -= parent
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_STICKER_STICKED,
		COMSIG_STICKER_UNSTICKED,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_ATTACK_ROBOT,
		COMSIG_ATOM_EX_ACT,
		COMSIG_ATOM_EMP_ACT,
	))

/datum/component/artifact/proc/setup()
	return

/datum/component/artifact/proc/artifact_activate(nosound)
	if(active) //dont activate activated objects
		return FALSE

	if(activation_sound && !nosound)
		playsound(holder, activation_sound, 75, TRUE)
	if(activation_message && !nosound)
		holder.visible_message(span_notice("[holder] [activation_message]"))
	active = TRUE
	holder.add_overlay(act_effect)
	effect_activate(nosound)
	return TRUE

/datum/component/artifact/proc/artifact_deactivate(nosound)
	if(!active)
		return
	if(deactivation_sound && !nosound)
		playsound(holder, deactivation_sound, 75, TRUE)
	if(deactivation_message && !nosound)
		holder.visible_message(span_notice("[holder] [deactivation_message]"))
	active = FALSE
	holder.cut_overlay(act_effect)
	effect_deactivate(nosound)

/datum/component/artifact/proc/process_stimuli(stimuli, stimuli_value)
	if(!stimuli || active) // if called without a stimuli dont bother if active we dont wanna reactivate
		return
	
	for(var/datum/artifact_activator/listed_activator in activators)
		if(!(listed_activator.required_stimuli & stimuli))
			continue
		if(istype(listed_activator, /datum/artifact_activator/range))
			var/datum/artifact_activator/range/ranged_activator
			//if we fail the range check check if we are in hint range to send out the hint
			if(!ISINRANGE(stimuli_value, ranged_activator.amount, ranged_activator.range))
				if(hint_text && !ISINRANGE(stimuli_value, ranged_activator.amount, ranged_activator.range + ranged_activator.hint_range))
					continue
				if(!prob(ranged_activator.hint_prob))
					continue
				holder.visible_message(span_notice("[holder] [hint_text]"))
				continue
		artifact_activate()

/datum/component/artifact/proc/stimulate_from_turf_heat(turf/target)
	process_stimuli(STIMULUS_HEAT, target.return_air().temperature)

#undef BASE_MAX_ACTIVATORS

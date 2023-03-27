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
	var/type_name = "coderbus moment"
	/// fake name for when unanalyzed
	var/fake_name
	///randomly generated names by origin for when it gets analyzed
	var/list/names = list()
	///Is the artifact active?
	var/active = FALSE
	///Triggers that activate the artifact
	var/list/datum/artifact_trigger/triggers = list()
	var/max_triggers = 2
	///Valid triggers to pick
	var/list/valid_triggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/force, /datum/artifact_trigger/heat, /datum/artifact_trigger/shock, /datum/artifact_trigger/radiation, /datum/artifact_trigger/data)
	///origin datum
	var/datum/artifact_origin/artifact_origin
	///origin datums to pick
	var/list/valid_origins = list(ORIGIN_NARSIE,ORIGIN_WIZARD,ORIGIN_SILICON)
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

/datum/component/artifact/Initialize(var/forced_origin = null)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	holder = parent
	SSartifacts.artifacts += holder
	if(forced_origin)
		valid_origins = list(forced_origin)
	artifact_origin = SSartifacts.artifact_origins_by_typename[pick(valid_origins)]
	fake_name = "[pick(artifact_origin.adjectives)] [pick(isitem(holder) ? artifact_origin.nouns_small : artifact_origin.nouns_large)]"
	for(var/datum/artifact_origin/og in SSartifacts.artifact_origins)
		var/a_name = og.generate_name()
		if(a_name)
			names[og.type_name] = a_name
		else
			names[og.type_name] = "[pick(og.adjectives)] [pick(isitem(holder) ? og.nouns_small : og.nouns_large)]"
	holder.name = fake_name
	holder.desc = "You have absolutely no clue what this thing is or how it got here."
	var/dat_icon
	var/origin_name = artifact_origin.type_name
	switch(artifact_size)
		if(ARTIFACT_SIZE_LARGE)
			dat_icon = "[origin_name]-[rand(1,artifact_origin.max_icons)]"
		if(ARTIFACT_SIZE_SMALL)
			dat_icon = "[origin_name]-item-[rand(1,artifact_origin.max_item_icons)]"
		if(ARTIFACT_SIZE_TINY)
			dat_icon = "[origin_name]-item-small-[rand(1,artifact_origin.max_item_icons)]"
	holder.icon_state = dat_icon
	act_effect = mutable_appearance(holder.icon, holder.icon_state + "fx", LIGHTING_PLANE + 0.5)
	activation_sound = pick(artifact_origin.activation_sounds)
	if(LAZYLEN(artifact_origin.deactivation_sounds))
		deactivation_sound = pick(artifact_origin.deactivation_sounds)
	var/trigger_amount = rand(1,max_triggers)
	while(trigger_amount>0)
		var/selection = pick(valid_triggers)
		valid_triggers -= selection
		triggers += new selection()
		trigger_amount--
	ADD_TRAIT(holder, TRAIT_HIDDEN_EXPORT_VALUE)
	setup()
//Seperate from initialize, for artifact inheritance funnies
/datum/component/artifact/proc/setup()
	potency = clamp(potency, 1, 100) //just incase
	for(var/datum/artifact_trigger/trigger in triggers)
		trigger.amount = max(trigger.base_amount,trigger.base_amount + (trigger.max_amount - trigger.base_amount) * (potency/100))

/datum/component/artifact/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_DESTRUCTION, PROC_REF(Destroyed))
	if(isitem(parent)) // if we registered both on an item it would call twice..
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(Touched))
	else
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(Touched))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attack_by))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(ex_act))
	RegisterSignal(parent, COMSIG_STICKER_STICKED, PROC_REF(on_analysis))
	RegisterSignal(parent, COMSIG_STICKER_UNSTICKED, PROC_REF(deanalyze))

/datum/component/artifact/UnregisterFromParent()
	SSartifacts.artifacts -= parent
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP,COMSIG_ATOM_ATTACK_HAND,COMSIG_ATOM_DESTRUCTION,COMSIG_PARENT_EXAMINE,COMSIG_ATOM_EMP_ACT,COMSIG_ATOM_EX_ACT,COMSIG_STICKER_STICKED,COMSIG_STICKER_UNSTICKED))

/datum/component/artifact/proc/Activate(silent=FALSE)
	if(active) //dont activate activated objects
		return FALSE
	if(activation_sound && !silent)
		playsound(holder, activation_sound, 75, TRUE)
	if(activation_message && !silent)
		holder.visible_message(span_notice("[holder] [activation_message]"))
	active = TRUE
	holder.add_overlay(act_effect)
	effect_activate()
	return TRUE

/datum/component/artifact/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(examine_hint)
		examine_list += examine_hint

/datum/component/artifact/proc/Deactivate(silent=FALSE)
	if(!active)
		return
	if(deactivation_sound && !silent)
		playsound(holder, deactivation_sound, 75, TRUE)
	if(deactivation_message && !silent)
		holder.visible_message(span_notice("[holder] [deactivation_message]"))
	active = FALSE
	holder.cut_overlay(act_effect)
	effect_deactivate()

/datum/component/artifact/proc/Destroyed(atom/source, silent=FALSE)
	SIGNAL_HANDLER
	//UnregisterSignal(holder, COMSIG_IN_RANGE_OF_IRRADIATION)
	if(!silent)
		holder.loc.visible_message(span_warning("[holder] [artifact_origin.destroy_message]"))
	Deactivate(silent=TRUE)
	if(!QDELETED(holder))
		qdel(holder) // if it isnt already...
// Stimuli stuff
/datum/component/artifact/proc/Stimulate(var/stimuli,var/severity = 0)
	if(!stimuli || active)
		return
	for(var/datum/artifact_trigger/trigger in triggers)
		if(active)
			break
		if(trigger.needed_stimulus == stimuli)
			if(trigger.check_amount)
				if(severity >= trigger.amount)
					Activate()
				else if(hint_text && (abs(severity - trigger.hint_range) < trigger.hint_range))
					if(prob(trigger.hint_prob))
						holder.visible_message(span_notice("[holder] [hint_text]"))
			else
				Activate()

/datum/component/artifact/proc/Touched(atom/source,mob/living/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(holder))
		return
	if(isAI(user) || isobserver(user)) //sanity
		return
	if(user.pulling && isliving(user.pulling))
		if(user.combat_mode && user.pulling.Adjacent(holder) && user.grab_state > GRAB_PASSIVE)
			holder.visible_message(span_warning("[user] forcefully shoves [user.pulling] against the [holder]!"))
			Touched(user.pulling)
		else if(!user.combat_mode)
			holder.visible_message(span_notice("[user] gently pushes [user.pulling] against the [holder]"))
			Stimulate(STIMULUS_CARBON_TOUCH)
		return
	if(artifact_size == ARTIFACT_SIZE_LARGE) //only large artifacts since the average spessman wouldnt notice)
		user.visible_message(span_notice("[user] touches [holder]."))
	if(ishuman(user))
		var/mob/living/carbon/human/human = user 
		var/obj/item/bodypart/arm = human.get_active_hand()
		if(arm.bodytype & BODYTYPE_ROBOTIC)
			Stimulate(STIMULUS_SILICON_TOUCH)
		else
			Stimulate(STIMULUS_CARBON_TOUCH)
	else if(iscarbon(user))
		Stimulate(STIMULUS_CARBON_TOUCH)
	else if(issilicon(user))
		Stimulate(STIMULUS_SILICON_TOUCH)
	Stimulate(STIMULUS_FORCE,1)
	if(active)
		effect_touched(user)
		return
	if(LAZYLEN(artifact_origin.touch_descriptors))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), user, span_notice("<i>[pick(artifact_origin.touch_descriptors)]</i>")), 0.5 SECONDS)

//doesnt work
/*/datum/artifact/proc/Irradiating(atom/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER
	to_chat(world,"[get_perceived_radiation_danger(pulse_information,insulation_to_target)]")
	if(!active)
		Stimulate(STIMULUS_RADIATION, get_perceived_radiation_danger(pulse_information,insulation_to_target)*2)*/

/datum/component/artifact/proc/attack_by(atom/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(istype(I,/obj/item/weldingtool))
		if(I.use(1))
			Stimulate(STIMULUS_HEAT,800)
			holder.visible_message(span_warning("[user] burns the artifact with the [I]!"))
			playsound(user,pick(I.usesound),50, TRUE)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I, /obj/item/bodypart/arm))
		var/obj/item/bodypart/arm/arm = I
		if(arm.bodytype & BODYTYPE_ROBOTIC)
			Stimulate(STIMULUS_SILICON_TOUCH)
		else
			Stimulate(STIMULUS_CARBON_TOUCH)
		holder.visible_message(span_notice("[user] presses the [arm] against the artifact.")) //pressing stuff against stuff isnt very severe so
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I,/obj/item/assembly/igniter))
		Stimulate(STIMULUS_HEAT, I.heat)
		Stimulate(STIMULUS_SHOCK, 700)
		holder.visible_message(span_warning("[user] zaps the artifact with the [I]!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I, /obj/item/lighter))
		var/obj/item/lighter/lighter = I
		if(lighter.lit)
			Stimulate(STIMULUS_HEAT, lighter.heat*0.4)
			holder.visible_message(span_warning("[user] burns the artifact with the [I]!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(I.tool_behaviour == TOOL_MULTITOOL)
		Stimulate(STIMULUS_SHOCK, 1000)
		holder.visible_message(span_warning("[user] shocks the artifact with the [I]!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I,/obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = I
		if(paddles.defib.deductcharge(2000))
			Stimulate(STIMULUS_SHOCK, 2000)
			playsound(user,'sound/machines/defib_zap.ogg', 50, TRUE, -1)
			holder.visible_message(span_warning("[user] shocks the artifact with the [I]."))
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I,/obj/item/disk/data) || istype(I,/obj/item/circuitboard))
		holder.visible_message(span_notice("[user] touches the artifact with the [I]"))
		Stimulate(STIMULUS_DATA)

	if(I.force)
		Stimulate(STIMULUS_FORCE,I.force)

/datum/component/artifact/proc/ex_act(atom/source, severity)
	SIGNAL_HANDLER
	switch(severity)
		if(EXPLODE_DEVASTATE)
			Stimulate(STIMULUS_FORCE,100)
			Stimulate(STIMULUS_HEAT,600)
		if(EXPLODE_HEAVY)
			Stimulate(STIMULUS_FORCE,50)
			Stimulate(STIMULUS_HEAT,450)
		if(EXPLODE_LIGHT)
			Stimulate(STIMULUS_FORCE,25)
			Stimulate(STIMULUS_HEAT,360)

/datum/component/artifact/proc/emp_act(atom/source, severity)
	SIGNAL_HANDLER
	Stimulate(STIMULUS_SHOCK, 800 * severity)
	Stimulate(STIMULUS_RADIATION, 2 * severity)

/datum/component/artifact/proc/on_analysis(atom/source, obj/item/sticker/sticker, mob/user)
	SIGNAL_HANDLER
	if(analysis)
		to_chat(user, "You peel off [sticker], to make room for [sticker].")
		sticker.peel()
	if(!istype(sticker, /obj/item/sticker/analysis_form))
		return
	analysis = sticker

/datum/component/artifact/proc/deanalyze(atom/source)
	SIGNAL_HANDLER
	analysis = null

// Effects for subtypes
/datum/component/artifact/proc/effect_activate()
	return
/datum/component/artifact/proc/effect_deactivate()
	return
/datum/component/artifact/proc/effect_touched()
	return
/datum/component/artifact/proc/effect_process()
	return
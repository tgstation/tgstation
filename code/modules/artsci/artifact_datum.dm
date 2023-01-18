/datum/artifact
	///object related to this datum
	var/obj/associated_object
	///actual specific object for this instance
	var/obj/holder
	///list weight for picking this artifact datum (0 = never)
	var/weight = 0
	///size class
	var/artifact_size = ARTIFACT_SIZE_LARGE
	///type name for displaying visually
	var/type_name = "coderbus moment"
	///real name of the artifact when properly analyzed
	var/real_name = ""
	///Is the artifact active?
	var/active = FALSE
	///Activate on start?
	var/auto_activate = FALSE
	///Does it need activation at all?
	var/doesnt_need_activation = FALSE
	///Triggers that activate the artifact
	var/list/datum/artifact_trigger/triggers = list()
	///minimum and maximum amount of triggers to get
	var/min_triggers = 1
	var/max_triggers = 1
	///Valid triggers to pick
	var/list/valid_triggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/force, /datum/artifact_trigger/heat, /datum/artifact_trigger/cold, /datum/artifact_trigger/shock, /datum/artifact_trigger/radiation, /datum/artifact_trigger/data)
	///origin datum
	var/datum/artifact_origin/artifact_origin
	///origin datums to pick
	var/list/valid_origins = list(ORIGIN_NARSIE,ORIGIN_WIZARD,ORIGIN_SILICON)
	///Text on activation
	var/activation_message
	///Text on deactivation
	var/deactivation_message
	///Text on hint
	var/hint_text = "emits a <i>faint</i> noise.."
	///examine hint
	var/examine_hint = ""
	/// cool effect
	var/mutable_appearance/act_effect
	

/datum/artifact/New(obj/art)
		. = ..()
		//setup(art)

/datum/artifact/proc/setup(obj/art)
	holder = art
	
	artifact_origin = SSartifacts.artifact_origins_by_name[pick(valid_origins)]
	var/named = "[pick(artifact_origin.adjectives)] [pick(isitem(holder) ? artifact_origin.nouns_small : artifact_origin.nouns_large)]"
	holder.name = named
	holder.desc = "You have absolutely no clue what this thing is or how it got here."
	if(artifact_origin.max_sprites)
		holder.icon_state = "[artifact_origin.type_name]-[rand(1,artifact_origin.max_sprites)]"
	real_name = artifact_origin.generate_name()
	act_effect = emissive_appearance(holder.icon, holder.icon_state + "fx", holder, alpha = holder.alpha)
	if(auto_activate)
		Activate()
	var/trigger_amount = rand(min_triggers,max_triggers)
	while(trigger_amount>0)
		var/selection = pick(valid_triggers)
		valid_triggers -= selection
		triggers += new selection()
		trigger_amount--
	//RegisterSignal(holder, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(Irradiating))

/datum/artifact/proc/Activate(silent=FALSE)
	if(active) //dont activate activated objects
		return FALSE
	if(LAZYLEN(artifact_origin.activation_sounds) && !silent)
		playsound(holder, pick(artifact_origin.activation_sounds), 75, TRUE)
	if(activation_message && !silent)
		holder.visible_message(span_notice("[holder] [activation_message]"))
	active = TRUE
	holder.add_overlay(act_effect)
	effect_activate()
	return TRUE

/datum/artifact/proc/Deactivate(silent=FALSE)
	if(!active)
		return
	if(LAZYLEN(artifact_origin.deactivation_sounds) && !silent)
		playsound(holder, pick(artifact_origin.deactivation_sounds), 75, TRUE)
	if(deactivation_message && !silent)
		holder.visible_message(span_notice("[holder] [deactivation_message]"))
	active = FALSE
	holder.cut_overlay(act_effect)
	effect_deactivate()

/datum/artifact/proc/Took_Damage(damage_amount, damage_type = BRUTE)
	//add faults oki thank
/datum/artifact/proc/Destroyed(silent=FALSE)
	//UnregisterSignal(holder, COMSIG_IN_RANGE_OF_IRRADIATION)
	if(!silent)
		holder.loc.visible_message(span_warning("[holder] [artifact_origin.destroy_message]"))
	Deactivate(silent=TRUE)
	qdel(holder)
///////////// Stimuli stuff
/datum/artifact/proc/Stimulate(var/stimuli,var/severity = 0)
	if(!stimuli || active)
		return
	for(var/datum/artifact_trigger/trigger in triggers)
		if(active)
			break
		if(trigger.needed_stimulus == stimuli)
			if(trigger.check_amount)
				if(trigger.stimulus_operator == ">=" && severity >= trigger.stimulus_amount)
					Activate()
				else if(trigger.stimulus_operator == "<=" && severity <= trigger.stimulus_amount)
					Activate()
				else if(hint_text && (severity >= trigger.stimulus_amount - trigger.hint_range && severity <= trigger.stimulus_amount + trigger.hint_range))
					if(prob(trigger.hint_prob))
						holder.visible_message(span_notice("[holder] [hint_text]"))
			else
				Activate()

/datum/artifact/proc/Touched(mob/living/user)
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
/*/datum/artifact/proc/Irradiating(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER
	to_chat(world,"[get_perceived_radiation_danger(pulse_information,insulation_to_target)]")
	if(!active)
		Stimulate(STIMULUS_RADIATION, get_perceived_radiation_danger(pulse_information,insulation_to_target)*2)*/

/datum/artifact/proc/attack_by(obj/item/I, mob/user)
	. = TRUE
	if(istype(I,/obj/item/weldingtool))
		if(I.use(1))
			Stimulate(STIMULUS_HEAT,800)
			holder.visible_message(span_warning("[user] burns the artifact with the [I]!"))
			playsound(user,pick(I.usesound),50, TRUE)
			return FALSE

	if(istype(I, /obj/item/bodypart/arm))
		var/obj/item/bodypart/arm/arm = I
		if(arm.bodytype & BODYTYPE_ROBOTIC)
			Stimulate(STIMULUS_SILICON_TOUCH)
		else
			Stimulate(STIMULUS_CARBON_TOUCH)
		holder.visible_message(span_notice("[user] presses the [arm] against the artifact!")) //pressing stuff against stuff isnt very severe so
		return FALSE

	if(istype(I,/obj/item/assembly/igniter))
		Stimulate(STIMULUS_HEAT, I.heat)
		Stimulate(STIMULUS_SHOCK, 700)
		holder.visible_message(span_warning("[user] zaps the artifact with the [I]!"))
		return FALSE

	if(istype(I, /obj/item/lighter))
		var/obj/item/lighter/lighter = I
		if(lighter.lit)
			Stimulate(STIMULUS_HEAT, lighter.heat*0.4)
			holder.visible_message(span_warning("[user] burns the artifact with the [I]!"))
		return FALSE

	if(I.tool_behaviour == TOOL_MULTITOOL)
		Stimulate(STIMULUS_SHOCK, 1000)
		holder.visible_message(span_warning("[user] shocks the artifact with the [I]!"))
		return FALSE

	if(istype(I,/obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = I
		if(paddles.defib.deductcharge(2000))
			Stimulate(STIMULUS_SHOCK, 2000)
			playsound(user,'sound/machines/defib_zap.ogg', 50, TRUE, -1)
			holder.visible_message(span_warning("[user] shocks the artifact with the [I]."))
			return FALSE

	if(istype(I,/obj/item/disk/data) || istype(I,/obj/item/circuitboard))
		holder.visible_message(span_notice("[user] touches the artifact with the [I]"))
		Stimulate(STIMULUS_DATA)

	if(I.force)
		Stimulate(STIMULUS_FORCE,I.force)
	
///////////// Effects for subtypes
/datum/artifact/proc/effect_activate()
	return
/datum/artifact/proc/effect_deactivate()
	return
/datum/artifact/proc/effect_touched()
	return
/datum/artifact/proc/effect_process()
	return
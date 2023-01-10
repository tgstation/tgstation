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
	var/list/valid_triggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/force)
	///origin datum
	var/datum/artifact_origin/artifact_origin
	///origin datums to pick
	var/list/valid_origins = list(ORIGIN_NARSIE,ORIGIN_WIZARD,ORIGIN_SILICON)
	///Text on activation
	var/activation_message = "starts shining!"
	///Text on deactivation
	var/deactivation_message = "stops shining."
	///Deactivation sound
	var/deactivation_sound
	///Text on hint
	var/hint_text = "emits a <i>faint</i> noise.."
	///examine hint
	var/examine_hint = ""
	New(obj/art)
		. = ..()
		//setup(art)

	proc/setup(obj/art)
		holder = art
		
		var/datum/artifact_origin/art_origin = SSartifacts.artifact_origins_by_name[pick(valid_origins)]
		var/named = "[pick(art_origin.adjectives)] [pick(isitem(holder) ? art_origin.nouns_small : art_origin.nouns_large)]"
		holder.name = named
		holder.desc = "You have absolutely no clue what this thing is or how it got here."
		if(auto_activate)
			Activate()
		var/trigger_amount = rand(min_triggers,max_triggers)
		while(trigger_amount>0)
			var/selection = pick(valid_triggers)
			valid_triggers -= selection
			triggers += new selection()
			trigger_amount--

	proc/Activate()
		if(active) //dont activate activated objects and dont activate non-activatables
			return FALSE
		if(LAZYLEN(artifact_origin?.activation_sounds))
			playsound(holder, pick(artifact_origin.activation_sounds), 75, TRUE)
		if(activation_message)
			holder.visible_message(span_notice("[holder] [activation_message]"))
		active = TRUE
		effect_activate()
		return TRUE

	proc/Deactivate()
		if(!active)
			return
		if(deactivation_sound)
			playsound(holder, deactivation_sound, 75, TRUE)
		if(deactivation_message)
			holder.visible_message("[holder] [deactivation_message]")
		active = FALSE
		effect_deactivate()
///////////// Stimuli stuff
	proc/Stimulate(var/stimuli,var/severity = 0)
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
					else if(hint_text && (severity >= trigger.stimulus_amount - trigger.hint_range && strength <= trigger.stimulus_amount + trigger.hint_range))
						if(prob(trigger.hint_prob))
							holder.visible_message(span_notice("[holder] [hint_text]"))
				else
					Activate()

	proc/Touched(mob/living/user)
		if(!user.Adjacent(holder))
			return
		if(isAI(user) || isobserver(user)) //sanity
			return
		if(ishuman(user))
			var/mob/living/carbon/human/human = user 
			var/obj/item/bodypart/arm = human.get_active_hand()
			if(istype(arm,/obj/item/bodypart/arm/right/robot) || istype(arm,/obj/item/bodypart/arm/left/robot))
				Stimulate(STIMULUS_SILICON_TOUCH)
			else
				Stimulate(STIMULUS_CARBON_TOUCH)
		else if(iscarbon(user))
			Stimulate(STIMULUS_CARBON_TOUCH)
		else if(issilicon(user))
			Stimulate(STIMULUS_SILICON_TOUCH)
		Stimulate(STIMULUS_FORCE,1)
		user.visible_message(span_notice("[user.name] touches [holder]."))
		if(LAZYLEN(artifact_origin?.touch_descriptors))
			to_chat(user,pick(artifact_origin.touch_descriptors))
		if(active)
			effect_touched()
	
	proc/attack_by(obj/item/I, mob/user)
		. = TRUE
		if(istype(I,/obj/item/weldingtool))
			if(I.use(5))
				Stimulate(STIMULUS_HEAT,800)
				holder.visible_message(span_warning("[user] burns the artifact with the [I]"))
				return FALSE
		if(istype(I, /obj/item/bodypart/arm))
			var/obj/item/bodypart/arm/arm = I
			if(arm.bodytype & BODYTYPE_ROBOTIC)
				Stimulate(STIMULUS_SILICON_TOUCH)
			else
				Stimulate(STIMULUS_CARBON_TOUCH)
///////////// Effects for subtypes
	proc/effect_activate()
		return
	proc/effect_deactivate()
		return
	proc/effect_touched()
		return
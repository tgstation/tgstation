//Contains a bunch of procs for different types, but in the end it just lets you restyle external_organs so thats why its here

///Helper proc to fetch a list of styles a player might want to restyle their features into during the round
/obj/item/organ/external/proc/get_valid_restyles()
	var/static/list/valid_restyles //Static because there's no reason to do this more than once. If there is, you can overwrite/remove it
	if(valid_restyles)
		return valid_restyles

	valid_restyles = list()
	for(var/datum/sprite_accessory/accessory as anything in get_global_feature_list())
		if(initial(accessory.locked)) //locked is for stuff that shouldn't appear here
			continue
		valid_restyles.Add(accessory)

	return valid_restyles

///Invokes async to ask a mob if their limb if their limb has an external organ
/mob/living/carbon/proc/on_attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(attempt_feature_restyle), source, trimmer, original_target, body_zone, restyle_type, style_speed)

///Asks the mob to ask their limb about restyling
/mob/living/carbon/proc/attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	var/obj/item/bodypart/targeted_part = get_bodypart(body_zone)
	if(!targeted_part)
		to_chat(trimmer, span_warning("There's no bodypart there!"))
		return FALSE
	targeted_part.attempt_feature_restyle(source, trimmer, original_target, body_zone, restyle_type, style_speed)
	return TRUE

///Invoke async so we dont break signals
/obj/item/bodypart/proc/on_attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(attempt_feature_restyle), source, trimmer, original_target, body_zone, restyle_type, style_speed)

///Asks the external organs inside the limb if they can restyle
/obj/item/bodypart/proc/attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	var/list/valid_features = list()
	for(var/obj/item/organ/external/feature as anything in external_organs)
		if(feature.restyle_flags & restyle_type)
			valid_features.Add(feature)

	var/obj/item/organ/external/target_organ
	switch(LAZYLEN(valid_features))
		if(1)
			target_organ = valid_features[1]
		if(2 to INFINITY)
			var/choose_options = list()
			var/name_to_organ = list() //literally so I dont have to loop again after someones made their choice
			for(var/obj/item/organ/external/organ_choice as anything in valid_features)
				choose_options[organ_choice.name] = image(organ_choice)
				name_to_organ[organ_choice.name] = organ_choice
			var/picked_option = show_radial_menu(trimmer, original_target, choose_options, radius = 38, require_near = TRUE)
			if(picked_option)
				target_organ = name_to_organ[picked_option]
			else
				return
		else
			to_chat(trimmer, span_warning("There are no restylable features there!"))
			return

	target_organ.attempt_feature_restyle(source, trimmer, original_target, body_zone, restyle_type, style_speed)

///Invoke async so we dont break signals
/obj/item/organ/external/proc/on_attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	SIGNAL_HANDLER

	if(restyle_flags & restyle_type)
		INVOKE_ASYNC(src, PROC_REF(attempt_feature_restyle), source, trimmer, original_target, body_zone, restyle_type, style_speed)
	else
		to_chat(trimmer, span_warning("This tool is incompatible with the [src.name]!"))

///Restyles the external organ from a list of valid options
/obj/item/organ/external/proc/attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	var/new_style = tgui_input_list(trimmer, "Select a new style", "Grooming", get_valid_restyles())

	trimmer.visible_message(
		span_notice("[trimmer] tries to change [original_target == trimmer ? trimmer.p_their() : original_target.name + "'s"] [name]."),
		span_notice("You try to change [original_target == trimmer ? "your" : original_target.name + "'s"] [name].")
	)
	if(new_style && do_after(trimmer, style_speed, target = original_target))
		trimmer.visible_message(
			span_notice("[trimmer] successfully changes [original_target == trimmer ? trimmer.p_their() : original_target.name + "'s"] [name]."),
			span_notice("You successfully change [original_target == trimmer ? "your" : original_target.name + "'s"] [name].")
		)

		simple_change_sprite(new_style)

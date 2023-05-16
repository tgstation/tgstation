//Contains a bunch of procs for different types, but in the end it just lets you restyle external_organs so thats why its here

///Helper proc to fetch a list of styles a player might want to restyle their features into during the round : returns list("Cabbage" = /datum/sprite_accessory/cabbage)
/obj/item/organ/external/proc/get_valid_restyles()
	var/list/valid_restyles

	valid_restyles = list()
	var/list/feature_list = bodypart_overlay.get_global_feature_list()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		if(initial(accessory_datum.locked)) //locked is for stuff that shouldn't appear here
			continue
		valid_restyles[accessory] = accessory_datum

	return valid_restyles

///Someone used a restyling thingymajigga on our limb owner
/obj/item/bodypart/proc/on_attempt_feature_restyle_mob(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	SIGNAL_HANDLER

	//Check what body zone we are against the targeted zone, so we're sure we are the targeted limb
	if(src.body_zone == body_zone)
		INVOKE_ASYNC(src, PROC_REF(attempt_feature_restyle), source, trimmer, original_target, body_zone, restyle_type, style_speed)

///Invoke async so we dont break signals
/obj/item/bodypart/proc/on_attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(attempt_feature_restyle), source, trimmer, original_target, body_zone, restyle_type, style_speed)

///Asks the external organs inside the limb if they can restyle
/obj/item/bodypart/proc/attempt_feature_restyle(atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
	var/list/valid_features = list()
	for(var/obj/item/organ/external/feature in external_organs)
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
	var/list/restyles = get_valid_restyles()
	var/new_style = tgui_input_list(trimmer, "Select a new style", "Grooming", restyles)

	trimmer.visible_message(
		span_notice("[trimmer] tries to change [original_target == trimmer ? trimmer.p_their() : original_target.name + "'s"] [name]."),
		span_notice("You try to change [original_target == trimmer ? "your" : original_target.name + "'s"] [name].")
	)
	if(new_style && do_after(trimmer, style_speed, target = original_target))
		trimmer.visible_message(
			span_notice("[trimmer] successfully changes [original_target == trimmer ? trimmer.p_their() : original_target.name + "'s"] [name]."),
			span_notice("You successfully change [original_target == trimmer ? "your" : original_target.name + "'s"] [name].")
		)


		simple_change_sprite(restyles[new_style]) //turn name to type and pass it on

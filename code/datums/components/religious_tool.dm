/**
 *
 * Allows the parent to act similarly to the Altar of Gods with modularity. Invoke and Sect Selection is done via attacking with a bible. This means you cannot sacrifice Bibles (you shouldn't want to do this anyways although now that I mentioned it you probably will want to).
 *
 */
/datum/component/religious_tool
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Enables access to the global sect directly
	var/datum/religion_sect/easy_access_sect
	/// What extent do we want this religious tool to act? In case you don't want full access to the list. Generated on New
	var/operation_flags
	/// The rite currently being invoked
	var/datum/religion_rites/performing_rite
	///Sets the type for catalyst
	var/catalyst_type = /obj/item/storage/book/bible
	///Enables overide of COMPONENT_NO_AFTERATTACK, not recommended as it means you can potentially cause damage to the item using the catalyst.
	var/force_catalyst_afterattack = FALSE
	var/datum/callback/after_sect_select_cb

/datum/component/religious_tool/Initialize(_flags = ALL, _force_catalyst_afterattack = FALSE, _after_sect_select_cb, override_catalyst_type)
	. = ..()
	SetGlobalToLocal() //attempt to connect on start in case one already exists!
	operation_flags = _flags
	force_catalyst_afterattack = _force_catalyst_afterattack
	after_sect_select_cb = _after_sect_select_cb
	if(override_catalyst_type)
		catalyst_type = override_catalyst_type

/datum/component/religious_tool/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY,.proc/AttemptActions)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/religious_tool/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))

/**
 * Sets the easy access variable to the global if it exists.
 */
/datum/component/religious_tool/proc/SetGlobalToLocal()
	if(easy_access_sect)
		return TRUE
	if(!GLOB.religious_sect)
		return FALSE
	easy_access_sect = GLOB.religious_sect
	after_sect_select_cb.Invoke()
	return TRUE



/**
 * Since all of these involve attackby, we require mega proc. Handles Invocation, Sacrificing, And Selection of Sects.
 */
/datum/component/religious_tool/proc/AttemptActions(datum/source, obj/item/the_item, mob/living/user)
	SIGNAL_HANDLER

	/**********Sect Selection**********/
	if(!SetGlobalToLocal())
		if(!(operation_flags & RELIGION_TOOL_SECTSELECT))
			return
		//At this point you're intentionally trying to select a sect.
		INVOKE_ASYNC(src, .proc/select_sect, user)
		return COMPONENT_NO_AFTERATTACK

	/**********Rite Invocation**********/
	else if(istype(the_item, catalyst_type))
		if(!(operation_flags & RELIGION_TOOL_INVOKE))
			return
		INVOKE_ASYNC(src, .proc/perform_rite, user)
		return (force_catalyst_afterattack ? NONE : COMPONENT_NO_AFTERATTACK)

	/**********Sacrificing**********/
	else if(operation_flags & RELIGION_TOOL_SACRIFICE)
		if(!easy_access_sect?.can_sacrifice(the_item,user))
			return
		easy_access_sect.on_sacrifice(the_item,user)
		return COMPONENT_NO_AFTERATTACK

/// Select the sect, called async from [/datum/component/religious_tool/proc/AttemptActions]
/datum/component/religious_tool/proc/select_sect(mob/living/user)
	if(user.mind.holy_role != HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='warning'>You are not the high priest, and therefore cannot select a religious sect.")
		return
	var/list/available_options = generate_available_sects(user)
	if(!available_options)
		return

	var/sect_select = input(user,"Select a sect (You CANNOT revert this decision!)","Select a Sect",null) in available_options
	if(!sect_select || !user.canUseTopic(parent, BE_CLOSE, FALSE, NO_TK))
		to_chat(user,"<span class ='warning'>You cannot select a sect at this time.</span>")
		return
	var/type_selected = available_options[sect_select]
	GLOB.religious_sect = new type_selected()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_conversion(am_i_holy_living)
	easy_access_sect = GLOB.religious_sect
	after_sect_select_cb.Invoke()

/// Perform the rite, called async from [/datum/component/religious_tool/proc/AttemptActions]
/datum/component/religious_tool/proc/perform_rite(mob/living/user)
	if(!easy_access_sect.rites_list)
		to_chat(user, "<span class='notice'>Your sect doesn't have any rites to perform!")
		return
	if(performing_rite)
		to_chat(user, "<span class='notice'>There is a rite currently being performed here already!")
		return
	var/rite_select = input(user,"Select a rite to perform!","Select a rite",null) in easy_access_sect.rites_list
	if(!rite_select || !user.canUseTopic(parent, BE_CLOSE, FALSE, NO_TK))
		to_chat(user,"<span class ='warning'>You cannot perform the rite at this time.</span>")
		return
	var/selection2type = easy_access_sect.rites_list[rite_select]
	performing_rite = new selection2type(parent)
	if(!performing_rite.perform_rite(user, parent))
		QDEL_NULL(performing_rite)
	else
		performing_rite.invoke_effect(user, parent)
		easy_access_sect.adjust_favor(-performing_rite.favor_cost)
		QDEL_NULL(performing_rite)

/**
 * Generates a list of available sects to the user. Intended to support custom-availability sects. Because these are not instanced, we cannot put the availability on said sect beyond variables.
 */
/datum/component/religious_tool/proc/generate_available_sects(mob/user)
	. = list()
	for(var/i in subtypesof(/datum/religion_sect))
		var/datum/religion_sect/not_a_real_instance_rs = i
		if(initial(not_a_real_instance_rs.starter))
			. += list(initial(not_a_real_instance_rs.name) = i)

/**
 * Appends to examine so the user knows it can be used for religious purposes.
 */
/datum/component/religious_tool/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/can_i_see = FALSE
	if(isobserver(user))
		can_i_see = TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.mind?.holy_role)
			can_i_see = TRUE

	if(!can_i_see)
		return
	if(!easy_access_sect)
		if(operation_flags & RELIGION_TOOL_SECTSELECT)
			examine_list += "<span class='notice'>This looks like it can be used to select a sect.</span>"
			return

	examine_list += "<span class='notice'>The sect currently has [round(easy_access_sect.favor)] favor with [GLOB.deity].[(operation_flags & RELIGION_TOOL_SACRIFICE) ? "Desired items can be used on this to increase favor." : ""]</span>"
	if(!easy_access_sect.rites_list)
		return //if we dont have rites it doesnt do us much good if the object can be used to invoke them!
	if(operation_flags & RELIGION_TOOL_INVOKE)
		examine_list += "List of available Rites:"
		examine_list += easy_access_sect.rites_list

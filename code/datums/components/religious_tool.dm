/**
 *
 * Allows the parent to act similarly to the Altar of Gods with modularity. Invoke and Sect Selection is done via attacking with a bible. This means you cannot sacrifice Bibles (you shouldn't want to do this anyways although now that I mentioned it you probably will want to).
 *
 */
/datum/component/religious_tool
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Enables access to the global sect directly
	var/datum/religion_sect/easy_access_sect
	/// Prevents double selecting sects
	var/selecting_sect = FALSE
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

	if(istype(the_item, catalyst_type))
		ui_interact(user)

	/*

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

	*/

/datum/component/religious_tool/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReligiousTool")
		ui.open()
	return COMPONENT_NO_AFTERATTACK

/datum/component/religious_tool/ui_state(mob/user)
	if(!iscarbon(user))
		return UI_CLOSE
	var/mob/living/carbon/carbon = user
	if(!carbon.is_holding_item_of_type(catalyst_type))
		return UI_CLOSE
	return ..() //default state if addditional checks pass

/datum/component/religious_tool/ui_data(mob/user)
	var/list/data = list()
	//cannot find global vars, so lets offer options
	if(!SetGlobalToLocal())
		data["sects"] = generate_available_sects(user)
	else
		data["sects"] = null
		data["name"] = initial(easy_access_sect.name)
		data["desc"] = initial(easy_access_sect.desc)
		data["quote"] = initial(easy_access_sect.quote)
		data["icon"] = initial(easy_access_sect.tgui_icon)
		data["rites"] = generate_available_rites()


	data["can_select_sect"] = (operation_flags & RELIGION_TOOL_SECTSELECT)
	data["can_invoke_rite"] = (operation_flags & RELIGION_TOOL_INVOKE)
	data["can_sacrifice_item"] = (operation_flags & RELIGION_TOOL_SACRIFICE)

/datum/component/religious_tool/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("sect_select")
			var/path = params["path"]
			select_sect(usr, path)
		else
			to_chat(world, action)


/// Select the sect, called async from [/datum/component/religious_tool/proc/AttemptActions]
/datum/component/religious_tool/proc/select_sect(mob/living/user, path)
	if(user.mind.holy_role != HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='warning'>You are not the high priest, and therefore cannot select a religious sect.")
		return
	if(!user.canUseTopic(parent, BE_CLOSE, FALSE, NO_TK))
		to_chat(user,"<span class='warning'>You cannot select a sect at this time.</span>")
		return
	GLOB.religious_sect = new path()
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
/datum/component/religious_tool/proc/perform_rite(mob/living/user, path)
	if(user.mind.holy_role == HOLY_ROLE_DEACON)
		to_chat(user, "<span class='warning'>You are merely a deacon of [GLOB.deity], and therefore cannot perform rites.")
		return
	if(performing_rite)
		to_chat(user, "<span class='notice'>There is a rite currently being performed here already.")
		return
	if(!user.canUseTopic(parent, BE_CLOSE, FALSE, NO_TK))
		to_chat(user,"<span class='warning'>You are not close enough to perform the rite.</span>")
		return
	performing_rite = new path(parent)
	if(!performing_rite.perform_rite(user, parent))
		QDEL_NULL(performing_rite)
	else
		performing_rite.invoke_effect(user, parent)
		easy_access_sect.adjust_favor(-performing_rite.favor_cost)
		QDEL_NULL(performing_rite)

/**
 * Generates a list of available sects to the user. Intended to support custom-availability sects.
 */
/datum/component/religious_tool/proc/generate_available_sects(mob/user)
	var/list/sects_to_pick = list()
	var/human_highpriest = ishuman(user)
	var/mob/living/carbon/human/highpriest = user
	for(var/path in subtypesof(/datum/religion_sect))
		if(human_highpriest && initial(easy_access_sect.invalidating_qualities))
			var/datum/species/highpriest_species = highpriest.dna.species
			if(initial(easy_access_sect.invalidating_qualities) in highpriest_species.inherent_traits)
				continue
		var/list/sect = list()
		var/datum/religion_sect/not_a_real_instance_rs = path
		sect["name"] = initial(not_a_real_instance_rs.name)
		sect["desc"] = initial(not_a_real_instance_rs.desc)
		sect["quote"] = initial(not_a_real_instance_rs.quote)
		sect["icon"] = initial(not_a_real_instance_rs.tgui_icon)
		sect["path"] = path
		sects_to_pick += list(sect)
	return sects_to_pick

/**
 * Generates available rites to pick from. It expects the sect to be picked by the time it was called (by tgui data)
 */
/datum/component/religious_tool/proc/generate_available_rites()
	var/list/rites_to_pick = list()
	for(var/path in easy_access_sect.rites_list)
		///checks to invalidate
		var/list/rite = list()
		var/datum/religion_rites/rite_type = path
		rite["name"] = initial(rite_type.name)
		rite["desc"] = initial(rite_type.desc)
		rite["favor"] = initial(rite_type.favor_cost)
		rite["path"] = path
		rites_to_pick += list(rite)
	return rites_to_pick

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

	examine_list += easy_access_sect.tool_examine(user)
	if(!easy_access_sect.rites_list)
		return //if we dont have rites it doesnt do us much good if the object can be used to invoke them!
	if(operation_flags & RELIGION_TOOL_SACRIFICE)//this can be moved around if things change but usually no rites == no sacrifice
		examine_list += "<span class='notice'>Desired items can be used on this to increase favor.</span>"
	if(operation_flags & RELIGION_TOOL_INVOKE)
		examine_list += "List of available Rites:"
		examine_list += easy_access_sect.rites_list
